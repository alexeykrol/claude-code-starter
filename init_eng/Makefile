# Makefile for Project_init
# This file simplifies executing typical commands and allows Claude Code to control what runs

.PHONY: help dev build test lint typecheck security clean install audit fix-lint

# Show help by default
.DEFAULT_GOAL := help

## help: Show this help message
help:
	@echo "Available commands:"
	@echo ""
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'
	@echo ""

## dev: Start development server
dev:
	@echo "🚀 Starting development server..."
	npm run dev

## build: Build project for production
build:
	@echo "📦 Building project..."
	npm run build

## start: Start production server (after build)
start:
	@echo "▶️  Starting production server..."
	npm run start

## test: Run all tests
test:
	@echo "🧪 Running tests..."
	npm run test

## test-watch: Run tests in watch mode
test-watch:
	@echo "👀 Running tests in watch mode..."
	npm run test:watch

## lint: Check code with linter
lint:
	@echo "🔍 Checking code with linter..."
	npm run lint

## fix-lint: Auto-fix linter issues
fix-lint:
	@echo "🔧 Auto-fixing linter..."
	npm run lint -- --fix

## typecheck: Check TypeScript types
typecheck:
	@echo "📘 Checking TypeScript types..."
	npm run type-check

## security: Check security (npm audit)
security:
	@echo "🔐 Security check..."
	npm audit
	@echo ""
	@echo "To auto-fix: make security-fix"

## security-fix: Auto-fix vulnerabilities
security-fix:
	@echo "🔐 Auto-fixing vulnerabilities..."
	npm audit fix

## audit: Full project check (lint + typecheck + test + security)
audit:
	@echo "🔎 Full project check..."
	@make lint
	@make typecheck
	@make test
	@make security

## install: Install dependencies
install:
	@echo "📥 Installing dependencies..."
	npm install

## clean: Clean build artifacts and node_modules
clean:
	@echo "🧹 Cleaning project..."
	rm -rf node_modules .next dist build out
	@echo "✅ Project cleaned"

## reinstall: Reinstall all dependencies (clean + install)
reinstall: clean install
	@echo "✅ Dependencies reinstalled"

## format: Format code (Prettier)
format:
	@echo "✨ Formatting code..."
	npm run format

## db-migrate: Run database migrations
db-migrate:
	@echo "🗄️  Running DB migrations..."
	npm run db:migrate

## db-reset: Reset DB and apply migrations
db-reset:
	@echo "⚠️  Resetting DB..."
	npm run db:reset

## db-seed: Seed DB with test data
db-seed:
	@echo "🌱 Seeding DB with test data..."
	npm run db:seed

## pre-commit: Pre-commit checks (lint + typecheck)
pre-commit:
	@echo "✅ Pre-commit checks..."
	@make lint
	@make typecheck
	@echo "✅ Ready to commit!"

## pre-push: Pre-push checks (audit + build)
pre-push:
	@echo "✅ Pre-push checks..."
	@make audit
	@make build
	@echo "✅ Ready to push!"

## init: Initial project setup (for new developers)
init:
	@echo "🎉 Initializing project..."
	@make install
	@cp -n .env.example .env.local || echo ".env.local already exists"
	@echo ""
	@echo "✅ Project initialized!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Edit .env.local with required variables"
	@echo "2. Run 'make dev' to start development server"

## doctor: Environment diagnostics (check everything is installed)
doctor:
	@echo "🔬 Environment diagnostics..."
	@echo ""
	@echo "Node.js version:"
	@node --version || echo "❌ Node.js not installed"
	@echo ""
	@echo "npm version:"
	@npm --version || echo "❌ npm not installed"
	@echo ""
	@echo "git version:"
	@git --version || echo "❌ git not installed"
	@echo ""
	@echo "gh CLI version:"
	@gh --version || echo "⚠️  gh CLI not installed (optional)"
	@echo ""
	@test -f .env.local && echo "✅ .env.local exists" || echo "⚠️  .env.local not found"
	@test -d node_modules && echo "✅ node_modules installed" || echo "⚠️  node_modules not installed (run: make install)"
