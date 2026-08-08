-- Phase 3 of the Qaida adaptation: Sukoon (no-vowel mark) and Tanween
-- (Fathatain/Kasratain/Dhammatain — doubled vowel marks giving an "n"
-- sound at the end of a noun). Grouped as the book's own "Third
-- Section." Extends the existing "Vowel Marks (Harakat)" unit rather
-- than a new one — still the same underlying concept (diacritical
-- marks needed to read at all), not a new topic.
--
-- No app code changes needed this phase: the diacritic_intro exercise
-- type and comprehensive-quiz pattern built for Fathah/Kasrah/Dhammah
-- are generic enough to cover these too.
--
-- Simplification flagged explicitly: the book notes an Alif is added
-- after Fathatain in spelling (e.g. عَطَاءً), except when Hamzah is
-- preceded by an Alif Madd. The reading grids here use plain letter +
-- mark concatenation and don't encode that spelling exception — correct
-- for the sound taught, not a full spelling-rule engine.

insert into diacritics (name_en, mark_unicode, placement, sound_description, explanation_short, explanation_full, sequence_order, audio_url) values
  ('Sukoon', chr(1618), 'above',
   'No vowel sound at all — the letter is read plainly, cut short',
   'Sukoon is a small circle written above a letter. It means that letter has no vowel sound — read it plainly, with no "a," "i," or "u" after it.',
   'Sukoon (سكون) is the opposite of a harakah: instead of adding a vowel sound, it marks a letter as having none at all. A ب with a Sukoon is read as a bare "b" sound, stopped short, not "Ba/Bi/Bu." A Sukoon is never found at the very beginning of a word — every word has to start on a vowel sound. Five letters (ق ط ب ج د) get a slight bounce or echo when they carry a Sukoon, called Qalqalah.',
   4, 'placeholder/audio-not-yet-recorded.mp3'),
  ('Fathatain', chr(1611), 'above',
   'Like Fathah, but adds an "n" sound — "an"',
   'Fathatain is a doubled Fathah, written as two small diagonal strokes. It adds an "an" sound and appears at the end of nouns.',
   'Fathatain (فتحتين) is Tanween applied to Fathah — two Fathah strokes instead of one. It is a form of Noon Sakinah (a hidden "n" sound) that shows up at the end of a noun rather than being written as an actual ن. A ب with Fathatain is read "Ban," not "Ba."',
   5, 'placeholder/audio-not-yet-recorded.mp3'),
  ('Kasratain', chr(1613), 'below',
   'Like Kasrah, but adds an "n" sound — "in"',
   'Kasratain is a doubled Kasrah, written as two small diagonal strokes below the letter. It adds an "in" sound at the end of nouns.',
   'Kasratain (كسرتين) is Tanween applied to Kasrah — two Kasrah strokes instead of one, written below the letter. A ب with Kasratain is read "Bin," not "Bi."',
   6, 'placeholder/audio-not-yet-recorded.mp3'),
  ('Dhammatain', chr(1612), 'above',
   'Like Dhammah, but adds an "n" sound — "un"',
   'Dhammatain is a doubled Dhammah, written as a small doubled curl. It adds an "un" sound at the end of nouns.',
   'Dhammatain (ضمتين) is Tanween applied to Dhammah — a doubled version of the small curl. A ب with Dhammatain is read "Bun," not "Bu." Together, Fathatain, Kasratain, and Dhammatain are collectively called Tanween — Noon Sakinah folded into the final vowel mark of a noun instead of being written out as its own letter.',
   7, 'placeholder/audio-not-yet-recorded.mp3');

-- ============================================================
-- New lessons, appended to the existing Vowel Marks (Harakat) unit
-- ============================================================

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Sukoon', 7, 5 from units where title = 'Vowel Marks (Harakat)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Sukoon Quiz', 8, 10 from units where title = 'Vowel Marks (Harakat)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Tanween', 9, 6 from units where title = 'Vowel Marks (Harakat)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Fathatain Quiz', 10, 10 from units where title = 'Vowel Marks (Harakat)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Kasratain Quiz', 11, 10 from units where title = 'Vowel Marks (Harakat)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Dhammatain Quiz', 12, 10 from units where title = 'Vowel Marks (Harakat)';

do $$
declare
  v_unit_id int;
  v_sukoon_lesson_id int;
  v_sukoon_quiz_lesson_id int;
  v_tanween_lesson_id int;
  v_fathatain_quiz_lesson_id int;
  v_kasratain_quiz_lesson_id int;
  v_dhammatain_quiz_lesson_id int;
  v_sukoon_id int;
  v_fathatain_id int;
  v_kasratain_id int;
  v_dhammatain_id int;
  v_fathah_mark text;
  v_kasrah_mark text;
  v_dhammah_mark text;
  v_sukoon_mark text;
  v_fathatain_mark text;
  v_kasratain_mark text;
  v_dhammatain_mark text;
  v_exercise_id int;
  v_letter record;
  v_options jsonb;
  v_seq int;
begin
  select id into v_unit_id from units where title = 'Vowel Marks (Harakat)';
  select id into v_sukoon_lesson_id from lessons where unit_id = v_unit_id and title = 'Sukoon';
  select id into v_sukoon_quiz_lesson_id from lessons where unit_id = v_unit_id and title = 'Sukoon Quiz';
  select id into v_tanween_lesson_id from lessons where unit_id = v_unit_id and title = 'Tanween';
  select id into v_fathatain_quiz_lesson_id from lessons where unit_id = v_unit_id and title = 'Fathatain Quiz';
  select id into v_kasratain_quiz_lesson_id from lessons where unit_id = v_unit_id and title = 'Kasratain Quiz';
  select id into v_dhammatain_quiz_lesson_id from lessons where unit_id = v_unit_id and title = 'Dhammatain Quiz';

  select id into v_sukoon_id from diacritics where name_en = 'Sukoon';
  select id into v_fathatain_id from diacritics where name_en = 'Fathatain';
  select id into v_kasratain_id from diacritics where name_en = 'Kasratain';
  select id into v_dhammatain_id from diacritics where name_en = 'Dhammatain';

  select mark_unicode into v_fathah_mark from diacritics where name_en = 'Fathah';
  select mark_unicode into v_kasrah_mark from diacritics where name_en = 'Kasrah';
  select mark_unicode into v_dhammah_mark from diacritics where name_en = 'Dhammah';
  select mark_unicode into v_sukoon_mark from diacritics where name_en = 'Sukoon';
  select mark_unicode into v_fathatain_mark from diacritics where name_en = 'Fathatain';
  select mark_unicode into v_kasratain_mark from diacritics where name_en = 'Kasratain';
  select mark_unicode into v_dhammatain_mark from diacritics where name_en = 'Dhammatain';

  -- Intro exercises: Sukoon lesson gets one; Tanween lesson gets all
  -- three sub-marks as sequential exercises within the same lesson,
  -- since the book teaches them together as one concept.
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_sukoon_lesson_id, 'diacritic_intro', 1) returning id into v_exercise_id;
  insert into exercise_diacritic_intro (exercise_id, diacritic_id) values (v_exercise_id, v_sukoon_id);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_tanween_lesson_id, 'diacritic_intro', 1) returning id into v_exercise_id;
  insert into exercise_diacritic_intro (exercise_id, diacritic_id) values (v_exercise_id, v_fathatain_id);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_tanween_lesson_id, 'diacritic_intro', 2) returning id into v_exercise_id;
  insert into exercise_diacritic_intro (exercise_id, diacritic_id) values (v_exercise_id, v_kasratain_id);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_tanween_lesson_id, 'diacritic_intro', 3) returning id into v_exercise_id;
  insert into exercise_diacritic_intro (exercise_id, diacritic_id) values (v_exercise_id, v_dhammatain_id);

  v_seq := 0;
  for v_letter in
    select l.id, l.isolated_form, v.base_consonant
    from letters l
    join (values
      (1,  'A'),  (2,  'B'),  (3,  'T'),  (4,  'Th'), (5,  'J'),
      (6,  'H'),  (7,  'Kh'), (8,  'D'),  (9,  'Dh'), (10, 'R'),
      (11, 'Z'),  (12, 'S'),  (13, 'Sh'), (14, 'S'),  (15, 'D'),
      (16, 'T'),  (17, 'Dh'), (18, 'A'),  (19, 'Gh'), (20, 'F'),
      (21, 'Q'),  (22, 'K'),  (23, 'L'),  (24, 'M'),  (25, 'N'),
      (26, 'H'),  (27, 'W'),  (28, 'Y')
    ) as v(sequence_order, base_consonant) on v.sequence_order = l.sequence_order
    order by l.sequence_order
  loop
    v_seq := v_seq + 1;

    -- Sukoon quiz: recognize the Sukoon form among all 4 marks learned
    -- so far, rather than "how do you read" (Sukoon's answer would just
    -- be the bare consonant, which doesn't fit that question shape).
    v_options := jsonb_build_array(
      v_letter.isolated_form || v_fathah_mark,
      v_letter.isolated_form || v_kasrah_mark,
      v_letter.isolated_form || v_dhammah_mark,
      v_letter.isolated_form || v_sukoon_mark
    );
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_sukoon_quiz_lesson_id, 'recall_quiz', v_seq) returning id into v_exercise_id;
    insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
    values (v_exercise_id, 'Which of these shows ' || v_letter.isolated_form || ' with NO vowel sound (Sukoon)?', v_options, 3, v_letter.id);

    -- Tanween quizzes: same "how do you read" shape as Phase 2, with
    -- an "n" appended to the vowel sound.
    v_options := jsonb_build_array(
      v_letter.base_consonant || 'an',
      v_letter.base_consonant || 'in',
      v_letter.base_consonant || 'un',
      v_letter.base_consonant
    );

    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_fathatain_quiz_lesson_id, 'recall_quiz', v_seq) returning id into v_exercise_id;
    insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
    values (v_exercise_id, 'How do you read ' || v_letter.isolated_form || v_fathatain_mark || ' ?', v_options, 0, v_letter.id);

    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_kasratain_quiz_lesson_id, 'recall_quiz', v_seq) returning id into v_exercise_id;
    insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
    values (v_exercise_id, 'How do you read ' || v_letter.isolated_form || v_kasratain_mark || ' ?', v_options, 1, v_letter.id);

    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_dhammatain_quiz_lesson_id, 'recall_quiz', v_seq) returning id into v_exercise_id;
    insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
    values (v_exercise_id, 'How do you read ' || v_letter.isolated_form || v_dhammatain_mark || ' ?', v_options, 2, v_letter.id);
  end loop;
end $$;
