# Using this repo with Cursor

This project includes a **Cursor project rule** so HOKO Corp's coding guidelines apply automatically when you work here.

## In this repository

1. Open the folder in Cursor.
2. The rule [`.cursor/rules/hoko-agent-guidelines.mdc`](.cursor/rules/hoko-agent-guidelines.mdc) is committed with `alwaysApply: true`, so you do not need extra installation steps.
3. In Cursor, you can confirm it under **Settings → Rules** (or the project rules UI), where `hoko-agent-guidelines` should appear.

## Use the same guidelines in another project

**Cursor (recommended):** Copy `.cursor/rules/hoko-agent-guidelines.mdc` into that project’s `.cursor/rules/` directory (create the folders if needed). Adjust or merge with existing rules as you like.

**Other tools:** If a stack only supports a root instruction file, copy [`CLAUDE.md`](CLAUDE.md) into that project instead (or merge its contents into your existing instructions).

## Optional: personal Agent Skills

If you want the same content as a reusable skill under `~/.cursor/skills`, use [`skills/hoko-agent-guidelines/SKILL.md`](skills/hoko-agent-guidelines/SKILL.md). You can copy or symlink it into your personal skills directory; use whatever layout you use for other skills.

## Claude Code vs Cursor

- **Claude Code:** Install via the plugin marketplace and [`README.md`](README.md) instructions; the plugin exposes the skill from this repo. Per-project use can also rely on `CLAUDE.md`.
- **Cursor:** Use the committed `.cursor/rules/` file as described above. Cursor does not read `.claude-plugin/` or `CLAUDE.md` by default.

## For contributors

When you change the eight principles, update all three auto-loaded instruction files — **[`CLAUDE.md`](CLAUDE.md)**, **[`.cursor/rules/hoko-agent-guidelines.mdc`](.cursor/rules/hoko-agent-guidelines.mdc)**, and **[`skills/hoko-agent-guidelines/SKILL.md`](skills/hoko-agent-guidelines/SKILL.md)** — then run [`scripts/check-sync.sh`](scripts/check-sync.sh) to confirm the principle bodies stay identical. Wire the same script into CI or a pre-commit hook to catch drift automatically.
