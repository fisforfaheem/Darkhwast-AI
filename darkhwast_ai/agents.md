# DarkhwastAI — Complete Project Specification & Antigravity Build Guide
### AISeekho 2026 | Challenge 1: Autonomous Content-to-Action Agent
### Pakistan's First AI-Powered Citizen Rights Enforcement Engine

---

## PART 1: PROJECT OVERVIEW

### Tagline
> *"Apka document. Apka haq. 90 seconds."*

### Problem Statement
Pakistan's Citizens Portal has received 5.46 million complaints in 5 years — mostly
against SNGPL, MEPCO, and BISP. But for every 1 person who files a complaint,
10–15 give up silently. That's 50+ million silent losses per year. Citizens receive
confusing utility bills with hidden overcharges, government notices with buried
deadlines, and rejection letters with no explanation — and have no idea what to do.

DarkhwastAI solves this. Take a photo. Speak in Roman Urdu. The AI reads your
document, detects violations, calculates what you're owed, drafts the complaint,
files it — and follows up automatically.

### Core Differentiators (Never Built Before in Pakistan)
1. **Ghost Deadline Detector** — Hunts for hidden deadlines buried in footnotes/stamps
2. **HAQ Score** — Legal standing index 0–100 with Pakistani law citations
3. **Collective Action Engine** — Clusters similar complaints into group petitions
4. **Autonomous Follow-up** — Agent follows up at 7/14/30 days, escalates if ignored

---

## PART 2: TECHNICAL ARCHITECTURE

### Tech Stack
```
Frontend:       Flutter 3.x (Android + iOS)
State Mgmt:     Riverpod
Backend:        Firebase (Firestore + Cloud Functions + Storage)
AI/Agents:      Google Gemini 1.5 Pro API (via Vertex AI / AI Studio)
OCR:            Google ML Kit (on-device) + Gemini Vision (cloud)
Voice Input:    Flutter Speech-to-Text + Gemini audio processing
Database:       Firestore (mock cases, law knowledge base, complaints)
Auth:           Firebase Anonymous Auth
Notifications:  Firebase Cloud Messaging (follow-up reminders)
```

### Agent Pipeline Architecture
```
USER INPUT (Photo / PDF / Voice)
         │
         ▼
┌─────────────────────────────────────────────────────┐
│  AGENT 1: DocumentIntelligenceAgent                 │
│  • ML Kit OCR extracts raw text                     │
│  • Gemini classifies document type                  │
│  • Extracts: amounts, dates, reference numbers,     │
│    authority name, consumer ID, all dates/numbers   │
│  • Output: DocumentEntity JSON                      │
└──────────────────────┬──────────────────────────────┘
                       │
         ┌─────────────▼─────────────┐
         │  AGENT 2: UrgencyAgent    │  ← FIRES FIRST
         │  • Scans ALL text for     │    if deadline < 3 days
         │    deadline patterns      │    interrupts normal flow
         │  • Ghost deadline hunt:   │
         │    footnotes, stamps,     │
         │    sub-clauses            │
         │  • Output: DeadlineAlert  │
         └─────────────┬─────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│  AGENT 3: RightsIntelligenceAgent                   │
│  • Queries Pakistani law knowledge base (Firestore) │
│  • Laws: OGRA, NEPRA, BISP, FBR, NADRA rules        │
│  • Detects: exact violation, regulation reference   │
│  • Calculates HAQ Score (0–100)                     │
│  • Determines exact amount owed                     │
│  • Output: RightsAnalysis JSON                      │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│  AGENT 4: ActionDrafterAgent                        │
│  • Drafts complaint in Urdu + English               │
│  • Selects correct authority + portal per doc type  │
│  • Auto-fills all required fields                   │
│  • Generates case reference number (mock)           │
│  • Output: ComplaintDraft + SubmissionPayload       │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│  AGENT 5: CollectivePatternAgent                    │
│  • Scans Firestore for similar cases (same          │
│    authority + violation + area)                    │
│  • Detects cluster: "29 similar cases this month"   │
│  • Offers: Join Collective Action                   │
│  • Schedules: follow-up at 7, 14, 30 days           │
│  • Escalates: to ombudsman if no response           │
│  • Output: CollectiveActionOption + Timeline        │
└─────────────────────────────────────────────────────┘
```

### Firestore Collections
```
/documents          — uploaded document metadata
/cases              — filed complaints with status
/collectiveCases    — grouped complaints by pattern
/knowledgeBase      — Pakistani laws, regulations, precedents
/followUps          — scheduled follow-up queue
/mockAuthorities    — mock portal endpoints per authority
```

### Document Types Supported (MVP)
```
1. IESCO/WAPDA Electricity Bill   → NEPRA Consumer Protection Rules 2021
2. SNGPL/SSGC Gas Bill            → OGRA Consumer Protection Regulations 2018  
3. BISP Rejection/Status Letter   → BISP Appeal Procedure Guidelines
4. FBR Income Tax Notice          → Income Tax Ordinance 2001, Section 122
```

---

## PART 3: APP SCREENS & UX FLOW

### Design Language
```
Aesthetic:      Refined authority — trustworthy, clean, Pakistani
Primary:        Deep Teal      #0D3B44
Accent:         Warm Amber     #F5A623  (urgency, action)
Background:     Off-white      #F5F4F0
Surface:        Pure White     #FFFFFF
Urgent/Alert:   Crimson        #D62828
Success:        Forest Green   #2D6A4F
Text Primary:   Near Black     #1C1C2E
Text Secondary: Cool Gray      #64748B
Font (English): Sora (Google Fonts) — clean, modern, not generic
Font (Urdu):    Noto Nastaliq Urdu
```

### Screen 1: SPLASH + ONBOARDING (2 screens)
```
Splash:
  - Animated DarkhwastAI logo (scales in)
  - Tagline: "Apka Haq. AI Ka Kaam."
  - Dark teal background, amber accent

Onboarding (3 cards, swipeable):
  Card 1: "Koi bhi document scan karen"
           Photo of a confusing SNGPL bill
  Card 2: "AI apka haq dhundh leta hai"  
           HAQ Score gauge animating to 84
  Card 3: "Complaint automatic file ho jati hai"
           Mock portal confirmation screen
  → "Shuru Karen" CTA button
```

### Screen 2: HOME
```
Header:
  - "DarkhwastAI" wordmark (top left)
  - Notification bell (top right)
  - Subtitle: "Apna document scan karen"

Hero CTA (center, prominent):
  Large circular scan button with camera icon
  Pulsing amber ring animation
  Label: "Document Scan Karen"

Secondary options (row below):
  [📄 PDF Upload]  [🎙️ Voice Input]

Recent Cases section:
  - List of previous scans with status chips:
    "Pending" (amber) / "Filed" (green) / "Resolved" (teal)
  - Each card: Document type + HAQ Score + date

Stats bar (bottom of scrollable content):
  "29 cases filed this week in Islamabad"
```

### Screen 3: DOCUMENT SCANNER
```
Camera view (full screen) with:
  - Corner guides for document alignment
  - "Document sidha rakhein" hint text
  - Auto-capture when document detected
  - Manual capture button
  
Bottom sheet:
  [Retake] [Upload PDF] [Use This]
```

### Screen 4: LIVE AGENT TRACE (THE SHOWSTOPPER SCREEN)
```
Header: "AI Analysis Chal Rahi Hai..."

5 Agent Cards (vertical list, sequential activation):

  ┌─────────────────────────────────────┐
  │ 🔍 Agent 1: Document Intelligence  │
  │ Status: [ANALYZING...] → [DONE ✓]  │
  │ "IESCO Electricity Bill detected"  │
  │ "Rs. 3,800 FCA charge extracted"   │
  └─────────────────────────────────────┘
  
  ┌─────────────────────────────────────┐  ← AMBER if urgent
  │ ⚠️  Agent 2: Deadline Scanner      │
  │ Status: [SCANNING...] → [DONE ✓]   │
  │ "No urgent deadlines found"         │
  └─────────────────────────────────────┘
  
  ┌─────────────────────────────────────┐
  │ ⚖️  Agent 3: Rights Intelligence   │
  │ Status: [CHECKING LAW...] → [DONE] │
  │ "NEPRA overcharge detected"         │
  │ "HAQ Score: 81/100"                 │
  └─────────────────────────────────────┘
  
  ┌─────────────────────────────────────┐
  │ ✍️  Agent 4: Action Drafter        │
  │ Status: [DRAFTING...] → [DONE ✓]   │
  │ "Complaint drafted in Urdu+English" │
  └─────────────────────────────────────┘
  
  ┌─────────────────────────────────────┐
  │ 🤝 Agent 5: Pattern Engine         │
  │ Status: [SCANNING...] → [DONE ✓]   │
  │ "29 similar cases found"            │
  └─────────────────────────────────────┘

Each card: left border glow animates from gray → teal when active
Completed cards: subtle green checkmark, slightly dimmed
Active card: amber left border pulse
→ Auto-navigates to HAQ Dashboard when all 5 complete
```

### Screen 5: HAQ DASHBOARD (HERO SCREEN)
```
Top Section — HAQ Score:
  Large circular gauge (270° arc)
  Animated fill: 0 → 81 over 1.5 seconds
  Center: "81" large + "/100" small
  Below gauge: "Aapka case mazboot hai" 
  Color: Teal (60–100), Amber (30–59), Red (0–29)

Details Card:
  ┌──────────────────────────────────────────┐
  │  Document Type:  IESCO Electricity Bill  │
  │  Violation:      FCA Overcharge          │
  │  Legal Basis:    NEPRA QTA Circular      │
  │                  May 2025, Section 4(b)  │
  │  Your Slab:      B2 (450 units)          │
  │  Max FCA Allowed: Rs. 2,200              │
  │  Billed FCA:      Rs. 3,800             │
  │  ─────────────────────────────────────   │
  │  AMOUNT OWED:    Rs. 1,600    [AMBER BOX]│
  └──────────────────────────────────────────┘

Deadline Card (if applicable):
  RED border, pulsing
  "⚠️ 4 din baaki hain — Abhi action len"
  Countdown timer

Collective Action Banner:
  Amber background card
  "🤝 29 logon ne isi mahine same complaint ki"
  "Collective action mein shamil hon?"
  [Shamil Hoon] [Akela File Karen]

CTA Buttons:
  Primary:   [Complaint File Karen] — Teal, full width
  Secondary: [Draft Dekhein] — outlined
```

### Screen 6: COMPLAINT DRAFT VIEWER
```
Tabs: [Urdu] [English]

Urdu draft (Noto Nastaliq font, RTL):
  Shows full complaint letter with:
  - Citizen details (mock/anonymous)
  - Violation description
  - Amount claimed
  - Legal reference
  - Request for refund
  
English version mirrors the same.

[Edit] button — allows manual edits
[Confirm & File] — proceeds to submission
```

### Screen 7: FILING + CONFIRMATION
```
Filing animation:
  Document icon flies toward portal icon
  Progress bar: "Citizens Portal ko submit ho raha hai..."

Confirmation screen:
  ✅ Green checkmark (animated)
  "Complaint File Ho Gayi!"
  
  Case Reference: DW-2026-ISB-4521
  Authority: NEPRA / Citizens Portal
  Filed: [Today's date]
  Expected Response: 14 working days
  
  Follow-up Schedule:
  📅 7 days:  Auto reminder
  📅 14 days: Status check
  📅 30 days: Escalation if no response
  
  If collective: "Aap 30 logon ke saath file kiya"
  
  [Share Receipt] [Track Case] [Home]
```

### Screen 8: CASE TRACKER
```
Timeline view per case:
  ● Complaint Filed (Day 0) ✅
  ○ Department Review (Day 7) — Pending
  ○ Response Due (Day 14)
  ○ Resolution (Day 30)
  
Status updates with timestamps
If overdue: Red dot + "Escalation triggered"
```

---

## PART 4: MOCK KNOWLEDGE BASE DATA

### Pakistani Law Entries (Firestore: /knowledgeBase)
```json
{
  "NEPRA_FCA_2025": {
    "authority": "NEPRA",
    "regulation": "Quarterly Tariff Adjustment Circular May 2025",
    "section": "4(b)",
    "rule": "FCA charges cannot exceed approved rate per consumption slab",
    "slabs": {
      "B1_0_100": {"maxFCA": 800},
      "B1_101_200": {"maxFCA": 1200},
      "B1_201_300": {"maxFCA": 1600},
      "B2_301_500": {"maxFCA": 2200},
      "B2_500plus": {"maxFCA": 3100}
    },
    "complaintAuthority": "NEPRA Consumer Affairs",
    "complaintPortal": "complaints.nepra.org.pk (mock)",
    "responseWindow": 14
  },
  "OGRA_SNGPL_2018": {
    "authority": "OGRA",
    "regulation": "OGRA Consumer Protection Regulations 2018",
    "section": "12(a)",
    "rule": "Meter reading must match actual reading within 5% variance",
    "complaintAuthority": "OGRA Complaint Cell",
    "responseWindow": 21
  },
  "BISP_APPEAL_2023": {
    "authority": "BISP",
    "regulation": "BISP Grievance Redressal Mechanism 2023",
    "section": "Section 6",
    "rule": "Every rejected applicant has right to appeal within 60 days",
    "complaintAuthority": "BISP Tehsil Office + Portal",
    "responseWindow": 30
  },
  "FBR_122_2001": {
    "authority": "FBR",
    "regulation": "Income Tax Ordinance 2001",
    "section": "122",
    "rule": "Assessment notice must be responded to within 30 days",
    "complaintAuthority": "FBR Facilitation Center",
    "responseWindow": 7,
    "urgency": "HIGH"
  }
}
```

### Mock Collective Cases (Firestore: /collectiveCases)
```json
{
  "cluster_IESCO_FCA_ISB_May2026": {
    "authority": "IESCO",
    "violationType": "FCA_Overcharge",
    "area": "Islamabad",
    "month": "May 2026",
    "count": 29,
    "status": "Open",
    "collectivePetitionDrafted": true
  }
}
```

---

## PART 5: GEMINI PROMPTS (Used Inside Flutter/Cloud Functions)

### Agent 1 — Document Intelligence Prompt
```
You are a document analysis agent for Pakistani government documents.

Analyze this document text and return ONLY valid JSON with this exact structure:
{
  "documentType": "ELECTRICITY_BILL | GAS_BILL | BISP_LETTER | TAX_NOTICE | COURT_NOTICE | UNKNOWN",
  "authority": "string (e.g. IESCO, SNGPL, BISP, FBR)",
  "consumerRef": "string or null",
  "amounts": [{"label": "string", "amount": number, "currency": "PKR"}],
  "dates": [{"label": "string", "date": "YYYY-MM-DD or null"}],
  "deadlines": [{"label": "string", "date": "YYYY-MM-DD", "daysRemaining": number, "isHidden": boolean}],
  "keyFacts": ["string array of 3-5 critical extracted facts"],
  "rawAmountsBilled": {"total": number, "breakdown": {}}
}

Document text: {EXTRACTED_TEXT}
```

### Agent 3 — Rights Intelligence Prompt
```
You are Pakistan's citizen rights legal AI. You know NEPRA, OGRA, BISP, FBR,
NADRA regulations precisely.

Given this document analysis:
{DOCUMENT_ENTITY_JSON}

And this law knowledge entry:
{RELEVANT_LAW_JSON}

Return ONLY valid JSON:
{
  "violationDetected": boolean,
  "violationType": "string",
  "legalBasis": "exact regulation name + section",
  "maxAllowed": number,
  "actualCharged": number,
  "amountOwed": number,
  "haqScore": number (0-100, based on strength of legal case),
  "haqReasoning": "1-2 sentences explaining the score in simple Urdu-friendly language",
  "precedents": "string describing similar resolved cases",
  "confidenceLevel": "HIGH | MEDIUM | LOW"
}
```

### Agent 4 — Complaint Drafter Prompt
```
You are a complaint drafting agent for Pakistani citizens.

Write a formal complaint letter based on:
Document: {DOCUMENT_TYPE}
Authority to complain to: {COMPLAINT_AUTHORITY}
Violation: {VIOLATION_TYPE}  
Amount owed: Rs. {AMOUNT_OWED}
Legal basis: {LEGAL_BASIS}
Consumer reference: {CONSUMER_REF}
Date: {TODAY_DATE}

Return ONLY valid JSON:
{
  "urduDraft": "Full complaint letter in formal Urdu (Nastaliq-compatible)",
  "englishDraft": "Full complaint letter in formal English",
  "subject": "Subject line in English",
  "submissionAuthority": "Authority name",
  "submissionPortal": "Portal name (mock URL)",
  "estimatedResponseDays": number
}

Make it professional, cite the specific law section, state the exact amount claimed.
Do NOT use placeholder brackets in the output — use actual values.
```

---

## PART 6: ANTIGRAVITY MASTER PROMPT

Feed this ONCE at the start of your Antigravity session as the project context.

```
═══════════════════════════════════════════════════════════════
DARKHWASTAI — MASTER CONTEXT PROMPT
═══════════════════════════════════════════════════════════════

PROJECT: DarkhwastAI — Pakistan's AI Citizen Rights Enforcement Engine
HACKATHON: AISeekho 2026 (Google Antigravity, Telenor, MoIT)
CHALLENGE: Challenge 1 — Autonomous Content-to-Action Agent

WHAT THIS APP DOES:
User takes a photo of any Pakistani government document (electricity
bill, gas bill, BISP letter, tax notice). A 5-agent AI pipeline reads
it, detects rights violations, calculates the HAQ Score (legal standing
0-100), drafts a complaint in Urdu and English, simulates filing it to
a mock Citizens Portal, and clusters similar complaints into collective
actions.

TECH STACK:
- Flutter 3.x (Dart), targeting Android + iOS
- State management: Riverpod (flutter_riverpod)
- Backend: Firebase (Firestore, Cloud Functions, Storage, Auth)
- AI: Google Gemini 1.5 Pro via google_generative_ai Flutter package
- OCR: google_mlkit_text_recognition (on-device)
- Voice: speech_to_text package
- Fonts: Sora (English), Noto Nastaliq Urdu (Urdu text)
- All fonts loaded via Google Fonts package

DESIGN SYSTEM:
- Primary:    #0D3B44 (Deep Teal)
- Accent:     #F5A623 (Amber)
- Background: #F5F4F0 (Warm Off-White)
- Surface:    #FFFFFF
- Urgent:     #D62828 (Crimson)
- Success:    #2D6A4F (Forest Green)
- Text:       #1C1C2E (Near Black)
- TextSub:    #64748B (Cool Gray)
- Font scale: Display 28sp, Headline 22sp, Body 16sp, Caption 13sp
- Radius: 16dp cards, 12dp buttons, 24dp FAB
- NO Material default blue anywhere. Replace ALL default Flutter
  blue with #0D3B44

ARCHITECTURE PATTERN:
- Feature-first folder structure
- Riverpod StateNotifierProvider for each agent
- Repository pattern for Firestore + Gemini calls
- All Gemini calls return typed Dart models (never raw strings)
- Firebase mock data seeded in a seed_data.dart file

CORE MODELS (Dart classes needed):
- DocumentEntity (type, authority, amounts, dates, deadlines, keyFacts)
- DeadlineAlert (label, date, daysRemaining, isHidden, urgencyLevel)
- RightsAnalysis (violationDetected, legalBasis, haqScore, amountOwed,
  haqReasoning, confidenceLevel)
- ComplaintDraft (urduDraft, englishDraft, subject, authority, portal,
  estimatedResponseDays)
- CollectiveCluster (authority, violationType, area, count, status)
- CaseEntity (id, documentEntity, rightsAnalysis, complaintDraft,
  status, filedDate, followUpDates)

AGENT PIPELINE FLOW:
Input → Agent1(DocIntelligence) → Agent2(UrgencyDetector) →
Agent3(RightsIntelligence) → Agent4(ActionDrafter) →
Agent5(CollectivePattern) → Output

Each agent emits AgentState: idle | loading | complete | error
The UI Live Trace screen subscribes to all 5 AgentState streams
and animates accordingly.

FOLDER STRUCTURE TO CREATE:
lib/
  core/
    constants/        (colors.dart, text_styles.dart, app_theme.dart)
    models/           (all Dart model classes)
    services/         (gemini_service.dart, firestore_service.dart,
                       ocr_service.dart, voice_service.dart)
  features/
    onboarding/       (screens + widgets)
    home/             (screens + widgets)
    scanner/          (screens + widgets)
    agent_trace/      (screens + widgets)
    haq_dashboard/    (screens + widgets)
    complaint/        (screens + widgets)
    confirmation/     (screens + widgets)
    case_tracker/     (screens + widgets)
  shared/
    widgets/          (reusable components)
  main.dart
  firebase_options.dart (generated)

MOCK DATA BEHAVIOR:
Since this is a hackathon demo, Gemini calls happen ONCE on initial
pipeline run. Results are stored in Firestore. Mock authorities and
law knowledge base are pre-seeded. The Citizens Portal submission
is fully simulated — it generates a fake case reference number
(format: DW-2026-ISB-XXXX) and stores it in Firestore.

IMPORTANT RULES:
1. NEVER use default Flutter blue anywhere in the UI
2. ALL text in agent trace must appear with a typewriter animation
3. HAQ Score gauge must animate from 0 to final value on load
4. Agent cards activate SEQUENTIALLY, not simultaneously
5. Urdu text must always use Noto Nastaliq Urdu font, RTL alignment
6. All Gemini API calls must have try/catch with user-friendly errors
7. The app must run WITHOUT internet for the demo if needed
   (fallback to pre-seeded mock responses in assets/mock_responses/)
8. Every screen must have a loading state, error state, empty state

GEMINI API KEY HANDLING:
Store in Flutter --dart-define or .env, never hardcode in source.
Use: const apiKey = String.fromEnvironment('GEMINI_API_KEY');

═══════════════════════════════════════════════════════════════
```

---

## PART 7: SEQUENTIAL BUILD PROMPTS FOR ANTIGRAVITY

Feed these ONE BY ONE. Wait for each task to complete before sending the next.

---

### PROMPT 1 — Project Setup & Architecture

```
TASK 1: Project Foundation

Using the master context already provided, do the following:

1. Create a new Flutter project named 'darkhwast_ai'
2. Update pubspec.yaml with ALL required dependencies:
   - flutter_riverpod: ^2.5.1
   - google_generative_ai: ^0.4.3
   - firebase_core, firebase_auth, cloud_firestore, firebase_storage
   - google_mlkit_text_recognition: ^0.13.0
   - speech_to_text: ^6.6.2
   - google_fonts: ^6.2.1
   - image_picker: ^1.1.2
   - camera: ^0.10.5
   - percent_indicator: ^4.2.3  (for HAQ gauge)
   - lottie: ^3.1.2
   - flutter_animate: ^4.5.0
   - intl: ^0.19.0
   - uuid: ^4.4.0
   - path_provider: ^2.1.3

3. Create the COMPLETE folder structure as defined in master context

4. Create lib/core/constants/colors.dart with ALL color constants
   (exact hex values from master context, as static const Color)

5. Create lib/core/constants/text_styles.dart using Sora font for
   English. Define: displayStyle, headlineStyle, titleStyle,
   bodyStyle, captionStyle, urgentStyle (crimson, bold)

6. Create lib/core/constants/app_theme.dart — full Material ThemeData
   with the design system. useMaterial3: true. Override ALL default
   blue to #0D3B44. Custom ColorScheme. Custom card theme with 16dp
   radius. Custom elevated button theme (teal, white text, 12dp radius)

7. Create ALL Dart model classes in lib/core/models/:
   - document_entity.dart
   - deadline_alert.dart
   - rights_analysis.dart
   - complaint_draft.dart
   - collective_cluster.dart
   - case_entity.dart
   Each must have: fromJson, toJson, copyWith methods

8. Create lib/main.dart with ProviderScope wrapping, Firebase
   initialization, app theme applied, and route to SplashScreen

9. Create assets/mock_responses/ folder with 4 JSON files:
   - electricity_bill_response.json
   - gas_bill_response.json
   - bisp_letter_response.json
   - tax_notice_response.json
   Each containing fully pre-filled mock responses for ALL 5 agents
   (realistic Pakistani data, not placeholder text)

10. Seed the mock_responses JSONs with realistic data:
    electricity_bill should show:
    - IESCO bill, Rs. 3,800 FCA charged, Rs. 2,200 max allowed
    - Rs. 1,600 amount owed, HAQ Score 81
    - Collective cluster: 29 similar cases, Islamabad, May 2026
    
Run flutter pub get and verify zero errors before completing.
```

---

### PROMPT 2 — Core Services Layer

```
TASK 2: Services Layer

Create the following service files. Each must be a clean class with
dependency injection support via Riverpod Provider.

1. lib/core/services/gemini_service.dart
   - GeminiService class
   - Method: analyzeDocument(String extractedText) → DocumentEntity
   - Method: analyzeRights(DocumentEntity doc, Map lawEntry) → RightsAnalysis
   - Method: draftComplaint(RightsAnalysis analysis, DocumentEntity doc) → ComplaintDraft
   - Each method builds the EXACT prompt from the spec, calls Gemini
     1.5 Pro, parses JSON response into typed model
   - CRITICAL: if GEMINI_API_KEY env var is empty, return mock
     response from assets/mock_responses/ instead
   - All methods: async, try/catch, throw typed GeminiException on fail

2. lib/core/services/ocr_service.dart
   - OcrService class
   - Method: extractText(File imageFile) → String
   - Uses google_mlkit_text_recognition
   - Preprocesses: normalizes whitespace, handles Urdu/English mixed

3. lib/core/services/firestore_service.dart
   - FirestoreService class
   - Method: seedKnowledgeBase() — seeds /knowledgeBase collection
     with the 4 Pakistani law entries from the spec
   - Method: seedCollectiveCases() — seeds /collectiveCases
   - Method: saveCase(CaseEntity) → String (case ID)
   - Method: getCases() → Stream<List<CaseEntity>>
   - Method: findCollectiveCluster(String authority, String violationType)
     → CollectiveCluster?
   - Method: joinCollectiveCase(String clusterId, String caseId) → void
   - Method: scheduleFollowUps(String caseId) — creates follow-up docs
     at +7, +14, +30 days from now

4. lib/core/services/voice_service.dart
   - VoiceService class
   - Method: startListening(Function(String) onResult) → void
   - Method: stopListening() → void
   - Supports Roman Urdu, Urdu, English via speech_to_text
   - Returns transcribed text to caller

5. Create Riverpod providers for ALL services in
   lib/core/providers/service_providers.dart
   Use Provider<GeminiService>, Provider<OcrService>, etc.
```

---

### PROMPT 3 — Agent Pipeline State Management

```
TASK 3: Agent Pipeline with Riverpod

Create the full agent pipeline state management system.

1. Create lib/core/models/agent_state.dart:
   Enum AgentStatus { idle, loading, complete, error }
   
   Class AgentState<T> {
     final AgentStatus status;
     final T? result;
     final String? agentMessage; // shown in trace UI
     final String? errorMessage;
   }

2. Create lib/features/agent_trace/providers/agent_pipeline_provider.dart

   Create AgentPipelineNotifier extends StateNotifier<AgentPipelineState>
   
   AgentPipelineState holds:
   - agent1State: AgentState<DocumentEntity>
   - agent2State: AgentState<List<DeadlineAlert>>
   - agent3State: AgentState<RightsAnalysis>
   - agent4State: AgentState<ComplaintDraft>
   - agent5State: AgentState<CollectiveCluster?>
   - overallStatus: PipelineStatus (idle/running/complete/error)
   
   Method: runPipeline(File documentImage) — runs all 5 agents
   SEQUENTIALLY (not parallel). Each agent must COMPLETE before
   next starts. Uses 800ms artificial delay between agents for
   demo effect. Updates each AgentState as it runs.
   
   Message strings to use per agent (shown in trace UI):
   Agent 1 messages: 
     loading → "Document scan ho rahi hai..."
     complete → "Document identify ho gaya: {documentType}"
   Agent 2 messages:
     loading → "Deadlines dhundh raha hai..."
     complete → "Koi urgent deadline nahi mili" OR "⚠️ {N} din baaki!"
   Agent 3 messages:
     loading → "Pakistani qanoon se match kar raha hai..."
     complete → "HAQ Score: {score}/100 — {violationType}"
   Agent 4 messages:
     loading → "Complaint draft ho rahi hai..."
     complete → "Complaint tayyar — Urdu + English mein"
   Agent 5 messages:
     loading → "Similar cases dhundh raha hai..."
     complete → "{N} similar cases mile — Collective action mumkin"
   
3. Create agentPipelineProvider as StateNotifierProvider

4. Create individual computed providers:
   - documentEntityProvider → derived from pipeline state
   - rightsAnalysisProvider → derived from pipeline state
   - complaintDraftProvider → derived from pipeline state
   - hasUrgentDeadlineProvider → bool, computed
   - collectiveClusterProvider → derived from pipeline state
```

---

### PROMPT 4 — Splash, Onboarding & Home Screens

```
TASK 4: Splash + Onboarding + Home Screens

Build these 3 screens with full animations. NO placeholder widgets.
Every screen must be pixel-perfect per the design spec.

1. lib/features/onboarding/screens/splash_screen.dart
   - Deep teal (#0D3B44) full-screen background
   - Center: DarkhwastAI logo (stylized text, Sora font, white)
   - Below: amber line divider (2dp, animated width 0→80% in 600ms)
   - Below: "Apka Haq. AI Ka Kaam." caption (white, fade in at 800ms)
   - Auto-navigates to OnboardingScreen after 2.5 seconds
   - Uses flutter_animate for all animations

2. lib/features/onboarding/screens/onboarding_screen.dart
   - PageView with 3 pages, dot indicators (amber active)
   - Page 1: Scan icon + "Koi bhi document scan karen"
   - Page 2: HAQ gauge (animated, plays on page enter) + rights text
   - Page 3: Checkmark animation + "Complaint automatic file ho jati"
   - "Shuru Karen" CTA button on last page → HomeScreen
   - "Skip" text button top-right
   - Background: off-white #F5F4F0
   - Uses SharedPreferences to skip onboarding on return visits

3. lib/features/home/screens/home_screen.dart
   - AppBar: "DarkhwastAI" title (Sora, teal), bell icon
   - Subtitle text: "Apna haq janein, apna haq len"
   
   HERO SCAN BUTTON (center, below subtitle):
   - 120dp circle, teal background
   - Camera icon (white, 40dp)
   - AMBER pulsing ring animation (2 rings, opacity fades out,
     repeating, using flutter_animate)
   - "Document Scan Karen" label below
   
   Secondary row: [PDF Upload card] [Voice Input card]
   Both: 70dp height, outlined style, icons, labels
   
   Stats Card:
   - Amber left border (4dp)
   - "Islamabad mein is hafte 29 complaints file huin"
   - Small chart or icon
   
   Recent Cases List:
   - Each CaseCard widget: document type icon, authority name,
     HAQ score chip (colored), date, status chip
   - If empty: illustration + "Abhi koi case nahi. Scan karen!"
   
   FAB: not needed (hero button serves this purpose)
   
   Bottom NavBar: Home | Cases | Settings
   (simple, teal active indicator, no labels on inactive)
```

---

### PROMPT 5 — Document Scanner Screen

```
TASK 5: Document Scanner Screen

Build lib/features/scanner/screens/scanner_screen.dart

This screen has 3 modes: CAMERA, UPLOAD, VOICE

1. CAMERA MODE (default):
   - Full-screen camera preview using camera package
   - Overlay: 4 corner brackets (white, 2dp stroke) forming a
     document guide rectangle (80% width, 60% height of screen)
   - Hint text below brackets: "Document ko rectangle mein rakhein"
   - Auto-detect: when document fills 70%+ of guide area,
     amber border animates and "Capture" button pulses
   - Capture button: bottom center, 70dp circle, amber
   - "Switch to Upload" text button at bottom
   
2. UPLOAD MODE (sheet slides up on tap):
   - image_picker.ImageSource.gallery
   - Shows selected image preview with crop handles
   - "Confirm" button → triggers pipeline
   
3. VOICE MODE:
   - Waveform animation (4-5 bars, bouncing to audio amplitude)
   - Status text: "Bol rahe hain..." / "Processing..."
   - Voice transcribed text appears below waveform
   - Stop button → text forwarded to pipeline as document description
   
4. On image capture/confirm:
   - Run OcrService.extractText() on the image
   - Show brief "Reading document..." overlay (0.5 second)
   - Navigate to AgentTraceScreen, passing the File and extracted text

5. Handle permissions gracefully:
   - Camera permission: show custom permission dialog (teal themed)
   - If denied: show "Camera zaroor hai" with Settings button
```

---

### PROMPT 6 — Live Agent Trace Screen (SHOWSTOPPER)

```
TASK 6: Agent Trace Screen — This is the most important screen.

Build lib/features/agent_trace/screens/agent_trace_screen.dart

This screen starts the Antigravity pipeline and shows each agent
firing in real-time. It must be visually stunning for the demo.

LAYOUT:
- Dark background: #0D3B44 (deep teal) — makes amber/green pop
- Top: "AI Soch Rahi Hai..." title (white, Sora, 22sp)
- Subtitle: typewriter animation of current agent message

AGENT CARDS (5 stacked vertical, each 100dp height):
Each AgentCard widget takes:
  - agentNumber: int
  - icon: IconData
  - title: String
  - AgentState status

Visual states per card:
  IDLE:
  - Gray left border (4dp)
  - Dimmed (opacity 0.4)
  - Icon: gray
  
  LOADING (active):
  - AMBER left border (4dp) with animated brightness pulse
  - Full opacity
  - Icon: amber, rotating subtly
  - Message text: typewriter animation character by character
  - Right side: animated dots "..."
  
  COMPLETE:
  - TEAL left border (4dp)
  - Full opacity, slight green tint on background
  - Icon: replaced with ✓ (animated scale-in)
  - Message text: final message, static
  - Right: timestamp "2.3s"
  
  ERROR:
  - RED border, error icon, error message

AGENT ICONS to use:
  Agent 1: Icons.document_scanner
  Agent 2: Icons.timer_outlined
  Agent 3: Icons.balance
  Agent 4: Icons.edit_note
  Agent 5: Icons.group

BOTTOM SECTION (appears after all 5 complete):
  - Animated slide-up white card
  - Large green ✓ with "Analysis Mukammal!"
  - HAQ Score preview: "HAQ Score: 81/100"
  - "Details Dekhein →" button (amber)
  
BEHAVIOR:
  - On screen init: call agentPipelineNotifier.runPipeline(file)
  - Subscribe to agentPipelineProvider
  - Each state change triggers the card animation
  - Cards activate one by one — never all at once
  - After pipeline complete: auto-navigate to HaqDashboardScreen
    after 1.5 second delay (so user sees the completion state)

The overall feeling should be like watching a smart AI genuinely
think through your problem. This is the demo money shot.
```

---

### PROMPT 7 — HAQ Dashboard Screen

```
TASK 7: HAQ Dashboard Screen

Build lib/features/haq_dashboard/screens/haq_dashboard_screen.dart

This is the results hero screen. Clean, confident, information-rich.

BACKGROUND: Off-white #F5F4F0

SECTION 1 — HAQ SCORE GAUGE:
  - CircularPercentIndicator (percent_indicator package)
  - Radius: 90dp, lineWidth: 14dp
  - Animate from 0.0 → (haqScore/100) over 1500ms on screen enter
  - Color based on score:
    80–100: #2D6A4F (forest green) 
    50–79:  #F5A623 (amber)
    0–49:   #D62828 (crimson)
  - Center content:
    Big number (score, 48sp, bold, Sora)
    "/100" (20sp, gray)
    Below: "{haqReasoning}" in 13sp gray
  - Below gauge:
    "Aapka case {strength}" — strength text computed from score:
    80+: "mazboot hai ✓"
    50-79: "theek hai"
    <50: "kamzor hai"

SECTION 2 — DETAIL CARD:
  White surface card, 16dp radius, subtle shadow
  Rows with icon + label + value:
  📄 Document:    IESCO Electricity Bill
  🏛️  Authority:  NEPRA
  ⚖️  Violation:  FCA Overcharge
  📋 Legal Basis: NEPRA QTA May 2025 §4(b)
  ─────────────────────────────────
  💰 Max Allowed: Rs. 2,200
  💸 Billed:      Rs. 3,800
  ─────────────────────────────────
  → "Aapko mila: Rs. 1,600" — amber background highlight row

SECTION 3 — DEADLINE CARD (conditional, only if deadline exists):
  Crimson border card, pulsing
  ⚠️  "{N} din baaki hain"
  CountdownTimer widget (days:hours:mins)
  "Fauran action len" — bold text

SECTION 4 — COLLECTIVE ACTION BANNER:
  Amber background card, 16dp radius
  Left: 🤝 icon in circle
  Title: "29 logon ne same complaint ki"
  Subtitle: "Mil kar file karen — zyada asar hoga"
  [Shamil Hoon] [Akela File Karen] — side by side buttons

SECTION 5 — ACTION BUTTONS:
  Primary: "Complaint File Karen" — full width, teal, 56dp height
  Secondary: "Draft Dekhein" — outlined, teal text

All sections animate in with staggered fade+slide-up (100ms apart)
using flutter_animate.
```

---

### PROMPT 8 — Complaint Draft & Filing + Confirmation

```
TASK 8: Complaint Draft, Filing & Confirmation Screens

BUILD 3 SCREENS:

━━━ SCREEN A: ComplaintDraftScreen ━━━
lib/features/complaint/screens/complaint_draft_screen.dart

- AppBar: "Aapki Darkhwast" with edit icon
- TabBar: [اردو] [English] — custom styled tabs (teal indicator)

URDU TAB:
  - RTL aligned text
  - Noto Nastaliq Urdu font, 16sp
  - Shows full formal complaint letter
  - Scrollable
  - All values filled from ComplaintDraft model (no placeholders)

ENGLISH TAB:
  - LTR, Sora font
  - Same letter in English

Bottom info bar:
  "Filed to: {authority}" | "{portal}"

CTA: "Confirm aur File Karen" — teal full-width button
  Tapping this → navigate to FilingScreen

━━━ SCREEN B: FilingScreen ━━━
lib/features/confirmation/screens/filing_screen.dart

- Full screen teal background
- Center: animated paper airplane flying toward a portal icon
  (use Lottie animation or Flutter animation — not a static icon)
- Text below: "Citizens Portal ko submit ho raha hai..."
- Progress indicator: animated progress bar (amber)
- After 2.5 second simulation: auto-navigate to ConfirmationScreen

If user joined collective action: 
  Show "30 logon ke saath file ho rahi hai..." instead

━━━ SCREEN C: ConfirmationScreen ━━━
lib/features/confirmation/screens/confirmation_screen.dart

- Animated green checkmark (scale + fade, 600ms)
- "Complaint File Ho Gayi!" headline

Case Reference Card (teal left border):
  Case Ref:     DW-2026-ISB-{4 random digits}
  Authority:    NEPRA Citizens Portal  
  Filed:        {today date}
  Amount Owed:  Rs. {amount}
  Expected:     14 working days

Follow-up Timeline (horizontal or vertical):
  ● Day 0  — Filed ✓
  ○ Day 7  — Auto reminder (pending)
  ○ Day 14 — Status check (pending)
  ○ Day 30 — Escalation if no response

If collective:
  Amber card: "Aap 30 logon ke saath case mein hain"

Buttons:
  [Receipt Share Karen] — shares case details as text
  [Case Track Karen] — navigates to CaseTrackerScreen
  [Ghar Jao] — pops to HomeScreen
```

---

### PROMPT 9 — Case Tracker & Settings + Navigation

```
TASK 9: Case Tracker, Navigation Shell & Polish

1. BUILD CaseTrackerScreen
   lib/features/case_tracker/screens/case_tracker_screen.dart
   
   - Loads all cases from FirestoreService.getCases() stream
   - Each case shown as CaseCard (expandable)
   - CaseCard expanded shows:
     Timeline widget — vertical dotted line with milestone dots
     Each milestone: icon, label, date (if passed) or "Pending"
     Overdue milestones: red dot + "Response nahi aaya"
   - Status chips: Processing | Filed | Responded | Resolved | Overdue
   - Empty state: illustration + "Abhi koi case nahi"

2. BUILD NavigationShell
   lib/shared/widgets/nav_shell.dart
   - BottomNavigationBar with 3 items:
     Home (house icon), Cases (folder icon), About (info icon)
   - Active: teal icon + amber bottom dot indicator
   - Inactive: gray icon
   - Uses IndexedStack to preserve scroll state

3. BUILD AboutScreen (simple, for demo):
   - App description in Urdu + English
   - "Powered by Google Antigravity + Gemini 3" badge
   - "HAQ Score aur AI Analysis sirf information ke liye hain.
     Legal advice ke liye waqeel se rabta karen."
   - Team info section

4. FIREBASE INITIALIZATION:
   - Create a FirebaseSeeder class
   - On first app launch (check SharedPreferences flag),
     call FirestoreService.seedKnowledgeBase() and seedCollectiveCases()
   - Runs once only

5. ROUTE SETUP:
   - Set up GoRouter or Navigator 2.0 with named routes:
     /splash, /onboarding, /home, /scanner, /agent-trace,
     /haq-dashboard, /complaint-draft, /filing, /confirmation,
     /cases, /about
   - Pass data between screens via route arguments (not global state)
```

---

### PROMPT 10 — Mock Offline Mode + Demo Polish

```
TASK 10: Demo Mode, Offline Fallback & Final Polish

This is critical for hackathon demo reliability. The app must work
perfectly even if internet is unavailable.

1. DEMO/OFFLINE MODE:
   Create lib/core/services/mock_response_service.dart
   
   - Reads from assets/mock_responses/ JSON files
   - DemoModeNotifier (StateNotifier<bool>) — toggle demo mode
   - When demo mode ON or no internet: ALL Gemini calls return
     mock responses with a 1-2 second artificial delay
     (to simulate real AI processing)
   - Demo mode toggle: hidden in Settings (tap logo 5 times)
   
   Pre-fill mock_responses with 2 scenarios:
   
   SCENARIO A (electricity_bill_demo.json) — the overcharge case:
   All 5 agent responses pre-filled, HAQ Score 81, Rs. 1,600 owed,
   collective cluster of 29 cases, no urgent deadline
   
   SCENARIO B (tax_notice_demo.json) — the urgent deadline case:
   FBR notice, 4 days remaining, HAQ Score 73, URGENT flag true,
   deadline red card fires, Agent 2 triggers interrupt behavior

2. LOADING + ERROR STATES:
   Every screen must handle:
   - Loading: shimmer skeleton (use shimmer package or custom)
   - Error: friendly Urdu error card with retry button
   - Empty: illustrated empty state with CTA

3. ANIMATIONS AUDIT:
   Verify these animations exist and work:
   - Splash: logo scale + amber divider width + text fade
   - Onboarding: HAQ gauge plays when page 2 enters view
   - Home: hero button amber pulse rings (continuous)
   - Agent trace: sequential card activation with typewriter text
   - HAQ gauge: 0 → score over 1500ms
   - Confirmation: checkmark scale+fade
   All using flutter_animate package with .animate() chains

4. RESPONSIVE ADJUSTMENTS:
   Test on: 360dp (small Android), 390dp (standard), 430dp (large)
   Ensure no overflow on small screens. Use FittedBox where needed.

5. THEME CONSISTENCY AUDIT:
   Scan ALL screens and ensure:
   - Zero default Flutter blue anywhere
   - All buttons use custom theme
   - All cards use 16dp radius
   - Consistent padding: 16dp horizontal, 20dp vertical sections

6. PERFORMANCE:
   - Use const constructors everywhere possible
   - ListView.builder for all lists (no ListView with children)
   - Image compression before OCR (resizeIfLarger: true)
   - Dispose all controllers and subscriptions

7. ANDROID MANIFEST permissions:
   Add to AndroidManifest.xml:
   - CAMERA
   - READ_EXTERNAL_STORAGE / READ_MEDIA_IMAGES
   - RECORD_AUDIO
   - INTERNET

8. FINAL INTEGRATION TEST:
   Run a full end-to-end flow in demo mode:
   Home → Scanner → Agent Trace (all 5 complete) → 
   HAQ Dashboard (score animates) → Complaint Draft →
   Filing (animation) → Confirmation (receipt) → Cases list
   
   Confirm: no errors, no crashes, all animations play,
   all text in correct fonts (Sora / Noto Nastaliq Urdu)
```

---

### PROMPT 11 — Antigravity Agent Trace Documentation (For Demo/Judging)

```
TASK 11: Generate Agent Trace Artifacts for Judges

Judges need to see Antigravity reasoning traces. Create these files:

1. docs/agent_architecture.md — Architecture overview document
   Describing each agent's role, inputs, outputs, reasoning logic

2. docs/antigravity_workflow.md — How Antigravity was used:
   - Which tasks were delegated to Antigravity agents
   - How parallel vs sequential execution was handled
   - How artifact verification worked

3. Create lib/features/agent_trace/widgets/agent_log_exporter.dart
   - Exports a full JSON log of the last pipeline run
   - Format:
   {
     "run_id": "uuid",
     "timestamp": "ISO8601",
     "input_document_type": "ELECTRICITY_BILL",
     "agents": [
       {
         "agent": "DocumentIntelligenceAgent",
         "started_at": "timestamp",
         "completed_at": "timestamp",
         "duration_ms": 2340,
         "status": "complete",
         "reasoning": "Detected IESCO bill via header text pattern...",
         "output_summary": "DocumentEntity: type=ELECTRICITY_BILL, authority=IESCO..."
       },
       ... (all 5 agents)
     ],
     "final_outcome": {
       "haq_score": 81,
       "amount_owed": 1600,
       "complaint_filed": true,
       "case_reference": "DW-2026-ISB-4521",
       "collective_action_joined": true
     }
   }
   
   This log is shown in a LogViewerScreen accessible from
   case detail → "Agent Log Dekhein" button.
   
   The LogViewerScreen displays this JSON in a clean formatted
   viewer (collapsible sections per agent) using a Card per agent.
   This is specifically for the hackathon judges to see the
   agentic reasoning trace.

4. Add "Export Logs" button in Settings screen that shares
   the latest agent log JSON as a .json file.
```

---

## PART 8: DEMO SCRIPT (3-5 minutes)

```
[0:00 - 0:20] PROBLEM SETUP
Show stat: "50 million Pakistanis silently overpay every year"
Open app → Splash + tagline

[0:20 - 0:50] THE SCAN
Real IESCO bill on table → open scanner → align → capture
OCR text appears briefly → "AI Analysis shuru..."

[0:50 - 2:00] AGENT TRACE (MONEY SHOT)
Show each of 5 agents activating one by one
Narrate what each agent is doing
Agent 3 fires → "HAQ Score: 81" appears
Agent 5 fires → "29 similar cases found"

[2:00 - 2:45] HAQ DASHBOARD
Gauge animates 0 → 81 (let this breathe, it's beautiful)
Show the violation card: Rs. 1,600 owed
Tap "Shamil Hoon" (join collective) → banner confirms

[2:45 - 3:15] FILING
Draft screen → Urdu letter (show briefly)
File button → airplane animation → confirmation
Show case reference, follow-up schedule

[3:15 - 3:45] AGENT LOGS (for judges)
Open agent log viewer → show reasoning traces
"Ye hai Antigravity ka kaam — har qadam traceable hai"

[3:45 - 4:00] CLOSING
"49 million logon ke liye — DarkhwastAI"
```

---

## PART 9: EVALUATION CRITERIA MAPPING

| Criteria | Weight | How DarkhwastAI Addresses It |
|---|---|---|
| Google Antigravity | 25% | 5-agent sequential pipeline, full trace logs, visible reasoning per agent, Gemini 3 core |
| Agentic Reasoning | 20% | Each agent has distinct role, sequential handoffs, interrupt logic (urgency agent), collective pattern detection |
| Insight & Decision Quality | 20% | HAQ Score with legal citations, amount calculation, collective action recommendation — NOT generic summaries |
| Action Simulation | 15% | Mock Citizens Portal submission, case reference generated, follow-up scheduled, collective petition filed |
| Technical Implementation | 10% | Clean architecture, Riverpod, typed models, offline fallback, Firebase integration |
| Innovation & UX | 10% | Never built before in Pakistan, emotional demo story, Urdu-first, Ghost Deadline Detector, Collective Action |

---

*DarkhwastAI — Built for the 49 million who give up silently.*
*AISeekho 2026 | Google Antigravity | Challenge 1*