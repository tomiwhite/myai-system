# Agent Runtime Notes for myAI_System

- Always open this workspace path first: C:\myAI_System\myai-system.code-workspace
- If that workspace file is missing, fall back to folder: C:\myAI_System
- Treat `unknown:/` resources as invalid context and re-open the workspace.
- Prefer tasks and scripts from C:\myAI_System\scripts before adding new automation.
- Store restart verification output in: C:\myAI_System\reports\post-restart-check.txt
- Keep auto-start checks non-destructive (no forced app termination).
