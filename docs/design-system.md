# UI/UX Design System — Tadabbur

## Brand Principles

1. **Reflective, not gamey.** Islamic branding means the emotional register is closer to *contemplation* than *competition* — this is the reasoning behind cutting leaderboards (PRD §6) and it should show up in visual tone too: warm, unhurried, no aggressive red "streak about to die!" panic states.
2. **The Arabic is the star.** English UI chrome should recede; diacritized Arabic content is what the eye should land on first in any lesson screen.
3. **"Seen" vs "understood" must look different, everywhere.** This is the visual expression of the PRD's comprehension-based success metric — a checkmark and a mastery indicator are never the same glyph.
4. **Avoid generic "AI dashboard" aesthetics.** No default purple gradients, no Inter/Roboto-everywhere sameness — this app should not look interchangeable with a generic SaaS analytics tool.

## Color System

Anchored in colors with real resonance for the audience — deep green (mosque domes, Islamic flags, the historical "green" of paradise imagery in Islamic art) and warm gold (light, *nur*) — on a warm off-white rather than clinical white, evoking parchment/mushaf paper rather than a sterile app background.

| Token | Light mode | Dark mode | Use |
|---|---|---|---|
| `bg.base` | `#FBF7EE` (warm cream) | `#12201C` (deep green-charcoal) | Screen background |
| `bg.surface` | `#FFFFFF` | `#1A2B25` | Cards, sheets |
| `brand.primary` | `#1B5E4A` (deep emerald) | `#3FA37E` (brighter emerald for dark-mode contrast) | Primary actions, active nav, unit-path line |
| `brand.accent` | `#C8932A` (warm gold) | `#E0AC4F` | Mastery states, achievement badges, XP |
| `text.primary` | `#1C2620` | `#F2EFE6` | Body text |
| `text.secondary` | `#5B6660` | `#AAB3AC` | Metadata, timestamps |
| `state.success` | `#2E7D4F` | `#4FAE78` | Correct answers |
| `state.error` | `#B3462C` (warm terracotta, not alarm-red) | `#D97456` | Incorrect answers — deliberately warmer/softer than a typical destructive red, matching the reflective tone |
| `state.locked` | `#C9C2B2` | `#3A423C` | Locked unit nodes |

All pairs verified at **WCAG AA (4.5:1)** minimum for body text, 3:1 for large text/icons, in both modes — re-verify after any palette tweak, don't assume it holds.

### Tajweed color coding — with a non-color fallback

Diacritized Quranic text uses the standard Tajweed color convention (distinct hues per rule category — madd, ghunnah, qalqalah, idgham, etc., stored in `ayat.tajweed_markup`). Color alone fails WCAG 1.4.1 ("use of color") for colorblind users — the most common form, red-green colorblindness, would blur several Tajweed categories together. **Every color-coded rule also gets a distinct underline style** (solid/dashed/dotted/wavy) as a non-color-dependent second channel, toggleable independently in Settings → Accessibility for users who find the dual-encoding visually busy once they've memorized the colors.

## Typography

- **Arabic (Quranic content)**: **Amiri Quran** — open-source (SIL license, no licensing cost, fits the budget-conscious constraint), purpose-built for Quranic typesetting with full Tashkeel and Tajweed-color-layer support. This is the one font every lesson screen renders.
- **English UI**: **Work Sans** — a warm, humanist sans rather than the generic Inter/Roboto default; distinct without sacrificing the legibility a learning app depends on for long reading sessions.
- **Serif accent (emotional moments only)**: **Lora**, used sparingly on onboarding screens, mastery-challenge results, and achievement unlocks — gives those specific moments a warmer, less "app-y" register without carrying that weight into everyday lesson screens.

Type scale follows a standard 1.25 ratio from a 16px base, with Arabic content rendered at a **minimum 24px** regardless of scale step — diacritics are illegible below that, and this is non-negotiable even at the smallest text-size setting (see Accessibility below).

## Spacing & Layout

8px base grid. Content max-width capped on tablets/large screens (this is a phone-first app per PRD §4.2, but shouldn't stretch illegibly wide if opened on a tablet). Minimum touch target **44×44pt** everywhere, non-negotiable given Aisha-persona users may have low technical dexterity with a new app.

## Core Components

| Component | Notes |
|---|---|
| `UnitPathNode` | Four distinct visual states: locked (muted, padlock icon), in-progress (brand.primary outline, partial fill), completed (`state.success` check), **mastered** (`brand.accent` gold star + subtle glow — visually distinct from a plain checkmark, per Brand Principle 3) |
| `ArabicTextRenderer` | Renders diacritized text with optional Tajweed color+underline layer; tap-word-to-hear-audio; used identically in reading exercises, listening drills, and the tutor's context display — one component, not three |
| `AudioRecordButton` | Press-and-hold record for pronunciation exercises; visual waveform feedback during recording; clear "processing" state while the word-accuracy score computes (this call has real latency — never leave the user looking at a static button) |
| `StreakDisplay` | Shows **both** Hijri and Gregorian dates — a plain Gregorian-only streak counter would undercut the Islamic-branding decision everywhere else |
| `XPCelebration` | Brief, restrained animation on lesson completion — reflective tone means this should read as quiet satisfaction, not a slot-machine win state |
| `TutorChatBubble` | Distinguishes user/assistant visually; always shows the anchoring context (word/verse/grammar point) as a small pinned header, since the tutor is scoped, not open-ended (PRD §4.1) |
| `SRSReviewCard` | Flip/reveal interaction for recall; records `quality_rating` on the self-assessed difficulty buttons that feed directly into `POST /srs/review` |
| `MasteryChallengeBanner` | Visually distinct from a regular lesson card (different card treatment, gold border) — this is where the primary success metric is measured, and it should not look like just another exercise |
| `BottomNavBar` | 4 items (Learn/Review/Tutor/Progress) per `information-architecture.md`; badge dot on Review shows due-count |

## Motion

Restrained by default, consistent with the reflective brand tone — no bouncing icons or aggressive micro-interactions on routine actions. Reserve more expressive motion for genuinely earned moments: lesson completion, mastery-challenge pass, streak milestones. **All animation respects the system-level reduced-motion accessibility setting** — this is a hard requirement, not a nice-to-have, given the audience skews toward users who may be less tech-forward.

## Accessibility

- **Dynamic text scaling** up to 200% supported throughout; Arabic content has its own floor (24px minimum, see Typography) that doesn't shrink below legibility even as English UI text scales down proportionally.
- **Screen reader labels for Arabic content**: VoiceOver/TalkBack pronunciation of diacritized Arabic is inconsistent across devices — every `ArabicTextRenderer` instance carries an explicit accessibility label using the transliteration, not relying on the screen reader to sound out the Arabic script itself.
- **Tajweed color-blind-safe mode**: on by default (color + underline dual-encoding, see Color System above).
- **Contrast**: WCAG AA minimum verified in both light and dark mode for every token pair above.
- **Touch targets**: 44×44pt minimum, no exceptions.
- **Reduced motion**: every animated component has a static-equivalent state.

---

*Next stage: detailed feature specs (onboarding/placement, adaptive learning engine, SRS, AI tutor, pronunciation scoring, grammar explanations, vocabulary training, reading/listening exercises, gamification, notifications, analytics, admin tools) — building directly on the components and screens defined here.*
