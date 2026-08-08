-- Phase 4 of the Qaida adaptation: Huroof-ul Madd (the 3 elongation
-- letters — long vowels held for 2 beats) and Letters of Leen (the 2
-- diphthong letters). New unit, inserted between Vowel Marks and
-- Al-Fatiha — reading Al-Fatiha genuinely involves Madd (e.g. the
-- alif in الرَّحْمَٰن), so this has to come before it.
--
-- Structurally different from Fathah/Kasrah/.../Sukoon: those were a
-- single combining mark; Madd and Leen are a short-vowel mark followed
-- by one of ا/و/ي (and, for Leen, a trailing Sukoon) — 2-3 characters,
-- not 1. Still fits the existing diacritics table without any schema
-- or app change: mark_unicode is plain text, not constrained to a
-- single character, so `isolatedForm + markUnicode` (already how the
-- app renders every grid cell) produces the correct combined glyph
-- exactly the same way.
--
-- Skipped again this phase, same reasoning as migration 0003's
-- "Connecting Letters" skip: the book's "Words with Huroof-Ul Madd" /
-- "Words with Waaw Leen" pages show real multi-letter word examples,
-- which aren't reproduced here — real words carry transcription risk
-- (easy to introduce a subtle error copying multi-letter Arabic text
-- by hand) that the single-letter combination grids don't.

insert into diacritics (name_en, mark_unicode, placement, sound_description, explanation_short, explanation_full, sequence_order, audio_url) values
  ('Alif Madd', chr(1614) || 'ا', 'above',
   'A long "aa" sound, held for two beats — not the short "a" of Fathah',
   'When an Alif follows a letter with a Fathah, the "a" sound is held twice as long. ب + Fathah + Alif is read "Baa," not "Ba."',
   'Huroof-ul Madd (حروف المد) are three letters — Alif, Waw, and Yaa — that elongate a vowel sound to two beats when they follow the matching short vowel. An Alif following a Fathah stretches that "a" into a long "aa." This is one of the three Madd letters; see Waw Madd and Yaa Madd for the other two.',
   8, 'placeholder/audio-not-yet-recorded.mp3'),
  ('Waw Madd', chr(1615) || 'و', 'above',
   'A long "oo" sound, held for two beats — not the short "u" of Dhammah',
   'When a Waw Saakinah follows a letter with a Dhammah, the "u" sound is held twice as long. ب + Dhammah + Waw is read "Boo," not "Bu."',
   'The second of the three Madd letters (see Alif Madd): a Waw Saakinah (a Waw with Sukoon) following a Dhammah stretches that "u" into a long "oo."',
   9, 'placeholder/audio-not-yet-recorded.mp3'),
  ('Yaa Madd', chr(1616) || 'ي', 'below',
   'A long "ee" sound, held for two beats — not the short "i" of Kasrah',
   'When a Yaa Saakinah follows a letter with a Kasrah, the "i" sound is held twice as long. ب + Kasrah + Yaa is read "Bee," not "Bi."',
   'The third of the three Madd letters (see Alif Madd, Waw Madd): a Yaa Saakinah following a Kasrah stretches that "i" into a long "ee."',
   10, 'placeholder/audio-not-yet-recorded.mp3'),
  ('Waw Leen', chr(1614) || 'و' || chr(1618), 'above',
   'A quick "aw" diphthong — glide from the letter into the vowel',
   'When a Waw Saakinah follows a letter with a Fathah, it glides quickly into an "aw" sound, like the "ow" in "cow." ب + Fathah + Waw + Sukoon is read "Baw."',
   'Leen (لين) means "softness" — the Waw and Yaa Saakinah are pronounced quickly and smoothly when they follow a Fathah, gliding rather than elongating the way Madd letters do. A Waw Saakinah after a Fathah gives an "aw" diphthong.',
   11, 'placeholder/audio-not-yet-recorded.mp3'),
  ('Yaa Leen', chr(1614) || 'ي' || chr(1618), 'above',
   'A quick "ay" diphthong — glide from the letter into the vowel',
   'When a Yaa Saakinah follows a letter with a Fathah, it glides quickly into an "ay" sound, like the "ay" in "day." ب + Fathah + Yaa + Sukoon is read "Bay."',
   'The second Letter of Leen (see Waw Leen): a Yaa Saakinah after a Fathah gives a quick "ay" diphthong, gliding rather than elongating.',
   12, 'placeholder/audio-not-yet-recorded.mp3');

-- ============================================================
-- New unit, inserted between Vowel Marks (2) and Al-Fatiha (3)
-- ============================================================

update units set sequence_order = 4 where title = 'Al-Fatiha — The Opening';

insert into units (track_id, unit_type, title, sequence_order)
select id, 'thematic', 'Long Vowels & Diphthongs (Madd & Leen)', 3 from tracks where code = 'quranic_arabic';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Madd', 1, 6 from units where title = 'Long Vowels & Diphthongs (Madd & Leen)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Alif Madd Quiz', 2, 10 from units where title = 'Long Vowels & Diphthongs (Madd & Leen)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Waw Madd Quiz', 3, 10 from units where title = 'Long Vowels & Diphthongs (Madd & Leen)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Yaa Madd Quiz', 4, 10 from units where title = 'Long Vowels & Diphthongs (Madd & Leen)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Leen', 5, 5 from units where title = 'Long Vowels & Diphthongs (Madd & Leen)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Waw Leen Quiz', 6, 10 from units where title = 'Long Vowels & Diphthongs (Madd & Leen)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Yaa Leen Quiz', 7, 10 from units where title = 'Long Vowels & Diphthongs (Madd & Leen)';

do $$
declare
  v_unit_id int;
  v_madd_lesson_id int;
  v_leen_lesson_id int;
  v_quiz_lesson_id int;
  v_diacritic record;
  v_intro_seq int;
  v_exercise_id int;
  v_letter record;
  v_options jsonb;
  v_seq int;
begin
  select id into v_unit_id from units where title = 'Long Vowels & Diphthongs (Madd & Leen)';
  select id into v_madd_lesson_id from lessons where unit_id = v_unit_id and title = 'Madd';
  select id into v_leen_lesson_id from lessons where unit_id = v_unit_id and title = 'Leen';

  -- Intro exercises: 3 sequential diacritic_intro exercises in "Madd"
  -- (Alif/Waw/Yaa Madd), 2 in "Leen" (Waw/Yaa Leen) — same "shared
  -- lesson, separate quizzes" pattern as Tanween in migration 0012.
  v_intro_seq := 0;
  for v_diacritic in select id, name_en from diacritics where name_en in ('Alif Madd', 'Waw Madd', 'Yaa Madd') order by sequence_order loop
    v_intro_seq := v_intro_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_madd_lesson_id, 'diacritic_intro', v_intro_seq) returning id into v_exercise_id;
    insert into exercise_diacritic_intro (exercise_id, diacritic_id) values (v_exercise_id, v_diacritic.id);
  end loop;

  v_intro_seq := 0;
  for v_diacritic in select id, name_en from diacritics where name_en in ('Waw Leen', 'Yaa Leen') order by sequence_order loop
    v_intro_seq := v_intro_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_leen_lesson_id, 'diacritic_intro', v_intro_seq) returning id into v_exercise_id;
    insert into exercise_diacritic_intro (exercise_id, diacritic_id) values (v_exercise_id, v_diacritic.id);
  end loop;

  -- One comprehensive 28-question quiz per mark. Options test whether
  -- the long vowel / diphthong is distinguished from the 3 short
  -- vowels, not just recognized in isolation — [correct, +a, +i, +u].
  for v_diacritic in select id, name_en, mark_unicode, reading_suffix from diacritics where name_en in ('Alif Madd', 'Waw Madd', 'Yaa Madd', 'Waw Leen', 'Yaa Leen') loop
    select id into v_quiz_lesson_id from lessons where unit_id = v_unit_id and title = v_diacritic.name_en || ' Quiz';

    v_seq := 0;
    for v_letter in select id, isolated_form, base_consonant from letters order by sequence_order loop
      v_seq := v_seq + 1;
      v_options := jsonb_build_array(
        v_letter.base_consonant || v_diacritic.reading_suffix,
        v_letter.base_consonant || 'a',
        v_letter.base_consonant || 'i',
        v_letter.base_consonant || 'u'
      );
      insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', v_seq) returning id into v_exercise_id;
      insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
      values (v_exercise_id, 'How do you read ' || v_letter.isolated_form || v_diacritic.mark_unicode || ' ?', v_options, 0, v_letter.id);
    end loop;
  end loop;
end $$;

-- Backfill existing users, same reasoning as migrations 0003/0010.
insert into user_unit_progress (user_id, unit_id, status, started_at)
select u.id, (select id from units where title = 'Long Vowels & Diphthongs (Madd & Leen)'), 'in_progress', now()
from users u
on conflict (user_id, unit_id) do nothing;
