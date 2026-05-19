# Implementation Plan — DarkhwastAI

This document outlines the architectural plan, data flow, and specialized agent integrations built during the Google Antigravity Hackathon.

## Goal Description
Build **DarkhwastAI**, Pakistan's first AI-powered citizen rights enforcement engine. The application takes confusing government documents (utility bills, tax notices, rejection letters), extracts numerical slabs, scans for hidden "ghost" deadlines, cross-references on-device OCR data with a Firestore knowledge base of Pakistani laws, calculates legal standing (HAQ Score), drafts bilingual (Urdu/English) complaints, and simulates submission to relevant citizen portal endpoints.

## 1. Core Technical Components

### Component A: Orchestration Pipeline (Riverpod)
- Sequence: Ingest -> Document Intelligence -> Urgency Detector -> Rights Intelligence -> Action Drafter -> Collective Pattern -> Dashboard.
- Pacing: 1.5-second sequential delay to provide high-fidelity visual trace animations on the UI.
- State: Redux-style `PipelineState` capturing loading, complete, facts, and output state per agent.

### Component B: AI & OCR Services
- **OCR:** On-device `google_mlkit_text_recognition` for rapid local text extraction.
- **AI Core:** `google_generative_ai` SDK connecting to Gemini 1.5 Pro / Gemini 2.5 Pro.
- **Mock Fallback:** Scripted local responses inside `assets/mock_responses/` to bypass API limits during offline judging.

### Component C: Firestore Synchronization
- Firestore collections: `cases`, `knowledgeBase`, `collectiveCases`, and `followUps`.
- Seeding: Auto-populate Pakistani consumer protection rules (NEPRA 2021, OGRA 2018, BISP, FBR) on launch.

---

## 2. Agent Workflow Design

```
Raw Text (ML Kit OCR)
       │
       ▼
┌───────────────────────────┐
│ Agent 1: DocIntelligence  ├─► Classifies and parses into DocumentEntity
└─────────────┬─────────────┘
              │
┌─────────────▼─────────────┐
│ Agent 2: UrgencyDetector  ├─► Rule-based deadline scan, triggers 72hr warning
└─────────────┬─────────────┘
              │
┌─────────────▼─────────────┐
│ Agent 3: RightsIntel      ├─► Matches Firestore laws, calculates HAQ Score & refund
└─────────────┬─────────────┘
              │
┌─────────────▼─────────────┐
│ Agent 4: ActionDrafter    ├─► Generates Nastaliq Urdu RTL & formal English letters
└─────────────┬─────────────┘
              │
┌─────────────▼─────────────┐
│ Agent 5: CollectiveEngine ├─► Clusters cases by area, registers follow-up queues
└───────────────────────────┘
```

---

## 3. UI/UX & Styling Specification
- **Theme:** Deep Teal (`#0D3B44`), Warm Amber (`#F5A623`), Off-White (`#F5F4F0`).
- **Typography:** English (`Sora`), Urdu (`Noto Nastaliq Urdu`).
- **Pacing & Polish:** `flutter_animate` triggers for typewriter transitions, custom radial dials, and filing flight animations.

---

## 4. Verification Plan

### Manual Verification Path
1. Launch app -> Tap sparkle logo 5x to trigger Demo Mode.
2. Select IESCO FCA Scenario -> Run Scan.
3. Verify sequential trace cards show matching details.
4. Verify HAQ Dashboard radial dial shows 81/100 and refund of Rs. 1,600.
5. Verify Urdu draft shows elegant Noto Nastaliq RTL text.
6. Verify filing animation and tracking status timelines.
