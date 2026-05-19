# DarkhwastAI — Agent Orchestration

## Overview

DarkhwastAI implements a **sequential multi-agent pipeline** orchestrated in Flutter using **Riverpod** `StateNotifierProvider`. Each agent has a distinct role, typed inputs/outputs, and traceable reasoning exported as JSON for judges.

```
User Input (photo / voice / PDF)
        │
        ▼
┌───────────────────────────────────────┐
│  AgentPipelineNotifier (Riverpod)     │
│  Sequential execution, 1.5s pacing    │
└───────────────────────────────────────┘
        │
        ├──► Agent 1: Document Intelligence (ML Kit OCR + Gemini / mocks)
        ├──► Agent 2: Urgency Detector (deadline scan, interrupt if ≤4 days)
        ├──► Agent 3: Rights Intelligence (Firestore law KB + Gemini)
        ├──► Agent 4: Action Drafter (bilingual complaint)
        └──► Agent 5: Collective Pattern (Firestore cluster lookup)
        │
        ▼
   HAQ Dashboard → Draft → Simulated Filing → Case saved locally
```

## Tools integrated per agent

| Agent | Tools / services |
|-------|------------------|
| Document Intelligence | `OCRService` (ML Kit), `GeminiService.analyzeDocument`, `MockResponseService` |
| Urgency Detector | Rule-based scan of `DocumentEntity.deadlines` |
| Rights Intelligence | `FirestoreService.getLawKnowledge`, `GeminiService.analyzeRights` |
| Action Drafter | `GeminiService.draftComplaint` |
| Collective Pattern | `FirestoreService.findCollectiveCluster` |

## Trace export

- **In-app:** `/logs` — `LogViewerScreen` with expandable agent cards
- **Share:** `AgentLogExporter.shareLog()` — writes JSON to app documents, opens system share sheet
- **Clipboard:** copy full JSON from log viewer

Trace includes: `run_id`, per-agent `reasoning`, `facts`, structured `output_summary`, and `final_outcome` with case reference after filing.

## Demo vs live

| Mode | Trigger | Behavior |
|------|---------|----------|
| Demo | About → logo 5× | Uses `assets/mock_responses/{scenario}_response.json` |
| Live | Demo off + `GEMINI_API_KEY` | OCR → Gemini, Firestore law lookup |

## Development platform

Built with **Google Antigravity** (agentic IDE) and **Flutter + Riverpod**. Antigravity scaffolded the project, implemented the 5-agent pipeline, UI, demo-mode mocks, and trace export. See [`antigravity_workflow.md`](antigravity_workflow.md) for build phases. Judges can audit runtime reasoning via in-app Agent Trace and Share JSON (`trace_format: antigravity_agent_v1`).
