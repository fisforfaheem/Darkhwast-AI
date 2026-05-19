# Task Tracker — DarkhwastAI Development

Tracked tasks and implementation milestones completed under the Google Antigravity session.

- [x] Phase 1: Project Scaffolding
  - [x] Create Flutter folder structure
  - [x] Set up dependencies in `pubspec.yaml`
  - [x] Implement global colors (`colors.dart`) and text styles (`text_styles.dart`)
  - [x] Configure GoRouter routes (`app_router.dart`)

- [x] Phase 2: Agent Models & Models Data
  - [x] Define `DocumentEntity` and `DeadlineAlert` Dart classes
  - [x] Define `RightsAnalysis` and `ComplaintDraft` models
  - [x] Implement local JSON assets representing Pakistani billing overcharges

- [x] Phase 3: Orchestration Pipeline
  - [x] Build `AgentPipelineNotifier` using Riverpod
  - [x] Set up sequential pacing state transitions (1.5s delay)
  - [x] Integrate on-device `google_mlkit_text_recognition`
  - [x] Connect `google_generative_ai` for live Gemini 1.5 Pro inferences

- [x] Phase 4: High-Fidelity UI Screens
  - [x] Develop Onboarding and Splash views with animated assets
  - [x] Build Home Screen with active scanning widgets
  - [x] Create sequential Live Agent Trace interface
  - [x] Program dynamic 270° radial gauge inside `HaqDashboardScreen`
  - [x] Design bilingual Complaint draft tabs using RTL Noto Nastaliq Urdu
  - [x] Animate mock portal filing flights and tracking timeline bars

- [x] Phase 5: Reliability & Demos
  - [x] Construct offline Demo Mode toggle inside About tab
  - [x] Write background auto-seeding routines for Firestore
  - [x] Export structured Antigravity audit JSONs in-app
