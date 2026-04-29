# Lia — AI Onboarding Liaison

Lia helps software engineers take their first meaningful steps toward agentic engineering.

It interviews you about your current workflow, scans your project environment, and hands you
one concrete, achievable next step — calibrated to where you actually are.

No overwhelm. No hype. Just the highest-leverage door for you, right now.

---

## How It Works

1. **Clone this repo** somewhere on your machine
2. **Open your AI coding agent** inside the `lia/` directory
   - Claude Code: `cd lia && claude`
   - Cursor: open the folder, Cursor reads CLAUDE.md automatically
   - Augment: open the folder, Augment loads the project context
3. **The agent becomes Lia** — it reads CLAUDE.md on boot and starts the interview
4. **Answer Lia's questions** honestly. The more specific, the better.
5. **Run the workspace scan** when Lia asks (takes about 5 seconds):
   ```bash
   bash /path/to/lia/scan/scan.sh /path/to/your/main/project
   ```
6. **Paste the scan output** back to Lia
7. **Get your next step** — one thing, specific to your situation, you can do today

The whole interview takes 10–15 minutes.

---

## What Lia Covers

- Your current development workflow (what you build, how, how often)
- Your experience with AI coding tools — from zero to daily use
- What's already in your environment (scripts, config, AI tooling)
- Where you fall on the adoption curve (Tier 0 through Tier 5)
- The single highest-leverage next move for where you are

---

## The Scan Script

The scan looks at a project directory and reports:

- AI tooling present (CLAUDE.md, .claude/, .augment/, .cursorrules)
- Scripts and automation (scripts/, bin/, Makefile targets)
- Tech stack (package.json, Cargo.toml, go.mod, requirements.txt, etc.)
- Git activity (recent commits, contributors)
- Context and memory files (architecture docs, decision logs, session notes)

Run it against any repo you work in regularly:

```bash
bash scan/scan.sh /path/to/your/project
```

No dependencies. No installs. Plain bash.

---

## Compatible Agents

Works with any agent that reads CLAUDE.md on startup:

- **Claude Code** — reads CLAUDE.md natively, ideal
- **Cursor** — add CLAUDE.md to your rules or open the folder
- **Augment Code** — reads project context files automatically
- **Any agent** that supports project-level instruction files

---

## Philosophy

Lia doesn't push you to go fully agentic overnight.

The adoption curve is real. Most engineers are somewhere between "I tried Copilot once" and
"I delegate whole features." Both are valid starting points. Lia's job is to find the gap between
where you are and where you could reasonably be, then give you the key that fits.

Tier 0 is a blank slate. Tier 5 is running unsupervised workflows and reviewing diffs.
Most engineers reading this are somewhere in the middle — and that's exactly where Lia is most useful.

---

## Part of the Brown Family Harnesses

Lia lives at `harnesses/lia` and is one of a set of workflow harnesses for agentic engineering.
Source: [github.com/parker-brown-family/lia](https://github.com/parker-brown-family/lia)
