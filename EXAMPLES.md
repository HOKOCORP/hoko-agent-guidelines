# Examples

Real-world code examples demonstrating the six principles. Each example shows what LLMs commonly do wrong and how to fix it.

One file per principle (Principle #5 — Small Files, Single Purpose — applied to the docs themselves):

1. [Think Before Coding](examples/1-think-before-coding.md)
2. [Simplicity First](examples/2-simplicity-first.md)
3. [Surgical Changes](examples/3-surgical-changes.md)
4. [Goal-Driven Execution](examples/4-goal-driven-execution.md)
5. [Small Files, Single Purpose](examples/5-small-files-single-purpose.md)
6. [Reuse APIs Before Creating](examples/6-reuse-apis-before-creating.md)

## Anti-Patterns Summary

| Principle | Anti-Pattern | Fix |
|-----------|-------------|-----|
| Think Before Coding | Silently assumes file format, fields, scope | List assumptions explicitly, ask for clarification |
| Simplicity First | Strategy pattern for single discount calculation | One function until complexity is actually needed |
| Surgical Changes | Reformats quotes, adds type hints while fixing bug | Only change lines that fix the reported issue |
| Goal-Driven | "I'll review and improve the code" | "Write test for bug X → make it pass → verify no regressions" |
| Small Files | Model, persistence, routes, and logic in one 400-line file | One purpose per file; split when a file does several jobs |
| Reuse APIs | Adds a duplicate endpoint without checking what exists | Search first; extend/reuse existing APIs; spec new ones in OpenAPI |

## Key Insight

The "overcomplicated" examples aren't obviously wrong—they follow design patterns and best practices. The problem is **timing**: they add complexity before it's needed, which:

- Makes code harder to understand
- Introduces more bugs
- Takes longer to implement
- Harder to test

The "simple" versions are:
- Easier to understand
- Faster to implement
- Easier to test
- Can be refactored later when complexity is actually needed

**Good code is code that solves today's problem simply, not tomorrow's problem prematurely.**
