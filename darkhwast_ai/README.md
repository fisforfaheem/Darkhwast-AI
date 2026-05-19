# DarkhwastAI

**Apka document. Apka haq. 90 seconds.**

Pakistan's AI citizen rights engine — AISeekho 2026, **Challenge 1: Autonomous Content-to-Action Agent**.

A Flutter app that turns government documents (bills, tax notices, BISP letters) into **insights**, **legal standing (HAQ Score)**, **recommended actions**, and **simulated complaint filing** with visible system state change.

## Challenge 1 flow

```
Scan document → 5 AI agents → HAQ Dashboard → Complaint draft → Simulated filing → Case saved
```

| Step | What happens |
|------|----------------|
| Input | Photo, PDF, or voice (Roman Urdu / Urdu / English) |
| Agents | Document read → deadlines → law check → draft → collective pattern |
| Insight | HAQ Score 0–100, violation, amount owed, law citation |
| Action | Bilingual complaint + portal simulation |
| Outcome | Case reference, before/after state, follow-ups at Day 7/14/30 |

## Firebase (optional cloud)

Cases, law KB, and collective clusters sync to Firestore when configured.

```bash
# One-time setup — see docs/FIREBASE_SETUP.md
flutterfire configure
firebase deploy --only firestore:rules
```

Without Firebase, the app uses **local storage** + demo mocks (fully functional for judges).

## Quick start (demo mode — recommended for judges)

```bash
cd darkhwast_ai
flutter pub get
flutter run
```

On device:

1. **About** tab → tap the sparkle logo **5 times** → Demo Mode ON
2. Pick scenario: **IESCO Bill** or **FBR Tax (Urgent)**
3. **Home** → scan any image (demo uses pre-built JSON)
4. Watch **Live Agent Trace** → HAQ Dashboard → File complaint → Confirmation
5. **Cases** tab → your filed case appears

## Live AI (Gemini 2.5 / 3.1)

1. Copy `.env.example` → `.env` (or edit the existing `.env`)
2. Set your key:

```env
GEMINI_API_KEY=your_key_from_aistudio_google_com
GEMINI_MODEL=gemini-2.5-pro
USE_MOCK=false
```

| Model | When to use |
|-------|-------------|
| `gemini-2.5-pro` | **Default** — stable, strong reasoning + structured JSON |
| `gemini-3.1-pro-preview` | **Latest** — best for multi-step agent pipelines (preview) |
| `gemini-2.5-flash` | Faster scans, lower cost |

3. Run the app:

```bash
cd darkhwast_ai
flutter pub get
flutter run
```

4. **About** → confirm **LIVE GEMINI-2.5-PRO** (or your `GEMINI_MODEL`) — Demo Mode OFF when a key is set

Optional CI override: `--dart-define=GEMINI_API_KEY=...`

Turn **Demo Mode ON** (tap logo 5×) only for offline judge demos without API calls.

## Architecture

- **Flutter 3** + **Riverpod** — 5-agent sequential pipeline
- **Gemini 2.5 Pro / 3.1 Pro** — document analysis, rights, complaint drafting (configurable via `GEMINI_MODEL`)
- **ML Kit** — on-device OCR
- **Firestore** — law KB, collective clusters, cases, follow-ups (when configured)
- **Firebase Anonymous Auth** — required for Firestore writes
- **SharedPreferences** — local case fallback (always works offline)

See [`docs/agent_architecture.md`](docs/agent_architecture.md) and [`docs/challenge1_mapping.md`](docs/challenge1_mapping.md).

## Agent trace (judges — Antigravity format)

Exported JSON uses `trace_format: antigravity_agent_v1` with orchestration metadata, per-agent timing, `reasoning`, `decision`, and structured `output`.

**Pre-built samples** (submit with repo or show if asked):

- `docs/samples/antigravity_trace_iesco_electricity.json`
- `docs/samples/antigravity_trace_fbr_tax_urgent.json`

After a live pipeline run:

1. **Confirmation → Agent Log Dekhein** or **Cases → expand case → Agent Log Dekhein**
2. **About → Share Agent JSON**
3. **Share** exports `antigravity_trace_<run_id>.json`

See [`docs/orchestration.md`](docs/orchestration.md) for the pipeline architecture.

## Assumptions

- Citizens Portal / NEPRA submission is **simulated** (mock API log + case ref)
- HAQ Score is informational, not legal advice
- Demo mode uses assets in `assets/mock_responses/`
- Firebase uses placeholder config until `flutterfire configure` is run

## Team

DarkhwastAI — AISeekho 2026
