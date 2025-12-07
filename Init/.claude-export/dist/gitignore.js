"use strict";
/**
 * Gitignore utilities - manage dialog visibility in Git
 * Uses .gitignore as the "database" for public/private state
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.getGitignorePath = getGitignorePath;
exports.readGitignore = readGitignore;
exports.writeGitignore = writeGitignore;
exports.normalizeDialogPath = normalizeDialogPath;
exports.isInGitignore = isInGitignore;
exports.isPublic = isPublic;
exports.addToGitignore = addToGitignore;
exports.removeFromGitignore = removeFromGitignore;
exports.toggleVisibility = toggleVisibility;
exports.setVisibility = setVisibility;
exports.ensureDialogFolder = ensureDialogFolder;
exports.getDialogFolder = getDialogFolder;
exports.getDialogFiles = getDialogFiles;
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const DIALOG_FOLDER = 'dialog';
/**
 * Get path to .gitignore in project
 */
function getGitignorePath(projectPath) {
    return path.join(projectPath, '.gitignore');
}
/**
 * Read .gitignore content as array of lines
 */
function readGitignore(projectPath) {
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
function writeGitignore(projectPath, lines) {
    const gitignorePath = getGitignorePath(projectPath);
    fs.writeFileSync(gitignorePath, lines.join('\n'));
}
/**
 * Normalize dialog file path for gitignore entry
 * Returns relative path like: *dialog/2025-12-05_session-abc123.md
 */
function normalizeDialogPath(filePath, projectPath) {
    const relative = path.relative(projectPath, filePath);
    return relative;
}
/**
 * Check if a dialog file is in .gitignore (private)
 */
function isInGitignore(dialogFile, projectPath) {
    const lines = readGitignore(projectPath);
    const relativePath = normalizeDialogPath(dialogFile, projectPath);
    // Check exact match or pattern match
    return lines.some(line => {
        const trimmed = line.trim();
        if (!trimmed || trimmed.startsWith('#'))
            return false;
        // Exact match
        if (trimmed === relativePath)
            return true;
        if (trimmed === '/' + relativePath)
            return true;
        return false;
    });
}
/**
 * Check if dialog is public (NOT in gitignore)
 */
function isPublic(dialogFile, projectPath) {
    return !isInGitignore(dialogFile, projectPath);
}
/**
 * Add dialog file to .gitignore (make private)
 */
function addToGitignore(dialogFile, projectPath) {
    if (isInGitignore(dialogFile, projectPath)) {
        return; // Already in gitignore
    }
    const lines = readGitignore(projectPath);
    const relativePath = normalizeDialogPath(dialogFile, projectPath);
    // Find or create *dialog section
    const dialogSectionIndex = lines.findIndex(line => line.trim() === `# ${DIALOG_FOLDER}` || line.trim() === `# Claude dialogs`);
    if (dialogSectionIndex === -1) {
        // Add section at the end
        if (lines.length > 0 && lines[lines.length - 1].trim() !== '') {
            lines.push('');
        }
        lines.push('# Claude dialogs');
        lines.push(relativePath);
    }
    else {
        // Insert after the section header
        lines.splice(dialogSectionIndex + 1, 0, relativePath);
    }
    writeGitignore(projectPath, lines);
}
/**
 * Remove dialog file from .gitignore (make public)
 */
function removeFromGitignore(dialogFile, projectPath) {
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
function toggleVisibility(dialogFile, projectPath) {
    const currentlyPublic = isPublic(dialogFile, projectPath);
    if (currentlyPublic) {
        addToGitignore(dialogFile, projectPath);
        return false; // Now private
    }
    else {
        removeFromGitignore(dialogFile, projectPath);
        return true; // Now public
    }
}
/**
 * Set dialog visibility explicitly
 */
function setVisibility(dialogFile, projectPath, isPublic) {
    if (isPublic) {
        removeFromGitignore(dialogFile, projectPath);
    }
    else {
        addToGitignore(dialogFile, projectPath);
    }
}
/**
 * Clean up empty sections in gitignore
 */
function cleanEmptySections(lines) {
    const result = [];
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const trimmed = line.trim();
        // Check if this is a section header followed only by empty lines or another header
        if (trimmed.startsWith('#')) {
            let hasContent = false;
            for (let j = i + 1; j < lines.length; j++) {
                const nextTrimmed = lines[j].trim();
                if (nextTrimmed === '')
                    continue;
                if (nextTrimmed.startsWith('#'))
                    break;
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
function ensureDialogFolder(projectPath) {
    const dialogPath = path.join(projectPath, DIALOG_FOLDER);
    if (!fs.existsSync(dialogPath)) {
        fs.mkdirSync(dialogPath, { recursive: true });
    }
    return dialogPath;
}
/**
 * Get dialog folder path
 */
function getDialogFolder(projectPath) {
    return path.join(projectPath, DIALOG_FOLDER);
}
/**
 * List all dialog files in project
 */
function getDialogFiles(projectPath) {
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
