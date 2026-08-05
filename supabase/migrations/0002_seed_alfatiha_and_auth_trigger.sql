-- Seeds the Quranic Arabic track with Al-Fatiha as the first real unit, and
-- adds the standard Supabase pattern of auto-provisioning a public.users
-- row (plus starting the first unit) whenever someone signs in for the
-- first time — anonymous or email, doesn't matter, both create an
-- auth.users row that this trigger reacts to.

-- ============================================================
-- 1. Track + Al-Fatiha content
-- ============================================================

insert into tracks (code, name) values ('quranic_arabic', 'Quranic Arabic');

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type)
values (1, 'الفاتحة', 'Al-Fatiha', 7, 'meccan');

-- Uthmani/diacritized text is identical here — both fields carry full
-- Tashkeel per the standard King Fahd Complex Uthmani printing; they'd
-- only diverge if we later add a simplified/Imlaei spelling variant.
-- Tajweed markup is intentionally left empty: per docs/tech-stack.md §5,
-- rule-level Tajweed detail is descoped to a post-MVP phase, and hand-
-- authoring positions we can't verify against real tooling risks being
-- wrong, which is worse than leaving it empty for now.
insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en) values
  (1, 1, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', '[]'::jsonb, 'In the name of Allah, the Entirely Merciful, the Especially Merciful.'),
  (1, 2, 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', '[]'::jsonb, 'All praise is due to Allah, Lord of the worlds.'),
  (1, 3, 'الرَّحْمَٰنِ الرَّحِيمِ', 'الرَّحْمَٰنِ الرَّحِيمِ', '[]'::jsonb, 'The Entirely Merciful, the Especially Merciful,'),
  (1, 4, 'مَالِكِ يَوْمِ الدِّينِ', 'مَالِكِ يَوْمِ الدِّينِ', '[]'::jsonb, 'Sovereign of the Day of Recompense.'),
  (1, 5, 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', '[]'::jsonb, 'It is You we worship and You we ask for help.'),
  (1, 6, 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', '[]'::jsonb, 'Guide us to the straight path,'),
  (1, 7, 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', '[]'::jsonb, 'The path of those You have blessed, not of those who have incurred wrath, nor of those who have gone astray.');

insert into units (track_id, unit_type, surah_number, title, sequence_order)
select id, 'surah', 1, 'Al-Fatiha — The Opening', 1 from tracks where code = 'quranic_arabic';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Fatiha: Meaning and Vocabulary', 1, 5 from units where title = 'Al-Fatiha — The Opening';

-- audio_url is a placeholder — real reciter audio is a content-sourcing
-- task for the ongoing M1 milestone (docs/implementation-plan.md), not
-- something to fabricate a fake working URL for here.
insert into vocab_items (arabic_text, transliteration, root_letters, wazn_pattern, meaning_en, frequency_rank, audio_url) values
  ('اللَّه', 'Allah', null, null, 'Allah (the one God) — a proper noun, not derived from a root the way ordinary words are', 1, 'placeholder/audio-not-yet-recorded.mp3'),
  ('رَبّ', 'Rabb', 'ر-ب-ب', 'فَعْل', 'Lord, Sustainer, the one who nurtures something to completion', 2, 'placeholder/audio-not-yet-recorded.mp3'),
  ('الرَّحْمَٰن', 'Ar-Rahman', 'ر-ح-م', 'فَعْلَان', 'The Entirely Merciful — mercy encompassing all creation', 3, 'placeholder/audio-not-yet-recorded.mp3'),
  ('الرَّحِيم', 'Ar-Raheem', 'ر-ح-م', 'فَعِيل', 'The Especially Merciful — mercy specific to the believers', 4, 'placeholder/audio-not-yet-recorded.mp3'),
  ('الْحَمْد', 'Al-Hamd', 'ح-م-د', 'فَعْل', 'Praise — gratitude and commendation together', 5, 'placeholder/audio-not-yet-recorded.mp3'),
  ('الصِّرَاط', 'As-Sirat', 'ص-ر-ط', 'فِعَال', 'The path, the way', 6, 'placeholder/audio-not-yet-recorded.mp3');

-- Two vocab_card exercises, one reading_passage covering the whole surah,
-- two recall_quiz exercises — enough for a real, working lesson end to
-- end. More lessons/exercises are ongoing M1 content work, not a one-shot
-- deliverable.
insert into exercises (lesson_id, exercise_type, sequence_order)
select l.id, 'vocab_card', 1 from lessons l where l.title = 'Al-Fatiha: Meaning and Vocabulary';
insert into exercise_vocab_card (exercise_id, vocab_item_id)
select e.id, v.id from exercises e, vocab_items v
where e.sequence_order = 1 and e.lesson_id = (select id from lessons where title = 'Al-Fatiha: Meaning and Vocabulary')
  and v.transliteration = 'Ar-Rahman';

insert into exercises (lesson_id, exercise_type, sequence_order)
select l.id, 'vocab_card', 2 from lessons l where l.title = 'Al-Fatiha: Meaning and Vocabulary';
insert into exercise_vocab_card (exercise_id, vocab_item_id)
select e.id, v.id from exercises e, vocab_items v
where e.sequence_order = 2 and e.lesson_id = (select id from lessons where title = 'Al-Fatiha: Meaning and Vocabulary')
  and v.transliteration = 'Rabb';

insert into exercises (lesson_id, exercise_type, sequence_order)
select l.id, 'reading_passage', 3 from lessons l where l.title = 'Al-Fatiha: Meaning and Vocabulary';
insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id)
select e.id,
  (select id from ayat where surah_number = 1 and ayah_number = 1),
  (select id from ayat where surah_number = 1 and ayah_number = 7)
from exercises e
where e.sequence_order = 3 and e.lesson_id = (select id from lessons where title = 'Al-Fatiha: Meaning and Vocabulary');

insert into exercises (lesson_id, exercise_type, sequence_order)
select l.id, 'recall_quiz', 4 from lessons l where l.title = 'Al-Fatiha: Meaning and Vocabulary';
insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
select e.id, 'What does "الرَّحْمَٰن" (Ar-Rahman) mean?',
  '["The Entirely Merciful", "The King", "The Creator", "The Guide"]'::jsonb, 0
from exercises e
where e.sequence_order = 4 and e.lesson_id = (select id from lessons where title = 'Al-Fatiha: Meaning and Vocabulary');

insert into exercises (lesson_id, exercise_type, sequence_order)
select l.id, 'recall_quiz', 5 from lessons l where l.title = 'Al-Fatiha: Meaning and Vocabulary';
insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
select e.id, 'What does "رَبّ" (Rabb) mean?',
  '["Lord / Sustainer", "Worship", "Path", "Praise"]'::jsonb, 0
from exercises e
where e.sequence_order = 5 and e.lesson_id = (select id from lessons where title = 'Al-Fatiha: Meaning and Vocabulary');

-- ============================================================
-- 2. Auto-provision public.users + start the first unit
-- ============================================================
-- Standard Supabase pattern: auth.users is managed by the Auth service,
-- so anything the app needs alongside it (a public.users row, initial
-- progress) has to be created reactively via a trigger, not inserted by
-- client code that may not have permission to write to auth.users itself.
-- Fires identically for anonymous and email sign-ins — both create an
-- auth.users row.

create function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  v_track_id int;
  v_first_unit_id int;
begin
  select id into v_track_id from public.tracks where code = 'quranic_arabic' limit 1;

  insert into public.users (id, display_name, timezone, current_track_id)
  values (new.id, coalesce(new.email, 'Learner'), 'UTC', v_track_id);

  select id into v_first_unit_id from public.units
    where track_id = v_track_id
    order by sequence_order
    limit 1;

  if v_first_unit_id is not null then
    insert into public.user_unit_progress (user_id, unit_id, status, started_at)
    values (new.id, v_first_unit_id, 'in_progress', now());
  end if;

  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();
