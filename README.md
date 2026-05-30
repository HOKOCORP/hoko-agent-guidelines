# HOKO Corp — AI Agent Coding Guidelines

HOKO Corp's standard `CLAUDE.md` for AI coding agents — behavioral guidelines that reduce the mistakes agents make most often.

## The Problems

AI coding agents share a recurring set of failure modes:

- **They make wrong assumptions and run with them** — without checking, seeking clarification, surfacing inconsistencies, presenting tradeoffs, or pushing back when they should.
- **They overcomplicate** — bloating code and APIs, adding abstractions nobody asked for, and writing 1000 lines where 100 would do.
- **They cause collateral damage** — changing or removing comments and code they don't fully understand, even when it's orthogonal to the task.

## The Solution

Seven principles in one file that directly address these issues:

| Principle | Addresses |
|-----------|-----------|
| **Think Before Coding** | Wrong assumptions, hidden confusion, missing tradeoffs |
| **Simplicity First** | Overcomplication, bloated abstractions |
| **Surgical Changes** | Orthogonal edits, touching code you shouldn't |
| **Goal-Driven Execution** | Leverage through tests-first, verifiable success criteria |
| **Small Files, Single Purpose** | Large files, context bloat, unreliable edits |
| **Reuse APIs Before Creating** | Duplicate endpoints, redundant APIs, inconsistent contracts |
| **Guard Secrets** | Leaked credentials, secrets in output or commits |

## The Seven Principles in Detail

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

LLMs often pick an interpretation silently and run with it. This principle forces explicit reasoning:

- **State assumptions explicitly** — If uncertain, ask rather than guess
- **Present multiple interpretations** — Don't pick silently when ambiguity exists
- **Push back when warranted** — If a simpler approach exists, say so
- **Stop when confused** — Name what's unclear and ask for clarification

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

Scope: *how much* logic and abstraction you write — not how it's split across files.

Combat the tendency toward overengineering:

- No features beyond what was asked
- No abstractions for single-use code
- No "flexibility" or "configurability" that wasn't requested
- No error handling for impossible scenarios
- If 200 lines could be 50, rewrite it

**The test:** Would a senior engineer say this is overcomplicated? If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting
- Don't refactor things that aren't broken
- Match existing style, even if you'd do it differently
- If you notice unrelated dead code, mention it — don't delete it

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused
- Don't remove pre-existing dead code unless asked

**The test:** Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform imperative tasks into verifiable goals:

| Instead of... | Transform to... |
|--------------|-----------------|
| "Add validation" | "Write tests for invalid inputs, then make them pass" |
| "Fix the bug" | "Write a test that reproduces it, then make it pass" |
| "Refactor X" | "Ensure tests pass before and after" |

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let the LLM loop independently. Weak criteria ("make it work") require constant clarification.

### 5. Small Files, Single Purpose

**Split code across small, single-purpose files. Agents read and edit small files more reliably than large ones.**

Scope: *file and module layout* — not how much code you write.

- One function, component, or module per file — where it doesn't hurt readability
- Split a file once it grows past one clear responsibility
- Large files bloat agent context and produce bigger, riskier diffs
- A recommendation to improve quality, not a hard line limit

### 6. Reuse APIs Before Creating

**Check for an existing API before adding one. Extend or reuse before you build new.**

LLMs reach for a fresh endpoint instead of finding the one that already exists:

- Search for an existing endpoint that already does the job
- If a similar API exists, extend or reuse it instead of duplicating
- Create a new API only when nothing existing can reasonably be extended
- Define HTTP APIs with an OpenAPI spec where possible — a single source of truth for clients and docs

### 7. Guard Secrets

**Never expose credentials. Don't read secret stores unless the task requires it.**

Leaking a secret means rotating it — the cleanup costs far more than the shortcut saved:

- Never print API keys, tokens, passwords, or secret values in output
- Don't read credential files (`.env`, `~/.claude/.credentials.json`, key files) unless the task explicitly needs them
- Don't run `env` / `printenv` to fish for secrets; don't commit secrets or paste them into code
- When you must reference a secret, use its name or a placeholder, not its value

## Install

**Option A: Claude Code Plugin (recommended)**

From within Claude Code, first add the marketplace:
```
/plugin marketplace add HOKOCORP/hoko-agent-guidelines
```

Then install the plugin:
```
/plugin install hoko-agent-guidelines@hoko-agent-guidelines
```

This installs the guidelines as a Claude Code plugin, making the skill available across all your projects.

**Option B: CLAUDE.md (per-project)**

New project:
```bash
curl -o CLAUDE.md https://raw.githubusercontent.com/HOKOCORP/hoko-agent-guidelines/main/CLAUDE.md
```

Existing project (append):
```bash
echo "" >> CLAUDE.md
curl https://raw.githubusercontent.com/HOKOCORP/hoko-agent-guidelines/main/CLAUDE.md >> CLAUDE.md
```

## Using with Cursor

This repository includes a committed Cursor project rule ([`.cursor/rules/hoko-agent-guidelines.mdc`](.cursor/rules/hoko-agent-guidelines.mdc)) so the same guidelines apply when you open the project in Cursor. See **[CURSOR.md](CURSOR.md)** for setup, using the rule in other projects, and how this relates to Claude Code.

## Key Insight

AI agents are exceptionally good at looping until they meet a specific goal. Don't just tell an agent what to do — give it success criteria and let it iterate.

The "Goal-Driven Execution" principle captures this: transform imperative instructions into declarative goals with verification loops.

## How to Know It's Working

These guidelines are working if you see:

- **Fewer unnecessary changes in diffs** — Only requested changes appear
- **Fewer rewrites due to overcomplication** — Code is simple the first time
- **Clarifying questions come before implementation** — Not after mistakes
- **Clean, minimal PRs** — No drive-by refactoring or "improvements"

## Customization

These guidelines are designed to be merged with project-specific instructions. Add them to your existing `CLAUDE.md` or create a new one.

For project-specific rules, add sections like:

```markdown
## Project-Specific Guidelines

- Use TypeScript strict mode
- All API endpoints must have tests
- Follow the existing error handling patterns in `src/utils/errors.ts`
```

## Tradeoff Note

These guidelines bias toward **caution over speed**. For trivial tasks (simple typo fixes, obvious one-liners), use judgment — not every change needs the full rigor.

The goal is reducing costly mistakes on non-trivial work, not slowing down simple tasks.

## License

Licensed under the [MIT License](LICENSE) — © 2026 HOKO CORP LIMITED.

Open source and free to use, modify, and distribute. The one condition: keep the copyright notice and license text in any copy or substantial portion, so HOKO Corp is credited where this is used.
