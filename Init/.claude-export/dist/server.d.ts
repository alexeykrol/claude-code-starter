/**
 * Server - Express server for Claude Export UI
 * Provides API for managing dialogs and their Git visibility
 */
import { Application } from 'express';
declare const app: Application;
export declare function startServer(port?: number, projectPath?: string): void;
export default app;
