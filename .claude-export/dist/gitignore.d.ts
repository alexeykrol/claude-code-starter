/**
 * Gitignore utilities - manage dialog visibility in Git
 * Uses .gitignore as the "database" for public/private state
 */
/**
 * Get path to .gitignore in project
 */
export declare function getGitignorePath(projectPath: string): string;
/**
 * Read .gitignore content as array of lines
 */
export declare function readGitignore(projectPath: string): string[];
/**
 * Write lines to .gitignore
 */
export declare function writeGitignore(projectPath: string, lines: string[]): void;
/**
 * Normalize dialog file path for gitignore entry
 * Returns relative path like: *dialog/2025-12-05_session-abc123.md
 */
export declare function normalizeDialogPath(filePath: string, projectPath: string): string;
/**
 * Check if a dialog file is in .gitignore (private)
 */
export declare function isInGitignore(dialogFile: string, projectPath: string): boolean;
/**
 * Check if dialog is public (NOT in gitignore)
 */
export declare function isPublic(dialogFile: string, projectPath: string): boolean;
/**
 * Add dialog file to .gitignore (make private)
 */
export declare function addToGitignore(dialogFile: string, projectPath: string): void;
/**
 * Remove dialog file from .gitignore (make public)
 */
export declare function removeFromGitignore(dialogFile: string, projectPath: string): void;
/**
 * Toggle dialog visibility
 * Returns new public state
 */
export declare function toggleVisibility(dialogFile: string, projectPath: string): boolean;
/**
 * Set dialog visibility explicitly
 */
export declare function setVisibility(dialogFile: string, projectPath: string, isPublic: boolean): void;
/**
 * Ensure *dialog folder exists and is set up correctly
 */
export declare function ensureDialogFolder(projectPath: string): string;
/**
 * Get dialog folder path
 */
export declare function getDialogFolder(projectPath: string): string;
/**
 * List all dialog files in project
 */
export declare function getDialogFiles(projectPath: string): string[];
