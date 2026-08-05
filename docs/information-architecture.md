# Information Architecture — Tadabbur

## Navigation Model

**Bottom tab bar, 4 tabs** (kept deliberately shallow — this audience includes low-tech-literacy users like Aisha, so navigation depth is a real accessibility concern, not just a style choice):

1. **Learn** — the curriculum path (default landing tab)
2. **Review** — SRS queue ("Muraja'ah"), badge shows count due today
3. **Tutor** — AI Q&A, contextual to recent lessons
4. **Progress** — streaks, XP, achievements, mastery milestones

Profile/Settings is reached via an avatar icon in the top-right corner of every tab, not a 5th tab — it's not a daily-use destination.

The **AI Tutor is also surfaced contextually**: every exercise screen has a persistent "Ask" affordance that opens the Tutor pre-loaded with the current word/verse/grammar point as context, in addition to its own tab for reviewing past Q&A. This matters because a buried "AI tutor" tab gets ignored (this is the #1 discovery failure mode in apps that bolt on AI chat as a separate destination) — the contextual entry point is what actually drives usage of the differentiating feature.

## Content Hierarchy

```
Track (Quranic Arabic — only track in v1)
 └─ Unit (one short surah, or a thematic vocab/grammar cluster e.g. "Names of Allah appearing in Juz Amma")
     └─ Lesson (5-10 min session: new material + practice, sequenced by curriculum)
         └─ Exercise (atomic activity — see types below)
             └─ SRS Item (individual word / root-pattern / grammar rule generated from exercises,
                           reviewed independently in the Review tab on its own spaced schedule)
```

Exercise types (the building blocks every Lesson is composed from): vocab-card intro, grammar micro-explanation, guided reading passage, listening drill, pronunciation/Tajweed recording, recall quiz, unseen-surah mastery challenge (a special exercise type gating unit completion).

## Screen Map

### Pre-auth / Onboarding (not in tab bar; linear flow, exits into main app)
1. Welcome / brand intro
2. Motivation selection ("Why are you learning?" — faith practice / heritage / academic / curiosity — informs tutor tone and notification copy, not routing)
3. Placement test intro
4. Placement — script literacy check
5. Placement — recitation fluency check
6. Placement — vocabulary/grammar check
7. Placement result → recommended starting unit, shown with a short rationale ("You already recite fluently, so we're starting with meaning, not letters")
8. **First lesson runs immediately, before account creation** — gets Aisha/Omar to an emotional win before asking for signup friction
9. Account creation (Apple/Google/email) — framed as "save your progress," not a gate
10. Notification permission + location/prayer-time consent (clearly explained why, given sensitivity of location access)

### Learn tab
- Curriculum path (vertical scroll, unit nodes, current position highlighted)
- Unit detail (lesson list + unit-level progress)
- Lesson player (full-screen modal takeover, sequences through exercises, exit-confirmation to protect progress)
- Mastery Challenge screen (unseen-surah challenge; distinct visual treatment from regular lessons — this is where the primary success metric gets measured)

### Review tab
- Due-today queue (count + estimated time, e.g. "12 items · ~4 min")
- Review session player (reuses lesson-player exercise components in recall mode)
- Session summary (accuracy, streak impact)

### Tutor tab
- Conversation view, grouped by originating lesson/unit
- Suggested prompt chips relevant to recent mistakes (AI-generated from SRS error patterns, not static)
- New scoped conversation always anchored to a specific word/verse/grammar point — no fully open blank-chat entry point in v1, consistent with the PRD's scoped-Q&A boundary

### Progress tab
- Streak display (Hijri + Gregorian, since brand voice is fully Islamic)
- XP/level
- Mastery milestones (surahs *understood*, distinct from surahs merely *seen* — this distinction is the whole point of the comprehension-based success metric and needs its own visual state, not just a checkmark)
- Achievement badge gallery
- Stats (words mastered, accuracy trend, review consistency)

### Profile/Settings (via avatar icon)
- Account
- Notification & prayer-time preferences (location settings, reminder timing)
- Learning preferences (session length target, preferred reciter voice for audio)
- Accessibility (text size, Tajweed color-blind-safe mode, screen-reader notes)
- Privacy & data (voice recording retention/deletion — flagged in PRD as sensitive)
- Help/feedback/about

## Deep-linking / Notification Routing

Prayer-time-aware notifications route directly into whichever has more pressing content: due SRS review (if queue is large) or next lesson (if queue is small/empty) — decided server-side per user, not a fixed rule, so the notification always lands on the highest-value 5-minute action rather than a generic "open app."
