# 6. Reuse APIs Before Creating

### Example 1: The Duplicate Endpoint

**User Request:** "Add an endpoint to get a user's active subscription"

**❌ What LLMs Do (Build a Fresh Endpoint)**

```python
# Adds a brand-new route without checking what already exists
@app.route("/users/<id>/active-subscription")
def get_active_subscription(id):
    sub = Subscription.query.filter_by(user_id=id, status="active").first()
    return jsonify(sub.to_dict())
```

**Problems:**
- A `GET /users/<id>/subscriptions?status=active` endpoint already existed
- Now two routes return overlapping data with slightly different shapes
- Clients must learn which one to call; the contract drifts over time

**✅ What Should Happen (Find It First, Then Extend)**

```
Before adding a route, I searched the codebase:

  GET /users/<id>/subscriptions      → exists (lists all)
  GET /users/<id>/subscriptions?status=active  → already supported via filter

The existing endpoint already covers "active subscription" with a query param.
No new API needed — call:

  GET /users/123/subscriptions?status=active

If you specifically want a single-object response, the smallest change is to
document that `?status=active` returns the active one, rather than add a route.
```

### Example 2: Define the Contract in OpenAPI

**User Request:** "We do need a new endpoint to cancel a subscription"

**❌ What LLMs Do (Hand-Roll the Route, No Spec)**

```python
# Route invented ad hoc; request/response shape lives only in code
@app.route("/subscriptions/<id>/cancel", methods=["POST"])
def cancel(id):
    ...
```

**✅ What Should Happen (Spec First, Consistent with Existing APIs)**

```yaml
# openapi.yaml — single source of truth; clients and docs generate from this
paths:
  /subscriptions/{id}/cancel:
    post:
      summary: Cancel a subscription
      parameters:
        - { name: id, in: path, required: true, schema: { type: string } }
      responses:
        "200": { $ref: "#/components/responses/Subscription" }
        "404": { $ref: "#/components/responses/NotFound" }
```

**Reused:** the existing `Subscription` and `NotFound` response components, so the new endpoint matches the contract clients already understand.

