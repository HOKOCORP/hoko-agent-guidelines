# 7. Guard Secrets

### Example 1: Leaking a Token While Debugging

**User Request:** "The deploy script fails auth — can you debug it?"

**❌ What LLMs Do (Dump the Secret)**

```bash
# Prints the live token straight into the chat transcript
$ env | grep TOKEN
GITHUB_TOKEN=ghp_aB3xK9realsecretvalue
$ echo "Using token: $GITHUB_TOKEN to authenticate"
```

**Problems:**
- The real token is now in the chat log, terminal history, and any screenshot
- `env | grep` scooped up every other secret in the environment too
- A leaked credential must be rotated — the "debug" just created an incident

**✅ What Should Happen (Reference, Don't Reveal)**

```bash
# Confirm the variable is SET without printing its value
$ test -n "$GITHUB_TOKEN" && echo "GITHUB_TOKEN is set (${#GITHUB_TOKEN} chars)" || echo "GITHUB_TOKEN is empty"
GITHUB_TOKEN is set (40 chars)
```

Check presence, length, or prefix — never the value. If auth still fails, the
problem is scope or expiry, which you can reason about without seeing the secret.

### Example 2: Committing Credentials

**User Request:** "Save my API keys so the app can read them"

**❌ What LLMs Do (Hardcode + Commit)**

```python
# config.py — committed to git
ANTHROPIC_API_KEY = "sk-ant-api03-realkey"
STRIPE_SECRET = "sk_live_realkey"
```

**✅ What Should Happen (Keep Them Out of the Repo)**

```python
# config.py — reads from the environment, no secrets in source
import os

ANTHROPIC_API_KEY = os.environ["ANTHROPIC_API_KEY"]
STRIPE_SECRET = os.environ["STRIPE_SECRET"]
```

```bash
# secrets live in .env (git-ignored), never committed
echo ".env" >> .gitignore
```

**Only change what was asked:** store the keys via the environment — don't also
add a secrets manager, rotation logic, or encryption nobody requested (Principle #2).
