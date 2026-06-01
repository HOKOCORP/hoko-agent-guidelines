# 8. Finish What You Start

### Example 1: The Silent Placeholder

**User Request:** "Add an endpoint that returns a user's unread notification count."

**❌ What LLMs Do (Stub It and Move On)**

```python
@app.get("/users/{user_id}/notifications/unread-count")
def unread_count(user_id: int):
    # TODO: wire up real query in Phase 2
    # acceptable for now — returns a placeholder
    return {"unread": 0}
```

**Problems:**
- It returns `200 OK` with `0`, so it *looks* finished — the dashboard renders, the demo passes, no test fails loudly.
- The `# Phase 2` comment is the last anyone sees of it; the gap ships and surfaces as "notifications are broken in prod" weeks later.
- A reviewer skimming the diff sees a working endpoint, not an unfinished one.

**✅ What Should Happen (Actually Implement It)**

```python
@app.get("/users/{user_id}/notifications/unread-count")
def unread_count(user_id: int):
    count = db.scalar(
        "SELECT count(*) FROM notifications WHERE user_id = ? AND read_at IS NULL",
        (user_id,),
    )
    return {"unread": count}
```

The work was in scope and small — finish it. Completeness over a placeholder that
hides the gap.

### Example 2: When You Genuinely Can't Finish — Flag It Loudly

**User Request:** "Wire up payment processing for checkout."

Sometimes a piece truly can't be completed now — a credential isn't provisioned,
an upstream API isn't ready, a decision is pending. The rule isn't "never defer."
It's **never defer silently**.

**❌ Buried in a Comment (Gets Forgotten)**

```python
def charge(order):
    # TODO: integrate Stripe later
    return {"status": "paid"}  # pretend it worked
```

This lies to every caller. Checkout reports success while charging nobody.

**✅ Surface the Gap So It Can't Be Missed**

```python
def charge(order):
    # Stripe keys not yet provisioned (BLOCKED on INFRA-412).
    # Fail loudly instead of faking success, so this can't ship unnoticed.
    raise NotImplementedError("Payment processing not wired up — see INFRA-412")
```

And say it in your response, not just the code: *"I stubbed `charge()` to raise
rather than fake a successful payment — it's blocked on Stripe keys (INFRA-412).
That's the one piece I couldn't complete."*

An honest error stops the line; a fake success ships a broken checkout.

**Not a license to expand scope (Principle #2):** finishing what was asked is the
goal — not adding retries, webhooks, or refund logic nobody requested. Complete the
work in scope; flag what you can't; build nothing beyond it.
