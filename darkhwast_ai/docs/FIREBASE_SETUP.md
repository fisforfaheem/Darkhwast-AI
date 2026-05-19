# Firebase Setup — DarkhwastAI (Phase C)

The app works **offline** with local case storage (demo mode). To enable **cloud cases**, **law knowledge base**, and **live collective counts**, connect a real Firebase project.

## 1. Create Firebase project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create project (e.g. `darkhwast-ai`)
3. Enable **Authentication** → Sign-in method → **Anonymous** → Enable
4. Enable **Cloud Firestore** → Start in **test mode** (then deploy rules below)

## 2. Register apps & generate config

Install FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

From the `darkhwast_ai` folder:

```bash
cd darkhwast_ai
flutterfire configure
```

This will:

- Replace [`lib/firebase_options.dart`](lib/firebase_options.dart) with real keys
- Add `android/app/google-services.json`
- Add iOS `GoogleService-Info.plist`

## 3. Android Gradle (if not auto-applied)

In `android/settings.gradle.kts` plugins block add:

```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

In `android/app/build.gradle.kts` plugins block add:

```kotlin
id("com.google.gms.google-services")
```

## 4. Deploy Firestore rules & seed data

```bash
npm install -g firebase-tools
firebase login
firebase use --add   # select your project
firebase deploy --only firestore:rules
```

On first app launch with real Firebase, the app **auto-seeds**:

- `knowledgeBase` — NEPRA, OGRA, BISP, FBR law entries
- `collectiveCases` — IESCO FCA cluster (29 cases)

## 5. Verify in app

1. Run the app (not demo-only — Firebase must init)
2. **About** screen should show **Cloud Connected** (green)
3. File a complaint → check **Firebase Console → Firestore → `cases`**
4. Collective join increments `collectiveCases/cluster_IESCO_FCA_ISB_May2026`

## Collections

| Collection | Purpose |
|------------|---------|
| `knowledgeBase` | Pakistani regulation snippets per document type |
| `collectiveCases` | Clustered complaints by authority + violation |
| `cases` | Filed user complaints |
| `followUps` | Scheduled reminders at +7, +14, +30 days |

## Offline / mock fallback

If `firebase_options.dart` still has `mock-api-key`, the app skips Firebase and uses **SharedPreferences** for cases. Demo mode continues to work without any cloud setup.

## Security note

Current rules allow any anonymous user to read/write all collections — acceptable for hackathon demos. Restrict by `userId` on `cases` before production.
