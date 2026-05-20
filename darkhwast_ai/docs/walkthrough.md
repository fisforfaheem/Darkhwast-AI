# Judge walkthrough — DarkhwastAI (90 seconds per scenario)

APK builds ship **without** a bundled Gemini API key. First launch asks: **Curated Demo** (default) or **your own key** (device-only).

## Quick start (judges)

1. Open app → **Continue with Demo**
2. Home → **Curated demo chunain**
3. Pick a scenario → demo runs automatically through the 5-agent pipeline
4. Choose intent (e.g. **Complaint likhein** or **Document samjhein**)
5. HAQ dashboard → complaint draft → filing simulation → confirmation (see [`complaint_filing_workflow.md`](complaint_filing_workflow.md) for technical detail)
6. About → **Agent log share karen** (Antigravity JSON)

---

## Scenario A — IESCO FCA (flagship, ~90s)

**Hook:** HAQ 81, Rs 1,600 refund, **29 collective cases**

| Step | Action | Point out |
|------|--------|-----------|
| 1 | Curated demo → **IESCO Bijli Bill** | Pre-loaded OCR, no camera needed |
| 2 | Watch Agent 1–2 | Document + urgency (6 days, monitor) |
| 3 | Intent → **Complaint likhein** | User steering |
| 4 | Agents 3–5 | HAQ score, bilingual draft, collective cluster |
| 5 | HAQ gauge | Rs 1,600 owed, NEPRA basis |
| 6 | Urdu draft tab | Formal IESCO/NEPRA letter |
| 7 | Share agent log | `trace_format: antigravity_agent_v1` |

---

## Scenario B — FBR Ghost deadline (~90s)

**Hook:** Hidden **4-day** deadline in footnote — Agent 2 URGENT

| Step | Action | Point out |
|------|--------|-----------|
| 1 | Pick **FBR Tax Notice** | Ghost Deadline Detector |
| 2 | Agent 2 card | Amber urgent + hidden deadline message |
| 3 | Intent → **Write Appeal** or **Find Issues** | |
| 4 | HAQ dashboard | Lower score (55), dispute Rs 75,000 |

---

## Scenario C — BISP appeal (~90s)

**Hook:** Procedural unfairness, appeal rights, HAQ 75

| Step | Action | Point out |
|------|--------|-----------|
| 1 | Pick **BISP Status Letter** | Rejection → appeal path |
| 2 | Intent → **Document samjhein** | Explain-only flow |
| 3 | Document explanation screen | Plain Urdu/English |

---

## Developers (local live AI)

- Copy `.env.example` to `darkhwast_ai/.env` with `GEMINI_API_KEY` (debug builds read `File('.env')` from project root)
- Or use **My key** in About after first launch
- Never commit `.env`; release APKs use demo or user-provided keys only

---

## In-app validation

- **About → AI mode:** Curated Demo vs My key
- **About → Curated demo scenarios:** Full picker
- **About → Agent trace / Share log:** After any completed run
