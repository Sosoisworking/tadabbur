-- Restructures the 4 alphabet lessons from "7 letters, then 2 quiz
-- questions at the end" to a Duolingo-style interleaved pattern: learn a
-- letter, get quizzed on that exact letter, learn the next one — 14
-- exercises per lesson (7 letter_card + 7 recall_quiz, alternating).
-- Replaces the 2-per-lesson "sampled" quizzes added in migration 0004.
--
-- This clears existing lesson_attempts/exercise_attempts for the
-- alphabet unit's lessons first, since the exercise set they reference
-- is being fundamentally restructured. Safe at this stage — pre-launch,
-- only the founder's own test data exists, not real users.

do $$
declare
  v_unit_id int;
begin
  select id into v_unit_id from units where title = 'The Arabic Alphabet';

  delete from exercise_attempts
    where exercise_id in (
      select e.id from exercises e join lessons l on l.id = e.lesson_id where l.unit_id = v_unit_id
    );
  delete from lesson_attempts
    where lesson_id in (select id from lessons where unit_id = v_unit_id);

  delete from exercise_recall_quiz
    where exercise_id in (
      select e.id from exercises e join lessons l on l.id = e.lesson_id
      where l.unit_id = v_unit_id and e.exercise_type = 'recall_quiz'
    );
  delete from exercises
    where lesson_id in (select id from lessons where unit_id = v_unit_id) and exercise_type = 'recall_quiz';

  -- Re-evaluate from scratch once the new structure is in place.
  update user_unit_progress set status = 'in_progress', completed_at = null
    where unit_id = v_unit_id and status = 'completed';
end $$;

-- Reposition each lesson's 7 letter_card exercises onto odd positions
-- (1, 3, 5, 7, 9, 11, 13), keeping their original alphabet order —
-- joined via letters.sequence_order rather than assuming exercise ids
-- are still contiguous after the migration 0004 inserts.
--
-- Staged through a safe high range first: the target positions (1-13)
-- overlap the current positions (1-7), and a single UPDATE checks the
-- unique (lesson_id, sequence_order) constraint per row as it's written,
-- not deferred to end-of-statement — writing straight to final positions
-- collides with a sibling row that hasn't moved yet.
update exercises set sequence_order = sequence_order + 1000
where lesson_id in (select id from lessons where unit_id = (select id from units where title = 'The Arabic Alphabet'))
  and exercise_type = 'letter_card';

update exercises e set sequence_order = 2 * l.sequence_order - 1
from exercise_letter_card elc join letters l on l.id = elc.letter_id
where e.id = elc.exercise_id and l.sequence_order between 1 and 7;

update exercises e set sequence_order = 2 * (l.sequence_order - 7) - 1
from exercise_letter_card elc join letters l on l.id = elc.letter_id
where e.id = elc.exercise_id and l.sequence_order between 8 and 14;

update exercises e set sequence_order = 2 * (l.sequence_order - 14) - 1
from exercise_letter_card elc join letters l on l.id = elc.letter_id
where e.id = elc.exercise_id and l.sequence_order between 15 and 21;

update exercises e set sequence_order = 2 * (l.sequence_order - 21) - 1
from exercise_letter_card elc join letters l on l.id = elc.letter_id
where e.id = elc.exercise_id and l.sequence_order between 22 and 28;

-- One recall_quiz per letter, immediately after that letter's card.
-- Distractor options are the other letters from the same lesson.

do $$
declare
  v_unit_id int;
  v_lesson_id int;
  v_exercise_id int;
begin
  select id into v_unit_id from units where title = 'The Arabic Alphabet';

  -- Lesson 1: Alif to Kha
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'The Alphabet: Alif to Kha';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ا', '["Alif", "Ba", "Jim", "Kha"]'::jsonb, 0);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ب', '["Ba", "Ta", "Tha", "Jim"]'::jsonb, 0);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ت', '["Tha", "Ta", "Ha", "Alif"]'::jsonb, 1);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ث', '["Tha", "Jim", "Kha", "Ba"]'::jsonb, 0);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 10) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ج', '["Ha", "Jim", "Ta", "Alif"]'::jsonb, 1);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 12) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ح', '["Kha", "Ha", "Jim", "Alif"]'::jsonb, 1);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 14) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: خ', '["Kha", "Ha", "Tha", "Ba"]'::jsonb, 0);

  -- Lesson 2: Dal to Sad
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'The Alphabet: Dal to Sad';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: د', '["Dal", "Dhal", "Ra", "Zay"]'::jsonb, 0);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ذ', '["Dal", "Dhal", "Ra", "Zay"]'::jsonb, 1);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ر', '["Zay", "Ra", "Sin", "Dal"]'::jsonb, 1);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ز', '["Sin", "Zay", "Shin", "Dhal"]'::jsonb, 1);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 10) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: س', '["Sin", "Shin", "Sad", "Ra"]'::jsonb, 0);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 12) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ش', '["Sin", "Sad", "Shin", "Ra"]'::jsonb, 2);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 14) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ص', '["Sad", "Shin", "Zay", "Dal"]'::jsonb, 0);

  -- Lesson 3: Dad to Qaf
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'The Alphabet: Dad to Qaf';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ض', '["Dad", "Ta (emphatic)", "Fa", "Qaf"]'::jsonb, 0);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ط', '["Dad", "Ta (emphatic)", "Dha (emphatic)", "Qaf"]'::jsonb, 1);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ظ', '["Ta (emphatic)", "Dha (emphatic)", "Ain", "Fa"]'::jsonb, 1);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ع', '["Ghain", "Ain", "Fa", "Qaf"]'::jsonb, 1);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 10) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: غ', '["Ghain", "Ain", "Dad", "Qaf"]'::jsonb, 0);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 12) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ف', '["Qaf", "Fa", "Ghain", "Dha (emphatic)"]'::jsonb, 1);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 14) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ق', '["Fa", "Qaf", "Ain", "Dad"]'::jsonb, 1);

  -- Lesson 4: Kaf to Ya
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'The Alphabet: Kaf to Ya';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ك', '["Kaf", "Lam", "Nun", "Waw"]'::jsonb, 0);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ل', '["Kaf", "Lam", "Mim", "Ya"]'::jsonb, 1);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: م', '["Nun", "Lam", "Mim", "Waw"]'::jsonb, 2);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ن', '["Nun", "Mim", "Ha (haa)", "Ya"]'::jsonb, 0);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 10) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ه', '["Ha (haa)", "Waw", "Kaf", "Nun"]'::jsonb, 0);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 12) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: و', '["Waw", "Ya", "Ha (haa)", "Kaf"]'::jsonb, 0);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 14) returning id into v_exercise_id;
  insert into exercise_recall_quiz values (v_exercise_id, 'What is the name of this letter: ي', '["Waw", "Ya", "Lam", "Mim"]'::jsonb, 1);
end $$;
