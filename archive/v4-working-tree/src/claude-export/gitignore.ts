/**
 * Gitignore utilities - manage dialog visibility in Git
 * Uses .gitignore as the "database" for public/private state
 */

import * as fs from 'fs';
import * as path from 'path';

const DIALOG_FOLDER = 'dialog';

/**
 * Get path to .gitignore in project
 */
export function getGitignorePath(projectPath: string): string {
  return path.join(projectPath, '.gitignore');
}

/**
 * Read .gitignore content as array of lines
 */
export function readGitignore(projectPath: string): string[] {
  const gitignorePath = getGitignorePath(projectPath);

  if (!fs.existsSync(gitignorePath)) {
    return [];
  }

  const content = fs.readFileSync(gitignorePath, 'utf-8');
  return content.split('\n');
}

/**
 * Write lines to .gitignore
 */
export function writeGitignore(projectPath: string, lines: string[]): void {
  const gitignorePath = getGitignorePath(projectPath);
  fs.writeFileSync(gitignorePath, lines.join('\n'));
}

/**
 * Normalize dialog file path for gitignore entry
 * Returns relative path like: *dialog/2025-12-05_session-abc123.md
 */
export function normalizeDialogPath(filePath: string, projectPath: string): string {
  const relative = path.relative(projectPath, filePath);
  return relative;
}

/**
 * Check if a dialog file is in .gitignore (private)
 */
export function isInGitignore(dialogFile: string, projectPath: string): boolean {
  const lines = readGitignore(projectPath);
  const relativePath = normalizeDialogPath(dialogFile, projectPath);

  // Check exact match or pattern match
  return lines.some(line => {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) return false;

    // Exact match
    if (trimmed === relativePath) return true;
    if (trimmed === '/' + relativePath) return true;

    return false;
  });
}

/**
 * Check if dialog is public (NOT in gitignore)
 */
export function isPublic(dialogFile: string, projectPath: string): boolean {
  return !isInGitignore(dialogFile, projectPath);
}

/**
 * Add dialog file to .gitignore (make private)
 */
export function addToGitignore(dialogFile: string, projectPath: string): void {
  if (isInGitignore(dialogFile, projectPath)) {
    return; // Already in gitignore
  }

  const lines = readGitignore(projectPath);
  const relativePath = normalizeDialogPath(dialogFile, projectPath);

  // Find or create *dialog section
  const dialogSectionIndex = lines.findIndex(line =>
    line.trim() === `# ${DIALOG_FOLDER}` || line.trim() === `# Claude dialogs`
  );

  if (dialogSectionIndex === -1) {
    // Add section at the end
    if (lines.length > 0 && lines[lines.length - 1].trim() !== '') {
      lines.push('');
    }
    lines.push('# Claude dialogs');
    lines.push(relativePath);
  } else {
    // Insert after the section header
    lines.splice(dialogSectionIndex + 1, 0, relativePath);
  }

  writeGitignore(projectPath, lines);
}

/**
 * Remove dialog file from .gitignore (make public)
 */
export function removeFromGitignore(dialogFile: string, projectPath: string): void {
  const lines = readGitignore(projectPath);
  const relativePath = normalizeDialogPath(dialogFile, projectPath);

  const filtered = lines.filter(line => {
    const trimmed = line.trim();
    return trimmed !== relativePath && trimmed !== '/' + relativePath;
  });

  // Clean up empty sections
  const cleaned = cleanEmptySections(filtered);

  writeGitignore(projectPath, cleaned);
}

/**
 * Toggle dialog visibility
 * Returns new public state
 */
export function toggleVisibility(dialogFile: string, projectPath: string): boolean {
  const currentlyPublic = isPublic(dialogFile, projectPath);

  if (currentlyPublic) {
    addToGitignore(dialogFile, projectPath);
    return false; // Now private
  } else {
    removeFromGitignore(dialogFile, projectPath);
    return true; // Now public
  }
}

/**
 * Set dialog visibility explicitly
 */
export function setVisibility(dialogFile: string, projectPath: string, isPublic: boolean): void {
  if (isPublic) {
    removeFromGitignore(dialogFile, projectPath);
  } else {
    addToGitignore(dialogFile, projectPath);
  }
}

/**
 * Clean up empty sections in gitignore
 */
function cleanEmptySections(lines: string[]): string[] {
  const result: string[] = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();

    // Check if this is a section header followed only by empty lines or another header
    if (trimmed.startsWith('#')) {
      let hasContent = false;
      for (let j = i + 1; j < lines.length; j++) {
        const nextTrimmed = lines[j].trim();
        if (nextTrimmed === '') continue;
        if (nextTrimmed.startsWith('#')) break;
        hasContent = true;
        break;
      }

      // Skip "# Claude dialogs" header if no content
      if (!hasContent && (trimmed === '# Claude dialogs' || trimmed === `# ${DIALOG_FOLDER}`)) {
        continue;
      }
    }

    result.push(line);
  }

  // Remove trailing empty lines
  while (result.length > 0 && result[result.length - 1].trim() === '') {
    result.pop();
  }

  // Ensure file ends with newline if not empty
  if (result.length > 0) {
    result.push('');
  }

  return result;
}

/**
 * Ensure *dialog folder exists and is set up correctly
 */
export function ensureDialogFolder(projectPath: string): string {
  const dialogPath = path.join(projectPath, DIALOG_FOLDER);

  if (!fs.existsSync(dialogPath)) {
    fs.mkdirSync(dialogPath, { recursive: true });
  }

  return dialogPath;
}

/**
 * Get dialog folder path
 */
export function getDialogFolder(projectPath: string): string {
  return path.join(projectPath, DIALOG_FOLDER);
}

/**
 * List all dialog files in project
 */
export function getDialogFiles(projectPath: string): string[] {
  const dialogPath = getDialogFolder(projectPath);

  if (!fs.existsSync(dialogPath)) {
    return [];
  }

  return fs.readdirSync(dialogPath)
    .filter(f => f.endsWith('.md'))
    .map(f => path.join(dialogPath, f))
    .sort((a, b) => {
      // Sort by modification time, newest first
      const statA = fs.statSync(a);
      const statB = fs.statSync(b);
      return statB.mtime.getTime() - statA.mtime.getTime();
    });
}
