That's an excellent and crucial refinement. If `Omni-Agent-Builder` is to become a truly universal system, it cannot be hardcoded to a single stack. Adding **C#, Python, React, TypeScript/JavaScript**, and especially the **legacy reverse-engineering capability** (to generate "As-Is" documents), makes the platform exponentially more valuable for enterprise migrations and polyglot environments.

I have completely revised the master blueprint. Below is the **updated, comprehensive plan document** with all new sections clearly marked. You can replace your old `blueprint.md` with this version.

---

# Project Blueprint: Omni-Agent-Builder
### *A Polyglot, Extensible Swarm for Building & Reverse-Engineering Software*
*(Powered by OpenCode Swarm | Initial Stack: Rust + Vue.js | Extensible to C#, Python, React, TS/JS)*

---

## 1. Project Overview & Core Philosophy (UPDATED)

- **Objective**: Build a swarm of specialized AI agents that collaboratively create, maintain, and **document** software across multiple technology stacks.
- **The "Omni" Promise**: The architecture is language-agnostic. While we **initially focus on Rust (Backend) + Vue.js (Frontend)**, the agent framework is explicitly designed to spawn specialized sub-agents for **C# (.NET 8+)**, **Python (FastAPI/Django)**, **React**, and **TypeScript/JavaScript** as the system matures.
- **Legacy Intelligence**: A specialized agent will reverse-engineer existing C# and Python codebases, generating comprehensive **"As-Is" Architecture Documents** (ERDs, API maps, dependency graphs) to enable safe migrations and refactoring.
- **Separation of Concerns**: Strictly separates **Decision/History** (1 repo), **UI Design** (1 repo), **Frontend Code** (1+ repos per framework), and **Backend Code** (1+ repos per language).
- **Human-in-the-Loop**: The Orchestrator requires explicit user authorization for: (a) Creating new repositories, (b) Final Rollback decisions, (c) Selecting the target tech stack for a new project.

---

## 2. Technology Stack Strategy

We categorize technology into **Initial Target**, **Extensible Targets**, and **Legacy Targets**.

| Layer | Initial Target | Extensible Targets (Future) | Legacy Reverse-Engineering |
| :--- | :--- | :--- | :--- |
| **Backend** | Rust (Axum/Tokio) | C# (.NET 8+), Python (FastAPI), Node.js (NestJS) | C# (.NET Framework/Core), Python 2/3 |
| **Frontend** | Vue.js 3 (TypeScript) | React (Next.js), Svelte, Angular | Legacy ASP.NET WebForms, jQuery, Django Templates |
| **Database** | PostgreSQL + PostGIS | SQL Server, MongoDB, MySQL | Extracts schema from existing DBs |
| **Cache/Queue** | Redis + RabbitMQ | Azure Service Bus, Kafka | Documents existing queue topology |
| **Orchestration** | OpenCode + Swarm plugin (Provider-agnostic) | | |
| **Local LLM** | Qwen3-Coder-Next 80B (Handles all languages well) | | |
| **Cloud LLMs** | GPT-5.5, Claude Sonnet 4.6 (for architecture/large refactors) | | |

---

## 3. The Master Orchestrator & Configuration

The `orchestrator_config.json` now contains a **`tech_stacks`** object. The Orchestrator uses this to select the correct specialized Coder agent for a given task.

```json
{
  "project_name": "OmniAI_Creator_Meta",
  "repos": {
    "decision_logs": "git@github.com:myorg/decision-logs.git",
    "ui_design": "git@github.com:myorg/ui-repo.git",
    "frontend_vue": "git@github.com:myorg/frontend-vue.git",
    "frontend_react": "git@github.com:myorg/frontend-react.git",
    "backend_rust": "git@github.com:myorg/backend-rust.git",
    "backend_python": "git@github.com:myorg/backend-python.git",
    "backend_csharp": "git@github.com:myorg/backend-csharp.git"
  },
  "tech_stacks": {
    "active": "rust_vue",
    "supported": [
      { "id": "rust_vue", "backend": "rust", "frontend": "vue" },
      { "id": "csharp_react", "backend": "csharp", "frontend": "react" },
      { "id": "python_vue", "backend": "python", "frontend": "vue" }
    ]
  },
  "agents_can_init_repo": false,
  "default_assignee": "@me"
}
```

---

## 4. Detailed Agent Roster (UPDATED & EXPANDED)

We now have **25 specialized agents + 1 Orchestrator**. The new agents are marked with **✨**.

### Layer 1: Strategy & Definition (Unchanged)
| Agent | Input | Output |
| :--- | :--- | :--- |
| **1. Business Interpreter** | User meeting transcripts/briefs | Formal Business Context Document (BCD). |
| **2. Use Case Modeler** | BCD | Visual Use Case diagrams + Basic/Alt/Exception flows. |
| **3. Prioritization Agent** | Use Cases & User urgency | Ranked backlog using MoSCoW. |
| **4. Requirements Writer** | Ranked Backlog | Exhaustive SRS with Acceptance Criteria (AC). |

### Layer 2: Design & Architecture (Updated)
| Agent | Input | Output |
| :--- | :--- | :--- |
| **5. Solution Architect** | NFRs + **Selected Tech Stack** | HLD + Technology Selection Matrix. |
| **6. Data Schema Modeler** | Use Cases + NFRs | ERD + Migration scripts (SQLAlchemy/EF Core/Diesel). |
| **7. API Contract Designer** | Use Cases + Data Schema | OpenAPI/Swagger YAML. |
| **8. UI/UX Designer** | Use Cases + **Target Frontend (Vue/React)** | High-fidelity prototypes + design system tokens. |

### Layer 3: Implementation (The "Builders") - **MAJOR REVISION**
*We now have specialized Coders per language. The Orchestrator routes the task to the correct one based on `tech_stacks.active`.*

| Agent | Specialization | Input | Output |
| :--- | :--- | :--- | :--- |
| **9a. Frontend Engineer (Vue)** | Vue.js 3, Pinia, Vite | UI Prototypes + API Contracts | Vue components + state management. |
| **9b. Frontend Engineer (React)** ✨ | React, Next.js, Redux | UI Prototypes + API Contracts | React components + hooks. |
| **10a. Backend Engineer (Rust)** | Axum, Tokio, Diesel | SRS + API Contracts + ERD | Rust microservices. |
| **10b. Backend Engineer (Python)** ✨ | FastAPI / Django, SQLAlchemy | SRS + API Contracts + ERD | Python REST/GraphQL APIs. |
| **10c. Backend Engineer (C#)** ✨ | .NET 8+, ASP.NET Core, EF Core | SRS + API Contracts + ERD | C# minimal APIs / Controllers. |
| **11. Unit Test Generator** | Framework-specific (Jest, pytest, xUnit, cargo test) | Code diffs + Use Cases | Language-specific test suites. |

### Layer 3.5: Legacy Reverse Engineering (NEW LAYER) - **✨ NEW**
*This is the "As-Is" documentation engine.*

| Agent | Specialization | Input | Output |
| :--- | :--- | :--- | :--- |
| **25a. Legacy Python Analyst** ✨ | Python 2/3 codebases | Path to legacy repo | "As-Is" Markdown: Architecture overview, data flow, class hierarchies, technical debt hotspots. |
| **25b. Legacy C# Analyst** ✨ | .NET Framework / Core | Path to legacy repo (`.sln`) | "As-Is" Markdown: Solution structure, dependency graphs, API endpoint inventory, DB context maps. |
| **25c. Schema Extractor** ✨ | Existing Databases | DB connection string | "As-Is" ERD and data dictionary. |

### Layer 4: Security & Integrity (Unchanged)
| Agent | Input | Output |
| :--- | :--- | :--- |
| **12. SAST Scanner** | PR source code | Security report (OWASP Top 10). |
| **13. DAST Tester** | Staging URL + API Docs | Penetration test report. |
| **14. Dependency Auditor** | Cargo.toml / package.json / requirements.txt / .csproj | List of vulnerable libraries + safe versions. |

### Layer 5: Testing, QA & Performance (Unchanged)
| Agent | Input | Output |
| :--- | :--- | :--- |
| **15. Integration Tester** | API Contracts + Backend | Postman/Cypress suites. |
| **16. Load Simulator** | NFRs (expected concurrent users) | k6/JMeter load test reports. |
| **17. QA Validator** | SRS + Test Suites | Functional QA Sign-off (Pass/Fail). |
| **18. UAT Mimic** | Business Context | Simulated user acceptance feedback. |

### Layer 6: DevOps, Release & Rollback (Unchanged)
| Agent | Input | Output |
| :--- | :--- | :--- |
| **19. Pipeline Engineer** | IaC (Terraform/Docker) | GitHub Actions/GitLab CI YAML files. |
| **20. Rollback Manager** | Production health checks | Generates rollback plan; Blocks execution until human click-to-authorize. |

### Layer 7: Observability (Unchanged)
| Agent | Input | Output |
| :--- | :--- | :--- |
| **21. Logging Strategist** | Security policies + NFRs | Structured logging schema (OpenTelemetry). |
| **22. Alerting Monitor** | SLOs/SLIs | Grafana dashboards + PagerDuty rules. |

### Layer 8: Cross-Cutting Governance (Unchanged)
| Agent | Input | Output |
| :--- | :--- | :--- |
| **23. Traceability Keeper** | All previous artifacts | RTM (Requirements Traceability Matrix). |
| **24. Technical Writer** | Code + API docs | Searchable MkDocs/Confluence wiki. |

---

## 5. The PR Review Automation Loop (Unchanged Logic)
*(The loop remains the same, but the PR-Validator now dynamically runs the correct test runner based on the repo's language—e.g., `cargo test`, `pytest`, or `dotnet test`).*

---

## 6. The Decision Logging Strategy (UPDATED for Legacy)
- **Repo**: `decision-logs`
- **New Use Case**: When the Legacy Python/C# Analyst runs, it creates ADRs titled: **`YYYY-MM-DD-AsIs-Analysis-[ProjectName].md`**. This document becomes the **source of truth** for understanding the legacy system before any new development begins.

**Example "As-Is" ADR Structure:**
```markdown
# ADR: As-Is Analysis - Legacy Billing System (Python)
**Status**: Complete
**Context**: We need to understand the monolithic Django app before migrating to Rust microservices.
**Key Findings**:
- Core Models: 45 tables (PostgreSQL)
- Entry Points: 12 Celery workers, 3 cron jobs.
- Technical Debt: Circular dependency between `orders` and `payments` apps.
**Recommended Migration Path**: Extract `payments` as an independent service first.
```

---

## 7. Local vs. Cloud LLM Allocation (Updated)
| Agent Type | Agent Numbers | Model & Location |
| :--- | :--- | :--- |
| **Orchestrator** | (Master) | **Local** - Qwen3-Coder-Next 80B |
| **All Coding/Review/Testing** | 9a, 9b, 10a, 10b, 10c, 11, 15, 17, 19, 21 | **Local** - Qwen3-Coder-Next 80B |
| **Legacy Reverse Engineers** ✨ | 25a, 25b, 25c | **Local** - Qwen3-Coder-Next (Large context window is excellent for reading huge legacy files). |
| **Security/SAST/DAST** | 12, 13, 14 | **Local** - Specialized Rule Engine + DeepSeek-Coder-V2 Lite |
| **UI/UX Design** | 8 | **Cloud** - Gemini 3 Pro (Multimodal) |
| **Complex Architecture** | 5, 23 | **Cloud** - Claude Sonnet 4.6 / GPT-5.5 |
| **External Search/Librarian** | 24 | **Cloud** - Claude Haiku 4.5 (Cheap & Fast) |

---

## 8. OpenCode Configuration Blueprint (Unchanged)
*OpenCode remains provider-agnostic. The agents will just need the relevant linters/compilers installed in the environment (Rustup, Python venv, .NET SDK, Node).*

---

## 9. Updated Implementation Roadmap (Iterative Phases)

We will build this incrementally, adding polyglot support step-by-step.

- **Phase 0: Foundation**
  - Install OpenCode, Swarm, and required plugins.
  - Create the initial GitHub repos manually (at least 1 Backend + 1 Frontend).
- **Phase 1: The Core Loop (Stack: Rust + Vue)**
  - Build Agents 1-4 (Strategy).
  - Build Agent 9a (Vue) and 10a (Rust).
  - Build the PR-Validator loop.
  - *Validation*: Can the system build a simple "Todo App" in Rust+Vue?
- **Phase 2: Add Legacy Reverse Engineering (NEW)**
  - Build Agents 25a (Python) and 25b (C#).
  - Feed them an open-source legacy project (e.g., a small Django app).
  - *Validation*: Does the agent output a comprehensive "As-Is" ADR with accurate architecture diagrams?
- **Phase 3: Expand the Polyglot Builders**
  - Add Agent 9b (React) and Agents 10b (Python) & 10c (C#).
  - Update Orchestrator to route tasks based on the `tech_stacks.active` flag.
  - *Validation*: The user says "Build this feature in C# + React". Does the Orchestrator automatically select 9b and 10c?
- **Phase 4: Full Production Readiness**
  - Integrate Security (12,13), Load (16), and DevOps (19,20).
  - *Validation*: Full pipeline from legacy document → new feature → deployed microservice.

---

## 10. Updated Open Points for USER Clarification

*To proceed, please clarify these additional points regarding the new polyglot/legacy features:*

1. **Legacy Code Access**: Do you plan to feed the legacy C#/Python codebases directly to the AI via file uploads, or will the agents `git clone` them from private repositories (requiring SSH keys)?
2. **Reverse Engineering Depth**: For the "As-Is" documents, do you want **only** high-level architecture (components and APIs), or do you want **detailed class/method-level** sequence diagrams for critical flows?
3. **Polyglot Migration**: When the system creates a new feature, do you want it to **automatically** pick the stack based on the target repository (e.g., if the repo is C#, it generates C# code), or do you want the Orchestrator to **always ask you** which language to use for each new feature?
4. **Testing Standards**: Should the Unit Test Generator (Agent 11) use the **same language** as the code it is testing, or should it always generate **Python scripts** (e.g., using `pytest` to test C# via HTTP calls)?
5. **LLM Fallback for Legacy**: Legacy codebases often have massive single files. If the local Qwen (80B context) cannot handle the file size, should the Orchestrator automatically escalate the task to Cloud (Claude 200k) or split the file into chunks?

## 11. Where you can find more information?

On this link, that leads to the deepseek session where I planned all, you can check all the questions, answers and conclusions. Please use it at will. [deepseek session discussion](https://chat.deepseek.com/share/fuoleo4hafaiezucdm)