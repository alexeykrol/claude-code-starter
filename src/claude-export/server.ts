/**
 * Server - Express server for Claude Export UI
 * Provides API for managing dialogs and their Git visibility
 */

import express, { Application, Request, Response } from 'express';
import * as path from 'path';
import * as fs from 'fs';
import {
  PROJECTS_DIR,
  getProjectSessions,
  getExportedDialogs,
  exportSession,
  exportNewSessions,
  syncCurrentSession,
  isSessionExported,
  getExportedPath,
  parseSession,
  extractContent,
  formatTimestamp,
  toMarkdown,
  SessionInfo,
  getExportedDialogsWithSummaries,
  getSummary,
  extractSessionDateTime,
  ExportedSession
} from './exporter';
import {
  getDialogFolder,
  toggleVisibility,
  setVisibility,
  isPublic
} from './gitignore';
import { SessionWatcher } from './watcher';

let currentProjectPath: string = process.cwd();
let watcher: SessionWatcher | null = null;

const app: Application = express();

app.use(express.json());

// Serve static files
app.use(express.static(path.join(__dirname, '..', 'src', 'public')));

// API: Get current project info
app.get('/api/project', (req: Request, res: Response) => {
  try {
    const dialogFolder = getDialogFolder(currentProjectPath);
    const dialogs = getExportedDialogs(currentProjectPath);
    const sessions = getProjectSessions(currentProjectPath);

    res.json({
      path: currentProjectPath,
      name: path.basename(currentProjectPath),
      dialogFolder,
      dialogCount: dialogs.length,
      sessionCount: sessions.length
    });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// API: Set current project path
app.post('/api/project', (req: Request, res: Response) => {
  try {
    const { path: newPath } = req.body;

    if (!newPath) {
      return res.status(400).json({ error: 'Path is required' });
    }

    const resolvedPath = path.resolve(newPath);

    if (!fs.existsSync(resolvedPath)) {
      return res.status(404).json({ error: 'Path does not exist' });
    }

    if (!fs.statSync(resolvedPath).isDirectory()) {
      return res.status(400).json({ error: 'Path must be a directory' });
    }

    currentProjectPath = resolvedPath;

    const dialogFolder = getDialogFolder(currentProjectPath);
    const dialogs = getExportedDialogs(currentProjectPath);
    const sessions = getProjectSessions(currentProjectPath);

    res.json({
      success: true,
      path: currentProjectPath,
      name: path.basename(currentProjectPath),
      dialogFolder,
      dialogCount: dialogs.length,
      sessionCount: sessions.length
    });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// API: Get all sessions for current project (including orphan markdown files)
app.get('/api/sessions', (req: Request, res: Response) => {
  try {
    const sessions = getProjectSessions(currentProjectPath);
    const dialogFolder = getDialogFolder(currentProjectPath);

    // Add export status, visibility, and summary from markdown to each session
    const sessionsWithStatus = sessions.map(s => {
      const exported = isSessionExported(s.id, currentProjectPath);
      const exportPath = getExportedPath(s.id, currentProjectPath);

      // Get summary and sessionDateTime from exported markdown file if available
      let summaryFromMarkdown: string | null = null;
      let sessionDateTime: Date | null = null;
      if (exported && exportPath) {
        summaryFromMarkdown = getSummary(exportPath);
        const content = fs.readFileSync(exportPath, 'utf-8');
        sessionDateTime = extractSessionDateTime(content);
      }

      // Use markdown summary as first priority, then JSONL summaries
      const summaries = summaryFromMarkdown
        ? [summaryFromMarkdown, ...s.summaries]
        : s.summaries;

      return {
        ...s,
        summaries,
        isExported: exported,
        exportPath,
        isPublic: exported && exportPath ? isPublic(exportPath, currentProjectPath) : false,
        isOrphan: false,
        sessionDateTime: sessionDateTime || s.lastModified
      };
    });

    // Find orphan markdown files (not linked to any session)
    const sessionIds = new Set(sessions.map(s => s.id.substring(0, 8)));
    const orphans: any[] = [];

    if (fs.existsSync(dialogFolder)) {
      const files = fs.readdirSync(dialogFolder).filter(f => f.endsWith('.md'));

      for (const filename of files) {
        // Extract session ID from filename: 2025-12-05_session-abc12345.md
        const match = filename.match(/(\d{4}-\d{2}-\d{2})_session-([a-f0-9]{8})\.md/);
        if (match) {
          const [, dateStr, shortId] = match;
          if (!sessionIds.has(shortId)) {
            // This is an orphan file
            const filePath = path.join(dialogFolder, filename);
            const stat = fs.statSync(filePath);
            const content = fs.readFileSync(filePath, 'utf-8');
            const summary = getSummary(filePath);
            const orphanSessionDateTime = extractSessionDateTime(content);

            // Parse date from filename
            const [year, month, day] = dateStr.split('-').map(Number);
            const fileDate = new Date(year, month - 1, day);

            orphans.push({
              id: shortId,
              filename,
              projectName: 'Imported',
              projectPath: '',
              date: `${day.toString().padStart(2, '0')}.${month.toString().padStart(2, '0')}.${year}`,
              dateISO: dateStr,
              size: `${Math.round(stat.size / 1024)}KB`,
              sizeBytes: stat.size,
              summaries: summary ? [summary] : [],
              messageCount: 0, // Unknown for orphans
              lastModified: stat.mtime,
              sessionDateTime: orphanSessionDateTime || stat.mtime,
              isExported: true,
              exportPath: filePath,
              isPublic: isPublic(filePath, currentProjectPath),
              isOrphan: true
            });
          }
        }
      }
    }

    // Merge and sort by date (newest first)
    const allSessions = [...sessionsWithStatus, ...orphans].sort((a, b) => {
      const dateA = new Date(a.dateISO);
      const dateB = new Date(b.dateISO);
      return dateB.getTime() - dateA.getTime();
    });

    res.json({
      sessions: allSessions,
      total: allSessions.length,
      exported: allSessions.filter(s => s.isExported).length,
      orphans: orphans.length,
      projectPath: currentProjectPath
    });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// API: Get exported dialogs with visibility status and summaries
app.get('/api/dialogs', (req: Request, res: Response) => {
  try {
    const dialogs = getExportedDialogsWithSummaries(currentProjectPath);

    res.json({
      dialogs,
      total: dialogs.length,
      public: dialogs.filter(d => d.isPublic).length,
      private: dialogs.filter(d => !d.isPublic).length,
      withSummary: dialogs.filter(d => d.summary).length,
      projectPath: currentProjectPath
    });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// API: Get session content
app.get('/api/session/:projectPath/:id', (req: Request, res: Response) => {
  try {
    const { projectPath, id } = req.params;
    const filePath = path.join(PROJECTS_DIR, projectPath, `${id}.jsonl`);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const messages = parseSession(filePath);

    const summaries = messages
      .filter(m => m.type === 'summary')
      .map(m => (m as any).summary || '');

    const dialog = messages
      .filter(m => m.type === 'user' || m.type === 'assistant')
      .map(m => ({
        role: m.type,
        content: extractContent(m),
        timestamp: m.timestamp,
        time: formatTimestamp(m.timestamp)
      }))
      .filter(m => m.content.trim().length > 0);

    res.json({
      id,
      projectPath,
      summaries,
      dialog,
      messageCount: dialog.length
    });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// API: Export session to dialog/
app.post('/api/export/:projectPath/:id', (req: Request, res: Response) => {
  try {
    const { projectPath, id } = req.params;

    const sessions = getProjectSessions(currentProjectPath);
    const session = sessions.find(s => s.projectPath === projectPath && s.id === id);

    if (!session) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const result = exportSession(session, currentProjectPath);

    res.json({
      success: true,
      ...result
    });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// API: Toggle dialog visibility in Git
app.post('/api/dialog/toggle/:filename', (req: Request, res: Response) => {
  try {
    const { filename } = req.params;
    const dialogFolder = getDialogFolder(currentProjectPath);
    const filePath = path.join(dialogFolder, filename);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: 'Dialog not found' });
    }

    const newIsPublic = toggleVisibility(filePath, currentProjectPath);

    res.json({
      success: true,
      filename,
      isPublic: newIsPublic
    });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// API: Set dialog visibility explicitly
app.post('/api/dialog/visibility/:filename', (req: Request, res: Response) => {
  try {
    const { filename } = req.params;
    const { isPublic: makePublic } = req.body;

    const dialogFolder = getDialogFolder(currentProjectPath);
    const filePath = path.join(dialogFolder, filename);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: 'Dialog not found' });
    }

    setVisibility(filePath, currentProjectPath, makePublic);

    res.json({
      success: true,
      filename,
      isPublic: makePublic
    });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// API: Sync current active session (append missing tail)
app.post('/api/force-export', (req: Request, res: Response) => {
  try {
    console.log('[FORCE-SYNC] Syncing current session...');
    const startTime = Date.now();

    const result = syncCurrentSession(currentProjectPath);
    const duration = Date.now() - startTime;

    if (!result) {
      return res.status(404).json({ error: 'No active session found' });
    }

    console.log(`[FORCE-SYNC] Completed in ${duration}ms - added ${result.added} message(s)`);

    res.json({
      success: true,
      sessionId: result.sessionId.substring(0, 8),
      added: result.added,
      filename: path.basename(result.markdownPath),
      duration,
      message: result.added === 0
        ? 'Already up to date'
        : `Added ${result.added} message(s)`
    });
  } catch (err) {
    console.error('[FORCE-SYNC] Error:', err);
    res.status(500).json({ error: String(err) });
  }
});

// API: Get dialog markdown content
app.get('/api/dialog/:filename', (req: Request, res: Response) => {
  try {
    const { filename } = req.params;
    const dialogFolder = getDialogFolder(currentProjectPath);
    const filePath = path.join(dialogFolder, filename);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: 'Dialog not found' });
    }

    const content = fs.readFileSync(filePath, 'utf-8');
    const fileIsPublic = isPublic(filePath, currentProjectPath);

    res.json({
      filename,
      content,
      path: filePath,
      isPublic: fileIsPublic
    });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// API: Download markdown file
app.get('/api/download/:projectPath/:id', (req: Request, res: Response) => {
  try {
    const { projectPath, id } = req.params;

    const sessions = getProjectSessions(currentProjectPath);
    const session = sessions.find(s => s.projectPath === projectPath && s.id === id);

    if (!session) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const filePath = path.join(PROJECTS_DIR, projectPath, `${id}.jsonl`);
    const messages = parseSession(filePath);
    const markdown = toMarkdown(messages, session);

    const filename = `${session.dateISO}_session-${id.substring(0, 8)}.md`;

    res.setHeader('Content-Type', 'text/markdown');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.send(markdown);
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// API: Search sessions
app.get('/api/search', (req: Request, res: Response) => {
  try {
    const query = (req.query.q as string || '').toLowerCase();

    if (!query) {
      return res.json({ results: [] });
    }

    const sessions = getProjectSessions(currentProjectPath);

    const results = sessions.filter(s => {
      // Search in summaries
      if (s.summaries.some(sum => sum.toLowerCase().includes(query))) {
        return true;
      }
      // Search in project name
      if (s.projectName.toLowerCase().includes(query)) {
        return true;
      }
      return false;
    });

    res.json({ results, query });
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});

// Serve index.html for all other routes
app.get('*', (req: Request, res: Response) => {
  res.sendFile(path.join(__dirname, '..', 'src', 'public', 'index.html'));
});

export function startServer(port: number = 3333, projectPath?: string, outputDir?: string): void {
  if (projectPath) {
    currentProjectPath = path.resolve(projectPath);
  }

  // Output path can be different from source project
  const outputPath = outputDir ? path.resolve(outputDir) : currentProjectPath;
  const dialogFolder = getDialogFolder(outputPath);

  // Start watcher for automatic export (with optional outputDir)
  watcher = new SessionWatcher(currentProjectPath, { outputDir });
  watcher.start();

  app.listen(port, () => {
    console.log('');
    console.log('═'.repeat(60));
    console.log('  Claude Export UI + Auto-Watch');
    console.log('═'.repeat(60));
    console.log(`  URL:      http://localhost:${port}`);
    console.log(`  Source:   ${currentProjectPath}`);
    if (outputDir) {
      console.log(`  Output:   ${outputPath}`);
    }
    console.log(`  Dialogs:  ${dialogFolder}`);
    console.log(`  Watch:    Active (auto-export enabled)`);
    console.log('═'.repeat(60));
    console.log('');
    console.log('Press Ctrl+C to stop');

    // Check for dialogs without summaries and signal Claude
    const dialogs = getExportedDialogsWithSummaries(outputPath);
    const withoutSummary = dialogs.filter(d => !d.summary);

    if (withoutSummary.length > 0) {
      console.log('');
      console.log(`Found ${withoutSummary.length} dialog(s) without summary:`);
      withoutSummary.forEach(d => {
        console.log(`[CLAUDE_TASK] Generate summary for: ${d.filePath}`);
      });
    }
  });

  // Graceful shutdown
  process.on('SIGINT', () => {
    console.log('\nStopping watcher...');
    if (watcher) {
      watcher.stop();
    }
    process.exit(0);
  });
}

export default app;
