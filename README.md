<div align="center">

# 📡 claude-code-radar

### A read-only radar for the Claude Code projects scattered across your server.

*You run Claude Code on a remote box for the heavy lifting. Months pass. Projects pile up in different folders. One day you genuinely can't remember how many you have, which ones are active, or which one has uncommitted work you forgot about.*

**This points a radar at all of them — in one command.**

</div>

---

```
===============================================
  MISSION CONTROL — 2026-06-24 22:02
===============================================

  Projects found: 6

--- NEEDS ATTENTION ---------------------------
  (*)  my-website        — 15 uncommitted changes
  (!)  data-cleaner      — last touched 2026-06-08 (stale > 14d)

--- ALL PROJECTS (most recent first) ----------

  image-classifier  — last 2026-06-24 | no-git
    Project Rules

  analysis-pipeline — last 2026-06-24 | no-git
    analysis-pipeline — nightly sales ETL

  my-website        — last 2026-06-22 | main (15 uncommitted)
    working rules for my-website

  ... (sorted by most recent) ...
===============================================
```

> One command in. A full status board out. No clicking through folders, no `ls` archaeology, no "wait, what was I doing here?"

---

## 🤔 Why this exists

Every project-management tool wants you to **register** projects, **fill in** fields, and **keep a board in sync by hand**. Nobody actually does that for long — the board rots, and you're back to keeping it all in your head.

claude-code-radar takes the opposite bet:

| 🛠️ Traditional tracker | 📡 claude-code-radar |
| :--- | :--- |
| Register each project manually | **Zero registration** — a folder is a project if it has a `CLAUDE.md` |
| Update statuses by hand | **Auto-detected** — git state, last activity, uncommitted work |
| Open a separate app | **One command** in your terminal |
| Drifts out of sync | **Always live** — re-scans every run |
| Can edit / break things | **Physically read-only** |

The trick: you're *already* dropping a `CLAUDE.md` in each project (Claude Code reads it). The radar keys off that same file. **The habit you already have becomes the index.** New project with a `CLAUDE.md`? It appears. Deleted it? It's gone. You never maintain a list.

---

## 🔍 What it shows you

- **Every project, sorted by most recent activity** — so the thing you actually care about is at the top.
- **🚩 NEEDS ATTENTION** — projects gone stale (untouched > 14 days, possibly forgotten) and projects with **uncommitted git changes** you'd hate to lose.
- **A one-line description per project** — pulled straight from the first line of each `CLAUDE.md`.

It deliberately **skips** third-party software checkouts and bulk data folders. If a directory has no `CLAUDE.md`, it isn't your project — it's noise — and the radar ignores it.

---

## 🛡️ Read-only by design

This tool is *built to be incapable of changing anything.*

- The scanner runs **only** `find`, `grep`, `git log`, and `git status`. It never writes, deletes, deploys, or runs your analyses.
- No `du` on multi-terabyte trees — it stays instant even when a project holds 2 TB of sequencing data.
- Safe to run on an HPC **login node**: the commands are featherweight. (Heavy work still belongs on a compute node via your scheduler — the radar just inventories, it never computes.)

Both files are short on purpose. Read them before you run them.

---

## 🚀 Quick start

On the server where your Claude Code projects live:

```bash
mkdir -p ~/mission-control && cd ~/mission-control
# put ccradar.sh here (git clone / scp / paste)
chmod +x ccradar.sh
```

Run it, pointing at the directory your projects live under (list several if you like):

```bash
./ccradar.sh /work/users/me/projects ~/dev
```

That's it — the dashboard prints immediately.

Make it a one-word habit:

```bash
echo "alias radar='~/mission-control/ccradar.sh /work/users/me/projects'" >> ~/.bashrc
source ~/.bashrc
radar
```

---

## 🖱️ One-tap launch from your laptop (optional)

If your projects live on a remote server, you can turn the whole dashboard into a **single click from your Mac**: tap an icon → SSH connects → the board prints → glance and close.

See **[`docs/one-tap-launch.md`](docs/one-tap-launch.md)** for an SSH-key + Touch ID + iTerm setup, including an example **university HPC** walkthrough (VPN and two-factor caveats included).

---

## 🧭 Convention: one `CLAUDE.md` per project

The radar keys off `CLAUDE.md`, and so does Claude Code itself — so the habit pays off twice. The first line doubles as your dashboard description:

```markdown
# analysis-pipeline — nightly ETL, raw vs cleaned tables
```

Keep it short and human. Future-you reading the board will thank present-you.

---

## 🤝 Want the AI version too?

A bonus [`CLAUDE.md`](CLAUDE.md) prompt is included. Drop it in `~/mission-control/` and run `claude` there instead of the script, and Claude Code will render the same board *and* let you say "okay, open analysis-pipeline and pick up where I left off." The script is for a glance; the prompt is for a conversation. Use whichever you're in the mood for.

---

## 📦 What's in the box

| File | Role |
| :--- | :--- |
| [`ccradar.sh`](ccradar.sh) | The radar. Read-only scanner that prints the dashboard. |
| [`CLAUDE.md`](CLAUDE.md) | Optional prompt for the interactive, Claude-rendered version. |
| [`docs/one-tap-launch.md`](docs/one-tap-launch.md) | SSH-key + iTerm one-click setup, with an example HPC walkthrough. |

---

## 📜 License

[MIT](LICENSE) — do whatever you like, no warranty.

<div align="center">
<sub>Built out of the very real problem of forgetting how many Claude Code projects were quietly living on an HPC cluster.</sub>
</div>
