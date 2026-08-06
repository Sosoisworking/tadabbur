-- Links each recall_quiz exercise to the specific vocab_item/letter it
-- tests, so answering a quiz (right or wrong) can feed directly into
-- that item's SRS schedule — not just passive exposure from viewing its
-- card. Both columns nullable and mutually optional (not a strict "must
-- have exactly one" constraint): a future quiz testing pure grammar
-- comprehension, with no single item to grade, is a legitimate case.

alter table exercise_recall_quiz add column tested_vocab_item_id int references vocab_items(id);
alter table exercise_recall_quiz add column tested_letter_id int references letters(id);

-- Backfill: alphabet quizzes always immediately follow the letter_card
-- they test (docs/feature-specs.md's Duolingo-style interleaving from
-- migration 0005) — match on sequence adjacency within the same lesson
-- rather than re-deriving 28 individual letter mappings by hand again.
update exercise_recall_quiz erq
set tested_letter_id = prev_letter.letter_id
from exercises quiz_ex
join exercises letter_ex
  on letter_ex.lesson_id = quiz_ex.lesson_id
  and letter_ex.sequence_order = quiz_ex.sequence_order - 1
  and letter_ex.exercise_type = 'letter_card'
join exercise_letter_card prev_letter on prev_letter.exercise_id = letter_ex.id
where erq.exercise_id = quiz_ex.id;

-- Al-Fatiha's 2 quizzes aren't positionally adjacent to their vocab card
-- (the lesson interleaves vocab -> vocab -> reading -> quiz -> quiz), so
-- matched directly on the question text instead, which is distinctive
-- enough for these two rows (see migration 0002).
update exercise_recall_quiz
set tested_vocab_item_id = (select id from vocab_items where transliteration = 'Ar-Rahman')
where question like '%Ar-Rahman%';

update exercise_recall_quiz
set tested_vocab_item_id = (select id from vocab_items where transliteration = 'Rabb')
where question like '%Rabb%';
