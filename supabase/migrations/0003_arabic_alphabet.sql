-- Adds the Arabic alphabet as its own content type — not shoehorned into
-- vocab_items, since letters aren't vocabulary (no root/pattern, and
-- docs/feature-specs.md §1 treats "script literacy" as an axis distinct
-- from "vocabulary/grammar knowledge"). This is the letter-recognition
-- primer that persona routing already assumes exists for a
-- zero-literacy learner (feature-specs.md: "Below threshold -> routes
-- into a letter-recognition primer before any vocabulary content").

-- ============================================================
-- 1. Schema: letters + the new letter_card exercise type
-- ============================================================

create table letters (
  id                     serial primary key,
  isolated_form          text not null,
  name_arabic            text not null,
  name_transliteration   text not null,
  pronunciation_guide    text not null,
  sequence_order         int not null unique,
  audio_url              text not null
);

alter table letters enable row level security;
create policy "content_public_read" on letters for select using (true);

create table exercise_letter_card (
  exercise_id  int primary key references exercises(id),
  letter_id    int not null references letters(id)
);

alter table exercise_letter_card enable row level security;
create policy "content_public_read" on exercise_letter_card for select using (true);

-- Widen the exercises.exercise_type check constraint to include
-- 'letter_card'. Found dynamically rather than hardcoding Postgres'
-- auto-generated constraint name, since guessing wrong would silently
-- fail or drop the wrong thing.
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
    'pronunciation_recording','recall_quiz','mastery_challenge','letter_card'
  ));

-- ============================================================
-- 2. Seed all 28 letters (standard hija'i / dictionary order)
-- ============================================================
-- Pronunciation guides are plain-English approximations for a complete
-- beginner, not IPA — good enough for "recognize and roughly sound out,"
-- which is this primer's whole job. audio_url is a placeholder, same as
-- the Al-Fatiha vocab seed — real reciter/pronunciation audio is ongoing
-- M1 content-sourcing work, not something to fabricate a URL for here.

insert into letters (isolated_form, name_arabic, name_transliteration, pronunciation_guide, sequence_order, audio_url) values
  ('ا', 'أَلِف', 'Alif', 'A long "aa" as in "father"', 1, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ب', 'باء', 'Ba', '"b" as in "book"', 2, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ت', 'تاء', 'Ta', '"t" as in "top"', 3, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ث', 'ثاء', 'Tha', '"th" as in "think"', 4, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ج', 'جيم', 'Jim', '"j" as in "jam"', 5, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ح', 'حاء', 'Ha', 'A breathy "h" from deep in the throat — no English equivalent', 6, 'placeholder/audio-not-yet-recorded.mp3'),
  ('خ', 'خاء', 'Kha', 'Like the "ch" in Scottish "loch"', 7, 'placeholder/audio-not-yet-recorded.mp3'),
  ('د', 'دال', 'Dal', '"d" as in "dog"', 8, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ذ', 'ذال', 'Dhal', '"th" as in "this"', 9, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ر', 'راء', 'Ra', 'A rolled/trilled "r"', 10, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ز', 'زاي', 'Zay', '"z" as in "zoo"', 11, 'placeholder/audio-not-yet-recorded.mp3'),
  ('س', 'سين', 'Sin', '"s" as in "sun"', 12, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ش', 'شين', 'Shin', '"sh" as in "shoe"', 13, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ص', 'صاد', 'Sad', 'An emphatic, heavy "s"', 14, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ض', 'ضاد', 'Dad', 'An emphatic, heavy "d"', 15, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ط', 'طاء', 'Ta (emphatic)', 'An emphatic, heavy "t"', 16, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ظ', 'ظاء', 'Dha (emphatic)', 'An emphatic, heavy "th" as in "this"', 17, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ع', 'عين', 'Ain', 'A deep throat sound — no English equivalent', 18, 'placeholder/audio-not-yet-recorded.mp3'),
  ('غ', 'غين', 'Ghain', 'A guttural sound similar to gargling, like a French "r"', 19, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ف', 'فاء', 'Fa', '"f" as in "fun"', 20, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ق', 'قاف', 'Qaf', 'A deep "k" sound made from the back of the throat', 21, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ك', 'كاف', 'Kaf', '"k" as in "kite"', 22, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ل', 'لام', 'Lam', '"l" as in "lamp"', 23, 'placeholder/audio-not-yet-recorded.mp3'),
  ('م', 'ميم', 'Mim', '"m" as in "moon"', 24, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ن', 'نون', 'Nun', '"n" as in "noon"', 25, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ه', 'هاء', 'Ha (haa)', '"h" as in "hat"', 26, 'placeholder/audio-not-yet-recorded.mp3'),
  ('و', 'واو', 'Waw', '"w" as in "wow", or a long "oo" vowel', 27, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ي', 'ياء', 'Ya', '"y" as in "yes", or a long "ee" vowel', 28, 'placeholder/audio-not-yet-recorded.mp3');

-- ============================================================
-- 3. New unit, sequenced BEFORE Al-Fatiha, with 4 lessons of 7 letters
-- ============================================================
-- Al-Fatiha moves to sequence_order 2 first, freeing up slot 1 — avoids
-- ever having two rows collide on the (track_id, sequence_order)
-- unique constraint mid-migration.

update units set sequence_order = 2 where title = 'Al-Fatiha — The Opening';

insert into units (track_id, unit_type, title, sequence_order)
select id, 'thematic', 'The Arabic Alphabet', 1 from tracks where code = 'quranic_arabic';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'The Alphabet: Alif to Kha', 1, 5 from units where title = 'The Arabic Alphabet';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'The Alphabet: Dal to Sad', 2, 5 from units where title = 'The Arabic Alphabet';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'The Alphabet: Dad to Qaf', 3, 5 from units where title = 'The Arabic Alphabet';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'The Alphabet: Kaf to Ya', 4, 5 from units where title = 'The Arabic Alphabet';

-- One letter_card exercise per letter, 7 per lesson, in alphabet order —
-- looped rather than 28 hand-written insert pairs, since the
-- lesson/sequence math is mechanical and copy-pasting 28 near-identical
-- statements is exactly where a manual mistake would creep in.
do $$
declare
  v_alphabet_unit_id int;
  v_lesson_id int;
  v_exercise_id int;
  v_letter record;
  v_lesson_seq int;
  v_exercise_seq int;
begin
  select id into v_alphabet_unit_id from units where title = 'The Arabic Alphabet';

  for v_letter in select id, sequence_order from letters order by sequence_order loop
    v_lesson_seq := ((v_letter.sequence_order - 1) / 7) + 1;
    v_exercise_seq := ((v_letter.sequence_order - 1) % 7) + 1;

    select id into v_lesson_id from lessons
      where unit_id = v_alphabet_unit_id and sequence_order = v_lesson_seq;

    insert into exercises (lesson_id, exercise_type, sequence_order)
    values (v_lesson_id, 'letter_card', v_exercise_seq)
    returning id into v_exercise_id;

    insert into exercise_letter_card (exercise_id, letter_id)
    values (v_exercise_id, v_letter.id);
  end loop;
end $$;

-- ============================================================
-- 4. Backfill: give any existing user the new unit immediately
-- ============================================================
-- New signups get this automatically (handle_new_auth_user always
-- starts whichever unit is sequence_order 1, which is now the alphabet
-- unit) — but users who already exist need it added explicitly, since
-- the trigger only fires on new auth.users rows.

insert into user_unit_progress (user_id, unit_id, status, started_at)
select u.id, (select id from units where title = 'The Arabic Alphabet'), 'in_progress', now()
from users u
on conflict (user_id, unit_id) do nothing;
