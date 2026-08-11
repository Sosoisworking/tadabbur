-- Removes the closing comprehension quiz (recall_quiz) from every
-- lesson in the "Short Surahs" unit, per user request. These are the
-- "What does Surat X describe?" multiple-choice questions added in
-- migrations 0035-0038, always the last exercise in each of the 16
-- lessons. A live check before writing this migration confirmed none
-- of the 16 recall_quiz exercises have any exercise_attempts rows, so
-- a plain delete is safe here (unlike migration 0039, which had to
-- preserve rows with real attempt history).
--
-- Deletes the exercise_recall_quiz child row before the exercises
-- parent row (no cascade on that FK). Scoped dynamically by unit/lesson
-- join rather than hardcoding the 16 exercise ids, so this doesn't
-- silently miss a lesson if the unit's content changes again later.
-- No renumbering needed afterward: the quiz was always the highest
-- sequence_order in its lesson, and the app only orders by
-- sequence_order, it doesn't require contiguous values.

delete from exercise_recall_quiz erq
using exercises e
join lessons l on l.id = e.lesson_id
join units u on u.id = l.unit_id
where erq.exercise_id = e.id
  and u.title = 'Short Surahs'
  and e.exercise_type = 'recall_quiz';

delete from exercises e
using lessons l, units u
where e.lesson_id = l.id
  and l.unit_id = u.id
  and u.title = 'Short Surahs'
  and e.exercise_type = 'recall_quiz';
