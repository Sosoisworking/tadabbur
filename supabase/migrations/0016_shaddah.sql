-- Phase 5 of the Qaida adaptation: Shaddah. New unit (per user request
-- to keep this separate from Long Vowels & Diphthongs), inserted before
-- Al-Fatiha — which contains a Shaddah (الرَّحْمَٰنِ), same reasoning as
-- every previous unit-ordering decision in this content track.
--
-- The book's own grid combines Shaddah with Fathah specifically (not a
-- separate grid per harakah), so that's what's modeled here.
--
-- Skipped again (consistent with every other "Words with X" page so
-- far): the book's "Words with Shaddah" review page, for the same
-- transcription-risk reasoning.

alter table diacritics add column doubles_consonant boolean not null default false;

insert into diacritics (name_en, mark_unicode, placement, sound_description, explanation_short, explanation_full, reading_suffix, doubles_consonant, sequence_order, audio_url) values
  ('Shaddah', chr(1617) || chr(1614), 'above',
   'The letter is pronounced TWICE — once with no vowel, once with the vowel',
   'Shaddah is a small "w"-shaped symbol above a letter. It means that letter is pronounced twice: first with no vowel (Saakin), then again with its vowel mark.',
   'Shaddah (شدة), also called Tashdeed, doubles a consonant: ب with a Shaddah and Fathah is read "Bba," not "Ba" — the letter is genuinely said twice, not just held longer the way a Madd letter is. When Shaddah falls on ن or م specifically, the reciter should prolong the nasal sound (Ghunnah) through the doubled letter.',
   'a', true, 13, 'placeholder/audio-not-yet-recorded.mp3');

update units set sequence_order = 5 where title = 'Al-Fatiha — The Opening';

insert into units (track_id, unit_type, title, sequence_order)
select id, 'thematic', 'Shaddah', 4 from tracks where code = 'quranic_arabic';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Shaddah', 1, 5 from units where title = 'Shaddah';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Shaddah Quiz', 2, 10 from units where title = 'Shaddah';

do $$
declare
  v_unit_id int;
  v_lesson_id int;
  v_quiz_lesson_id int;
  v_shaddah_id int;
  v_mark text;
  v_exercise_id int;
  v_letter record;
  v_options jsonb;
  v_correct text;
  v_seq int;
begin
  select id into v_unit_id from units where title = 'Shaddah';
  select id into v_lesson_id from lessons where unit_id = v_unit_id and title = 'Shaddah';
  select id into v_quiz_lesson_id from lessons where unit_id = v_unit_id and title = 'Shaddah Quiz';
  select id, mark_unicode into v_shaddah_id, v_mark from diacritics where name_en = 'Shaddah';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'diacritic_intro', 1) returning id into v_exercise_id;
  insert into exercise_diacritic_intro (exercise_id, diacritic_id) values (v_exercise_id, v_shaddah_id);

  v_seq := 0;
  for v_letter in select id, isolated_form, base_consonant from letters order by sequence_order loop
    v_seq := v_seq + 1;
    v_correct := v_letter.base_consonant || v_letter.base_consonant || 'a';
    -- Distractors are the plain short vowels (not doubled) — tests
    -- whether the doubling itself is recognized, not just "some vowel."
    v_options := jsonb_build_array(
      v_correct,
      v_letter.base_consonant || 'a',
      v_letter.base_consonant || 'i',
      v_letter.base_consonant || 'u'
    );
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', v_seq) returning id into v_exercise_id;
    insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
    values (v_exercise_id, 'How do you read ' || v_letter.isolated_form || v_mark || ' ?', v_options, 0, v_letter.id);
  end loop;
end $$;

insert into user_unit_progress (user_id, unit_id, status, started_at)
select u.id, (select id from units where title = 'Shaddah'), 'in_progress', now()
from users u
on conflict (user_id, unit_id) do nothing;
