-- Reorders the track so Core Vocabulary & Grammar comes BEFORE
-- Al-Fatiha instead of after it — per explicit user request to review
-- the whole sequence for "build on what's learned previously."
--
-- This was a real ordering bug, not a cosmetic one: Al-Fatiha's own
-- text directly uses words from Core Vocabulary & Grammar (رَبِّ in
-- ayah 2, يَوْمِ in ayah 4, لَا in ayah 7) and is saturated with the
-- definite article ال (الْحَمْدُ، لِلَّهِ، الْعَالَمِينَ، الرَّحْمَٰنِ،
-- الرَّحِيمِ، الدِّينِ، الصِّرَاطَ، الْمُسْتَقِيمَ، الَّذِينَ،
-- الْمَغْضُوبِ، الضَّالِّينَ — nearly every content word). A learner
-- who reached Al-Fatiha under the old order had no vocabulary or
-- grammar foundation yet and could only read it phonetically, with
-- zero comprehension — directly undercutting this app's actual stated
-- success metric (read & explain an unseen short surah), not just a
-- minor sequencing preference.
--
-- Reading Marks & Rules stays immediately after Al-Fatiha (unchanged
-- relative position) — its Word Allah lesson references Al-Fatiha
-- ayah 1 as a worked example, and Completion of an Ayah deepens
-- Al-Fatiha's own pause marks, so it must stay a follow-up, not a
-- prerequisite.
--
-- Old:  6 Al-Fatiha,        7 Reading Marks & Rules, 8 Core Vocabulary & Grammar
-- New:  6 Core Vocabulary & Grammar, 7 Al-Fatiha,     8 Reading Marks & Rules
--
-- A straight ascending or descending cascade can't do this rotation
-- collision-free (every target slot is occupied by another unit that's
-- also moving), so this stages the vacating unit through a temporary
-- sequence_order (1008) first, same +1000 staging trick used in
-- migrations 0005/0011.
--
-- No user_unit_progress changes needed: every unit already has a
-- backfilled progress row for every existing user (from each unit's
-- own creation migration), and progress is tracked by unit_id, not
-- sequence_order — reordering doesn't orphan or duplicate anything.
-- Audited every other unit's internal lesson order at the same time;
-- all of them already build correctly on what precedes them, so this
-- migration only touches unit-level sequence_order.

update units set sequence_order = 1008 where title = 'Core Vocabulary & Grammar';
update units set sequence_order = 8 where title = 'Reading Marks & Rules';
update units set sequence_order = 7 where title = 'Al-Fatiha — The Opening';
update units set sequence_order = 6 where title = 'Core Vocabulary & Grammar';
