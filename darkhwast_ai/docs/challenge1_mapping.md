# Challenge 1 Rubric Mapping — DarkhwastAI

## Problem fit

Challenge 1 requires: **unstructured content → insight → action → simulated execution → outcome**.

DarkhwastAI uses Pakistani government documents as input and files simulated complaints as output.

## System requirements checklist

| Requirement | Implementation | Screen / code |
|-------------|----------------|----------------|
| 1. Content understanding | ML Kit OCR + Gemini classification | Scanner, Agent 1 |
| 2. Insight extraction | HAQ Score, violation type, Rs. owed | HAQ Dashboard, Agent 3 |
| 3. Impact analysis | Impact card + deadline urgency | HAQ Dashboard, Agent 2 |
| 4. Action generation | Urdu/English complaint | Complaint Draft, Agent 4 |
| 5. Action simulation | Portal animation + execution log | Filing, Confirmation |
| 6. Outcome visualization | Before/After + saved cases | Confirmation, Cases tab |
| 7. Agentic workflow | 5 sequential agents with trace | Agent Trace, `/logs` |

## Evaluation criteria (self-assessment)

| Criteria | Weight | How we address it |
|----------|--------|-------------------|
| Agentic reasoning & workflow | 20% | 5 named agents, sequential Live Trace, JSON export |
| Insight & decision quality | 20% | HAQ Score with law citations — not summarization |
| Action simulation & outcome | 15% | Mock API log, case ref, local persistence, before/after |
| Technical implementation | 10% | Riverpod, typed models, offline demo fallback |
| Innovation & UX | 10% | Urdu-first, collective action, ghost deadlines |
| Google Antigravity | 25% | See note below |

### Antigravity (25% rubric)

Per `agents.md` and `docs/antigravity_workflow.md`, this repo was built with **Google Antigravity** (agentic IDE) for scaffolding, the 5-agent pipeline, UI, and trace export. Runtime orchestration is **Riverpod + Gemini 1.5 Pro** inside Flutter — judges inspect reasoning via in-app Agent Trace + Share JSON.

## Firebase (Phase C)

When configured via `flutterfire configure`:

- **Anonymous Auth** on launch
- Cases saved to Firestore `cases` + `followUps` collections
- Collective cluster from seeded `collectiveCases` (live count on join)
- **About** screen shows CLOUD CONNECTED vs LOCAL DEMO MODE

See [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md).

## Demo scenarios

| Scenario | Mock file | Story |
|----------|-----------|-------|
| Electricity | `electricity_bill_response.json` | IESCO FCA overcharge, HAQ 81, collective 29 cases |
| FBR Tax | `tax_notice_response.json` | 4-day hidden deadline, HAQ 55, urgent flow |

Enable via **About → Demo Mode → scenario chip**.

## 3-minute demo script

1. Problem: silent overpayment in Pakistan  
2. Scan → Agent Trace (narrate 5 agents)  
3. HAQ Dashboard: insight + impact + amount  
4. File → Confirmation: execution log + before/after  
5. Cases tab: persisted case  
6. Agent logs for traceability  
