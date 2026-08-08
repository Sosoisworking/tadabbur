-- Phase 2 of the Qaida content adaptation: Fathah, Kasrah, Dhammah — the
-- three short vowel marks. Modeled as their own table rather than
-- shoehorned into grammar_points (phonetic/orthographic marks aren't
-- grammar) or vocab_items (they're not words) — same reasoning as why
-- letters got their own table back in migration 0003.
--
-- Combination glyphs (letter + mark, e.g. "بَ") are NOT precomputed and
-- stored — Arabic combining diacritics render correctly when the mark's
-- Unicode character simply follows the base letter, so the app computes
-- these client-side from the existing letters table + this table's
-- mark_unicode, avoiding a 28-letters x N-marks join table for data that
-- has no independent existence beyond string concatenation.

create table diacritics (
  id                 serial primary key,
  name_en            text not null,
  mark_unicode       text not null,
  placement          text not null check (placement in ('above','below')),
  sound_description  text not null,
  explanation_short  text not null,
  explanation_full   text not null,
  sequence_order     int not null unique,
  audio_url          text not null
);

alter table diacritics enable row level security;
create policy "content_public_read" on diacritics for select using (true);

create table exercise_diacritic_intro (
  exercise_id   int primary key references exercises(id),
  diacritic_id  int not null references diacritics(id)
);

alter table exercise_diacritic_intro enable row level security;
create policy "content_public_read" on exercise_diacritic_intro for select using (true);

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
    'diacritic_intro'
  ));

insert into diacritics (name_en, mark_unicode, placement, sound_description, explanation_short, explanation_full, sequence_order, audio_url) values
  ('Fathah', chr(1614), 'above',
   'A short "a" sound, like the "a" in "man"',
   'Fathah is a small diagonal stroke written above a letter. It gives that letter a short "a" sound.',
   'Fathah (فتحة) is one of the three short vowel marks in Arabic. Written as a small diagonal stroke above a letter, it adds a short "a" sound right after that letter is pronounced — for example, a ب with a Fathah is read "Ba," not just "B." Every consonant in Arabic needs a vowel mark like Fathah to be readable; without one, you only know the letter, not how to say it.',
   1, 'placeholder/audio-not-yet-recorded.mp3'),
  ('Kasrah', chr(1616), 'below',
   'A short "i" sound, like the "i" in "tin"',
   'Kasrah is a small diagonal stroke written below a letter. It gives that letter a short "i" sound.',
   'Kasrah (كسرة) is written as a small diagonal stroke below a letter, adding a short "i" sound right after it — a ب with a Kasrah is read "Bi." It is the only one of the three short vowels written below the letter rather than above it, which is a useful visual cue when reading quickly.',
   2, 'placeholder/audio-not-yet-recorded.mp3'),
  ('Dhammah', chr(1615), 'above',
   'A short "u" sound, like the "u" in "push"',
   'Dhammah looks like a tiny waw written above a letter. It gives that letter a short "u" sound.',
   'Dhammah (ضمة) is written as a small curl (shaped like a miniature و) above a letter, adding a short "u" sound right after it — a ب with a Dhammah is read "Bu." Together, Fathah, Kasrah, and Dhammah are the three short vowels that make every letter in Arabic readable.',
   3, 'placeholder/audio-not-yet-recorded.mp3');

-- ============================================================
-- New unit, inserted BETWEEN Alphabet and Al-Fatiha
-- ============================================================
-- Reading Al-Fatiha requires vowel marks, so this has to come before
-- it, not after — same reasoning as putting the alphabet before
-- Al-Fatiha in migration 0003.

update units set sequence_order = 3 where title = 'Al-Fatiha — The Opening';

insert into units (track_id, unit_type, title, sequence_order)
select id, 'thematic', 'Vowel Marks (Harakat)', 2 from tracks where code = 'quranic_arabic';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Fathah', 1, 5 from units where title = 'Vowel Marks (Harakat)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Kasrah', 2, 5 from units where title = 'Vowel Marks (Harakat)';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Dhammah', 3, 5 from units where title = 'Vowel Marks (Harakat)';

do $$
declare
  v_unit_id int;
  v_lesson_id int;
  v_exercise_id int;
  v_fathah_id int;
  v_kasrah_id int;
  v_dhammah_id int;
begin
  select id into v_unit_id from units where title = 'Vowel Marks (Harakat)';
  select id into v_fathah_id from diacritics where name_en = 'Fathah';
  select id into v_kasrah_id from diacritics where name_en = 'Kasrah';
  select id into v_dhammah_id from diacritics where name_en = 'Dhammah';

  -- Fathah lesson
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'Fathah';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'diacritic_intro', 1) returning id into v_exercise_id;
  insert into exercise_diacritic_intro (exercise_id, diacritic_id) values (v_exercise_id, v_fathah_id);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index) values (v_exercise_id, 'How do you read بَ ?', '["Ba", "Bi", "Bu", "B"]'::jsonb, 0);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index) values (v_exercise_id, 'How do you read تَ ?', '["Ti", "Tu", "Ta", "T"]'::jsonb, 2);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index) values (v_exercise_id, 'What sound does Fathah make?', '["\"a\" as in \"man\"", "\"i\" as in \"tin\"", "\"u\" as in \"push\"", "no sound"]'::jsonb, 0);

  -- Kasrah lesson
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'Kasrah';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'diacritic_intro', 1) returning id into v_exercise_id;
  insert into exercise_diacritic_intro (exercise_id, diacritic_id) values (v_exercise_id, v_kasrah_id);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index) values (v_exercise_id, 'How do you read مِ ?', '["Ma", "Mi", "Mu", "M"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index) values (v_exercise_id, 'How do you read سِ ?', '["Sa", "Si", "Su", "S"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index) values (v_exercise_id, 'What sound does Kasrah make?', '["\"a\" as in \"man\"", "\"i\" as in \"tin\"", "\"u\" as in \"push\"", "no sound"]'::jsonb, 1);

  -- Dhammah lesson
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'Dhammah';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'diacritic_intro', 1) returning id into v_exercise_id;
  insert into exercise_diacritic_intro (exercise_id, diacritic_id) values (v_exercise_id, v_dhammah_id);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index) values (v_exercise_id, 'How do you read نُ ?', '["Na", "Ni", "Nu", "N"]'::jsonb, 2);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index) values (v_exercise_id, 'How do you read كُ ?', '["Ka", "Ki", "Ku", "K"]'::jsonb, 2);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index) values (v_exercise_id, 'What sound does Dhammah make?', '["\"a\" as in \"man\"", "\"i\" as in \"tin\"", "\"u\" as in \"push\"", "no sound"]'::jsonb, 2);
end $$;

-- Backfill: existing users get the new unit immediately, same reasoning
-- as migration 0003's backfill for the alphabet unit.
insert into user_unit_progress (user_id, unit_id, status, started_at)
select u.id, (select id from units where title = 'Vowel Marks (Harakat)'), 'in_progress', now()
from users u
on conflict (user_id, unit_id) do nothing;
