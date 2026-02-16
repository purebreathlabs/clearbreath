# ClearBreath — Product Requirements Document (PRD)

**Brand Name:** ClearBreath
**Domain:** clearbreath.life
**Tagline:** Breathe with intention.
**Last updated:** February 16, 2026
**Primary stack:** Flutter (Riverpod, go_router, Drift) + Go (Chi, PostgreSQL, Redis)
**Execution source of truth:** docs/final_plan.md

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

**Verdict: Flutter native apps (iOS + Android)**

### Why Flutter

- **Single codebase** for iOS and Android — critical for a small team
- **Deterministic rendering** (Impeller) with smooth 60–120fps visuals — the breathing animation is the product
- **Strong animation primitives** (AnimationController, CustomPainter) for precise phase pacing and high contrast visuals
- **Offline-first friendly** with SQLite + Drift and predictable local persistence
- **Mature platform integrations** for background audio, lock-screen controls, haptics, notifications, secure storage, keep-awake
- **Architecture fit** with Riverpod + go_router + Drift as the primary stack

### Why not PWA (previous direction)

- Background audio unreliable on iOS Safari
- No true push notifications without complex Web Push setup
- No haptic feedback in browsers
- PWA install friction and weaker app-store discovery
- Service Worker caching and IndexedDB edge cases are harder to reason about than a local SQLite store

### Why not React Native (for this product)

- Timing-sensitive session guidance benefits from Flutter’s single runtime and frame scheduling (no JS/native bridge in the hot path)
- Background audio + lock-screen behavior is easier to keep consistent across devices with common Flutter audio stacks
- Store-release driven updates keep technique configs, safety gates, and UX behavior tightly versioned

### Native Advantages (Unlocked from Day 1)

- **Reliable background audio** and lock-screen controls
- **Local reminders** and notifications with best-practice permission timing
- **Haptic feedback** for phase transitions
- **Offline-first by default** with local persistence and later cloud sync
- **App Store discoverability** with ratings, reviews, and ASO

---

## 5. Tech Stack

### Mobile App (Flutter)

- **Framework:** Flutter
- **Language:** Dart
- **State management:** Riverpod
- **Navigation:** go_router (with route guards for locked flows)
- **Local database:** Drift (SQLite) for sessions, settings, favorites, streak cache, sync queue
- **Animations:** Flutter animation system (AnimationController / Ticker) + CustomPainter where needed (Impeller renderer)
- **Audio + background:** just_audio + audio_service (+ audio_session) for background playback and lock-screen controls
- **Haptics:** HapticFeedback (+ optional vibration patterns)
- **Notifications:** flutter_local_notifications (daily reminder + streak warning)
- **Secure storage:** flutter_secure_storage (refresh tokens)
- **Keep awake:** wakelock_plus (during active sessions when enabled)
- **Testing baseline:** unit tests for session/streak logic + widget/integration tests for core flows (mirrors docs/final_plan.md)

### Backend (Go API)

- **HTTP:** Go + Chi
- **Database:** PostgreSQL (Neon)
- **Cache/rate limiting:** Redis (Upstash)
- **Migrations:** goose
- **Query layer:** sqlc (recommended) + repository boundaries
- **Auth:** verify Apple/Google provider tokens, issue short-lived JWT access tokens + rotating refresh tokens; hashed refresh tokens at rest
- **Leaderboard:** Redis sorted sets refreshed on a 5-minute cadence, profanity filtering, silent shadow-ban support, daily contribution caps

### Website

- **Astro** for landing page, Privacy, Terms, and 12 SEO pages

### Storage & Assets

- **Cue audio:** bundled with app for offline availability
- **Soundscapes:** hosted on Cloudflare R2 (S3-compatible) and downloaded/cached on first play
- **Audio format:** AAC primary, MP3 fallback

### Analytics & Monitoring

- **Analytics:** minimal anonymous event analytics with opt-out toggle
- **Crash/error tracking:** not included in v1
- **Backend ops:** structured logs + health/readiness endpoints

### Deployment & CI/CD

- **Backend deploy:** Docker on a Hetzner VPS behind Caddy
- **CI checks:** backend lint/tests, Flutter analyze/tests, web build validation
- **Target submission:** App Store / Play Store submission by March 31, 2026

### Estimated Costs (MVP)

| Service | Free Tier | Cost After |
|---------|-----------|------------|
| Apple Developer Program | — | $99/year |
| Google Play Developer | — | $25 one-time |
| Neon Postgres | Free tier | Usage-based |
| Upstash Redis | Free tier | Usage-based |
| Hetzner VPS | — | Low monthly cost (single VPS) |
| Cloudflare R2 | Free tier | Usage-based |
| Analytics (event-only) | Free tier | Usage-based |

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

- **Slow breathing (≤12 BPM):** Expanding/contracting circle animation (smooth, meditative) — powered by Flutter’s animation engine (AnimationController / Ticker)
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
- **Mid-round stop:** If user stops mid-round, partial session still counts (time spent is logged). Session marked as incomplete but contributes to daily total minutes and can help qualify the streak (≥2 minutes/day).
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

ClearBreath uses four bottom tabs: Home, Techniques, Stats/Profile, Leaderboard. The Leaderboard tab is visible but locked for guests.

### 7.1 First-Time User Flow (Guest Mode)

1. User downloads ClearBreath from App Store / Play Store → App opens
2. Splash screen with subtle breathing pulse animation
3. Seven-question onboarding (one question per screen, <2 minutes total):
   - Experience level (Beginner/Intermediate/Advanced)
   - Primary goal (Calm, Sleep, Focus, Energy, HRV, Spiritual)
   - Typical practice window (Morning/Afternoon/Evening/Varies)
   - Typical session length (2/5/10/20 min)
   - Haptics preference (On/Off)
   - Keep-screen-awake preference (On/Off)
   - Daily reminder preferred time
4. Home screen loads with Today’s Practice card and one primary Start button
5. User can start breathing immediately — zero sign-up required
6. All session data stored locally (Drift/SQLite) until they choose to sign in
7. OS notification permission prompt happens only after the first completed session

### 7.2 Daily Practice Flow (Returning User)

1. Open ClearBreath → Home tab
2. Today’s Practice recommendation based on:
   - Experience level and goal
   - Daypart (Morning 5–11, Afternoon 11–17, Evening 17–22, Night 22–5)
3. Start from Today’s Practice, goal shortcuts, or favorites
4. Browse Techniques tab to explore the full library
5. Tap technique → see detail (what it is, how to do it, contraindications) and presets
6. Tap preset → 3-2-1 countdown → Session begins

### 7.3 Active Session Flow

1. Pre-session countdown (3-2-1)
2. Full-screen breathing guide:
   - Slow techniques (≤12 BPM): breathing circle animation (expands on inhale, contracts on exhale, pauses on hold)
   - Rapid techniques (>12 BPM): pulsing metronome visual synced to pace
   - Phase label and timing (INHALE / HOLD / EXHALE / HOLD)
   - In-session sound controls: volume slider + mute
   - Pause/resume and end-early controls
   - Optional background soundscape (toggleable)
   - Phase-start audio cues (soft chimes for slow, ticks for rapid)
   - Haptic pulses at phase transitions (if enabled)
3. Eyes-closed friendly: large visuals, high contrast, audio + haptic cues are sufficient to follow without looking
4. Keep screen awake during active sessions when enabled
5. Background and lock behavior:
   - Session continues when app goes background and when phone locks
   - Lock-screen controls expose pause and stop
   - Audio interruptions auto-pause session and show interruption state upon return
6. Session complete → Completion screen:
   - Technique + preset summary
   - Actual practiced minutes + estimated breaths completed
   - Streak result (daily streak qualifies at ≥2 total minutes per local day)
   - Share streak card CTA
   - Prompt to sign in (guest) for cloud backup and leaderboard access

### 7.4 Technique "About" Card

Each technique has a short educational card accessible from the library:

- What it is (2-3 sentences)
- Benefits (careful wording — "may help with," "traditionally used for," NEVER medical claims)
- How to do it (step-by-step, brief)
- Best time of day
- Contraindications/warnings (if applicable)
- Difficulty badge

### 7.5 Auth Flow

- **Guest mode (default):** Everything works. Sessions tracked locally.
- **Sign-in policy:** Optional. Required only for leaderboard participation and cloud backup.
- **Providers:** Apple Sign-In and Google Sign-In.
- **Age gate:** Ask birth year before sign-in. If under 13, block sign-in and leaderboard participation, keep guest mode fully usable.
- **Prompts:** After 3 guest sessions, and when tapping the locked Leaderboard tab.
- No email/password.

---

## 8. Feature Specifications

### 8.1 Streak System

- **Definition:** A daily streak increments if total practiced time for the local day is at least 2 minutes (across any sessions and techniques).
- Partial sessions still count toward total minutes and can qualify a streak.
- **Timezone:**
  - Guest mode: Device local time.
  - Signed-in users: Server calculates streaks from UTC timestamps plus a submitted timezone offset per session.
  - Travel edge case: Streak is computed per local calendar day as derived from the session’s timezone offset, avoiding double counting.
- **Streak break:** Missing an entire calendar day (no qualifying session) resets the streak to 0.
- **Display:** Streak counter visible on home screen. Streak badge/number next to profile.

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
- Estimated breaths completed (session and aggregate)

**Weekly definition:** Week starts Monday in the user-local timezone.

**Display:** Stats/Profile tab (with Settings embedded inside Profile).

**Guest data:** Stored locally (Drift/SQLite). Syncs to the Go API on sign-in with server-side dedupe and authoritative recompute.

### 8.3 Leaderboard

- **Access:** Leaderboard tab is visible for all users. Guests see a locked state with a sign-in gate.
- **Eligibility:** Sign-in required. Under-13 users are blocked from sign-in and leaderboard participation, but guest mode remains fully usable.
- **Views:** Current streak (default), Weekly minutes, All-time minutes.
- **Display rules:**
  - Top 50 list
  - User’s own rank pinned even outside top 50
  - Display name or initials based on user preference
- **Privacy defaults:**
  - Leaderboard visibility defaults ON for signed-in users (opt-out available)
  - Display names are validated and profanity filtered
- **Refresh:** Rankings refreshed on a 5-minute server cadence.
- **Integrity/anti-cheat:**
  - Validate session plausibility against preset bounds and timestamps
  - Daily cap applies to leaderboard minute contribution (streak/stats remain uncapped)
  - Rate limit leaderboard reads to reduce scraping
  - Silent shadow-ban support for suspicious patterns
- **Moderation v1:** Profanity filter only (no report workflow in v1).

### 8.4 Audio System

**Three audio layers (independently controllable):**

1. **Transition cues:** Soft bell/chime/tone at each phase change (inhale→hold, hold→exhale, etc.) for slow techniques. Tick/beat for rapid techniques. Always on by default. This is the primary "eyes-closed" guidance mechanism.
2. **Background soundscape:** Ambient sounds (rain, forest, singing bowls, ocean, silence). User selects from 5-8 options. Off by default. Toggleable during session.
3. **Voice guidance (Phase 2):** Optional spoken instructions ("Inhale... Hold... Exhale..."). Not in MVP — cues + animation + haptics are sufficient.

**Audio behavior:**

- Plays via a Flutter background-audio stack (e.g., audio_service + just_audio) with platform audio session configuration
- **Background audio mode enabled** — audio continues when screen is locked or app is in background
- Lock-screen controls expose pause and stop
- In-session controls include volume slider and mute toggle
- Cue audio bundled with the app for offline availability; soundscapes downloaded from Cloudflare R2 and cached locally

**Audio format:** AAC primary (native iOS/Android support, smaller file size than MP3, gapless playback). MP3 fallback. Soundscape files are 2-3 min seamless loops.

**Audio style:** Minimal and soothing. No "yoga teacher" voiceover in MVP. Clean, short tones for transitions.

**Sourcing:** Royalty-free (Freesound, Pixabay) + AI-generated (with commercial license). All audio vetted for licensing before inclusion.

### 8.5 Haptic Feedback (Native Advantage)

- **Phase transitions:** Gentle haptic pulse when switching between inhale/hold/exhale phases
- **Rapid techniques:** Rhythmic haptic ticks synced to metronome beat (Kapalbhati/Bhastrika)
- **Session complete:** Success haptic pattern
- **Configurable:** Users can toggle haptics on/off in settings (default ON)
- **Implementation:** Flutter haptics via platform HapticFeedback with a small set of consistent patterns

### 8.6 Offline Support

**Native offline-first architecture:**

- All exercise configurations bundled with the app (JSON assets)
- Core transition cue audio files bundled with app binary
- Soundscape audio files downloaded on first play, cached in app storage
- All session data stored locally in Drift/SQLite and synced to the Go API when signed in and online
- Streaks and stats are calculated locally for guests/offline and reconciled with server-authoritative values after sync

**What works offline:** All breathing exercises, animations, bundled audio, local streak tracking, stats

**What requires connection:** Leaderboard, initial sign-in, first-time soundscape download, data sync

### 8.7 Push Notifications

- **Daily practice reminders:** Local notifications at user-chosen time
- **Streak reminders:** "You haven't practiced today — don't lose your 7-day streak!" (sent 2 hours before midnight if no session logged)
- **Implementation:** flutter_local_notifications for local scheduling (remote push out of scope in v1)
- **Permission:** Requested after first completed session (not on app launch — reduces rejection rate)
- **Configurable:** Full control in settings — toggle reminders, set preferred time, disable all

### 8.8 Safety & Disclaimers

- **Global disclaimer** in app settings/about screen: "ClearBreath is for wellness and relaxation purposes only. It is not medical advice and does not diagnose, treat, cure, or prevent any disease. Consult a healthcare professional before starting any breathing practice if you have existing health conditions."
- **Emergency guidance** in global disclaimer: "If you experience severe dizziness, chest pain, difficulty breathing, or any alarming symptoms during practice, stop immediately and seek medical attention."
- **Per-technique warnings:** Kapalbhati, Bhastrika, and Ultra-Slow (<2 BPM) show mandatory one-time interstitial warning screen before first session of that technique:
  - List of contraindications specific to that technique
  - "I understand, continue" button (stored per technique and synced after sign-in so it remains one-time across devices)
  - "Stop if you feel dizzy, lightheaded, or uncomfortable" reminder
  - These techniques are VISIBLE to all user levels (not locked behind Advanced onboarding), but the warning gate is mandatory.
- **In-session safety:** If user has been in a forceful-technique session for >10 minutes continuously (abnormally long for Kapalbhati/Bhastrika), gentle prompt: "You've been going for a while. Consider taking a break."
- No onboarding health questionnaire — too much friction for guest-first. Contraindications are shown per-technique instead.
- **Cultural guidelines:** ClearBreath avoids culturally sensitive traditional guidelines (e.g., menstruation restrictions). Safety guidance is based purely on medical contraindications and physical comfort.
- **Account age gate:** Under 13 cannot sign in or join the leaderboard; guest mode remains fully usable.
- No medical claims anywhere. All benefit descriptions use "may help with," "traditionally used for," "commonly practiced for" language.

---

## 9. Key Technical Decisions

### 9.1 Timer Precision

Breathing timer accuracy is critical — a 10-minute session cannot drift.

- Use a **single monotonic elapsed-time source of truth** (Stopwatch/monotonic clock) to drive phase transitions.
- UI renders off that same elapsed time using Flutter’s **Ticker/AnimationController** (avoid `Timer`-driven animation state).
- Audio cues are triggered from the same elapsed-time model, with guardrails to avoid double-fire on pause/resume and interruptions.
- Acceptance gate: timing drift must remain within the v1 quality budget over long sessions (see docs/final_plan.md).

### 9.2 Background Audio

Native mobile solves the biggest pain point from the PWA approach:

- **iOS:** Audio Session configured with `.playback` category — audio continues when screen locks or app backgrounds. Lock screen shows playback controls.
- **Android:** Audio focus requested with `AUDIOFOCUS_GAIN` — audio continues in background with foreground service notification showing controls.
- No hacks needed. No silent keepalive tracks. It just works.

### 9.3 Animation Approach

- **Slow techniques (≤12 BPM):** Flutter AnimationController driving circle scale (and optional subtle glow) with consistent frame pacing.
- **Rapid techniques (>12 BPM):** Metronome pulse using short, non-strobing animations synced to the session engine.
- **Hold phases:** Circle holds at current scale with a minimal pulse to avoid perceived “freeze.”

### 9.4 Offline Sync & Data Merge

Every session gets a `client_session_id` (UUID v4, generated on device at session start). This is the deduplication key.

**Guest mode:** All data is stored locally (Drift/SQLite).

**On sign-in (first time):**

1. App collects all local sessions from Drift/SQLite.
2. Sends them to the Go API bulk sync endpoint.
3. Server upserts with conflict resolution on `client_session_id` (idempotent dedupe).
4. Server recalculates streak and stats from the merged history.
5. Server returns authoritative streak/stats snapshot. App updates local state.

**Two-device conflict:** Both devices append their sessions. Server deduplicates by `client_session_id`. Streak is always recalculated from the full session list. No data loss, eventually consistent.

### 9.5 Content Configuration

- **v1:** All exercise configs bundled as JSON assets in the app. Updates ship via store releases.
- **Future:** Versioned remote configs served by the Go API/CDN with local cache fallback, gated behind strict validation and rollback controls.
- **About cards:** Written by Rahul only. No community-generated content.

---

## 10. Roadmap

### v1 — MVP Scope (Submission by March 31, 2026)

**Goal:** A guest-first breathing app that is fully useful without login, with optional accounts for cloud backup and leaderboard participation.

**Mobile (Flutter):**

- 4-tab shell: Home, Techniques, Stats/Profile, Leaderboard (locked for guests)
- Strict black/white theme, Manrope typography, splash breathing pulse
- Onboarding: exactly 7 questions, one per screen; notification permission only after first completed session
- Technique library (11 techniques) with detail screens and one-time safety gates
- Session engine: countdown, phase scheduler, pause/resume, end early, slow/rapid visuals, phase-start cues, in-session volume + mute
- Background continuation + lock-screen controls + interruption handling
- Stats + streaks: daily streak qualifies at ≥2 minutes/day; Monday-start week; share streak card
- Local reminders: daily reminder + streak warning with per-toggle settings
- Guest-to-account merge and dedupe by `client_session_id`

**Backend (Go):**

- Auth: Apple/Google verification, access/refresh token lifecycle and rotation, age gate enforcement
- Sessions: ingest, validate, dedupe, aggregate, stats snapshot
- Leaderboard: streak/weekly/all-time views, top 50 + pinned self rank, opt-out visibility + initials-only preference
- 5-minute refresh cadence with Redis caching and anti-cheat baseline

**Website (Astro):**

- Landing page, Privacy, Terms, and 12 SEO pages (11 technique pages + breathing-for-sleep hub)

Execution plan and module breakdown live in docs/final_plan.md and are the delivery source of truth.

### Post-v1 Backlog

- Voice guidance
- Curated programs/journeys
- Friends/community features and moderation workflows
- Remote exercise configuration (versioned and validated)
- Wearables, widgets, Siri shortcuts
- Monetization (subscriptions, premium content)
- Multi-language support

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
| Session timing drift | Medium | Drive session state from a monotonic clock, keep audio/visual in sync, and enforce timing drift gates with unit/integration tests |
| Low user retention after initial excitement | High | Streaks, curated "Today" recommendations, push notification reminders, haptic engagement |
| Audio licensing issues | Medium | Vet every audio file for licensing before inclusion; prefer CC0/public domain |
| Background/lock behavior edge cases | High | Add device-matrix testing, cover interruptions, and validate lock-screen controls on both platforms |
| Infra/provider outages (VPS/Neon/Upstash) | Medium | Health checks, backups, retries, graceful degradation to offline guest mode, and a rollback runbook |
| Safety/liability (user injury during Kapalbhati) | Medium | Prominent disclaimers, per-technique interstitials, "not medical advice" everywhere, emergency guidance text |
| HRV credibility risk (overpromising) | Medium | Separate HRV resonance vs ultra-slow terminology; never claim "improves HRV"; use "commonly used in" language |
| Two-platform testing burden (solo dev) | Medium | Prioritize iOS first (stricter), keep an integration test suite for background/interruptions, and test on a small device matrix |
| Auth complexity (Apple/Google) | Medium | Implement provider verification and token rotation early, with end-to-end integration tests and rate limits |
| Leaderboard abuse (fake names, cheating) | Medium | Profanity filter, caps, shadow-ban, session validation, and rate limiting |
| Offline→online sync data loss | Medium | Smart merge with client_session_id dedup; server recalculates streak from full history |
| Scope creep | High | Enforce v1 must-ship boundaries and weekly scope discipline (per docs/final_plan.md) |
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
- Soundscapes: Downloaded from Cloudflare R2 on first play (~5-10MB each), cached locally
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
- **Signed-in mode:** Apple/Google identity linkage (provider subject), profile preferences (display handle, avatar seed, privacy flags), session data, streak/stats.
- **Analytics:** PostHog, anonymous events only. No session replay in MVP. No selling data. No ads.
- **Data deletion:** "Delete account" action in Profile/Settings wipes server-side data and revokes tokens (meets app store account deletion requirements).
- **App Tracking Transparency (iOS):** ClearBreath does NOT track users across other apps. No ATT prompt needed. PostHog analytics are first-party, anonymized.

### Terms of Use

- Standard "use at your own risk" wellness app terms.
- Not medical advice disclaimer.
- Accounts/leaderboard require 13+; under-13 sign-in is blocked via birth-year age gate while guest mode remains usable.
- Acceptable use policy for leaderboard (no offensive names, no cheating).
- Right to shadow-ban or remove users from leaderboard.

### App Store Compliance

- **Apple:** Privacy nutrition labels filled accurately. No ATT required. Health & Fitness category. Age rating aligned with account/leaderboard policy.
- **Google Play:** Data safety section filled accurately. Health & Fitness category. Age/content rating aligned with account/leaderboard policy.
- **Both:** Privacy policy URL required at submission (hosted at clearbreath.life/privacy).

---

## 16. Launch Strategy

### App Store Distribution

- **Target submission:** March 31, 2026. Public launch in April 2026.
- **iOS:** Submit via App Store Connect. Category: Health & Fitness. Free app.
- **Android:** Submit via Google Play Console. Category: Health & Fitness. Free app.
- **Beta testing:** TestFlight (iOS) + Google Play Internal Testing before public launch.
- **Phased rollout:** Google Play supports staged rollout (10% → 50% → 100%). Use it.

### Marketing & Community

- **Reddit:** r/pranayama, r/breathing, r/Breathwork, r/HRV, r/biohacking, r/yoga, r/meditation
- **Twitter/X:** Dev build-in-public thread, wellness/yoga communities
- **Product Hunt:** Submit after v1 public launch
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
- **Visual direction:** Strict black background with white text/lines only
- **Typeface:** Manrope
- **Splash:** Subtle breathing pulse animation
- **Core visuals:** Breathing circle for slow techniques, metronome pulse for rapid techniques

### Still Open (To Be Resolved During Development)

1. ~~App name~~ — **RESOLVED: ClearBreath** (clearbreath.life)
2. **Exact soundscape selections** — Final audio files chosen during content sourcing phase.
3. **"Today’s Practice" algorithm tuning** — Baseline daypart/goal/level mapping is defined; iterate the mapping and rationale text based on real usage signals.
4. **Social media handles** — Secure @clearbreath or @clearbreathlife on Instagram, TikTok, X, YouTube.
5. **App icon design** — Clean, recognizable at small sizes. Consider: abstract breath/air motif, minimal monochrome palette.

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
