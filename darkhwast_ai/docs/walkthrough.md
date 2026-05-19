# Technical Walkthrough & Verification — DarkhwastAI

This document provides a technical walkthrough of the core features and verification states for DarkhwastAI.

## 1. Feature Walkthrough

### 1.1 Document Scan & OCR Processing
Upon uploading or capturing a government document, the app passes the file to `google_mlkit_text_recognition`. Once the raw OCR text is extracted, the **Document Intelligence Agent** (Agent 1) processes it via Gemini (or local mock services in Demo Mode) to populate the structured `DocumentEntity` model.

### 1.2 The Sequential Live Agent Trace
The **Live Agent Trace Screen** subscribes to Riverpod's `pipelineProvider`. It sequentially executes the 5 agents with a 1.5-second pacing:
1. **Document Intelligence:** Extracts document type, references, and amounts.
2. **Urgency Detector:** Scans for obscure deadline markers.
3. **Rights Intelligence:** Compares billed values with approved slabs from Firestore laws and computes the **HAQ Score**.
4. **Action Drafter:** Drafts the legal complaint.
5. **Collective Pattern:** Checks for systemic overcharge clusters in the same zip code.

### 1.3 HAQ Score & Details Dashboard
The **HAQ Dashboard** displays:
- A dynamic radial gauge indicating the legal case strength (0-100).
- Information boxes detailing the violation and legal basis.
- The precise amount of refund owed to the customer.
- Systemic collective action options if matching clusters are found in the area.

### 1.4 Bilingual Complaint & Automated Filing Simulation
The citizen reviews the complaint in formal English or beautiful Nastaliq Urdu (rendered RTL). Tapping **File Complaint** triggers a filing sequence representing a portal upload, culminating in a Case Reference ID (e.g. `DW-2026-ISB-XXXX`) and timeline updates.

---

## 2. In-App Validation & Logs
Judges can audit the entire agent reasoning sequence:
- Navigate to **About** -> Tap logo 5x to access Demo scenarios.
- Run any scenario.
- Tap **Agent Trace Dekhein** on the About screen or expand a case in the Tracker to audit step-by-step reasoning outputs.
- Share or copy the complete JSON trace matching the `trace_format: antigravity_agent_v1` specification.
