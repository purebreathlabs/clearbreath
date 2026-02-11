# ClearBreath — Product Requirements Document (PRD)

**Brand Name:** ClearBreath
**Domain:** clearbreath.life
**Tagline:** Breathe with intention.

---

## 1. Problem Statement

Millions of people practice pranayama and breathing exercises daily, yet the current app landscape is broken in three ways:

**The Generic Problem:** Apps like Calm and Headspace treat breathing as a side feature — offering 2-3 basic exercises buried inside a meditation app. They're designed for casual users, not serious practitioners.

**The Depth Problem:** There is no single app that offers the full range of authentic pranayama techniques — from beginner-friendly diaphragmatic breathing to advanced ultra-slow breathing at 1-3 BPM and HRV resonance training at 5-6 BPM. Users wanting to practice Anulom Vilom, Bhastrika, Kapalbhati, or low-BPM breathing currently juggle between YouTube videos, generic timers, and fragmented apps.

**The Progression Problem:** Existing breathing apps have no sense of journey. They don't track your growth, don't adapt to your level, and don't motivate you to build a consistent practice. There are no streaks, no leaderboards, and no community — breathing practice feels isolated and forgettable.

**What we're building:** ClearBreath — a native mobile app (iOS + Android) for pranayama and breathing exercises that provides the complete library of authentic breathing techniques with beautiful guided animations, soothing audio, adaptive difficulty levels, streak-based motivation, and community leaderboards — all free, requiring zero sign-up to start.

**One-sentence success definition:** "If someone opens ClearBreath daily for their breathing practice instead of opening YouTube or any other app, we've won."

---

## 2. Product Vision & Goals

### Vision

Become the definitive pranayama and breathing exercise platform — the app that serious practitioners, curious beginners, and HRV enthusiasts all reach for.

### User Outcome (Primary)

Help users build a consistent, effective breathing practice that improves their calm, focus, sleep quality, and overall wellbeing through authentic pranayama techniques.

### Founder Outcome

Start as a passion/portfolio project with a quality-first approach. Architect for future monetization (freemium with premium curated programs) without implementing paywalls until product-market fit is proven.

### Success Metrics (30/90 Days Post-Launch)

| Metric | 30 Days | 90 Days |
|--------|---------|---------|
| App downloads (iOS + Android) | 500+ | 2,000+ |
| Registered users (Google OAuth) | 100+ | 500+ |
| Daily Active Users (DAU) | 20+ | 80+ |
| Day-7 retention | 30%+ | 40%+ |
| Average session length | 5+ min | 7+ min |
| Users with 7+ day streak | 15% | 25% |
| Leaderboard participants | 30% of registered | 40% |
| App Store rating | 4.5+ | 4.5+ |
| Organic shares/referrals | Any signal | Measurable |

---

## 3. Target Audience

### Primary Persona: "The Curious Practitioner"

People who already know what pranayama is (or have heard of breathing exercises) and want a proper, structured tool to practice regularly. Age 18-40, India-first but globally accessible, comfortable with English, health-conscious, may already do yoga or meditation.

### Secondary Persona: "The Complete Beginner"

People who've heard that breathing exercises help with stress/anxiety/sleep and want to try but don't know where to start. They need education, hand-holding, and gentle onboarding.

### Tertiary Persona: "The HRV Optimizer"

Biohackers, athletes, and wellness enthusiasts who specifically want low-BPM resonance breathing for HRV training. They know exactly what they want and need precision timers with customizable cycles.

### Adaptive Experience

ClearBreath adapts to user level. Beginners see educational "About" cards, simpler techniques featured first, and gentler defaults. Advanced users see HRV/ultra-slow training prominently, have access to forceful techniques with appropriate warnings, and get longer session presets.

---

## 4. Platform Decision

**Verdict: Native Mobile Apps (iOS + Android) using React Native (Expo)**

### Why React Native with Expo:

- **Single codebase** for both iOS and Android — critical for a solo developer
- **Expo managed workflow** eliminates native build toolchain complexity (no Xcode/Android Studio setup headaches for most features)
- **Over-the-air (OTA) updates** via EAS Update — push bug fixes and content changes without App Store review
- **True native performance** for animations, audio, and background tasks — no browser limitations
- **Expo SDK** provides battle-tested modules for audio (expo-av), haptics (expo-haptics), notifications (expo-notifications), secure storage, and more
- **EAS Build + Submit** handles App Store and Play Store distribution from the CLI
- **React ecosystem** — Rahul's existing React/TypeScript expertise transfers directly
- **Large community and ecosystem** — proven at scale (Discord, Shopify, Microsoft apps)

### Why not PWA (Previous Decision):

- Background audio unreliable on iOS Safari — requires hacky workarounds that still break
- No true push notifications without complex Web Push setup
- No haptic feedback in browsers
- PWA "Add to Home Screen" friction kills discoverability — users expect app stores
- No App Store presence means missing the primary discovery channel for mobile wellness apps
- Service Worker caching is fragile compared to native offline storage

### Why not Flutter:

- Dart is a new language to learn — React Native uses TypeScript which Rahul already masters
- Smaller ecosystem for specific breathing/audio/wellness packages
- React Native's bridge to native modules is more mature for audio-heavy apps

### Native Advantages (Unlocked from Day 1):

- **Reliable background audio** — native audio sessions, no browser hacks needed
- **True push notifications** — local and remote, no Web Push complexity
- **Haptic feedback** — vibration cues for inhale/exhale/hold transitions
- **App Store discoverability** — ASO, ratings, reviews, featured placement potential
- **Deep OS integration** — widgets, Siri Shortcuts (iOS), notification channels (Android)
- **Offline-first by default** — local SQLite storage, no IndexedDB quirks
- **Smooth 60fps animations** — React Native Reanimated with native driver, no browser jank

---

## 5. Tech Stack

### Mobile App

- **Framework:** React Native with Expo (SDK 52+)
- **Language:** TypeScript
- **Navigation:** Expo Router (file-based routing, deep linking support)
- **Styling:** NativeWind (Tailwind CSS for React Native) or StyleSheet API
- **Animations:** React Native Reanimated 3 (native thread animations, 60fps breathing circles)
- **Audio Engine:** expo-av (background audio, audio sessions, lock-screen controls) + expo-audio for advanced layering
- **Haptics:** expo-haptics (vibration cues at phase transitions)
- **Local Storage:** expo-sqlite or WatermelonDB (offline session tracking, streak data, user preferences)
- **State Management:** Zustand (lightweight, same as before — works identically in React Native)
- **Icons:** Lucide React Native or expo-vector-icons
- **Notifications:** expo-notifications (local reminders + push via Expo Push Service)
- **Secure Storage:** expo-secure-store (auth tokens)

### Backend: Supabase (Backend-as-a-Service)

**Why Supabase over custom Node.js/Go backend:**

- **Zero server management** — Supabase handles hosting, scaling, security patches, backups
- **PostgreSQL included** — full relational database with row-level security (RLS)
- **Built-in Auth** — Google OAuth, Apple Sign-In, email — all pre-built, no custom auth code
- **Edge Functions** — TypeScript serverless functions for custom logic (streak calculation, leaderboard refresh, anti-cheat validation)
- **Realtime subscriptions** — live leaderboard updates without building WebSocket infrastructure
- **Storage** — file storage with CDN for audio files (replaces Cloudflare R2)
- **Free tier is generous** — 500MB database, 1GB file storage, 50K monthly active users, 500K Edge Function invocations
- **Cost at scale** — $25/month Pro plan covers up to ~100K users before needing anything more
- **Rahul already planned for Supabase** — zero learning curve, same choice from v3

**Why NOT a custom Node.js or Go backend:**

- **Node.js server** = you're now managing hosting (Railway/Render/VPS), deployments, uptime, SSL, CORS, rate limiting, auth middleware, database migrations, connection pooling — all yourself. For a solo dev, this is weeks of DevOps work that Supabase eliminates.
- **Go server** = same DevOps overhead PLUS learning a new language. Go is faster at runtime but irrelevant at MVP scale (Supabase Edge Functions handle <100ms responses easily). The "Go is cheaper at scale" argument only matters at 1M+ users — premature optimization.
- **The bottleneck is shipping, not server performance.** Supabase lets Rahul focus 100% on the app experience.

**When to consider a custom backend (future):** Only if Supabase Edge Functions can't handle a specific need (complex real-time processing, wearable data pipelines, ML inference). At that point, add a lightweight Node.js/Fastify microservice alongside Supabase — don't replace it.

### Storage & Assets

- **Audio Files:** Supabase Storage (S3-compatible, CDN-backed, free 1GB tier) — consolidates infra under one provider
- **Audio Format:** AAC primary (native iOS/Android support, smaller files, gapless playback), MP3 fallback
- **Audio Sources:** Royalty-free libraries (Freesound, Pixabay) + AI-generated ambient sounds (with commercial licensing)

### Analytics & Monitoring

- **Analytics:** PostHog (free tier, React Native SDK, events only — no session replay in MVP)
- **Error Tracking:** Sentry (free tier, React Native SDK with native crash reporting)
- **App Store Analytics:** App Store Connect + Google Play Console built-in analytics

### Build & Distribution

- **Build Service:** EAS Build (Expo Application Services) — cloud builds for iOS and Android
- **OTA Updates:** EAS Update — push JS bundle updates without App Store review
- **App Store Submission:** EAS Submit — automated submission to both stores
- **CI/CD:** GitHub Actions → EAS Build → automatic preview builds on PR

### Estimated Costs

| Service | Free Tier | Cost After |
|---------|-----------|------------|
| Expo / EAS | 30 builds/month, OTA updates | ~$0 for MVP (Pro $99/yr if needed) |
| Apple Developer Program | — | $99/year (required) |
| Google Play Developer | — | $25 one-time |
| Supabase | 500MB DB, 1GB storage, 50K MAU | ~$25/mo Pro plan after limits |
| PostHog | 1M events/mo | Free for MVP scale |
| Sentry | 5K errors/mo | Free for MVP scale |
| **Total Year 1 (MVP)** | | **~$124 fixed + $0-25/mo variable** |
| **Total at 10K users** | | **~$25-50/mo + $124/yr fixed** |

---

## 6. Canonical Exercise Library (MVP — 11 Techniques)

### BPM Definition

- 1 breath = 1 full cycle: Inhale → Hold (optional) → Exhale → Hold (optional)
- 6 BPM = 10 seconds per cycle (HRV resonance sweet spot)
- 3 BPM = 20 seconds per cycle
- 2 BPM = 30 seconds per cycle
- 1 BPM = 60 seconds per cycle

### HRV Terminology (IMPORTANT — Credibility Decision)

ClearBreath distinguishes between two related but different practices:

- **"HRV Resonance Breathing"** — Breathing at 4.5-6.5 BPM. This is the scientifically-backed frequency range where most people's heart rate variability resonates. The app says: "Commonly used in HRV training protocols."
- **"Ultra-Slow Breathing"** — Breathing at 1-3 BPM. This is a tolerance/training exercise for advanced practitioners. Not directly HRV resonance, but builds respiratory control.

ClearBreath NEVER claims "this improves your HRV." Instead: "Commonly used in HRV training," "May support cardiovascular coherence," "Traditionally practiced for..."

**Safety floor:** Below 2 BPM requires Advanced level selection. Warning shown: "Ultra-slow breathing below 2 BPM is an advanced practice. Start at higher BPM and work down gradually."

### Preset Levels

Each technique offers 3 preset difficulty levels (Beginner / Intermediate / Advanced) with pre-configured durations, ratios, and session lengths. No custom ratio controls in MVP. Holds (kumbhaka) are included in presets where traditionally appropriate — they are NOT a separate toggle.

### Nose vs Mouth Breathing

Per-technique breathing direction (nose inhale, mouth exhale, etc.) is SUGGESTED via cue text, not enforced by UI. The animation shows the phase; the cue text mentions the recommended airway.

### Animation Mode by Technique Speed

- **Slow breathing (≤12 BPM):** Expanding/contracting circle animation (smooth, meditative) — powered by React Native Reanimated on native thread
- **Rapid breathing (>12 BPM — Kapalbhati, Bhastrika):** Pulsing dot / metronome beat visual (prevents strobe-light effect at high speeds)

---

### Exercise List

### 1. HRV Resonance Breathing ⭐ (Signature Feature)

- **Difficulty:** Intermediate-Advanced
- **What it is:** Breathing at the scientifically-studied resonance frequency (~5-6 BPM) commonly used in HRV training protocols. ClearBreath's unique differentiator.
- **Presets:**
  - Beginner: 6 BPM (5s inhale, 5s exhale) — 5 min session
  - Intermediate: 5 BPM (6s inhale, 6s exhale) — 10 min session
  - Advanced: 4.5 BPM (6.5s inhale, 6.5s exhale + optional 2s holds) — 15 min session
- **Contraindications:** Not recommended for people with severe respiratory conditions. Start at 6 BPM and work down.
- **Cues:** "Breathe smoothly and evenly. Match your breath to the guide. If you feel dizzy, return to normal breathing."

### 2. Ultra-Slow Breathing (Deep Training) ⭐

- **Difficulty:** Advanced
- **What it is:** Extremely slow breathing at 1-3 BPM for advanced respiratory control training. Builds on HRV resonance.
- **Presets:**
  - Beginner: 3 BPM (10s inhale, 10s exhale) — 5 min session
  - Intermediate: 2 BPM (15s inhale, 15s exhale) — 10 min session
  - Advanced: 1.5 BPM (20s inhale, 20s exhale) — 15 min session
- **Contraindications:** ⚠️ Advanced practice only. Not for beginners or anyone with respiratory conditions. Mandatory interstitial warning before first session below 2 BPM.
- **Cues:** "This is an advanced practice. Breathe as slowly and smoothly as possible. If uncomfortable at any point, return to your natural rhythm immediately."

### 3. Diaphragmatic (Belly) Breathing

- **Difficulty:** Beginner
- **What it is:** Foundation breathing technique. Breathe deep into the belly, expanding the diaphragm.
- **Presets:**
  - Beginner: 4s inhale, 4s exhale — 3 min session
  - Intermediate: 5s inhale, 6s exhale — 5 min session
  - Advanced: 6s inhale, 8s exhale — 10 min session
- **Contraindications:** None. Safe for everyone.
- **Cues:** "Place one hand on your chest and one on your belly. Only your belly hand should rise."

### 4. Box Breathing (Sama Vritti)

- **Difficulty:** Beginner
- **What it is:** Equal-ratio breathing with holds. Used by Navy SEALs for stress management.
- **Presets:**
  - Beginner: 3-3-3-3 (inhale-hold-exhale-hold) — 3 min
  - Intermediate: 4-4-4-4 — 5 min
  - Advanced: 6-6-6-6 — 10 min
- **Contraindications:** Breath holds not recommended during pregnancy or for people with uncontrolled high blood pressure.
- **Cues:** "Inhale... Hold... Exhale... Hold... Keep each phase equal."

### 5. 4-7-8 Breathing (Relaxing Breath)

- **Difficulty:** Beginner
- **What it is:** Dr. Andrew Weil's calming technique. Excellent for sleep and anxiety.
- **Presets:**
  - Beginner: 4s inhale, 7s hold, 8s exhale — 4 cycles
  - Intermediate: 4s inhale, 7s hold, 8s exhale — 8 cycles
  - Advanced: 4s inhale, 7s hold, 8s exhale — 12 cycles
- **Contraindications:** The long hold may be uncomfortable for beginners. Stop if dizzy.
- **Cues:** "Inhale through your nose for 4... Hold for 7... Exhale slowly through your mouth for 8."

### 6. Yogic Breathing (Three-Part Breath / Dirga Pranayama)

- **Difficulty:** Beginner
- **What it is:** Sequential filling of belly, ribs, and chest. Teaches full lung capacity awareness.
- **Presets:**
  - Beginner: 4s inhale (3-part), 4s exhale — 5 min
  - Intermediate: 6s inhale, 6s exhale — 7 min
  - Advanced: 8s inhale, 2s hold, 8s exhale — 10 min
- **Contraindications:** None. Safe for everyone.
- **Cues:** "Fill your belly first... then your ribs... then your chest. Exhale in reverse."

### 7. Anulom Vilom (Alternate Nostril Breathing)

- **Difficulty:** Intermediate
- **What it is:** Alternate nostril breathing for balance and calm. Core pranayama technique.
- **Presets:**
  - Beginner: 4s left inhale, 4s right exhale — 5 min
  - Intermediate: 4s inhale, 2s hold, 4s exhale — 7 min
  - Advanced: 4s inhale, 4s hold, 6s exhale, 2s hold — 10 min
- **Visual:** Simplified nostril sequencing in MVP — left/right indicator showing which nostril is active. Full detailed hand-position animation deferred to Phase 2.
- **Contraindications:** Avoid during cold/nasal congestion. Not recommended with severe sinus issues.
- **Cues:** "Close right nostril... Inhale left... Close left... Exhale right..."

### 8. Ujjayi (Ocean Breath / Victorious Breath)

- **Difficulty:** Intermediate
- **What it is:** Breath with slight throat constriction creating an ocean-like sound. Commonly used in yoga.
- **Presets:**
  - Beginner: 4s inhale, 4s exhale — 5 min
  - Intermediate: 5s inhale, 7s exhale — 7 min
  - Advanced: 6s inhale, 2s hold, 8s exhale — 10 min
- **Contraindications:** Avoid if you have a sore throat or throat infection.
- **Cues:** "Slightly constrict the back of your throat, as if you're fogging a mirror. Breathe through your nose."

### 9. Bhramari (Bee Breath)

- **Difficulty:** Intermediate
- **What it is:** Humming exhalation that creates vibration. Calms the nervous system rapidly.
- **Presets:**
  - Beginner: 4s inhale, 6s humming exhale — 5 min
  - Intermediate: 5s inhale, 10s humming exhale — 7 min
  - Advanced: 6s inhale, 2s hold, 12s humming exhale — 10 min
- **Contraindications:** Avoid during ear infection. Not recommended while lying down.
- **Cues:** "Inhale deeply... Now exhale with a steady humming sound like a bee. Feel the vibration."

### 10. Kapalbhati (Skull Shining Breath) ⚠️

- **Difficulty:** Advanced
- **What it is:** Forceful, rapid exhalations with passive inhalations. Energizing and cleansing.
- **Animation:** Pulsing dot / metronome beat (NOT expanding circle — too fast, strobe-like).
- **Pacing:** Audio tick at each exhale (metronome-style pacing) + haptic pulse.
- **Rounds & Rest:** App FORCES rest timers between rounds. User cannot skip rest.
- **Presets:**
  - Beginner: 30 breaths/min, 1 min session (1 round)
  - Intermediate: 60 breaths/min, 3 min (3 rounds with 30s forced rest between)
  - Advanced: 90 breaths/min, 5 min (5 rounds with 30s forced rest between)
- **Contraindications:** ⚠️ NOT safe for: pregnancy, high blood pressure, heart conditions, hernia, recent abdominal surgery, epilepsy. Show prominent warning before starting.
- **Safety:** Mandatory one-time "I understand the risks" interstitial before first session. Visible to ALL user levels (not locked behind Advanced onboarding) but warning is prominent.
- **Mid-round stop:** If user stops mid-round, partial session still counts (time spent is logged). Session marked as incomplete but contributes to streak if ≥1 min.
- **Cues:** "Sharp exhale through the nose, pulling belly in. Let the inhale happen naturally. Start slowly."

### 11. Bhastrika (Bellows Breath) ⚠️

- **Difficulty:** Advanced
- **What it is:** Forceful, equal inhale and exhale. More intense than Kapalbhati. Generates heat and energy.
- **Animation:** Pulsing dot / metronome beat (same as Kapalbhati).
- **Pacing:** Audio tick at each breath (metronome-style) + haptic pulse.
- **Rounds & Rest:** Forced rest timers between rounds.
- **Presets:**
  - Beginner: 20 breaths/min, 1 min (1 round)
  - Intermediate: 30 breaths/min, 3 min (3 rounds with 45s forced rest)
  - Advanced: 40 breaths/min, 5 min (5 rounds with 30s forced rest)
- **Contraindications:** ⚠️ Same as Kapalbhati plus: asthma (can trigger bronchospasm), nosebleeds, retinal issues. Show prominent warning.
- **Safety:** Same one-time interstitial gate as Kapalbhati.
- **Cues:** "Forceful inhale AND exhale through the nose. Pump your belly like bellows. Equal force both ways."

> **Note:** Exercise list is 11 total (original 10 + Ultra-Slow split from HRV Resonance). Both HRV Resonance and Ultra-Slow are ClearBreath's signature features.

---

## 7. Core UX Flows

### 7.1 First-Time User Flow (Guest Mode)

1. User downloads ClearBreath from App Store / Play Store → App opens
2. Quick onboarding (3 screens max):
   - Screen 1: "Welcome to ClearBreath. What's your experience with breathing exercises?" → Beginner / Intermediate / Advanced
   - Screen 2: "What's your primary goal?" → Calm & Stress Relief / Better Sleep / Focus & Energy / HRV Training / Spiritual Practice
   - Screen 3: Brief explanation of how ClearBreath works + "Start Breathing" CTA
3. Home screen loads with personalized "Today's Practice" recommendation
4. User can start breathing immediately — zero sign-up required
5. All session data stored locally (SQLite) until they choose to sign in

### 7.2 Daily Practice Flow (Returning User)

1. Open ClearBreath → Home screen
2. "Today's Practice" section at top — curated recommendation based on:
   - User level (from onboarding)
   - Goal (from onboarding)
   - Time of day (morning = energizing techniques like Kapalbhati/Bhastrika, evening = calming like 4-7-8/HRV)
   - Streak/consistency (if they've been consistent, suggest slightly longer or harder sessions)
3. "Browse All Techniques" below — full library with difficulty tags and "About" cards
4. Tap technique → See preset levels (Beginner/Intermediate/Advanced) with time estimates
5. Tap preset → 3-2-1 countdown → Session begins

### 7.3 Active Session Flow

1. Full-screen breathing guide:
   - Slow techniques (≤12 BPM): Animated circle (expands on inhale, contracts on exhale, pauses on hold) — Reanimated native thread, buttery 60fps
   - Rapid techniques (>12 BPM): Pulsing dot / metronome visual synced to breath pace
   - Phase label: "INHALE" / "HOLD" / "EXHALE" / "HOLD"
   - Timer counting down the current phase
   - Overall session timer (elapsed / remaining)
   - Background soundscape playing (optional, toggleable)
   - Audio transition cues (soft bell/tone at phase changes for slow; tick/beat for rapid)
   - Haptic pulses at phase transitions (subtle vibration on inhale start, exhale start, hold start)
2. Minimal UI: pause button, close/end button
3. Eyes-closed friendly: Large visuals, high contrast, audio + haptic cues are sufficient to follow without looking
4. Screen stays awake (react-native keep-awake)
5. If user locks phone or switches apps → audio continues playing in background (native audio session)
6. Lock-screen controls: pause/stop session (Media Session integration via expo-av)
7. For round-based techniques (Kapalbhati/Bhastrika): Between rounds, forced rest timer with countdown. "Rest... Next round in 30s." Auto-continues.
8. Session complete → Completion screen:
   - "Great work!" with session summary (duration, technique, breaths completed)
   - Streak counter updated (if session ≥ 1 minute)
   - Gentle prompt to sign in (if guest) to save progress and access leaderboard

### 7.4 Technique "About" Card

Each technique has a short educational card accessible from the library:

- What it is (2-3 sentences)
- Benefits (careful wording — "may help with," "traditionally used for," NEVER medical claims)
- How to do it (step-by-step, brief)
- Best time of day
- Contraindications/warnings (if applicable)
- Difficulty badge

### 7.5 Auth Flow

- **Guest Mode (default):** Everything works. Sessions tracked in local SQLite database.
- **Google OAuth + Apple Sign-In (Phase 1.5):** Prompted softly after 3 sessions or when accessing leaderboard. On sign-in, local data syncs to Supabase via smart merge. Auth via Supabase Auth.
- Apple Sign-In is **required** by Apple for apps offering third-party sign-in. Both Google and Apple sign-in will be supported.
- No email/password. Keep it simple.

---

## 8. Feature Specifications

### 8.1 Streak System

- **Definition:** A streak increments when the user completes at least 1 session of ≥1 minute on a calendar day. (Sub-1-minute sessions are too short to be meaningful and prevent streak farming.)
- **Timezone:**
  - Guest mode: Device local time.
  - Signed-in users: Server calculates streaks. Session records include UTC timestamp + timezone offset from device. Streak is computed based on user's local calendar day (derived from offset).
  - Travel edge case: If a user sessions at 11 PM IST then flies to London (6 PM GMT same UTC moment), it counts as one session for the IST calendar day. Next session in London counts for the GMT calendar day. No double-counting.
- **Streak break:** Missing an entire calendar day (no qualifying session) resets the streak to 0.
- **Display:** Streak counter visible on home screen. Streak badge/number next to profile.
- **Streak freeze (Phase 2):** Allow 1 "freeze" per week to protect streaks.

### 8.2 Time Tracking & Stats

**Tracked metrics:**

- Total minutes practiced (all-time)
- Total sessions completed (all-time)
- Current streak (days)
- Longest streak (days)
- Minutes this week (bar chart by day)
- Minutes by technique (breakdown)
- Longest single session
- Favorite technique (most practiced)

**Display:** Profile/Stats screen accessible from home tab.

**Guest data:** Stored in local SQLite. Syncs to Supabase on sign-in.

### 8.3 Leaderboard

- **Scope:** Global leaderboard (all signed-in users). Guest users can view but not appear on it.
- **Default ranking:** Current streak length (descending).
- **Filterable by:** Current streak, total minutes (all-time), total minutes (this week).
- **Display:** Display name + avatar (from Google/Apple, customizable) + metric value. Top 50 shown. User's own rank always pinned/visible regardless of position.
- **Privacy:**
  - Users must explicitly opt-in to leaderboard visibility (toggle in settings, default OFF).
  - Display name can be customized (doesn't have to be Google/Apple name).
  - Option to show initials only instead of full name.
- **Anti-cheating:**
  - Session only counts if the app was in active/foreground state during the session (verified via app state tracking).
  - If app goes to background and session pauses, paused time doesn't count.
  - Minimum session validation: session data includes timestamps, technique ID, and expected duration. Backend validates that completed session duration is plausible.
  - Rate limiting: Maximum 10 sessions per day counted toward leaderboard metrics.
  - Silent shadow-ban: If backend detects suspicious patterns (e.g., perfectly identical session durations repeatedly, impossible BPM completions), user is silently excluded from leaderboard without notification.
- **Moderation (Phase 1.5):**
  - Basic profanity filter on display names (blocklist-based).
  - "Report user" button on leaderboard profiles.
  - Flagged/reported names auto-hidden and queued for manual review (by Rahul).

### 8.4 Audio System

**Three audio layers (independently controllable):**

1. **Transition cues:** Soft bell/chime/tone at each phase change (inhale→hold, hold→exhale, etc.) for slow techniques. Tick/beat for rapid techniques. Always on by default. This is the primary "eyes-closed" guidance mechanism.
2. **Background soundscape:** Ambient sounds (rain, forest, singing bowls, ocean, silence). User selects from 5-8 options. Off by default. Toggleable during session.
3. **Voice guidance (Phase 2):** Optional spoken instructions ("Inhale... Hold... Exhale..."). Not in MVP — cues + animation + haptics are sufficient.

**Audio behavior:**

- Plays via expo-av with native audio session configuration
- **Background audio mode enabled** — audio continues when screen is locked or app is in background (configured via iOS Audio Session Category and Android audio focus)
- Lock-screen controls (pause/stop) via native media session integration
- Audio files bundled with app for core cues, downloaded from Supabase Storage for soundscapes
- Soundscapes cached locally after first download for offline use

**Audio format:** AAC primary (native iOS/Android support, smaller file size than MP3, gapless playback). MP3 fallback. Soundscape files are 2-3 min seamless loops.

**Audio style:** Minimal and soothing. No "yoga teacher" voiceover in MVP. Clean, short tones for transitions.

**Sourcing:** Royalty-free (Freesound, Pixabay) + AI-generated (with commercial license). All audio vetted for licensing before inclusion.

### 8.5 Haptic Feedback (Native Advantage)

- **Phase transitions:** Gentle haptic pulse when switching between inhale/hold/exhale phases
- **Rapid techniques:** Rhythmic haptic ticks synced to metronome beat (Kapalbhati/Bhastrika)
- **Session complete:** Success haptic pattern
- **Configurable:** Users can toggle haptics on/off in settings (default ON)
- **Implementation:** expo-haptics with different intensity levels per event type

### 8.6 Offline Support

**Native offline-first architecture:**

- All exercise configurations bundled with the app (JSON assets)
- Core transition cue audio files bundled with app binary
- Soundscape audio files downloaded on first play, cached in app storage
- All session data stored locally in SQLite, synced to Supabase when online
- Streaks calculated locally when offline, reconciled with server when back online

**What works offline:** All breathing exercises, animations, bundled audio, local streak tracking, stats

**What requires connection:** Leaderboard, initial sign-in, first-time soundscape download, data sync

### 8.7 Push Notifications

- **Daily practice reminders:** Local notifications at user-chosen time (e.g., "Time for your morning breathwork 🌅")
- **Streak reminders:** "You haven't practiced today — don't lose your 7-day streak!" (sent 2 hours before midnight if no session logged)
- **Implementation:** expo-notifications for local scheduling, Expo Push Service for remote notifications (Phase 2)
- **Permission:** Requested after first completed session (not on app launch — reduces rejection rate)
- **Configurable:** Full control in settings — toggle reminders, set preferred time, disable all

### 8.8 Safety & Disclaimers

- **Global disclaimer** in app settings/about screen: "ClearBreath is for wellness and relaxation purposes only. It is not medical advice and does not diagnose, treat, cure, or prevent any disease. Consult a healthcare professional before starting any breathing practice if you have existing health conditions."
- **Emergency guidance** in global disclaimer: "If you experience severe dizziness, chest pain, difficulty breathing, or any alarming symptoms during practice, stop immediately and seek medical attention."
- **Per-technique warnings:** Kapalbhati, Bhastrika, and Ultra-Slow (<2 BPM) show mandatory one-time interstitial warning screen before first session of that technique:
  - List of contraindications specific to that technique
  - "I understand, continue" button (stored in local preferences so it only shows once per technique)
  - "Stop if you feel dizzy, lightheaded, or uncomfortable" reminder
  - These techniques are VISIBLE to all user levels (not locked behind Advanced onboarding), but the warning gate is mandatory.
- **In-session safety:** If user has been in a forceful-technique session for >10 minutes continuously (abnormally long for Kapalbhati/Bhastrika), gentle prompt: "You've been going for a while. Consider taking a break."
- No onboarding health questionnaire — too much friction for guest-first. Contraindications are shown per-technique instead.
- **Cultural guidelines:** ClearBreath avoids culturally sensitive traditional guidelines (e.g., menstruation restrictions). Safety guidance is based purely on medical contraindications and physical comfort.
- **Age restriction:** 13+ (standard for apps with user accounts and leaderboards). Set in App Store/Play Store metadata.
- No medical claims anywhere. All benefit descriptions use "may help with," "traditionally used for," "commonly practiced for" language.

---

## 9. Key Technical Decisions

### 9.1 Timer Precision

Breathing timer accuracy is critical — a 10-minute session cannot drift.

- **React Native Reanimated** runs animations on the native UI thread, independent of JavaScript thread. This eliminates the JS timer drift problem entirely for visual animations.
- **Audio cue scheduling** uses native audio engine timing (expo-av playback position callbacks), not JavaScript `setTimeout`.
- Both visual and audio are driven by a single elapsed-time source of truth, ensuring perfect sync.

### 9.2 Background Audio

Native mobile solves the biggest pain point from the PWA approach:

- **iOS:** Audio Session configured with `.playback` category — audio continues when screen locks or app backgrounds. Lock screen shows playback controls.
- **Android:** Audio focus requested with `AUDIOFOCUS_GAIN` — audio continues in background with foreground service notification showing controls.
- No hacks needed. No silent keepalive tracks. It just works.

### 9.3 Animation Approach

- **Slow techniques (≤12 BPM):** React Native Reanimated `withTiming` / `withSequence` driving circle scale transform on native thread. Buttery 60fps even during heavy JS work.
- **Rapid techniques (>12 BPM):** Reanimated `withSpring` or `withTiming` for quick "bump" animations synced to audio tick. No strobe effect.
- **Hold phases:** Circle holds at current scale with subtle `withRepeat` glow/pulse opacity animation.

### 9.4 Offline Sync & Data Merge

Every session gets a `client_session_id` (UUID v4, generated on device at session start). This is the deduplication key.

**Guest mode:** All data in local SQLite database.

**On sign-in (first time):**

1. App collects all local sessions from SQLite.
2. Sends them to a Supabase Edge Function (`/sync`).
3. Server inserts sessions with conflict resolution on `client_session_id` — automatic dedup.
4. Server recalculates streak from the full merged session history.
5. Server returns authoritative streak count + stats. App updates local state.

**Two-device conflict:** Both devices append their sessions. Server deduplicates by `client_session_id`. Streak is always recalculated from the full session list. No data loss, eventually consistent.

### 9.5 Content Configuration

- **Phase 1:** All exercise configs bundled as JSON assets in the app. Updating requires an app update (or OTA update via EAS Update — no App Store review needed for JS-only changes).
- **Phase 2:** Move configs to Supabase (remote JSON). App fetches on launch with local cache fallback. This allows updating technique timings, descriptions, and audio mappings without any app update.
- **About cards:** Written by Rahul only. No community-generated content.

---

## 10. Phased Roadmap

### Phase 1 — MVP (Core Breathing Experience)

**Goal:** A complete, polished breathing app that works beautifully for solo practice. No accounts, no social. Ship to both App Store and Play Store.

**Features:**

- Native iOS + Android app via React Native (Expo)
- Onboarding flow (3 screens: level, goal, welcome)
- Guest mode (zero sign-up, all data local in SQLite)
- Home screen with "Today's Practice" (curated recommendation based on level + goal + time of day)
- "Browse All Techniques" library (11 techniques with About cards)
- 3 preset levels per technique (beginner/intermediate/advanced)
- Full breathing session experience:
  - Expanding circle animation for slow techniques (Reanimated, native thread)
  - Pulsing dot/metronome for rapid techniques
  - Precision timer synced audio + visual
  - Phase labels and timers
  - Audio transition cues (bells/tones for slow, ticks for rapid)
  - 5-8 background soundscapes (selectable, AAC format)
  - True background audio (native audio session — no hacks)
  - Lock-screen playback controls
  - Haptic feedback at phase transitions
  - Screen stay-awake during sessions
  - Forced rest timers between rounds (Kapalbhati/Bhastrika)
  - Holds (kumbhaka) included in all applicable technique presets
- Session completion screen with summary
- Streak tracking (≥1 min session = 1 day)
- Basic stats screen (total minutes, sessions, current streak, longest streak, weekly chart, by-technique breakdown)
- Per-technique contraindication warnings and safety interstitials (one-time gate)
- Global disclaimer + emergency guidance
- Offline support (bundled exercise configs + cue audio, downloaded soundscapes cached)
- Local push notifications (daily practice reminder, streak reminder)
- PostHog analytics (anonymous events only) + Sentry error tracking + native crash reporting
- Privacy Policy + Terms of Use screens
- App Store Optimization (ASO): keyword-rich title, description, screenshots, category selection
- Landing page at clearbreath.life (simple marketing page linking to App Store / Play Store)

**NOT in Phase 1:** Google/Apple sign-in, leaderboard, voice guidance, curated programs, admin panel, wearable integration, widgets.

### Phase 1.5 — Auth & Leaderboard

**Goal:** Social motivation layer. Separated because leaderboard needs auth, and core experience should be validated first.

**Features:**

- Google OAuth + Apple Sign-In via Supabase Auth
- Soft sign-in prompts (after 3 sessions, when tapping leaderboard, in settings)
- Local → cloud data sync on sign-in (smart merge: dedupe by client_session_id, recalculate streak server-side)
- User profile screen (customizable display name, avatar, stats)
- Global leaderboard:
  - Default: current streak ranking
  - Filterable: total minutes all-time, total minutes this week
  - Top 50 display + user's own rank always pinned
  - Opt-in visibility toggle (default OFF)
  - Option to show initials only
- Leaderboard anti-cheat (session validation, rate limiting, silent shadow-ban)
- Basic profanity filter on display names
- "Report user" button
- Server-side streak calculation (UTC + timezone offset)
- Data export option (download your data as JSON)

### Phase 2 — Curated Programs & Social (Future Premium Layer)

**Goal:** Build the content layer that becomes the monetization vehicle.

**Features:**

- Curated programs/journeys (key Phase 2 deliverable — structured multi-day courses):
  - "7-Day Calm Starter" (beginner — Diaphragmatic → Box → 4-7-8, progressive difficulty)
  - "14-Day HRV Mastery" (intermediate-advanced — HRV Resonance progression from 6 BPM down to 4.5 BPM)
  - "21-Day Pranayama Journey" (progressive, introduces all techniques week by week)
  - "30-Day Sleep Protocol" (evening-focused — 4-7-8, Bhramari, Ujjayi, Yogic breathing)
  - "Morning Energy Ritual" (7 days — Kapalbhati, Bhastrika, energizing sequences)
- Program tracking UI (day progress bar, completion percentage, "Day X of Y" display)
- Programs unlock sequentially (must complete Day 1 before Day 2) to maintain structure
- Voice-guided sessions (optional toggle — AI-generated voice instructions layered on existing audio)
- Hindi language support (UI + audio)
- Streak freeze (1 per week, toggle in settings)
- Share-to-social (generate ClearBreath streak card for Instagram/Twitter/WhatsApp — native share sheet)
- Remote push notifications via Expo Push Service
- Friends leaderboard (invite by link/share, separate tab from global)
- "Coach logic" — adaptive recommendations based on full practice history
- Enhanced stats: progress line charts over time, monthly summary
- Remote exercise configuration (Supabase, editable without app update)

### Phase 3 — Advanced Native Features & Growth

**Goal:** Leverage native platform capabilities for deeper engagement.

**Features:**

- iOS Widget (home screen streak counter + quick-start button)
- Android Widget (same)
- Apple Watch companion app (start session from wrist, haptic breathing guide)
- Siri Shortcuts integration ("Hey Siri, start my breathing practice")
- Android Quick Settings tile
- Wearable integration (Apple Watch, Fitbit — read actual HRV data to show biometric improvement)
- Biometric dashboard (HRV score trends correlated with practice sessions)
- Admin panel (web-based) for managing exercises, audio, programs, user reports
- App Store Optimization refinement based on data

### Phase 4 — Monetization & Advanced Features

**Goal:** Revenue without breaking the free core experience.

**Features:**

- Freemium model:
  - **Free forever:** All 11 core techniques, all presets, streaks, basic stats, global leaderboard
  - **Premium:** Curated programs, voice guidance, advanced stats/charts, streak freeze, custom/premium soundscapes, friends leaderboard
- Payment integration:
  - iOS: In-App Purchases via StoreKit (Apple takes 30%/15% cut)
  - Android: Google Play Billing (Google takes 30%/15% cut)
  - Consider RevenueCat SDK for unified cross-platform subscription management
- Community features (shared routines, community challenges with prizes/badges)
- "Tip Jar" / voluntary donation option
- B2B play: "Breathing exercises for your team" — corporate wellness offering
- Multi-language expansion (Gujarati, Hindi, Spanish)

---

## 11. Unique Selling Points (Why ClearBreath)

1. **The only app with serious low-BPM breathing tools.** HRV resonance (5-6 BPM) AND ultra-slow (1-3 BPM) training with precision-synced animations. No competitor does this.
2. **Complete pranayama library in one place.** From beginner belly breathing to advanced Bhastrika — 11 techniques with proper presets, safety warnings, and educational cards.
3. **Zero friction to start.** No sign-up wall. Download, open, and breathe in under 30 seconds.
4. **Streak + leaderboard motivation.** Breathing apps lack any social/gamification layer. ClearBreath adds it thoughtfully with privacy-first defaults.
5. **Authentic technique education.** Proper "About" cards with traditional context, not just "breathe in, breathe out."
6. **Free.** No paywall for core functionality. No ads. Ever in core experience. (Premium programs come later.)
7. **Beautiful, eyes-closed friendly UX.** Audio cues + haptic feedback are sufficient to follow any exercise without looking at the screen.
8. **True native experience.** Silky smooth 60fps animations, reliable background audio, haptic feedback, push notifications, lock-screen controls — no browser compromises.

---

## 12. Competitive Landscape

| App | Strengths | Weaknesses (Our Opportunity) |
|-----|-----------|------------------------------|
| Calm | Beautiful design, brand recognition | Breathing is a side feature, no pranayama depth, $70/yr |
| Headspace | Good UX, guided content | Same — breathing is secondary, expensive subscription |
| Breathwrk | Dedicated breathing app | Limited technique library, no HRV/ultra-slow, no leaderboard |
| Prana Breath | Pranayama-focused | Dated UI, poor UX, no social features, Android only |
| Oak (Meditation) | Clean, free | Very basic breathing (only box + deep), no progression |
| Generic timer apps | Free | No guidance, no animation, no education, no motivation |

**ClearBreath's position:** The intersection of "authentic pranayama depth" + "modern native UX" + "social motivation" + "free" that doesn't exist today.

---

## 13. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| App Store rejection | High | Follow Apple/Google guidelines strictly; no medical claims; proper privacy disclosures; test on TestFlight/Internal Testing before submission |
| Apple 30% cut on premium | Medium | Accept for Phase 4; consider web-based subscription flow for direct billing (like Spotify) |
| JS timer drift on React Native | Low | Reanimated runs on native thread; audio scheduling via native engine; much less of a concern than web browsers |
| Low user retention after initial excitement | High | Streaks, curated "Today" recommendations, push notification reminders, haptic engagement |
| Audio licensing issues | Medium | Vet every audio file for licensing before inclusion; prefer CC0/public domain |
| Supabase free tier limits hit | Medium | Architecture supports migration to self-hosted Postgres; monitor usage early |
| Safety/liability (user injury during Kapalbhati) | Medium | Prominent disclaimers, per-technique interstitials, "not medical advice" everywhere, emergency guidance text |
| HRV credibility risk (overpromising) | Medium | Separate HRV resonance vs ultra-slow terminology; never claim "improves HRV"; use "commonly used in" language |
| React Native performance for complex animations | Low | Reanimated 3 runs on native thread; breathing circle is a simple scale transform; tested to 60fps |
| Two-platform testing burden (solo dev) | Medium | Expo managed workflow minimizes platform differences; focus testing on iOS first (stricter), Android follows |
| Leaderboard abuse (fake names, cheating) | Medium | Profanity filter, report button, shadow-ban, session validation, rate limiting |
| Offline→online sync data loss | Medium | Smart merge with client_session_id dedup; server recalculates streak from full history |
| Scope creep | High | Strict phase gating. Ship Phase 1 before touching Phase 1.5. |
| App Store review delays | Medium | Submit early, expect 1-3 day reviews, use TestFlight/Internal Testing for beta users while waiting |

---

## 14. Content & Audio Plan

### Audio Assets Needed for MVP

**Transition Cues (5 variations):**
- Soft bell (Tibetan singing bowl style)
- Gentle chime
- Soft sine tone (warm, round)
- Wooden knock (soft)
- Water drop

**Metronome Ticks (for rapid techniques, 2-3 variations):**
- Soft click
- Gentle tap
- Subtle beat

**Background Soundscapes (6-8 options):**
- Rain (gentle, no thunder)
- Forest/birds (morning ambiance)
- Ocean waves (slow, rhythmic)
- Singing bowls (continuous drone)
- Silence (no background — always available)
- White noise (soft)
- Night crickets
- Fireplace crackle

**Audio Format:** AAC primary (native gapless support on both platforms). MP3 fallback. 128kbps. Soundscapes are 2-3 min seamless loop files.

**Bundling strategy:**
- Transition cues + metronome ticks: Bundled with app binary (~2-5MB total) — always available offline
- Soundscapes: Downloaded from Supabase Storage on first play (~5-10MB each), cached locally
- Total estimated audio storage: ~50-100MB across all assets

### Exercise Configuration

All 11 techniques defined as JSON config files bundled with the app:

- Technique ID, name, slug, description, difficulty
- Preset levels with exact timing ratios (inhale/hold/exhale/hold in seconds)
- BPM value (for rapid techniques)
- Rounds + rest duration (for round-based techniques)
- Animation mode flag (circle vs metronome)
- Contraindication tags (array of strings)
- Safety gate required (boolean)
- Cue text strings per phase
- Haptic pattern per phase (intensity + duration)
- Recommended soundscape pairings
- About card content (what, benefits, how-to, best time, warnings)

---

## 15. Legal & Privacy

### Privacy Policy (Required before App Store submission)

- **Guest mode:** No PII collected. Anonymous analytics events (screen views, session starts/completions, technique used). Device data: none.
- **Signed-in mode:** Google/Apple profile info (name, email, avatar). Session data. Streak data. Display name.
- **Analytics:** PostHog, anonymous events only. No session replay in MVP. No selling data. No ads.
- **Data deletion:** Users can request data deletion. "Delete my account" button in settings (Phase 1.5). Wipes all server-side data. Compliant with Apple's account deletion requirement.
- **Data export:** JSON download of all sessions + profile (Phase 1.5).
- **App Tracking Transparency (iOS):** ClearBreath does NOT track users across other apps. No ATT prompt needed. PostHog analytics are first-party, anonymized.

### Terms of Use

- Standard "use at your own risk" wellness app terms.
- Not medical advice disclaimer.
- 13+ age requirement (set in App Store/Play Store).
- Acceptable use policy for leaderboard (no offensive names, no cheating).
- Right to shadow-ban or remove users from leaderboard.

### App Store Compliance

- **Apple:** Privacy nutrition labels filled accurately. No ATT required. Health & Fitness category. 13+ age rating.
- **Google Play:** Data safety section filled accurately. Health & Fitness category. "Everyone" rating with content descriptors.
- **Both:** Privacy policy URL required at submission (hosted at clearbreath.life/privacy).

---

## 16. Launch Strategy

### App Store Distribution

- **iOS:** Submit to App Store via EAS Submit. Category: Health & Fitness. Free app.
- **Android:** Submit to Google Play via EAS Submit. Category: Health & Fitness. Free app.
- **Beta testing:** TestFlight (iOS) + Google Play Internal Testing before public launch.
- **Phased rollout:** Google Play supports staged rollout (10% → 50% → 100%). Use it.

### Marketing & Community

- **Reddit:** r/pranayama, r/breathing, r/Breathwork, r/HRV, r/biohacking, r/yoga, r/meditation
- **Twitter/X:** Dev build-in-public thread, wellness/yoga communities
- **Product Hunt:** Submit when Phase 1.5 (with leaderboard) is live
- **Indian wellness communities:** Facebook groups, WhatsApp groups, yoga studio partnerships
- **College network:** Rahul's BTech peers and college wellness clubs
- **Hacker News:** "Show HN" post when MVP is polished

Public launch from day one (no invite-only / beta gating — reduces friction, maximizes feedback).

### SEO Strategy (Landing Page)

clearbreath.life serves as marketing landing page + App Store redirect. Build keyword-optimized pages:

- clearbreath.life/anulom-vilom-timer
- clearbreath.life/kapalbhati-counter
- clearbreath.life/coherent-breathing-5-5-bpm
- clearbreath.life/478-breathing-timer
- clearbreath.life/box-breathing-timer
- clearbreath.life/hrv-resonance-breathing

Each page explains the technique + CTA to download ClearBreath from App Store / Play Store.

### App Store Optimization (ASO)

- **App Title:** "ClearBreath — Pranayama & Breathing"
- **Subtitle (iOS):** "HRV Training, Streaks & Guided Practice"
- **Keywords:** pranayama, breathing exercises, HRV, box breathing, 4-7-8, kapalbhati, anulom vilom, meditation, breathwork, stress relief
- **Screenshots:** 6 polished screenshots showing breathing animation, technique library, streak counter, stats, leaderboard
- **App Preview Video:** 15-30s showing a breathing session in action

---

## 17. Brand Identity

### RESOLVED ✅

- **App Name:** ClearBreath
- **Domain:** clearbreath.life
- **Brand Voice:** Clean, calm, confident. Not clinical. Not "woo-woo." The intersection of authentic tradition and modern technology.

### Still Open (To Be Resolved During Development)

1. ~~App name~~ — **RESOLVED: ClearBreath** (clearbreath.life)
2. **Exact animation style** — Circle (expanding/contracting) vs. wave (flowing line) vs. hybrid for slow techniques. To be decided during UI prototyping.
3. **Exact soundscape selections** — Final audio files chosen during content sourcing phase.
4. **"Today's Practice" algorithm** — Exact recommendation logic. Start simple (time-of-day + level + goal), iterate based on PostHog event data.
5. **Leaderboard refresh frequency** — Start with every 5 minutes (Supabase Edge Function cron). Move to Realtime if demand warrants.
6. **Color palette / brand identity** — To be decided alongside UI design. Consider: calming blues/teals, dark mode default for nighttime breathing sessions, high contrast for eyes-closed-friendly UI.
7. **Social media handles** — Secure @clearbreath or @clearbreathlife on Instagram, TikTok, X, YouTube.
8. **App icon design** — Clean, recognizable at small sizes. Consider: abstract breath/air motif, minimal color palette.

---

## 18. Social Media & Handle Checklist

| Platform | Target Handle | Status |
|----------|--------------|--------|
| Instagram | @clearbreath or @clearbreathlife | TBD — Check availability |
| TikTok | @clearbreath or @clearbreathlife | TBD — Check availability |
| X (Twitter) | @clearbreath or @clearbreathlife | TBD — Check availability |
| YouTube | @clearbreath | TBD — Check availability |
| GitHub | clearbreath | TBD — Check availability |

---


