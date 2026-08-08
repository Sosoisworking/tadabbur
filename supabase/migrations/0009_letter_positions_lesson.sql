-- A 5th lesson in the Arabic Alphabet unit, practicing what migration
-- 0008 added: recognizing positional forms and the emphatic ("heavy")
-- letters. Deliberately reuses the existing recall_quiz exercise type
-- rather than inventing a new one — the positional-form data itself is
-- the new thing here, not the exercise mechanism.

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Letter Positions', 5, 4 from units where title = 'The Arabic Alphabet';

do $$
declare
  v_lesson_id int;
  v_exercise_id int;
begin
  select id into v_lesson_id from lessons where title = 'Letter Positions'
    and unit_id = (select id from units where title = 'The Arabic Alphabet');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 1) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
  values (v_exercise_id, 'Which is the BEGINNING form of ب?', '["بـ", "ـبـ", "ـب", "ب"]'::jsonb, 0, (select id from letters where sequence_order = 2));

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
  values (v_exercise_id, 'Which is the MIDDLE form of م?', '["مـ", "ـمـ", "ـم", "م"]'::jsonb, 1, (select id from letters where sequence_order = 24));

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
  values (v_exercise_id, 'Which is the END form of ن?', '["نـ", "ـنـ", "ـن", "ن"]'::jsonb, 2, (select id from letters where sequence_order = 25));

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
  values (v_exercise_id, 'و does not connect to the letter after it. What is its MIDDLE-of-word form?', '["و", "ـو", "ـوـ", "وـ"]'::jsonb, 1, (select id from letters where sequence_order = 27));

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 5) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
  values (v_exercise_id, 'Which of these letters is "heavy" (pronounced with a full mouth)?', '["ب", "ص", "م", "ن"]'::jsonb, 1, (select id from letters where sequence_order = 14));

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
  values (v_exercise_id, 'Which of these letters is NOT heavy?', '["ط", "ق", "ل", "غ"]'::jsonb, 2, (select id from letters where sequence_order = 23));

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 7) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
  values (v_exercise_id, 'Which is the BEGINNING form of س?', '["سـ", "ـسـ", "ـس", "س"]'::jsonb, 0, (select id from letters where sequence_order = 12));

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
  values (v_exercise_id, 'Which is the END form of ك?', '["كـ", "ـكـ", "ـك", "ك"]'::jsonb, 2, (select id from letters where sequence_order = 22));
end $$;
