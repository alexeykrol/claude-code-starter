/**
 * Exporter - Convert Claude Code JSONL sessions to Markdown
 * Saves dialogs to dialog/ folder inside the target project
 */

import * as fs from 'fs';
import * as path from 'path';
import * as os from 'os';
import { execSync } from 'child_process';
import {
  ensureDialogFolder,
  getDialogFolder,
  addToGitignore,
  removeFromGitignore,
  isPublic,
  getDialogFiles
} from './gitignore';

/**
 * Get git user info for author attribution
 */
export function getGitAuthor(): { name: string; email: string } {
  try {
    const name = execSync('git config user.name', { encoding: 'utf-8' }).trim();
    const email = execSync('git config user.email', { encoding: 'utf-8' }).trim();
    return { name: name || 'Unknown', email: email || '' };
  } catch {
    return { name: os.userInfo().username || 'Unknown', email: '' };
  }
}

// Types
export interface Message {
  type: 'user' | 'assistant' | 'summary' | 'file-history-snapshot';
  message?: {
    content?: string | Array<{ type: string; text?: string }>;
  };
  timestamp: number;
  uuid: string;
  parentUuid?: string;
  summary?: string;
}

export interface SessionInfo {
  id: string;
  filename: string;
  projectName: string;
  projectPath: string;
  date: string;
  dateISO: string;
  size: string;
  sizeBytes: number;
  summaries: string[];
  messageCount: number;
  lastModified: Date;
}

export interface ExportedSession {
  id: string;
  projectName: string;
  date: string;
  summaries: string[];
  messageCount: number;
  filename: string;
  markdownPath: string;
  exportedAt: string;
  isPublic: boolean;
}

export interface DialogInfo {
  filename: string;
  filePath: string;
  date: string;
  sessionId: string;
  isPublic: boolean;
  size: string;
  sizeBytes: number;
  lastModified: Date;
  sessionDateTime: Date | null;
}

// Paths
export const CLAUDE_DIR = path.join(os.homedir(), '.claude');
export const PROJECTS_DIR = path.join(CLAUDE_DIR, 'projects');

// Helpers
export function getProjectName(projectPath: string): string {
  // Convert "-Users-alex-Code-MyProject" to "MyProject"
  const parts = projectPath.split('-').filter(p => p.length > 0);
  return parts[parts.length - 1] || projectPath;
}

export function getProjectFullPath(projectPath: string): string {
  // Convert "-Users-alex-Code-MyProject" to "/Users/alex/Code/MyProject"
  return projectPath.replace(/^-/, '/').replace(/-/g, '/');
}

export function parseSession(filePath: string): Message[] {
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.trim().split('\n');

  return lines
    .map(line => {
      try {
        return JSON.parse(line) as Message;
      } catch {
        return null;
      }
    })
    .filter((msg): msg is Message => msg !== null);
}

export function extractContent(msg: Message): string {
  if (!msg.message?.content) return '';

  const content = msg.message.content;

  if (typeof content === 'string') {
    return content;
  }

  if (Array.isArray(content)) {
    return content
      .filter(block => block.type === 'text' && block.text)
      .map(block => block.text)
      .join('\n');
  }

  return '';
}

export function formatTimestamp(ts: number): string {
  return new Date(ts).toLocaleString('ru-RU', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  });
}

export function formatDate(ts: number): string {
  return new Date(ts).toLocaleDateString('ru-RU', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  });
}

export function formatDateISO(ts: number): string {
  const d = new Date(ts);
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * Find Claude project directory for a given real project path
 * Converts /Users/alex/Code/MyProject to -Users-alex-Code-MyProject
 */
export function findClaudeProjectDir(realProjectPath: string): string | null {
  const normalized = realProjectPath.replace(/\//g, '-');

  if (fs.existsSync(path.join(PROJECTS_DIR, normalized))) {
    return normalized;
  }

  // Try without leading dash
  const withoutLeading = normalized.replace(/^-/, '');
  if (fs.existsSync(path.join(PROJECTS_DIR, '-' + withoutLeading))) {
    return '-' + withoutLeading;
  }

  // Try with underscore → dash conversion (Claude may convert underscores)
  const withDashes = normalized.replace(/_/g, '-');
  if (withDashes !== normalized && fs.existsSync(path.join(PROJECTS_DIR, withDashes))) {
    return withDashes;
  }

  // Try with dash → underscore conversion
  const withUnderscores = normalized.replace(/-([^\/])/g, '_$1');
  if (withUnderscores !== normalized && fs.existsSync(path.join(PROJECTS_DIR, withUnderscores))) {
    return withUnderscores;
  }

  // Search for matching directory
  if (!fs.existsSync(PROJECTS_DIR)) {
    return null;
  }

  const dirs = fs.readdirSync(PROJECTS_DIR);
  const match = dirs.find(d => {
    const fullPath = getProjectFullPath(d);
    return fullPath === realProjectPath || fullPath === path.resolve(realProjectPath);
  });

  return match || null;
}

/**
 * Get all sessions from Claude for a specific project
 */
export function getProjectSessions(realProjectPath: string): SessionInfo[] {
  const claudeProjectDir = findClaudeProjectDir(realProjectPath);

  if (!claudeProjectDir) {
    return [];
  }

  const projectPath = path.join(PROJECTS_DIR, claudeProjectDir);
  const files = fs.readdirSync(projectPath)
    .filter(f => f.endsWith('.jsonl') && !f.startsWith('agent-'));

  const sessions: SessionInfo[] = [];

  for (const filename of files) {
    const filePath = path.join(projectPath, filename);
    const stat = fs.statSync(filePath);

    try {
      const messages = parseSession(filePath);

      const summaries = messages
        .filter(m => m.type === 'summary')
        .map(m => m.summary || '')
        .filter(s => s.length > 0);

      const dialogMessages = messages.filter(m => m.type === 'user' || m.type === 'assistant');

      const firstTimestamp = dialogMessages.length > 0
        ? dialogMessages[0].timestamp
        : stat.mtime.getTime();

      sessions.push({
        id: filename.replace('.jsonl', ''),
        filename,
        projectName: getProjectName(claudeProjectDir),
        projectPath: claudeProjectDir,
        date: formatTimestamp(firstTimestamp),
        dateISO: formatDateISO(firstTimestamp),
        size: `${(stat.size / 1024).toFixed(0)}KB`,
        sizeBytes: stat.size,
        summaries: summaries.slice(0, 5),
        messageCount: dialogMessages.length,
        lastModified: stat.mtime
      });
    } catch (err) {
      console.error(`Error parsing ${filePath}:`, err);
    }
  }

  // Sort by date descending
  sessions.sort((a, b) => b.lastModified.getTime() - a.lastModified.getTime());

  return sessions;
}

/**
 * Get all sessions from all projects (legacy, for compatibility)
 */
export function getAllSessions(): SessionInfo[] {
  if (!fs.existsSync(PROJECTS_DIR)) {
    return [];
  }

  const projectDirs = fs.readdirSync(PROJECTS_DIR)
    .filter(d => {
      const fullPath = path.join(PROJECTS_DIR, d);
      return fs.statSync(fullPath).isDirectory();
    });

  const sessions: SessionInfo[] = [];

  for (const projectDir of projectDirs) {
    const projectPath = path.join(PROJECTS_DIR, projectDir);
    const files = fs.readdirSync(projectPath)
      .filter(f => f.endsWith('.jsonl') && !f.startsWith('agent-'));

    for (const filename of files) {
      const filePath = path.join(projectPath, filename);
      const stat = fs.statSync(filePath);

      try {
        const messages = parseSession(filePath);

        const summaries = messages
          .filter(m => m.type === 'summary')
          .map(m => m.summary || '')
          .filter(s => s.length > 0);

        const dialogMessages = messages.filter(m => m.type === 'user' || m.type === 'assistant');

        const firstTimestamp = dialogMessages.length > 0
          ? dialogMessages[0].timestamp
          : stat.mtime.getTime();

        sessions.push({
          id: filename.replace('.jsonl', ''),
          filename,
          projectName: getProjectName(projectDir),
          projectPath: projectDir,
          date: formatTimestamp(firstTimestamp),
          dateISO: formatDateISO(firstTimestamp),
          size: `${(stat.size / 1024).toFixed(0)}KB`,
          sizeBytes: stat.size,
          summaries: summaries.slice(0, 5),
          messageCount: dialogMessages.length,
          lastModified: stat.mtime
        });
      } catch (err) {
        // Skip corrupted files
        console.error(`Error parsing ${filePath}:`, err);
      }
    }
  }

  // Sort by date descending
  sessions.sort((a, b) => b.lastModified.getTime() - a.lastModified.getTime());

  return sessions;
}

// Convert session to Markdown
export function toMarkdown(messages: Message[], session: SessionInfo): string {
  const dialogMessages = messages.filter(m => m.type === 'user' || m.type === 'assistant');
  const summaries = messages.filter(m => m.type === 'summary');
  const author = getGitAuthor();

  const lines: string[] = [];

  // Author comment for parsing
  lines.push(`<!-- AUTHOR: ${author.name}${author.email ? ` <${author.email}>` : ''} -->`);

  lines.push('');
  lines.push('# Claude Code Session');
  lines.push('');
  lines.push(`**Author:** ${author.name}`);
  lines.push(`**Project:** ${session.projectName}`);
  lines.push(`**Path:** \`${getProjectFullPath(session.projectPath)}\``);
  lines.push(`**Session ID:** \`${session.id}\``);
  lines.push(`**Date:** ${session.date}`);
  lines.push(`**Messages:** ${dialogMessages.length}`);
  lines.push(`**Exported:** ${new Date().toLocaleString('ru-RU')}`);
  lines.push('');

  if (summaries.length > 0) {
    lines.push('## Summaries');
    lines.push('');
    summaries.forEach(s => {
      lines.push(`- ${s.summary || ''}`);
    });
    lines.push('');
  }

  lines.push('---');
  lines.push('');
  lines.push('## Dialog');
  lines.push('');

  for (const msg of dialogMessages) {
    const role = msg.type === 'user' ? '👤 **User**' : '🤖 **Claude**';
    const time = formatTimestamp(msg.timestamp);
    const content = extractContent(msg);

    if (!content.trim()) continue;

    lines.push(`### ${role} *(${time})*`);
    lines.push('');
    lines.push(content);
    lines.push('');
    lines.push('---');
    lines.push('');
  }

  lines.push('');
  lines.push('*Exported with claude-export*');

  return lines.join('\n');
}

/**
 * Export session to markdown file in target project's dialog/ folder
 * @param session - Session info
 * @param targetProjectPath - Real path to target project (where dialog/ will be created)
 * @returns ExportedSession info
 */
export function exportSession(session: SessionInfo, targetProjectPath: string): ExportedSession {
  const sourcePath = path.join(PROJECTS_DIR, session.projectPath, session.filename);
  const messages = parseSession(sourcePath);
  const markdown = toMarkdown(messages, session);

  // Ensure .dialog folder exists
  const dialogFolder = ensureDialogFolder(targetProjectPath);

  // Create filename: 2025-12-05_session-abc12345.md
  const shortId = session.id.substring(0, 8);
  const filename = `${session.dateISO}_session-${shortId}.md`;
  const outputPath = path.join(dialogFolder, filename);

  // Check if there's an existing file with different name (e.g. due to timezone fix)
  const existingPath = getExportedPath(session.id, targetProjectPath);
  if (existingPath && existingPath !== outputPath) {
    // Old file with different date - remove it before creating new one
    const wasPublic = isPublic(existingPath, targetProjectPath);
    fs.unlinkSync(existingPath);
    if (wasPublic) {
      removeFromGitignore(existingPath, targetProjectPath);
    }
  }

  // Check if file already exists and was public
  const fileExists = fs.existsSync(outputPath);
  const wasPublic = fileExists && isPublic(outputPath, targetProjectPath);

  // Write markdown file
  fs.writeFileSync(outputPath, markdown);

  // Add to .gitignore only for NEW files (privacy by default)
  // Keep existing visibility for already exported files
  if (!fileExists) {
    addToGitignore(outputPath, targetProjectPath);
  } else if (wasPublic) {
    // Ensure public files stay public (in case they were re-added to gitignore)
    removeFromGitignore(outputPath, targetProjectPath);
  }

  return {
    id: session.id,
    projectName: session.projectName,
    date: session.date,
    summaries: session.summaries,
    messageCount: session.messageCount,
    filename,
    markdownPath: outputPath,
    exportedAt: new Date().toISOString(),
    isPublic: false // Private by default
  };
}

/**
 * Get list of exported dialogs in project's dialog/ folder
 */
export function getExportedDialogs(targetProjectPath: string): DialogInfo[] {
  const dialogFiles = getDialogFiles(targetProjectPath);

  return dialogFiles.map(filePath => {
    const stat = fs.statSync(filePath);
    const filename = path.basename(filePath);

    // Parse filename: 2025-12-05_session-abc12345.md
    const match = filename.match(/^(\d{4}-\d{2}-\d{2})_session-([a-f0-9]+)\.md$/);
    const date = match ? match[1] : 'Unknown';
    const sessionId = match ? match[2] : filename;

    return {
      filename,
      filePath,
      date,
      sessionId,
      isPublic: isPublic(filePath, targetProjectPath),
      size: `${(stat.size / 1024).toFixed(0)}KB`,
      sizeBytes: stat.size,
      lastModified: stat.mtime,
      sessionDateTime: null // Use getDialogWithSummary for full info
    };
  });
}

/**
 * Check if session is already exported in target project
 */
export function isSessionExported(sessionId: string, targetProjectPath: string): boolean {
  const shortId = sessionId.substring(0, 8);
  const dialogFolder = getDialogFolder(targetProjectPath);

  if (!fs.existsSync(dialogFolder)) {
    return false;
  }

  const files = fs.readdirSync(dialogFolder);
  return files.some(f => f.includes(`session-${shortId}`));
}

/**
 * Get the markdown path if session is exported
 */
export function getExportedPath(sessionId: string, targetProjectPath: string): string | null {
  const shortId = sessionId.substring(0, 8);
  const dialogFolder = getDialogFolder(targetProjectPath);

  if (!fs.existsSync(dialogFolder)) {
    return null;
  }

  const files = fs.readdirSync(dialogFolder);
  const match = files.find(f => f.includes(`session-${shortId}`));

  return match ? path.join(dialogFolder, match) : null;
}

/**
 * Export all new sessions for a project
 * @param targetProjectPath - source project for Claude sessions
 * @param outputDir - optional different output directory for exports
 */
export function exportNewSessions(targetProjectPath: string, outputDir?: string): ExportedSession[] {
  const sessions = getProjectSessions(targetProjectPath);
  const exportPath = outputDir || targetProjectPath;
  const newExports: ExportedSession[] = [];

  for (const session of sessions) {
    if (!isSessionExported(session.id, exportPath)) {
      try {
        const result = exportSession(session, exportPath);
        newExports.push(result);
        console.log(`Exported: ${path.basename(result.markdownPath)}`);
      } catch (err) {
        console.error(`Failed to export ${session.id}:`, err);
      }
    }
  }

  return newExports;
}

/**
 * Sync current active session (incremental update of the tail)
 * Finds the currently active JSONL file and appends missing messages to MD
 */
export function syncCurrentSession(targetProjectPath: string): { success: boolean; sessionId: string; added: number; markdownPath: string } | null {
  const sessions = getProjectSessions(targetProjectPath);

  // Find the most recently modified session (current active session)
  const currentSession = sessions.sort((a, b) =>
    b.lastModified.getTime() - a.lastModified.getTime()
  )[0];

  if (!currentSession) {
    return null;
  }

  const exportPath = getExportedPath(currentSession.id, targetProjectPath);

  if (!exportPath) {
    // Session not exported yet - do full export
    const result = exportSession(currentSession, targetProjectPath);
    return {
      success: true,
      sessionId: currentSession.id,
      added: result.messageCount,
      markdownPath: result.markdownPath
    };
  }

  // Read existing markdown to count messages
  const existingMd = fs.readFileSync(exportPath, 'utf-8');
  const existingMessageCount = (existingMd.match(/^### (User|Assistant)/gm) || []).length;

  // Parse JSONL to get current message count
  const jsonlPath = path.join(PROJECTS_DIR, currentSession.projectPath, `${currentSession.id}.jsonl`);
  const messages = parseSession(jsonlPath);
  const dialogMessages = messages.filter(m => m.type === 'user' || m.type === 'assistant');
  const currentMessageCount = dialogMessages.length;

  const newMessages = currentMessageCount - existingMessageCount;

  if (newMessages <= 0) {
    // Already up to date
    return {
      success: true,
      sessionId: currentSession.id,
      added: 0,
      markdownPath: exportPath
    };
  }

  // Re-export full session (simpler than appending)
  const result = exportSession(currentSession, targetProjectPath);

  return {
    success: true,
    sessionId: currentSession.id,
    added: newMessages,
    markdownPath: result.markdownPath
  };
}

// Summary management

const SUMMARY_PATTERN = /^<!-- SUMMARY: (.*?) -->$/m;
const SUMMARY_SHORT_PATTERN = /^<!-- SUMMARY_SHORT: (.*?) -->$/m;
const SUMMARY_FULL_PATTERN = /^<!-- SUMMARY_FULL: (.*?) -->$/m;
const SUMMARIES_SECTION_PATTERN = /## Summaries\n+(?:- (.+)(?:\n|$))/;

/**
 * Extract summary from dialog file content
 * Supports both <!-- SUMMARY: ... --> comment and ## Summaries section
 */
export function extractSummary(content: string): string | null {
  // First try the comment format
  const commentMatch = content.match(SUMMARY_PATTERN);
  if (commentMatch) {
    return commentMatch[1];
  }

  // Fallback to ## Summaries section (first bullet point)
  const sectionMatch = content.match(SUMMARIES_SECTION_PATTERN);
  if (sectionMatch) {
    return sectionMatch[1];
  }

  return null;
}

/**
 * Check if dialog file has a summary
 */
export function hasSummary(filePath: string): boolean {
  const content = fs.readFileSync(filePath, 'utf-8');
  return (
    SUMMARY_SHORT_PATTERN.test(content) ||
    SUMMARY_FULL_PATTERN.test(content) ||
    SUMMARY_PATTERN.test(content) ||
    SUMMARIES_SECTION_PATTERN.test(content)
  );
}

/**
 * Get summary from dialog file
 */
export function getSummary(filePath: string): string | null {
  const content = fs.readFileSync(filePath, 'utf-8');
  return extractSummary(content);
}

/**
 * Get short summary from dialog file
 * Falls back to regular summary if SHORT not found
 */
export function getSummaryShort(filePath: string): string | null {
  const content = fs.readFileSync(filePath, 'utf-8');
  const shortMatch = content.match(SUMMARY_SHORT_PATTERN);
  if (shortMatch) {
    return shortMatch[1];
  }
  // Fallback to regular summary
  return extractSummary(content);
}

/**
 * Get full summary from dialog file
 * Falls back to regular summary if FULL not found
 */
export function getSummaryFull(filePath: string): string | null {
  const content = fs.readFileSync(filePath, 'utf-8');
  const fullMatch = content.match(SUMMARY_FULL_PATTERN);
  if (fullMatch) {
    return fullMatch[1];
  }
  // Fallback to regular summary
  return extractSummary(content);
}

/**
 * Get current session ID (from most recently modified Claude session)
 * Returns null if no sessions exist
 */
export function getCurrentSessionId(projectPath: string): string | null {
  const claudeProjectDir = findClaudeProjectDir(projectPath);

  if (!claudeProjectDir) {
    return null;
  }

  const sessionsPath = path.join(PROJECTS_DIR, claudeProjectDir);

  if (!fs.existsSync(sessionsPath)) {
    return null;
  }

  // Get all .jsonl session files (excluding agent sessions)
  const sessionFiles = fs.readdirSync(sessionsPath)
    .filter(f => f.endsWith('.jsonl') && !f.startsWith('agent-'))
    .map(f => path.join(sessionsPath, f));

  if (sessionFiles.length === 0) {
    return null;
  }

  // Sort by modification time, newest first
  sessionFiles.sort((a, b) => {
    const statA = fs.statSync(a);
    const statB = fs.statSync(b);
    return statB.mtime.getTime() - statA.mtime.getTime();
  });

  // Most recently modified session is the current one
  const currentSession = sessionFiles[0];
  const filename = path.basename(currentSession, '.jsonl');

  return filename; // Returns the full session ID
}

/**
 * Add or update summary in dialog file
 */
export function setSummary(filePath: string, summary: string): void {
  let content = fs.readFileSync(filePath, 'utf-8');

  if (SUMMARY_PATTERN.test(content)) {
    // Update existing summary
    content = content.replace(SUMMARY_PATTERN, `<!-- SUMMARY: ${summary} -->`);
  } else {
    // Add summary at the beginning
    content = `<!-- SUMMARY: ${summary} -->\n\n${content}`;
  }

  fs.writeFileSync(filePath, content);
}


/**
 * Extract session date/time from markdown content
 * Pattern: **Date:** DD.MM.YYYY, HH:MM or **Exported:** DD.MM.YYYY, HH:MM:SS
 */
export function extractSessionDateTime(content: string): Date | null {
  // Try Date with time first: **Date:** DD.MM.YYYY, HH:MM
  const dateWithTime = content.match(/\*\*Date:\*\*\s*(\d{2})\.(\d{2})\.(\d{4}),\s*(\d{2}):(\d{2})/);
  if (dateWithTime) {
    const [, day, month, year, hour, minute] = dateWithTime;
    return new Date(parseInt(year), parseInt(month) - 1, parseInt(day), parseInt(hour), parseInt(minute));
  }

  // Fallback to Exported timestamp: **Exported:** DD.MM.YYYY, HH:MM:SS
  const exported = content.match(/\*\*Exported:\*\*\s*(\d{2})\.(\d{2})\.(\d{4}),\s*(\d{2}):(\d{2}):(\d{2})/);
  if (exported) {
    const [, day, month, year, hour, minute, second] = exported;
    return new Date(parseInt(year), parseInt(month) - 1, parseInt(day), parseInt(hour), parseInt(minute), parseInt(second));
  }

  // Try Date without time: **Date:** DD.MM.YYYY
  const dateOnly = content.match(/\*\*Date:\*\*\s*(\d{2})\.(\d{2})\.(\d{4})/);
  if (dateOnly) {
    const [, day, month, year] = dateOnly;
    return new Date(parseInt(year), parseInt(month) - 1, parseInt(day), 0, 0, 0);
  }

  return null;
}

/**
 * Get dialog info with summary
 */
export function getDialogWithSummary(filePath: string, projectPath: string): DialogInfo & { summary: string | null; summaryShort: string | null; summaryFull: string | null } {
  const stat = fs.statSync(filePath);
  const filename = path.basename(filePath);
  const content = fs.readFileSync(filePath, 'utf-8');

  const match = filename.match(/^(\d{4}-\d{2}-\d{2})_session-([a-f0-9]+)\.md$/);
  const date = match ? match[1] : 'Unknown';
  const sessionId = match ? match[2] : filename;

  // Extract both short and full summaries
  const shortMatch = content.match(SUMMARY_SHORT_PATTERN);
  const fullMatch = content.match(SUMMARY_FULL_PATTERN);

  const summaryShort = shortMatch ? shortMatch[1] : extractSummary(content);
  const summaryFull = fullMatch ? fullMatch[1] : extractSummary(content);

  return {
    filename,
    filePath,
    date,
    sessionId,
    isPublic: isPublic(filePath, projectPath),
    size: `${(stat.size / 1024).toFixed(0)}KB`,
    sizeBytes: stat.size,
    lastModified: stat.mtime,
    sessionDateTime: extractSessionDateTime(content),
    summary: summaryShort, // For backwards compatibility, use short version
    summaryShort,
    summaryFull
  };
}

/**
 * Get all dialogs with summaries
 */
export function getExportedDialogsWithSummaries(targetProjectPath: string): Array<DialogInfo & { summary: string | null; summaryShort: string | null; summaryFull: string | null }> {
  const dialogFiles = getDialogFiles(targetProjectPath);

  return dialogFiles.map(filePath => getDialogWithSummary(filePath, targetProjectPath));
}

// ===== Static HTML Viewer Generation =====

/**
 * Get template path for static HTML viewer
 * Always reads from project root html-viewer/template.html
 */
function getTemplatePath(): string {
  // Template is always in project root (not in dist/)
  const templatePath = path.join(process.cwd(), 'html-viewer', 'template.html');

  if (!fs.existsSync(templatePath)) {
    throw new Error('Template not found. Make sure html-viewer/template.html exists in project root.');
  }

  return templatePath;
}

/**
 * Generate static HTML viewer with embedded dialog data
 * Creates index.html in html-viewer/ folder that can be opened directly in browser
 * This folder is visible (not hidden) for easy sharing
 */
export function generateStaticHtml(targetProjectPath: string): string {
  const viewerFolder = path.join(targetProjectPath, 'html-viewer');

  // Ensure folder exists
  if (!fs.existsSync(viewerFolder)) {
    fs.mkdirSync(viewerFolder, { recursive: true });
  }

  const outputPath = path.join(viewerFolder, 'index.html');

  // Get all dialogs with full content
  const dialogFiles = getDialogFiles(targetProjectPath);
  const dialogsData = dialogFiles.map(filePath => {
    const stat = fs.statSync(filePath);
    const filename = path.basename(filePath);
    const content = fs.readFileSync(filePath, 'utf-8');

    const match = filename.match(/^(\d{4}-\d{2}-\d{2})_session-([a-f0-9]+)\.md$/);
    const date = match ? match[1] : 'Unknown';
    const sessionId = match ? match[2] : filename;

    // Extract summaries
    const shortMatch = content.match(SUMMARY_SHORT_PATTERN);
    const fullMatch = content.match(SUMMARY_FULL_PATTERN);
    const summaryShort = shortMatch ? shortMatch[1] : extractSummary(content);
    const summaryFull = fullMatch ? fullMatch[1] : extractSummary(content);

    // Extract date/time from content
    const sessionDateTime = extractSessionDateTime(content);

    return {
      filename,
      date,
      sessionId,
      isPublic: isPublic(filePath, targetProjectPath),
      size: `${(stat.size / 1024).toFixed(0)}KB`,
      summary: summaryShort,
      summaryShort,
      summaryFull,
      sessionDateTime: sessionDateTime ? sessionDateTime.toISOString() : null,
      content: content
    };
  });

  // Sort by date (newest first)
  dialogsData.sort((a, b) => {
    const dateA = a.sessionDateTime ? new Date(a.sessionDateTime).getTime() : 0;
    const dateB = b.sessionDateTime ? new Date(b.sessionDateTime).getTime() : 0;
    return dateB - dateA;
  });

  // Filter for public dialogs only (Student UI should only show public content)
  const publicDialogs = dialogsData.filter(d => d.isPublic);

  // Project info
  const projectName = path.basename(targetProjectPath);
  const projectInfo = {
    name: projectName,
    path: targetProjectPath,
    dialogCount: publicDialogs.length,
    generatedAt: new Date().toISOString()
  };

  // Read template
  const templatePath = getTemplatePath();
  let template = fs.readFileSync(templatePath, 'utf-8');

  // Replace placeholders
  const now = new Date();
  const dateStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
  const timeStr = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
  const dateTimeStr = `${dateStr}, ${timeStr}`;

  // Replace simple placeholders first, before embedding dialog content
  // (dialog content may mention these placeholders in conversation)
  template = template.replace('__PROJECT_INFO__', JSON.stringify(projectInfo));
  template = template.replace('__VERSION__', 'v2.3.0');
  template = template.replace('__DATE__', dateStr);
  template = template.replace('__DATETIME__', dateTimeStr);
  template = template.replace('__PROJECT_NAME__', projectName);

  // Replace dialog data last (may contain placeholder strings in content)
  // IMPORTANT: Escape </script> to prevent breaking out of script tag in HTML
  const dialogsDataJson = JSON.stringify(publicDialogs).replace(/<\/script>/gi, '<\\/script>');
  template = template.replace('__DIALOGS_DATA__', dialogsDataJson);

  // Write output
  fs.writeFileSync(outputPath, template);

  return outputPath;
}
