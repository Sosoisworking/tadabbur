-- Reorders lessons within two units, per user request to review
-- ordering more broadly. Both are real structural issues, not
-- cosmetic preference: content added in a later migration got
-- appended to the end of an already-well-ordered lesson list,
-- regardless of whether that was still the right position.
--
-- 1. Core Vocabulary & Grammar (12 lessons, built across three
--    separate migrations — 0022, 0029, 0031) currently interleaves
--    particles/nouns/grammar lessons by *when each was added*, not by
--    type: Essential Particles, Common Nouns, Basic Grammar, More
--    Particles, More Grammar, Additional Particles, Additional Nouns.
--    A learner bounces between three different skills repeatedly
--    instead of finishing one before the next. Regrouped so every
--    particles lesson comes first (in the same frequency-tier order
--    they were built: Essential -> More -> Additional), then every
--    nouns lesson, then both grammar lessons last — concrete
--    vocabulary before the more abstract grammatical patterns that
--    describe how it combines, which was the original design intent
--    before later migrations disrupted it by appending to the end.
--
-- 2. Salah — The Prayer: "Salah Quiz" (migration 0027) was built as
--    the unit's closing/capstone lesson. "Short Surahs for Prayer"
--    (migration 0028) was then appended after it, displacing the quiz
--    from that position — and its content is explicitly tied to an
--    earlier point in the sequence: "The First Rak'ah: Standing and
--    Reciting" (step 4) says "you may then recite another short
--    surah... a dedicated lesson on short surahs for prayer is coming
--    soon." Moved to right after that reference point; Salah Quiz
--    restored as the closing lesson.
--
-- Both use the same collision-safe 2-phase staging as previous
-- multi-lesson rotations (migration 0024): every affected row moves
-- to a temporary sequence_order (+1000) first, then to its final
-- target — since several lessons are moving into slots currently
-- occupied by other moving lessons, no single-pass ordering of plain
-- UPDATEs can avoid a unique(lesson_id... wait, unique(unit_id,
-- sequence_order)) collision.
--
-- Basic Verbs was also considered for an earlier unit-level position
-- (right after Core Vocabulary & Grammar, before Al-Fatiha) but is
-- deliberately left at the end: its grammar examples link real ayahs
-- from Al-Fatiha (id 5), Al-Falaq (id 30, part of Salah's Short Surahs
-- for Prayer), and An-Nas (id 38, same lesson) — all of which live in
-- units that come after Basic Verbs' current position. Moving it
-- earlier would turn those into forward references to content the
-- learner hasn't reached yet, recreating the exact kind of
-- prerequisite violation migration 0024 fixed for Al-Fatiha/Core
-- Vocabulary. No unit-level change made here.

-- Phase 1: stage every lesson being moved in either unit to a
-- temporary sequence_order.
update lessons set sequence_order = sequence_order + 1000 where id in (37, 38, 39, 40, 41, 57, 58, 59, 63, 64, 65, 66, 48, 49, 50, 51, 52, 53, 54, 55, 56);

-- Phase 2: Core Vocabulary & Grammar — particles, then nouns, then
-- grammar, frequency-tier order preserved within each group.
update lessons set sequence_order = 1 where id = 37;  -- Essential Particles
update lessons set sequence_order = 2 where id = 38;  -- Essential Particles Quiz
update lessons set sequence_order = 3 where id = 57;  -- More Essential Particles
update lessons set sequence_order = 4 where id = 58;  -- More Essential Particles Quiz
update lessons set sequence_order = 5 where id = 63;  -- Additional Particles
update lessons set sequence_order = 6 where id = 64;  -- Additional Particles Quiz
update lessons set sequence_order = 7 where id = 39;  -- Common Nouns
update lessons set sequence_order = 8 where id = 40;  -- Common Nouns Quiz
update lessons set sequence_order = 9 where id = 65;  -- Additional Nouns
update lessons set sequence_order = 10 where id = 66; -- Additional Nouns Quiz
update lessons set sequence_order = 11 where id = 41; -- Basic Grammar: Articles, Gender & Demonstratives
update lessons set sequence_order = 12 where id = 59; -- More Grammar: Relative Pronoun & Possessive Suffixes

-- Phase 2: Salah — The Prayer — Short Surahs for Prayer moves to right
-- after the lesson that references it; Salah Quiz restored as closing.
update lessons set sequence_order = 1 where id = 48;  -- Understanding Salah
update lessons set sequence_order = 2 where id = 49;  -- Before You Begin
update lessons set sequence_order = 3 where id = 50;  -- The First Rak'ah: Standing and Reciting
update lessons set sequence_order = 4 where id = 56;  -- Short Surahs for Prayer
update lessons set sequence_order = 5 where id = 51;  -- The First Rak'ah: Bowing and Prostrating
update lessons set sequence_order = 6 where id = 52;  -- The Second Rak'ah
update lessons set sequence_order = 7 where id = 53;  -- Tashahhud — The Sitting Recitation
update lessons set sequence_order = 8 where id = 54;  -- Completing the Prayer
update lessons set sequence_order = 9 where id = 55;  -- Salah Quiz
