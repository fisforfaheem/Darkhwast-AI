# DarkhwastAI: 5-Agent Pipeline Architecture

DarkhwastAI utilizes a sophisticated multi-agent pipeline orchestrated via Riverpod and powered by Google Gemini 1.5 Pro. Each agent has a specific role, input/output contract, and specialized prompt.

For the full path from document upload through draft review, simulated filing, persistence, follow-up scheduling, and collective join logic, see [`complaint_filing_workflow.md`](complaint_filing_workflow.md).

## 1. Document Intelligence Agent
- **Role**: Extract structured data from raw OCR text or images.
- **Input**: Raw text (from Google ML Kit) or document image.
- **Output**: `DocumentEntity` (Type, Authority, Consumer ID, Amounts, Dates).
- **Reasoning**: Uses vision-language patterns to identify Pakistani government headers (IESCO, SNGPL, FBR) and extract critical numerical slabs.

## 2. Urgency Detector Agent
- **Role**: Scan for "ghost deadlines" and urgent legal timelines.
- **Input**: `DocumentEntity`.
- **Output**: `List<DeadlineAlert>`.
- **Reasoning**: specifically hunts for fine-print dates, stamps, and footnotes. Triggers an "URGENT" interrupt if a deadline is within 72 hours.

## 3. Rights Intelligence Agent
- **Role**: Match extracted data against Pakistani Consumer Protection Laws.
- **Input**: `DocumentEntity` + `LawKnowledgeBase` (pre-seeded in Firestore).
- **Output**: `RightsAnalysis` (HAQ Score, Violation Type, Amount Owed).
- **Reasoning**: Calculates the "HAQ Score" (0-100) based on the strength of the legal case. Cites specific regulations (e.g., NEPRA Consumer Rules 2021).

## 4. Action Drafter Agent
- **Role**: Generate formal, legal-grade complaint letters.
- **Input**: `RightsAnalysis` + `DocumentEntity`.
- **Output**: `ComplaintDraft` (Bilingual Urdu/English letters).
- **Reasoning**: Writes professional letters using Noto Nastaliq Urdu formatting. Cites the specific legal basis discovered by Agent 3.

## 5. Collective Pattern Agent
- **Role**: Cluster similar complaints for group petitions.
- **Input**: Authority + Violation Type.
- **Output**: `CollectiveCluster`.
- **Reasoning**: Scans Firestore for similar complaints in the same area. Detects systemic overcharges (e.g., "29 others also overcharged by IESCO this month").
