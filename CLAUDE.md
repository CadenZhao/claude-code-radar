# Mission Control — interactive mode (optional)

This file is **optional**. The `ccradar.sh` script already prints the full
dashboard on its own — you don't need Claude for a glance. Use this prompt only
when you want the dashboard *and* the ability to then say "open project X and
pick up where I left off."

Place this file in `~/mission-control/` and run `claude` from that directory.

## On startup

1. Run the read-only scanner and show me its output verbatim (it already renders
   a complete dashboard):
   `bash ~/mission-control/ccradar.sh <YOUR_PROJECT_ROOT>`
   (Replace `<YOUR_PROJECT_ROOT>` with the directory your projects live under;
   multiple roots may be passed, space-separated.)
2. Then ask: "Which project do you want to work on today?"

## Boundaries (safety)

This is a **read-only command center**. You help me see and decide; you do not act.

- ALLOWED: run `ccradar.sh`, summarize it, suggest what to work on, point out
  stale projects or uncommitted changes.
- NOT ALLOWED: modify any project's code or data.
- NOT ALLOWED: deploy, delete, or run any analysis or long-running job.
- NOT ALLOWED: run compute on a login node (heavy work goes to the scheduler,
  e.g. SLURM, on a compute node).
- NOT ALLOWED: make decisions for me — suggest only.

If I ask to actually work on a project, switch to that project's own directory
and follow its own CLAUDE.md from there. This file governs the radar only.
