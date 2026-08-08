-- Phase 6c: The Word Allah and Completion of an Ayah, using the
-- grammar_explanation exercise type built in migration/commit 6b.
-- New unit placed AFTER Al-Fatiha (unlike every previous unit in this
-- track) — this content deepens understanding of things a learner has
-- already encountered in real recitation, rather than being a
-- foundational-reading prerequisite the way the alphabet/vowel marks/
-- Madd/Shaddah units are.
--
-- Explanations below are original wording describing the same rules
-- the book teaches, not copied from it.

do $$
declare
  v_constraint_name text;
begin
  select conname into v_constraint_name
  from pg_constraint
  where conrelid = 'public.grammar_points'::regclass
    and contype = 'c'
    and pg_get_constraintdef(oid) like '%category%';

  if v_constraint_name is not null then
    execute format('alter table grammar_points drop constraint %I', v_constraint_name);
  end if;
end $$;

alter table grammar_points add constraint grammar_points_category_check
  check (category in ('nahw', 'sarf', 'tajweed'));

insert into grammar_points (code, category, title_en, explanation_short, explanation_full) values
  ('word_allah', 'tajweed', 'The Word Allah',
   'The ل in الله (Allah) changes depending on what comes right before it: heavy after a Fathah or Dhammah, light after a Kasrah.',
   'This rule applies only to the word الله (Allah) or اللَّهُمَّ (Allahumma) — nowhere else. If the letter immediately before it carries a Fathah or a Dhammah, the ل is pronounced heavy (Tafkhim): a full mouth, tongue pulled back. If the letter immediately before it carries a Kasrah, the ل is pronounced light (Tarqiq): an empty mouth, tongue forward. The example below shows the light version — بِسْمِ ends in a Kasrah, so اللَّهِ right after it gets a light ل.'),
  ('ayah_completion', 'tajweed', 'Completion of an Ayah',
   'The end of each ayah is marked with a small circle containing its number — reciters commonly pause there, even mid-sentence.',
   'Every ayah in the Mushaf ends with a small decorative circle (a Waqf al-Ayah mark), usually with the ayah''s number written inside using Arabic-Indic numerals. Reciters often pause briefly here to breathe and mark the boundary between verses — even when the grammatical sentence continues into the next ayah. This is different from the other waqf (stopping) signs found within the text, which indicate whether pausing at a specific word is preferred, permitted, or best avoided.');

insert into units (track_id, unit_type, title, sequence_order)
select id, 'thematic', 'Reading Marks & Rules', 6 from tracks where code = 'quranic_arabic';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'The Word Allah', 1, 4 from units where title = 'Reading Marks & Rules';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Completion of an Ayah', 2, 4 from units where title = 'Reading Marks & Rules';

do $$
declare
  v_unit_id int;
  v_lesson_id int;
  v_exercise_id int;
  v_word_allah_id int;
  v_ayah_completion_id int;
  v_fatiha_ayah1_id bigint;
begin
  select id into v_unit_id from units where title = 'Reading Marks & Rules';
  select id into v_word_allah_id from grammar_points where code = 'word_allah';
  select id into v_ayah_completion_id from grammar_points where code = 'ayah_completion';
  select id into v_fatiha_ayah1_id from ayat where surah_number = 1 and ayah_number = 1;

  -- The Word Allah lesson
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'The Word Allah';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'grammar_explanation', 1) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_word_allah_id, v_fatiha_ayah1_id);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'In بِسْمِ اللَّهِ, is the ل in اللَّهِ heavy or light?', '["Heavy", "Light"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'If الله comes right after a word ending in Dhammah, how is the ل pronounced?', '["Heavy", "Light"]'::jsonb, 0);

  -- Completion of an Ayah lesson
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'Completion of an Ayah';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'grammar_explanation', 1) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_ayah_completion_id, null);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What does the small circle symbol at the end of an ayah usually contain?', '["The ayah''s number", "The surah''s name", "A translation note", "Nothing"]'::jsonb, 0);
end $$;

insert into user_unit_progress (user_id, unit_id, status, started_at)
select u.id, (select id from units where title = 'Reading Marks & Rules'), 'in_progress', now()
from users u
on conflict (user_id, unit_id) do nothing;
