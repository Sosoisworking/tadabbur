-- Replaces the 3 sample quiz questions in each Fathah/Kasrah/Dhammah
-- lesson with a fully separate "Quiz" lesson per mark, covering all 28
-- letters — not a sample. Learning (the diacritic_intro exercise) and
-- testing are now distinct sessions the user completes one after the
-- other, not interleaved within the same lesson.

-- ============================================================
-- 1. Strip the old sample quizzes back down to just the intro exercise
-- ============================================================

delete from exercise_attempts
  where exercise_id in (
    select e.id from exercises e
    join lessons l on l.id = e.lesson_id
    where l.unit_id = (select id from units where title = 'Vowel Marks (Harakat)')
      and e.exercise_type = 'recall_quiz'
  );

delete from exercise_recall_quiz
  where exercise_id in (
    select e.id from exercises e
    join lessons l on l.id = e.lesson_id
    where l.unit_id = (select id from units where title = 'Vowel Marks (Harakat)')
      and e.exercise_type = 'recall_quiz'
  );

delete from exercises
  where lesson_id in (select id from lessons where unit_id = (select id from units where title = 'Vowel Marks (Harakat)'))
    and exercise_type = 'recall_quiz';

-- ============================================================
-- 2. Reorder: Fathah, Fathah Quiz, Kasrah, Kasrah Quiz, Dhammah, Dhammah Quiz
-- ============================================================
-- Staged through a high range first — same reasoning as migration
-- 0005's letter_card repositioning: target positions overlap current
-- ones, and a single UPDATE checks the unique constraint per row as
-- written, not deferred to end of statement.

update lessons set sequence_order = sequence_order + 100
where unit_id = (select id from units where title = 'Vowel Marks (Harakat)');

update lessons set sequence_order = 1 where unit_id = (select id from units where title = 'Vowel Marks (Harakat)') and title = 'Fathah';
update lessons set sequence_order = 3 where unit_id = (select id from units where title = 'Vowel Marks (Harakat)') and title = 'Kasrah';
update lessons set sequence_order = 5 where unit_id = (select id from units where title = 'Vowel Marks (Harakat)') and title = 'Dhammah';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Fathah Quiz', 2, 10 from units where title = 'Vowel Marks (Harakat)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Kasrah Quiz', 4, 10 from units where title = 'Vowel Marks (Harakat)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Dhammah Quiz', 6, 10 from units where title = 'Vowel Marks (Harakat)';

-- ============================================================
-- 3. Generate all 28 x 3 = 84 quiz questions
-- ============================================================
-- Each letter's "base consonant" is given explicitly (sequence_order ->
-- base) rather than derived from name_transliteration by string
-- manipulation — a trailing-vowel-strip regex looks tempting but is
-- wrong for most names (e.g. "Jim", "Sin", "Lam" don't end in a vowel
-- at all, so naive stripping leaves the whole name as the "base" and
-- produces nonsense options like "Jima/Jimi/Jimu/Jim"). A few bases
-- intentionally repeat across emphatic/non-emphatic pairs (Sin & Sad
-- both "S", Dal & Dad both "D", etc.) — this quiz tests the vowel
-- mark, not distinguishing emphatic consonants, so that collision
-- doesn't undermine what's being tested.
--
-- Options are always presented in the same fixed order [+a, +i, +u,
-- bare consonant], so correct_option_index is simply which axis
-- (Fathah/Kasrah/Dhammah) is being tested — 0, 1, or 2 respectively.

do $$
declare
  v_unit_id int;
  v_fathah_lesson_id int;
  v_kasrah_lesson_id int;
  v_dhammah_lesson_id int;
  v_fathah_mark text;
  v_kasrah_mark text;
  v_dhammah_mark text;
  v_letter record;
  v_exercise_id int;
  v_options jsonb;
  v_seq int;
begin
  select id into v_unit_id from units where title = 'Vowel Marks (Harakat)';
  select id into v_fathah_lesson_id from lessons where unit_id = v_unit_id and title = 'Fathah Quiz';
  select id into v_kasrah_lesson_id from lessons where unit_id = v_unit_id and title = 'Kasrah Quiz';
  select id into v_dhammah_lesson_id from lessons where unit_id = v_unit_id and title = 'Dhammah Quiz';
  select mark_unicode into v_fathah_mark from diacritics where name_en = 'Fathah';
  select mark_unicode into v_kasrah_mark from diacritics where name_en = 'Kasrah';
  select mark_unicode into v_dhammah_mark from diacritics where name_en = 'Dhammah';

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
    v_options := jsonb_build_array(
      v_letter.base_consonant || 'a',
      v_letter.base_consonant || 'i',
      v_letter.base_consonant || 'u',
      v_letter.base_consonant
    );

    -- Fathah (correct = index 0)
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_fathah_lesson_id, 'recall_quiz', v_seq) returning id into v_exercise_id;
    insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
    values (v_exercise_id, 'How do you read ' || v_letter.isolated_form || v_fathah_mark || ' ?', v_options, 0, v_letter.id);

    -- Kasrah (correct = index 1)
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_kasrah_lesson_id, 'recall_quiz', v_seq) returning id into v_exercise_id;
    insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
    values (v_exercise_id, 'How do you read ' || v_letter.isolated_form || v_kasrah_mark || ' ?', v_options, 1, v_letter.id);

    -- Dhammah (correct = index 2)
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_dhammah_lesson_id, 'recall_quiz', v_seq) returning id into v_exercise_id;
    insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
    values (v_exercise_id, 'How do you read ' || v_letter.isolated_form || v_dhammah_mark || ' ?', v_options, 2, v_letter.id);
  end loop;
end $$;
