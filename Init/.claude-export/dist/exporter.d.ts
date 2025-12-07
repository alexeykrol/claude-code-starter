/**
 * Exporter - Convert Claude Code JSONL sessions to Markdown
 * Saves dialogs to dialog/ folder inside the target project
 */
/**
 * Get git user info for author attribution
 */
export declare function getGitAuthor(): {
    name: string;
    email: string;
};
export interface Message {
    type: 'user' | 'assistant' | 'summary' | 'file-history-snapshot';
    message?: {
        content?: string | Array<{
            type: string;
            text?: string;
        }>;
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
export declare const CLAUDE_DIR: string;
export declare const PROJECTS_DIR: string;
export declare function getProjectName(projectPath: string): string;
export declare function getProjectFullPath(projectPath: string): string;
export declare function parseSession(filePath: string): Message[];
export declare function extractContent(msg: Message): string;
export declare function formatTimestamp(ts: number): string;
export declare function formatDate(ts: number): string;
export declare function formatDateISO(ts: number): string;
/**
 * Find Claude project directory for a given real project path
 * Converts /Users/alex/Code/MyProject to -Users-alex-Code-MyProject
 */
export declare function findClaudeProjectDir(realProjectPath: string): string | null;
/**
 * Get all sessions from Claude for a specific project
 */
export declare function getProjectSessions(realProjectPath: string): SessionInfo[];
/**
 * Get all sessions from all projects (legacy, for compatibility)
 */
export declare function getAllSessions(): SessionInfo[];
export declare function toMarkdown(messages: Message[], session: SessionInfo): string;
/**
 * Export session to markdown file in target project's dialog/ folder
 * @param session - Session info
 * @param targetProjectPath - Real path to target project (where dialog/ will be created)
 * @returns ExportedSession info
 */
export declare function exportSession(session: SessionInfo, targetProjectPath: string): ExportedSession;
/**
 * Get list of exported dialogs in project's dialog/ folder
 */
export declare function getExportedDialogs(targetProjectPath: string): DialogInfo[];
/**
 * Check if session is already exported in target project
 */
export declare function isSessionExported(sessionId: string, targetProjectPath: string): boolean;
/**
 * Get the markdown path if session is exported
 */
export declare function getExportedPath(sessionId: string, targetProjectPath: string): string | null;
/**
 * Export all new sessions for a project
 */
export declare function exportNewSessions(targetProjectPath: string): ExportedSession[];
/**
 * Sync current active session (incremental update of the tail)
 * Finds the currently active JSONL file and appends missing messages to MD
 */
export declare function syncCurrentSession(targetProjectPath: string): {
    success: boolean;
    sessionId: string;
    added: number;
    markdownPath: string;
} | null;
/**
 * Extract summary from dialog file content
 * Supports both <!-- SUMMARY: ... --> comment and ## Summaries section
 */
export declare function extractSummary(content: string): string | null;
/**
 * Check if dialog file has a summary
 */
export declare function hasSummary(filePath: string): boolean;
/**
 * Get summary from dialog file
 */
export declare function getSummary(filePath: string): string | null;
/**
 * Get short summary from dialog file
 * Falls back to regular summary if SHORT not found
 */
export declare function getSummaryShort(filePath: string): string | null;
/**
 * Get full summary from dialog file
 * Falls back to regular summary if FULL not found
 */
export declare function getSummaryFull(filePath: string): string | null;
/**
 * Add or update summary in dialog file
 */
export declare function setSummary(filePath: string, summary: string): void;
/**
 * Extract session date/time from markdown content
 * Pattern: **Date:** DD.MM.YYYY, HH:MM or **Exported:** DD.MM.YYYY, HH:MM:SS
 */
export declare function extractSessionDateTime(content: string): Date | null;
/**
 * Get dialog info with summary
 */
export declare function getDialogWithSummary(filePath: string, projectPath: string): DialogInfo & {
    summary: string | null;
    summaryShort: string | null;
    summaryFull: string | null;
};
/**
 * Get all dialogs with summaries
 */
export declare function getExportedDialogsWithSummaries(targetProjectPath: string): Array<DialogInfo & {
    summary: string | null;
    summaryShort: string | null;
    summaryFull: string | null;
}>;
/**
 * Generate static HTML viewer with embedded dialog data
 * Creates index.html in html-viewer/ folder that can be opened directly in browser
 * This folder is visible (not hidden) for easy sharing
 */
export declare function generateStaticHtml(targetProjectPath: string): string;
