#!/usr/bin/env node
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

import * as path from 'path';
import * as fs from 'fs';
import { startWatcher } from './watcher';
import { startServer } from './server';
import {
  getProjectSessions,
  exportNewSessions,
  getExportedDialogs,
  PROJECTS_DIR,
  generateStaticHtml
} from './exporter';
import { getDialogFolder, ensureDialogFolder, addToGitignore } from './gitignore';

const VERSION = '2.3.0';

function showHelp(): void {
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
  --output <path>    Export to different directory (keep session source)
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

function resolveProjectPath(args: string[]): string {
  // Find first non-option argument after command
  for (const arg of args) {
    if (!arg.startsWith('-') && fs.existsSync(arg)) {
      return path.resolve(arg);
    }
  }

  // Default to current directory
  return process.cwd();
}

function showList(projectPath: string): void {
  console.log(`\nProject: ${projectPath}`);

  const sessions = getProjectSessions(projectPath);

  if (sessions.length === 0) {
    console.log('No Claude sessions found for this project.');
    console.log(`Looking in: ${PROJECTS_DIR}`);
    return;
  }

  console.log(`\nFound ${sessions.length} sessions:\n`);
  console.log('Date       | Messages | Summary');
  console.log('-'.repeat(60));

  for (const session of sessions.slice(0, 30)) {
    const summary = session.summaries[0]?.substring(0, 35) || 'No summary';
    console.log(
      `${session.date} | ${String(session.messageCount).padStart(8)} | ${summary}...`
    );
  }

  if (sessions.length > 30) {
    console.log(`\n... and ${sessions.length - 30} more sessions`);
  }

  // Show exported dialogs
  const dialogs = getExportedDialogs(projectPath);
  const dialogFolder = getDialogFolder(projectPath);

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

async function runExport(projectPath: string): Promise<void> {
  console.log(`\nProject: ${projectPath}`);
  console.log('Exporting sessions...\n');

  const newExports = exportNewSessions(projectPath);
  const dialogFolder = getDialogFolder(projectPath);

  if (newExports.length === 0) {
    console.log('All sessions already exported.');
  } else {
    console.log(`Exported ${newExports.length} new sessions to ${dialogFolder}`);
  }

  // Generate static HTML viewer
  try {
    const htmlPath = generateStaticHtml(projectPath);
    console.log(`Generated: ${htmlPath}`);
  } catch (err) {
    console.error(`Warning: Could not generate HTML viewer: ${err}`);
  }

  console.log('\nNote: New dialogs are added to .gitignore by default (private)');
  console.log('Use "npm run dialog:ui" to manage visibility.');
}

async function runInit(projectPath: string): Promise<void> {
  console.log('');
  console.log('═'.repeat(60));
  console.log('  Claude Export - Project Initialization');
  console.log('═'.repeat(60));
  console.log('');
  console.log(`Project: ${projectPath}`);
  console.log('');

  // Step 1: Check for Claude sessions
  console.log('Step 1: Checking for Claude Code sessions...');
  const sessions = getProjectSessions(projectPath);

  if (sessions.length === 0) {
    console.log('');
    console.log('⚠️  No Claude Code sessions found for this project.');
    console.log('');
    console.log('Make sure you have used Claude Code in this project.');
    console.log(`Sessions are stored in: ${PROJECTS_DIR}`);
    console.log('');
    console.log('You can still initialize the project structure:');
  } else {
    console.log(`   Found ${sessions.length} session(s)`);
  }

  // Step 2: Create dialog/ folder
  console.log('');
  console.log('Step 2: Creating dialog/ folder...');
  const dialogFolder = ensureDialogFolder(projectPath);
  console.log(`   Created: ${dialogFolder}`);

  // Step 3: Export all sessions
  if (sessions.length > 0) {
    console.log('');
    console.log('Step 3: Exporting sessions to Markdown...');
    const exported = exportNewSessions(projectPath);
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
  const dialogs = getExportedDialogs(projectPath);

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

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const command = args[0] || 'help';

  // Parse options
  const options: Record<string, string | boolean> = {};
  const filteredArgs: string[] = [];

  for (let i = 1; i < args.length; i++) {
    if (args[i] === '--port' && args[i + 1]) {
      options.port = args[i + 1];
      i++;
    } else if (args[i] === '--output' && args[i + 1]) {
      options.output = path.resolve(args[i + 1]);
      i++;
    } else if (args[i] === '--verbose' || args[i] === '-v') {
      options.verbose = true;
    } else if (!args[i].startsWith('-')) {
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
      await startWatcher(projectPath, {
        verbose: options.verbose as boolean,
        outputDir: options.output as string | undefined
      });
      break;

    case 'ui':
    case 'server':
    case 'u':
      const port = parseInt(options.port as string) || 3333;
      startServer(port, projectPath, options.output as string | undefined);
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
