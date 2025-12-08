/**
 * Watcher - Background daemon that monitors Claude Code sessions
 * for a specific project and exports dialogs to dialog/ folder
 */

import * as chokidar from 'chokidar';
import * as path from 'path';
import * as fs from 'fs';
import { spawn } from 'child_process';
import {
  PROJECTS_DIR,
  findClaudeProjectDir,
  getProjectSessions,
  exportSession,
  isSessionExported,
  parseSession,
  SessionInfo,
  getProjectName,
  getSummary,
  getSummaryShort,
  formatTimestamp,
  exportNewSessions,
  generateStaticHtml
} from './exporter';
import { getDialogFolder, ensureDialogFolder } from './gitignore';

// Debounce map to avoid multiple exports on rapid changes
const pendingExports = new Map<string, NodeJS.Timeout>();
const DEBOUNCE_MS = 2000; // Wait 2 seconds after last change

// Pending summary generation (longer debounce - wait for dialog to "close")
const pendingSummaries = new Map<string, NodeJS.Timeout>();
const SUMMARY_DEBOUNCE_MS = 1800000; // Wait 30 minutes of inactivity before generating summary

// Track active session per project to detect session closure
const activeSessionPerProject = new Map<string, string>(); // projectDir -> sessionId

// Track file sizes to detect actual content changes
const fileSizes = new Map<string, number>();

/**
 * Request summary generation for a dialog
 * @param dialogPath - path to the markdown file
 * @param verbose - enable verbose logging
 * @param isFinal - true if this is a final summary for a closed dialog
 */
function requestSummary(dialogPath: string, verbose: boolean = false, isFinal: boolean = false): void {
  const log = (msg: string) => {
    const timestamp = new Date().toLocaleTimeString('ru-RU');
    console.log(`[${timestamp}] ${msg}`);
  };

  // For non-final summaries, skip if already has summary
  const existingSummary = getSummary(dialogPath);
  if (existingSummary && !isFinal) {
    if (verbose) {
      log(`Summary already exists for ${path.basename(dialogPath)}`);
    }
    return;
  }

  const summaryType = isFinal ? 'FINAL summary' : 'summary';
  log(`Requesting ${summaryType} for: ${path.basename(dialogPath)}`);

  // Different prompts for interim vs final summary
  const prompt = isFinal
    ? `Прочитай файл ${dialogPath} — это завершённый диалог с Claude Code.

Создай ДВА саммари на русском языке:

1. КОРОТКОЕ (для списка диалогов) - одно предложение:
   - Суть изменений или проблемы
   - Конкретные файлы/модули если есть
   Пример: "Исправлена логика чекбоксов visibility в index.html"

2. ПОЛНОЕ (для детального просмотра) - 3-5 предложений:
   - Главная цель/задача
   - Что конкретно сделано (файлы, методы, изменения)
   - Технические решения
   - Итоговый статус

Затем используй Edit чтобы ЗАМЕНИТЬ существующее саммари в начале файла в формате:
<!-- SUMMARY_SHORT: короткое саммари -->
<!-- SUMMARY_FULL: полное детальное саммари -->`
    : `Прочитай файл ${dialogPath}.

Создай ДВА саммари на русском:

1. КОРОТКОЕ - одно предложение с конкретикой (файлы/функции/модули)
   Пример: "Добавлен watcher для автоэкспорта диалогов в dialog/"

2. ПОЛНОЕ - 2-3 предложения с деталями и техническими решениями

Затем используй Edit чтобы добавить саммари в начало файла в формате:
<!-- SUMMARY_SHORT: короткое -->
<!-- SUMMARY_FULL: полное -->`;

  const claude = spawn('claude', [
    '-p',
    '--dangerously-skip-permissions',
    '--model', 'haiku',
    '--tools', 'Read,Edit'
  ], {
    stdio: ['pipe', 'pipe', 'pipe'],
    shell: false,
    cwd: path.dirname(dialogPath)
  });

  // Write prompt to stdin
  claude.stdin?.write(prompt);
  claude.stdin?.end();

  let output = '';
  let errorOutput = '';

  claude.stdout?.on('data', (data) => {
    output += data.toString();
  });

  claude.stderr?.on('data', (data) => {
    errorOutput += data.toString();
  });

  claude.on('error', (err) => {
    console.error(`Failed to spawn claude: ${err.message}`);
  });

  claude.on('close', (code) => {
    if (code === 0) {
      log(`Summary completed for: ${path.basename(dialogPath)}`);
      if (verbose) {
        log(`Claude output: ${output.substring(0, 200)}...`);
      }
    } else {
      console.error(`Summary generation failed (code ${code})`);
      if (errorOutput) {
        console.error(`Error: ${errorOutput.substring(0, 200)}`);
      }
    }
  });
}

export interface WatcherOptions {
  verbose?: boolean;
  debounceMs?: number;
  outputDir?: string; // Export to different directory while reading from source project
}

export class SessionWatcher {
  private watcher: chokidar.FSWatcher | null = null;
  private options: WatcherOptions;
  private isRunning = false;
  private targetProjectPath: string;
  private outputProjectPath: string; // Where to export dialogs
  private claudeProjectDir: string | null = null;

  constructor(targetProjectPath: string, options: WatcherOptions = {}) {
    this.targetProjectPath = path.resolve(targetProjectPath);
    this.outputProjectPath = options.outputDir
      ? path.resolve(options.outputDir)
      : this.targetProjectPath;
    this.options = {
      verbose: false,
      debounceMs: DEBOUNCE_MS,
      ...options
    };
  }

  /** Get effective output directory (for exports) */
  getOutputPath(): string {
    return this.outputProjectPath;
  }

  private log(message: string): void {
    const timestamp = new Date().toLocaleTimeString('ru-RU');
    console.log(`[${timestamp}] ${message}`);
  }

  private debug(message: string): void {
    if (this.options.verbose) {
      this.log(`DEBUG: ${message}`);
    }
  }

  private findDialogPath(sessionId: string): string | null {
    const dialogFolder = getDialogFolder(this.outputProjectPath);
    if (!fs.existsSync(dialogFolder)) {
      return null;
    }
    const files = fs.readdirSync(dialogFolder);
    const match = files.find(f => f.includes(sessionId.substring(0, 8)));
    return match ? path.join(dialogFolder, match) : null;
  }

  private scheduleSummary(dialogPath: string): void {
    const filename = path.basename(dialogPath);

    // Cancel existing scheduled summary
    const existing = pendingSummaries.get(filename);
    if (existing) {
      clearTimeout(existing);
    }

    // Schedule summary generation after period of inactivity
    const timeout = setTimeout(() => {
      pendingSummaries.delete(filename);
      requestSummary(dialogPath, this.options.verbose);
    }, SUMMARY_DEBOUNCE_MS);

    pendingSummaries.set(filename, timeout);
    this.debug(`Scheduled summary for ${filename} in ${SUMMARY_DEBOUNCE_MS / 1000}s`);
  }

  private scheduleExport(filePath: string): void {
    const sessionId = path.basename(filePath, '.jsonl');

    // Clear existing timeout
    const existing = pendingExports.get(sessionId);
    if (existing) {
      clearTimeout(existing);
    }

    // Schedule new export
    const timeout = setTimeout(() => {
      pendingExports.delete(sessionId);
      this.exportFile(filePath);
    }, this.options.debounceMs);

    pendingExports.set(sessionId, timeout);
    this.debug(`Scheduled export for ${sessionId} in ${this.options.debounceMs}ms`);
  }

  private exportFile(filePath: string): void {
    try {
      const stat = fs.statSync(filePath);
      const previousSize = fileSizes.get(filePath);

      // Skip if file size hasn't changed (avoid duplicate exports)
      if (previousSize === stat.size) {
        this.debug(`Skipping ${path.basename(filePath)} - no size change`);
        return;
      }

      fileSizes.set(filePath, stat.size);

      // Parse session info
      const projectDir = path.basename(path.dirname(filePath));
      const filename = path.basename(filePath);
      const sessionId = filename.replace('.jsonl', '');

      const messages = parseSession(filePath);
      const dialogMessages = messages.filter(m => m.type === 'user' || m.type === 'assistant');

      if (dialogMessages.length === 0) {
        this.debug(`Skipping ${sessionId} - no dialog messages`);
        return;
      }

      const summaries = messages
        .filter(m => m.type === 'summary')
        .map(m => (m as any).summary || '')
        .filter((s: string) => s.length > 0);

      const firstTimestamp = dialogMessages[0].timestamp;

      const session: SessionInfo = {
        id: sessionId,
        filename,
        projectName: getProjectName(projectDir),
        projectPath: projectDir,
        date: formatTimestamp(firstTimestamp),
        dateISO: new Date(firstTimestamp).toISOString().split('T')[0],
        size: `${(stat.size / 1024).toFixed(0)}KB`,
        sizeBytes: stat.size,
        summaries: summaries.slice(0, 5),
        messageCount: dialogMessages.length,
        lastModified: stat.mtime
      };

      // Check if previous session was closed (new session appeared)
      const previousSessionId = activeSessionPerProject.get(projectDir);
      if (previousSessionId && previousSessionId !== sessionId) {
        // Previous session is now closed - generate final summary
        const previousDialogPath = this.findDialogPath(previousSessionId);
        if (previousDialogPath) {
          this.log(`Session ${previousSessionId.substring(0, 8)} closed, generating final summary...`);
          requestSummary(previousDialogPath, this.options.verbose, true); // isFinal = true
        }
      }
      activeSessionPerProject.set(projectDir, sessionId);

      // Export to output project's dialog/ folder
      const result = exportSession(session, this.outputProjectPath);

      this.log(`Exported: ${path.basename(result.markdownPath)} (${session.messageCount} messages)`);

      // Regenerate static HTML viewer
      try {
        generateStaticHtml(this.outputProjectPath);
        this.log('Updated index.html');
      } catch (err) {
        // Non-fatal error - just log
        this.log(`Warning: Could not update index.html: ${err}`);
      }

      // Schedule summary generation (will run after inactivity period)
      this.scheduleSummary(result.markdownPath);

    } catch (err) {
      console.error(`Error exporting ${filePath}:`, err);
    }
  }

  async start(): Promise<void> {
    if (this.isRunning) {
      console.log('Watcher is already running');
      return;
    }

    // Check if target project exists
    if (!fs.existsSync(this.targetProjectPath)) {
      console.error(`Target project not found: ${this.targetProjectPath}`);
      process.exit(1);
    }

    // Find Claude project directory
    this.claudeProjectDir = findClaudeProjectDir(this.targetProjectPath);

    if (!this.claudeProjectDir) {
      console.error(`No Claude sessions found for project: ${this.targetProjectPath}`);
      console.error('Make sure Claude Code has been used in this project.');
      process.exit(1);
    }

    const claudeProjectPath = path.join(PROJECTS_DIR, this.claudeProjectDir);
    const dialogFolder = ensureDialogFolder(this.outputProjectPath);

    this.log('Starting Claude Export Watcher...');
    this.log(`Source project: ${this.targetProjectPath}`);
    if (this.outputProjectPath !== this.targetProjectPath) {
      this.log(`Output project: ${this.outputProjectPath}`);
    }
    this.log(`Claude sessions: ${claudeProjectPath}`);
    this.log(`Dialogs folder: ${dialogFolder}`);
    this.log('');

    // Initial export of all sessions using robust exportNewSessions()
    this.log('Performing initial export...');

    // Use the same reliable logic as CLI export command
    // Note: exportNewSessions needs both source (for sessions) and output (for dialogs)
    const exported = exportNewSessions(this.targetProjectPath, this.outputProjectPath);

    // Track file sizes for all sessions (including already exported ones)
    const sessions = getProjectSessions(this.targetProjectPath);
    for (const session of sessions) {
      const sourcePath = path.join(PROJECTS_DIR, session.projectPath, session.filename);
      fileSizes.set(sourcePath, session.sizeBytes);
    }

    if (exported.length === 0) {
      this.log('All sessions already exported and up to date');
    } else {
      this.log(`New exports: ${exported.length}`);
    }

    // Generate static HTML viewer
    try {
      const htmlPath = generateStaticHtml(this.outputProjectPath);
      this.log(`Generated: ${path.basename(htmlPath)}`);
    } catch (err) {
      this.log(`Warning: Could not generate index.html: ${err}`);
    }

    this.log('');

    // Generate final summaries for closed sessions (all except the most recent one)
    if (sessions.length > 0) {
      // Find the most recent (active) session by lastModified timestamp
      const activeSession = sessions.reduce((latest, current) =>
        current.lastModified > latest.lastModified ? current : latest
      );

      // All other sessions are closed - generate final summaries for them
      const closedSessions = sessions.filter(s => s.id !== activeSession.id);

      for (const session of closedSessions) {
        const dialogPath = this.findDialogPath(session.id);
        if (dialogPath) {
          // Skip very large files (>300KB) to save tokens
          const stats = fs.statSync(dialogPath);
          if (stats.size > 300 * 1024) {
            continue;
          }

          // Check if file has new format summary (SUMMARY_SHORT)
          // Old format summaries should be regenerated
          const hasSummaryShort = getSummaryShort(dialogPath);
          if (!hasSummaryShort || hasSummaryShort === getSummary(dialogPath)) {
            // Either no summary, or only old format - generate new one
            this.log(`Generating final summary for closed session: ${session.id.substring(0, 8)}...`);
            requestSummary(dialogPath, this.options.verbose, true); // isFinal = true
          }
        }
      }
    }

    // Start watching Claude project directory
    this.watcher = chokidar.watch(claudeProjectPath, {
      ignored: /(^|[\/\\])\../,    // Only ignore dotfiles
      persistent: true,
      ignoreInitial: true,
      depth: 0,                     // Only watch files in this directory
      usePolling: true,             // Use polling instead of fs.watch
      interval: 1000,               // Poll every second
      awaitWriteFinish: {
        stabilityThreshold: 500,
        pollInterval: 100
      }
    });

    this.watcher
      .on('add', (filePath) => {
        if (filePath.endsWith('.jsonl') && !path.basename(filePath).startsWith('agent-')) {
          this.debug(`New file: ${filePath}`);
          this.scheduleExport(filePath);
        }
      })
      .on('change', (filePath) => {
        if (filePath.endsWith('.jsonl') && !path.basename(filePath).startsWith('agent-')) {
          this.debug(`Changed: ${filePath}`);
          this.scheduleExport(filePath);
        }
      })
      .on('error', (error) => {
        console.error('Watcher error:', error);
      });

    this.isRunning = true;
    this.log('Watcher started. Press Ctrl+C to stop.');
    this.log('New and updated sessions will be automatically exported to dialog/');
  }

  async stop(): Promise<void> {
    if (this.watcher) {
      await this.watcher.close();
      this.watcher = null;
    }

    // Clear pending exports
    for (const timeout of pendingExports.values()) {
      clearTimeout(timeout);
    }
    pendingExports.clear();

    // Clear pending summaries
    for (const timeout of pendingSummaries.values()) {
      clearTimeout(timeout);
    }
    pendingSummaries.clear();

    this.isRunning = false;
    this.log('Watcher stopped');
  }
}

// Run as standalone
export async function startWatcher(
  targetProjectPath: string,
  options: WatcherOptions = {}
): Promise<SessionWatcher> {
  const watcher = new SessionWatcher(targetProjectPath, options);

  // Handle graceful shutdown
  process.on('SIGINT', async () => {
    console.log('\n');
    await watcher.stop();
    process.exit(0);
  });

  process.on('SIGTERM', async () => {
    await watcher.stop();
    process.exit(0);
  });

  await watcher.start();
  return watcher;
}
