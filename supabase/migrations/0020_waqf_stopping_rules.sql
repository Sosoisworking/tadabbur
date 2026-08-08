-- Enriches "Completion of an Ayah" (built in migration 0018) with the
-- three actual stopping/pausing (waqf) rules from that section of the
-- book (its pages 38-40), rather than just the general "there's a
-- circle mark" framing migration 0018 gave it. Book's drill tables
-- (rows of example words per rule) are skipped as usual — transcription
-- risk isn't worth it for content that's illustrative, not the rule
-- itself — but the three rules are simple, well-defined, and stated
-- here in original wording:
--
--   1. Pausing on a word drops its last letter's vowel (reads Saakin),
--      whatever that vowel originally was.
--   2. Taa Marboutah (ة) at a pause is read as Haa (ه), not Taa.
--   3. Fathatain (ً) at a pause loses its "n" sound, leaving a plain
--      long "aa".
--
-- The existing grammar_explanation (waqf circle mark) and recall_quiz
-- stay as the lesson's opening and closing exercises; three new
-- concept+quiz pairs are inserted between them.

insert into grammar_points (code, category, title_en, explanation_short, explanation_full) values
  ('waqf_saakin', 'tajweed', 'Pausing at the End of a Word',
   'When you pause on a word instead of continuing to read, its last letter drops its vowel and is read Saakin (with no vowel sound) — no matter what vowel it originally had.',
   'Arabic is read continuously by default, but a reciter can pause — at the end of an ayah, at a waqf sign, or simply to breathe. Whenever you pause on a word, the very last letter changes: whatever vowel it carried (Fathah, Kasrah, Dhammah, or even Tanween) is dropped, and the letter is read Saakin — with no vowel sound at all, the same way it would sound with a Sukoon. This only affects the last letter, and only when you actually pause there; keep reading past that word, and it''s pronounced normally with its vowel.'),
  ('waqf_taa_marboota', 'tajweed', 'Taa Marboutah at a Pause',
   'If the word you pause on ends in Taa Marboutah (ة), that letter is pronounced as a plain Haa (ه) instead — not as a Taa.',
   'Taa Marboutah (ة) is a special letter shape found only at the end of words, almost always marking a feminine noun. It''s normally read as a soft "t" sound. But when a reciter pauses on a word ending in Taa Marboutah, the pronunciation changes: it''s read as a Haa (ه) sound instead, with no vowel — a word ending رَحْمَةً is read "...rahmah," not "...rahmat," when you stop there. Keep reading past it, and it goes back to its normal "t" sound.'),
  ('waqf_fathatain', 'tajweed', 'Fathatain at a Pause',
   'If the word you pause on ends in Fathatain (ً), only a single, plain "aa" sound is pronounced — the "n" sound of the Tanween is dropped.',
   'Fathatain (ً) — Tanween on a Fathah — normally adds an "an" sound to the end of a word. But when a reciter pauses on a word ending in Fathatain, the "n" sound disappears: only the Fathah is pronounced, drawn out into a long "aa," usually written as though the word ends with an Alif. A word like كَبِيرًا, read "kabiiran" mid-recitation, becomes "kabiiraa" the moment you pause on it.');

do $$
declare
  v_lesson_id int;
  v_exercise_id int;
  v_saakin_id int;
  v_taa_id int;
  v_fathatain_id int;
begin
  select l.id into v_lesson_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Reading Marks & Rules' and l.title = 'Completion of an Ayah';
  select id into v_saakin_id from grammar_points where code = 'waqf_saakin';
  select id into v_taa_id from grammar_points where code = 'waqf_taa_marboota';
  select id into v_fathatain_id from grammar_points where code = 'waqf_fathatain';

  -- Move the existing closing quiz out of the way first (its slot,
  -- sequence_order 2, is where the new content is about to land) —
  -- unique(lesson_id, sequence_order) means this has to happen before
  -- any insert, not after.
  update exercises set sequence_order = 8
    where lesson_id = v_lesson_id and exercise_type = 'recall_quiz';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'grammar_explanation', 2) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_saakin_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'If you pause on a word, how is its last letter pronounced?',
    '["With its normal vowel", "Saakin — no vowel sound", "Always with a Fathah", "It''s dropped entirely"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'grammar_explanation', 4) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_taa_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 5) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'If you pause on a word ending in ة (Taa Marboutah), how is that letter pronounced?',
    '["As a Haa (ه) sound", "As a Taa (ت) sound", "It''s silent", "As a Kasrah"]'::jsonb, 0);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'grammar_explanation', 6) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_fathatain_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 7) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'If you pause on a word ending in Fathatain (ً), what happens to the sound?',
    '["It stays exactly the same", "The ''n'' sound drops, leaving a long ''aa''", "It becomes a Kasrah sound", "The whole last letter is dropped"]'::jsonb, 1);

  update lessons set estimated_minutes = 8 where id = v_lesson_id;
end $$;
