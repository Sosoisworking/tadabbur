-- New unit: Connecting Letters. Matches the book's own sequence (Arabic
-- Alphabet -> Letter Recognition -> Letter Positions -> Connecting
-- Letters -> Fathah/Kasrah/Dhammah), which we'd departed from — our
-- "Vowel Marks" unit currently sits right after "The Arabic Alphabet"
-- with nothing in between. Per user request: jumping from single
-- letters straight to full words/ayahs is a big leap for a beginner;
-- this unit is the missing stepping stone — 2-letter chains, then
-- 3-letter chains, all unvocalized (no diacritics), same as how the
-- book's own connecting-letters table has no vowel marks either. It's
-- pure shape recognition: which letters are these, joined together?
--
-- The book's own table gives 3 example chains per letter (28 letters x
-- 3 = 84 cells) purely to drill every letter's joining behavior in
-- every position. We don't reproduce that table verbatim (same
-- transcription-risk reasoning as every other skipped page in this
-- track) — instead we use a smaller, hand-picked set of real short
-- Arabic words, still fully unvocalized, so every example is
-- independently verifiable and several double as thematically fitting
-- previews of vocabulary a Quranic Arabic learner will meet again
-- later (رب, سلم, علم, حمد, نور).
--
-- Because this sits BEFORE Vowel Marks rather than after Shaddah (where
-- every previous new unit has landed), inserting it means renumbering
-- five existing units, not just one. Done as a strict top-down cascade
-- (highest sequence_order moved first) so every UPDATE's target slot is
-- already vacant when it runs — no need for the +1000 staging trick
-- used in migrations 0005/0011, since a descending cascade never
-- collides.

update units set sequence_order = 7 where title = 'Reading Marks & Rules';
update units set sequence_order = 6 where title = 'Al-Fatiha — The Opening';
update units set sequence_order = 5 where title = 'Shaddah';
update units set sequence_order = 4 where title = 'Long Vowels & Diphthongs (Madd & Leen)';
update units set sequence_order = 3 where title = 'Vowel Marks (Harakat)';

-- A new grammar_points category: this content is about the Arabic
-- writing system itself (which letters visually join, which don't) —
-- not syntax (nahw), word-pattern morphology (sarf), or a recitation
-- rule (tajweed). grammar_points.category isn't read anywhere in the
-- app (grep confirms — it's a DB-side tag only), so widening it is
-- low-risk, same as adding 'tajweed' in migration 0018.
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
  check (category in ('nahw', 'sarf', 'tajweed', 'script'));

insert into grammar_points (code, category, title_en, explanation_short, explanation_full) values
  ('connecting_letters', 'script', 'Connecting Letters',
   'Most Arabic letters change shape and link to their neighbors when written together; six letters — ا د ذ ر ز و — never connect to the letter after them.',
   'When letters sit next to each other in a word, most of them join together with a small connecting stroke, and each letter takes on a slightly different shape depending on whether it''s at the start, middle, or end of that connected group. Six letters are the exception: ا (Alif), د (Dal), ذ (Dhal), ر (Ra), ز (Zay), and و (Waw) never connect forward to whatever comes after them, even in the middle of a word — so whenever one of them appears, the next letter starts a fresh, unjoined shape right beside it. Recognizing these joined and unjoined shapes is the last step before reading real words, which is exactly what the next two lessons practice.');

-- New exercise type: letter_chain. Just one column — chain_text, plain
-- unvocalized Arabic letters (e.g. 'كتب') — because there's nothing
-- else worth storing. The per-letter breakdown the UI shows underneath
-- (ك + ت + ب) isn't separately recorded: every Arabic consonant is a
-- single Unicode code point regardless of position, so splitting
-- chain_text into characters and rendering each alone (isolated form)
-- or together (joined form) is the same underlying text either way —
-- the font's shaping engine (already relied on throughout this app for
-- real ayah text) handles the rest, the same reasoning DiacriticIntro's
-- combined glyphs already rely on (computed at fetch/render time, never
-- precomputed and stored).
create table exercise_letter_chain (
  exercise_id  int primary key references exercises(id),
  chain_text   text not null
);

alter table exercise_letter_chain enable row level security;
create policy "content_public_read" on exercise_letter_chain for select using (true);

do $$
declare
  v_constraint_name text;
begin
  select conname into v_constraint_name
  from pg_constraint
  where conrelid = 'public.exercises'::regclass
    and contype = 'c'
    and pg_get_constraintdef(oid) like '%exercise_type%';

  if v_constraint_name is not null then
    execute format('alter table exercises drop constraint %I', v_constraint_name);
  end if;
end $$;

alter table exercises add constraint exercises_exercise_type_check
  check (exercise_type in (
    'vocab_card','grammar_explanation','reading_passage','listening_drill',
    'pronunciation_recording','recall_quiz','mastery_challenge','letter_card',
    'diacritic_intro','letter_chain'
  ));

insert into units (track_id, unit_type, title, sequence_order)
select id, 'thematic', 'Connecting Letters', 2 from tracks where code = 'quranic_arabic';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Two Letters Together', 1, 5 from units where title = 'Connecting Letters';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Three Letters Together', 2, 5 from units where title = 'Connecting Letters';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Connecting Letters Quiz', 3, 8 from units where title = 'Connecting Letters';

do $$
declare
  v_two_lesson_id int;
  v_three_lesson_id int;
  v_quiz_lesson_id int;
  v_connecting_id int;
  v_exercise_id int;
  v_chain text;
  v_seq int;
begin
  select l.id into v_two_lesson_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Connecting Letters' and l.title = 'Two Letters Together';
  select l.id into v_three_lesson_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Connecting Letters' and l.title = 'Three Letters Together';
  select l.id into v_quiz_lesson_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Connecting Letters' and l.title = 'Connecting Letters Quiz';
  select id into v_connecting_id from grammar_points where code = 'connecting_letters';

  -- Two Letters Together: concept intro, then 8 real 2-letter words
  -- (unvocalized) chosen to include both joined pairs and one pair
  -- with a visible gap (رب — ر doesn't connect forward).
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_two_lesson_id, 'grammar_explanation', 1) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_connecting_id, null);

  v_seq := 1;
  foreach v_chain in array array['من','في','هل','قد','يد','رب','لك','بر'] loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_two_lesson_id, 'letter_chain', v_seq) returning id into v_exercise_id;
    insert into exercise_letter_chain (exercise_id, chain_text) values (v_exercise_id, v_chain);
  end loop;

  -- Three Letters Together: 7 real 3-letter words, several of them
  -- roots the learner will meet again (علم, سلم, حمد, قلب, نور).
  v_seq := 0;
  foreach v_chain in array array['كتب','علم','سلم','قلب','نور','درس','حمد'] loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_three_lesson_id, 'letter_chain', v_seq) returning id into v_exercise_id;
    insert into exercise_letter_chain (exercise_id, chain_text) values (v_exercise_id, v_chain);
  end loop;

  -- Connecting Letters Quiz: tests letter-counting, ordered
  -- decomposition, and recognizing the six non-connecting letters —
  -- the actual skills this unit is building, not just recall of the
  -- specific words shown above.
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 1) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'How many letters make up كتب؟', '["2", "3", "4"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'How many letters make up من؟', '["1", "2", "3"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which letters make up قلب, in order?', '["ق ل ب", "ب ل ق", "ل ق ب", "ب ق ل"]'::jsonb, 0);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which letters make up سلم, in order?', '["م ل س", "س ل م", "ل س م", "س م ل"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 5) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which of these letters never connects to the letter after it?', '["ب", "ر", "س", "ك"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which of these letters never connects to the letter after it?', '["م", "ن", "و", "ت"]'::jsonb, 2);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 7) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'How many letters make up نور؟', '["2", "3", "4"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which letters make up درس, in order?', '["س ر د", "د ر س", "ر د س", "س د ر"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 9) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which of these words has a visible gap where two letters don''t connect?', '["كتب", "علم", "درس", "حمد"]'::jsonb, 2);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 10) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which of these two-letter words has a visible gap between its letters?', '["من", "لك", "رب", "في"]'::jsonb, 2);
end $$;

insert into user_unit_progress (user_id, unit_id, status, started_at)
select u.id, (select id from units where title = 'Connecting Letters'), 'in_progress', now()
from users u
on conflict (user_id, unit_id) do nothing;
