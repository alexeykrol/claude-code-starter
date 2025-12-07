#!/usr/bin/env node
"use strict";
/**
 * Claude Export CLI
 *
 * Commands:
 *   watch [path]  Start background watcher for a project
 *   ui [path]     Start web UI for browsing dialogs
 *   export [path] Export all sessions for a project
 *   list [path]   List all sessions for a project
 *   help          Show help
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
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
const watcher_1 = require("./watcher");
const server_1 = require("./server");
const exporter_1 = require("./exporter");
const gitignore_1 = require("./gitignore");
const VERSION = '2.3.0';
function showHelp() {
    console.log(`
Claude Export v${VERSION}
Export Claude Code dialogs to project's dialog/ folder

Usage:
  claude-export <command> [project-path] [options]

Commands:
  init [path]     Initialize claude-export for a project (first-time setup)
  watch [path]    Start background watcher that auto-exports new sessions
  ui [path]       Start web UI for browsing and managing dialogs
  export [path]   Export all sessions once and exit
  list [path]     List all available sessions for the project
  help            Show this help message

Arguments:
  [path]          Path to target project (default: current directory)

Options:
  --port <number>    Port for UI server (default: 3333)
  --verbose, -v      Enable verbose logging for watcher

Examples:
  claude-export init                     # Initialize current project
  claude-export init /path/to/project    # Initialize specific project
  claude-export watch                    # Watch current project
  claude-export ui                       # Open UI for current project
  claude-export list                     # Show all sessions

Dialogs are saved to:
  <project>/dialog/

Privacy:
  - New dialogs are added to .gitignore by default (private)
  - Use the UI to toggle visibility for Git commits
`);
}
function resolveProjectPath(args) {
    // Find first non-option argument after command
    for (const arg of args) {
        if (!arg.startsWith('-') && fs.existsSync(arg)) {
            return path.resolve(arg);
        }
    }
    // Default to current directory
    return process.cwd();
}
function showList(projectPath) {
    console.log(`\nProject: ${projectPath}`);
    const sessions = (0, exporter_1.getProjectSessions)(projectPath);
    if (sessions.length === 0) {
        console.log('No Claude sessions found for this project.');
        console.log(`Looking in: ${exporter_1.PROJECTS_DIR}`);
        return;
    }
    console.log(`\nFound ${sessions.length} sessions:\n`);
    console.log('Date       | Messages | Summary');
    console.log('-'.repeat(60));
    for (const session of sessions.slice(0, 30)) {
        const summary = session.summaries[0]?.substring(0, 35) || 'No summary';
        console.log(`${session.date} | ${String(session.messageCount).padStart(8)} | ${summary}...`);
    }
    if (sessions.length > 30) {
        console.log(`\n... and ${sessions.length - 30} more sessions`);
    }
    // Show exported dialogs
    const dialogs = (0, exporter_1.getExportedDialogs)(projectPath);
    const dialogFolder = (0, gitignore_1.getDialogFolder)(projectPath);
    console.log(`\n${'='.repeat(60)}`);
    console.log(`Exported dialogs: ${dialogs.length}`);
    console.log(`Location: ${dialogFolder}`);
    if (dialogs.length > 0) {
        console.log('\nDate       | Public | File');
        console.log('-'.repeat(60));
        for (const dialog of dialogs.slice(0, 10)) {
            const publicStatus = dialog.isPublic ? '  Yes ' : '  No  ';
            console.log(`${dialog.date} |${publicStatus}| ${dialog.filename}`);
        }
        if (dialogs.length > 10) {
            console.log(`\n... and ${dialogs.length - 10} more dialogs`);
        }
    }
    console.log(`\nTotal: ${sessions.length} sessions, ${dialogs.length} exported`);
}
async function runExport(projectPath) {
    console.log(`\nProject: ${projectPath}`);
    console.log('Exporting sessions...\n');
    const newExports = (0, exporter_1.exportNewSessions)(projectPath);
    const dialogFolder = (0, gitignore_1.getDialogFolder)(projectPath);
    if (newExports.length === 0) {
        console.log('All sessions already exported.');
    }
    else {
        console.log(`Exported ${newExports.length} new sessions to ${dialogFolder}`);
    }
    // Generate static HTML viewer
    try {
        const htmlPath = (0, exporter_1.generateStaticHtml)(projectPath);
        console.log(`Generated: ${htmlPath}`);
    }
    catch (err) {
        console.error(`Warning: Could not generate HTML viewer: ${err}`);
    }
    console.log('\nNote: New dialogs are added to .gitignore by default (private)');
    console.log('Use "npm run dialog:ui" to manage visibility.');
}
async function runInit(projectPath) {
    console.log('');
    console.log('═'.repeat(60));
    console.log('  Claude Export - Project Initialization');
    console.log('═'.repeat(60));
    console.log('');
    console.log(`Project: ${projectPath}`);
    console.log('');
    // Step 1: Check for Claude sessions
    console.log('Step 1: Checking for Claude Code sessions...');
    const sessions = (0, exporter_1.getProjectSessions)(projectPath);
    if (sessions.length === 0) {
        console.log('');
        console.log('⚠️  No Claude Code sessions found for this project.');
        console.log('');
        console.log('Make sure you have used Claude Code in this project.');
        console.log(`Sessions are stored in: ${exporter_1.PROJECTS_DIR}`);
        console.log('');
        console.log('You can still initialize the project structure:');
    }
    else {
        console.log(`   Found ${sessions.length} session(s)`);
    }
    // Step 2: Create dialog/ folder
    console.log('');
    console.log('Step 2: Creating dialog/ folder...');
    const dialogFolder = (0, gitignore_1.ensureDialogFolder)(projectPath);
    console.log(`   Created: ${dialogFolder}`);
    // Step 3: Export all sessions
    if (sessions.length > 0) {
        console.log('');
        console.log('Step 3: Exporting sessions to Markdown...');
        const exported = (0, exporter_1.exportNewSessions)(projectPath);
        console.log(`   Exported ${exported.length} session(s)`);
        // Show exported files
        if (exported.length > 0) {
            console.log('');
            for (const exp of exported.slice(0, 5)) {
                console.log(`   → ${path.basename(exp.markdownPath)}`);
            }
            if (exported.length > 5) {
                console.log(`   ... and ${exported.length - 5} more`);
            }
        }
    }
    // Step 4: Summary
    const dialogs = (0, exporter_1.getExportedDialogs)(projectPath);
    console.log('');
    console.log('═'.repeat(60));
    console.log('  Initialization Complete!');
    console.log('═'.repeat(60));
    console.log('');
    console.log(`  📁 Dialog folder: ${dialogFolder}`);
    console.log(`  📄 Exported dialogs: ${dialogs.length}`);
    console.log(`  🔒 All dialogs are private by default (in .gitignore)`);
    console.log('');
    console.log('Next steps:');
    console.log('');
    console.log('  1. Start the watcher for auto-export:');
    console.log('     claude-export watch');
    console.log('');
    console.log('  2. Or open the UI to manage dialogs:');
    console.log('     claude-export ui');
    console.log('');
    console.log('  3. To make a dialog public (visible in Git):');
    console.log('     Use the UI checkbox or edit .gitignore manually');
    console.log('');
}
async function main() {
    const args = process.argv.slice(2);
    const command = args[0] || 'help';
    // Parse options
    const options = {};
    const filteredArgs = [];
    for (let i = 1; i < args.length; i++) {
        if (args[i] === '--port' && args[i + 1]) {
            options.port = args[i + 1];
            i++;
        }
        else if (args[i] === '--verbose' || args[i] === '-v') {
            options.verbose = true;
        }
        else if (!args[i].startsWith('-')) {
            filteredArgs.push(args[i]);
        }
    }
    const projectPath = resolveProjectPath(filteredArgs);
    switch (command) {
        case 'init':
        case 'i':
            await runInit(projectPath);
            break;
        case 'watch':
        case 'w':
            await (0, watcher_1.startWatcher)(projectPath, { verbose: options.verbose });
            break;
        case 'ui':
        case 'server':
        case 'u':
            const port = parseInt(options.port) || 3333;
            (0, server_1.startServer)(port, projectPath);
            break;
        case 'export':
        case 'e':
            await runExport(projectPath);
            break;
        case 'list':
        case 'ls':
        case 'l':
            showList(projectPath);
            break;
        case 'help':
        case '--help':
        case '-h':
        default:
            showHelp();
            break;
    }
}
main().catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
});
