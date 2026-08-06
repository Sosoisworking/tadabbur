-- Adds a 2-question recall_quiz section to the end of each of the 4
-- Arabic alphabet lessons (sequence_order continuing after the 7
-- letter_card exercises already in each lesson), testing recognition of
-- the letters just taught. Distractor options are drawn from the same
-- lesson's letters, since those are what a learner would realistically
-- confuse — not random letters from elsewhere in the alphabet.

do $$
declare
  v_unit_id int;
  v_lesson_id int;
  v_exercise_id int;
begin
  select id into v_unit_id from units where title = 'The Arabic Alphabet';

  -- Lesson 1: Alif to Kha (ا ب ت ث ج ح خ)
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'The Alphabet: Alif to Kha';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What is the name of this letter: ب', '["Ba", "Ta", "Tha", "Jim"]'::jsonb, 0);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 9) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What is the name of this letter: ح', '["Kha", "Ha", "Jim", "Alif"]'::jsonb, 1);

  -- Lesson 2: Dal to Sad (د ذ ر ز س ش ص)
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'The Alphabet: Dal to Sad';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What is the name of this letter: ذ', '["Dal", "Dhal", "Ra", "Zay"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 9) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What is the name of this letter: ش', '["Sin", "Sad", "Shin", "Ra"]'::jsonb, 2);

  -- Lesson 3: Dad to Qaf (ض ط ظ ع غ ف ق)
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'The Alphabet: Dad to Qaf';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What is the name of this letter: ع', '["Ghain", "Ain", "Fa", "Qaf"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 9) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What is the name of this letter: ط', '["Dad", "Ta (emphatic)", "Dha (emphatic)", "Qaf"]'::jsonb, 1);

  -- Lesson 4: Kaf to Ya (ك ل م ن ه و ي)
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'The Alphabet: Kaf to Ya';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What is the name of this letter: م', '["Nun", "Lam", "Mim", "Waw"]'::jsonb, 2);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 9) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What is the name of this letter: و', '["Waw", "Ya", "Ha (haa)", "Kaf"]'::jsonb, 0);
end $$;
