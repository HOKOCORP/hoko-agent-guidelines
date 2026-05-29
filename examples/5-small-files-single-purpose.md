# 5. Small Files, Single Purpose

### Example 1: The Catch-All Module

**User Request:** "Add a user service"

**❌ What LLMs Do (One Giant File)**

```python
# user_service.py — 400+ lines, everything in one place

@dataclass
class User: ...

class UserRepository:
    def get(self, id): ...
    def save(self, user): ...
    def delete(self, id): ...

def validate_user(data): ...
def hash_password(pw): ...

class UserService:
    # business logic
    ...

# Flask routes
@app.route("/users", methods=["POST"])
def create_user(): ...

@app.route("/users/<id>")
def get_user(): ...
```

**Problems:**
- Model, persistence, validation, business logic, and HTTP routes in one file
- An edit to a route forces the agent to load 400 lines it doesn't need
- A small change produces a large, hard-to-review diff

**✅ What Should Happen (One Purpose Per File)**

```
user/
├── model.py        # User dataclass
├── repository.py   # UserRepository (persistence)
├── validation.py   # validate_user, hash_password
├── service.py      # UserService (business logic)
└── routes.py       # Flask routes
```

Each file does one thing. To change a route, the agent opens `routes.py` (~30 lines), not the whole subsystem. Diffs stay small and the change is easy to verify.

**Not a hard limit:** A 60-line file with one cohesive responsibility is fine. Split when a file is doing several jobs at once — not just because it crossed a line count.

