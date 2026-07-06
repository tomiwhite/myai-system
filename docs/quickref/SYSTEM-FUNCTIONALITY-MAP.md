# System Functionality Map

## Purpose

myAI_System is a Windows-level operations layer for the wider myAI ecosystem.
It is designed to keep the machine stable, observable, and recoverable before and after automation changes.

## Design Intent

1. Safe operations first: diagnostics and previews before invasive cleanup.
2. Backup-before-change: critical state is saved before registry/ACL/system changes.
3. Repeatable startup: one-click launchers validate dependencies and open the right workspace.
4. Config-driven behavior: environment paths can be centrally managed in config.
5. Operational evidence: scripts produce logs and technical JSON reports.

## Functional Layers

1. Entry Layer
- scripts/startup/start-myai-system-c.ps1
- scripts/startup/start-myai-application-d.ps1
- scripts/startup/create-desktop-shortcuts.vbs

What it does:
- validates required folders
- checks .env readiness
- checks VS Code and extension availability
- opens the target workspace

2. Configuration Layer
- scripts/config/sync-env-from-gdrive.ps1
- config/system-config.json

What it does:
- resolves env source and destination paths
- supports override variable MYAI_GDRIVE_ENV
- supports preview mode with DryRun
- creates backup before replacing master env

3. Diagnostics Layer
- scripts/diagnostics/quick-permissions-check.ps1
- scripts/diagnostics/deep-system-audit.ps1
- scripts/diagnostics/audit-permissions.ps1

What it does:
- fast checks for baseline readiness
- deep read-only inventory of risks and leftovers
- optional permission repair with explicit fix mode

4. Cleanup and Remediation Layer
- scripts/diagnostics/cleanup-safe-junk.ps1
- scripts/diagnostics/auto-cleanup.ps1
- scripts/diagnostics/auto-cleanup-orphaned.ps1
- scripts/diagnostics/deep-cleanup-admin.ps1
- scripts/diagnostics/remove-euvkbd-driver.ps1

What it does:
- removes low-risk junk in controlled scope
- performs medium/high-risk cleanup with guardrails
- supports DryRun/WhatIf patterns where available
- uses backup + manifest patterns before destructive operations

5. Governance and Evidence Layer
- scripts/validation/validate-naming-rules.ps1
- docs/quickref/SCRIPT-MAP.md
- reports/*
- logs/*
- backups/*

What it does:
- enforces naming policy from AI_RULES.md
- keeps quick operational reference up to date
- stores machine-readable reports and operation logs

## End-to-End Flow

1. Run startup launcher.
2. Validate naming and baseline diagnostics.
3. Run read-only deep diagnostics.
4. Apply targeted remediation only when needed.
5. Save report/log artifacts and re-run validator.

## New Automation Added In This Session

- scripts/startup/run-system-baseline-check.ps1

Why it was added:
- to standardize repeatable, safe, low-risk validation runs
- to provide one JSON summary for operational checkpoints
- to reduce manual command chaining during maintenance sessions

Default checks:
- naming validator
- env sync dry-run
- quick permissions check
- auto-fix in what-if mode

Optional check:
- deep system audit via IncludeDeepAudit switch
