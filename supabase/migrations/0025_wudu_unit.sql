-- Phase 1 of the Prayer Guide adaptation (Prayer-Guide.pdf, a new,
-- separate source from the Qaida book — practical worship instruction,
-- not Arabic reading mechanics). Per user decision, phased: Wudu first
-- (smaller, self-contained, 10 clear steps), Salah itself and the
-- short-surahs-for-prayer content follow in later migrations.
--
-- Two new exercise types, neither of which fit any existing table:
--
-- 1. knowledge_card / knowledge_points — a general "explain a concept"
--    card, structurally identical to grammar_explanation but
--    deliberately a NEW table rather than widening grammar_points'
--    category enum again. tajweed and script (migrations 0018, 0019)
--    were still fundamentally about Quranic Arabic reading; "why wudu
--    matters" is Islamic practice, not language — stretching
--    grammar_points to cover it would make that table's name actively
--    misleading. category is 'wudu' for now; 'salah' will be added in
--    the next phase.
--
-- 2. prayer_step / exercise_prayer_step — a single step in a physical+
--    verbal procedure: an instruction, and an optional Arabic phrase
--    to say (with transliteration, translation, and how many times to
--    repeat it). Nothing existing models "do this action, optionally
--    saying this phrase N times" — vocab_card is a single word with no
--    action/repeat concept, grammar_explanation has no phrase-to-say
--    concept. All fields but instruction_en are nullable because not
--    every step involves speech (e.g. washing the arms) and not every
--    spoken step has a repeat count (e.g. the one-time shahada at the
--    end of wudu).
--
-- Arabic phrases here (Bismillah, the shahada, the post-wudu dua) are
-- standard, universally fixed liturgical wording, not Quranic text
-- requiring per-verse sourcing the way Short Ayahs did — verified
-- against well-established transliteration/translation convention,
-- same confidence level as Al-Fatiha's own seed data.

create table knowledge_points (
  id                serial primary key,
  code              text unique not null,
  category          text not null check (category in ('wudu', 'salah')),
  title_en          text not null,
  explanation_short text not null,
  explanation_full  text not null
);

alter table knowledge_points enable row level security;
create policy "content_public_read" on knowledge_points for select using (true);

create table exercise_knowledge_card (
  exercise_id       int primary key references exercises(id),
  knowledge_point_id int not null references knowledge_points(id)
);

alter table exercise_knowledge_card enable row level security;
create policy "content_public_read" on exercise_knowledge_card for select using (true);

create table exercise_prayer_step (
  exercise_id     int primary key references exercises(id),
  instruction_en  text not null,
  arabic_text     text,
  transliteration text,
  translation_en  text,
  repeat_count    smallint
);

alter table exercise_prayer_step enable row level security;
create policy "content_public_read" on exercise_prayer_step for select using (true);

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
    'diacritic_intro','letter_chain','knowledge_card','prayer_step'
  ));

insert into knowledge_points (code, category, title_en, explanation_short, explanation_full) values
  ('wudu_importance', 'wudu', 'The Importance of Wudu',
   'Salah is not accepted without wudu — it''s a prerequisite for valid prayer, not an optional nicety.',
   'The Prophet Muhammad (peace be upon him) said: "The prayer of anyone of you who has invalidated his purification is not accepted unless he makes wudu" (Bukhari). Wudu — ritual washing done in a specific order — restores the state of purity a Muslim needs before standing in prayer. Losing wudu (through sleep, using the toilet, passing wind, and other specific causes) doesn''t undo any prayer already completed, but it does mean wudu must be renewed before the next one.'),
  ('wudu_virtues', 'wudu', 'The Virtues of Wudu',
   'Wudu doesn''t just prepare the body for prayer — each part washed is described as washing away sins committed by that part.',
   'Beyond being a requirement for prayer, wudu carries its own spiritual reward. The Prophet (peace be upon him) said: "When the Muslim or believing servant performs ablution and washes his face, each sin he has committed by his eyes washes away with the water. When he washes his hands, each sin his hands have committed washes away with the water — or with the last drop of water until he becomes free of sin" (Malik and others).'),
  ('wudu_preparation', 'wudu', 'Before You Begin Wudu',
   'Three things come before the washing itself: using the toilet first if needed, cleaning the teeth, and making the intention.',
   'A few things come before the actual washing steps of wudu: (1) use the toilet first if needed, washing the private parts, since wudu itself doesn''t include that; (2) it''s good practice to clean the teeth with a siwak (tooth-stick) or a toothbrush, as the Prophet (peace be upon him) taught; (3) before starting the washing, make the intention (niyyah) in the heart that this washing is specifically for the purpose of wudu — the intention doesn''t need to be spoken aloud.');

insert into units (track_id, unit_type, title, sequence_order)
select id, 'thematic', 'Wudu — Ablution', 9 from tracks where code = 'quranic_arabic';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Why Wudu Matters', 1, 5 from units where title = 'Wudu — Ablution';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'How to Perform Wudu', 2, 8 from units where title = 'Wudu — Ablution';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Wudu Quiz', 3, 6 from units where title = 'Wudu — Ablution';

do $$
declare
  v_why_lesson_id int;
  v_howto_lesson_id int;
  v_quiz_lesson_id int;
  v_exercise_id int;
  v_kp record;
  v_seq int;
begin
  select l.id into v_why_lesson_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Wudu — Ablution' and l.title = 'Why Wudu Matters';
  select l.id into v_howto_lesson_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Wudu — Ablution' and l.title = 'How to Perform Wudu';
  select l.id into v_quiz_lesson_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Wudu — Ablution' and l.title = 'Wudu Quiz';

  -- Why Wudu Matters: 3 knowledge_card exercises, book order.
  v_seq := 0;
  for v_kp in
    select id, code from knowledge_points where code in ('wudu_importance', 'wudu_virtues', 'wudu_preparation')
    order by array_position(array['wudu_importance','wudu_virtues','wudu_preparation'], code)
  loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_why_lesson_id, 'knowledge_card', v_seq) returning id into v_exercise_id;
    insert into exercise_knowledge_card (exercise_id, knowledge_point_id) values (v_exercise_id, v_kp.id);
  end loop;

  -- How to Perform Wudu: 11 prayer_step exercises (9 physical steps +
  -- 2 recitations split out of the book's combined "step 10").
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_howto_lesson_id, 'prayer_step', 1) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en, repeat_count)
  values (v_exercise_id, 'Before starting, make the intention of wudu in your heart, then say:', 'بِسْمِ اللَّهِ', 'Bismillah', 'In the name of Allah', null);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_howto_lesson_id, 'prayer_step', 2) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, repeat_count)
  values (v_exercise_id, 'Completely wash the hands, including the wrists and between the fingers.', 3);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_howto_lesson_id, 'prayer_step', 3) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, repeat_count)
  values (v_exercise_id, 'Rinse the mouth. Using the right hand, put a small amount of water into the mouth, swirl it around, then spit it out.', 3);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_howto_lesson_id, 'prayer_step', 4) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, repeat_count)
  values (v_exercise_id, 'Sniff water into the nostrils as far as comfortable using the right hand, then breathe it back out using the left hand.', 3);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_howto_lesson_id, 'prayer_step', 5) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, repeat_count)
  values (v_exercise_id, 'Wash the face from the forehead to the chin, and from ear to ear, making sure the whole face is washed.', 3);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_howto_lesson_id, 'prayer_step', 6) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, repeat_count)
  values (v_exercise_id, 'Wash both arms up to and including the elbows, and between the fingers. Begin with the right arm, then the left.', 3);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_howto_lesson_id, 'prayer_step', 7) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, repeat_count)
  values (v_exercise_id, 'Wipe the head with wet fingers, starting at the hairline above the forehead, passing back to the back hairline, then back again — one movement.', 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_howto_lesson_id, 'prayer_step', 8) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, repeat_count)
  values (v_exercise_id, 'Wipe the insides of both ears with the index fingers, and the backs of the ears with the thumbs, at the same time.', 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_howto_lesson_id, 'prayer_step', 9) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, repeat_count)
  values (v_exercise_id, 'Wash the feet, including the ankles and between the toes. Begin with the right foot, then the left.', 3);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_howto_lesson_id, 'prayer_step', 10) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'After finishing the washing, recite the testimony of faith:',
    'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
    'Ash-hadu allaa ilaaha illallaah wa ash-hadu anna Muhammadan ''abduhu wa rasooluh',
    'I bear witness that there is no god worthy of worship except Allah, and I bear witness that Muhammad is His slave and Messenger.');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_howto_lesson_id, 'prayer_step', 11) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'Then this closing dua:',
    'اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ',
    'Allahumma ij''alnee minat-tawwabeena waj''alnee minal-mutatahhireen',
    'Oh Allah, make me among those who turn in repentance to You, and make me among those who purify themselves.');

  -- Wudu Quiz: tests the sequence and the two recitations, not rote
  -- repeat-count trivia (repeat counts are shown right on each step
  -- card during teaching, not a meaningful recall-quiz skill on their own).
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 1) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What should you say before starting wudu?', '["Bismillah", "Allahu Akbar", "Astaghfirullah", "Alhamdulillah"]'::jsonb, 0);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which is washed first: the face, or the hands?', '["The face", "The hands", "They''re washed together", "Neither is washed"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'After washing the arms, what comes next?', '["Washing the feet", "Wiping the head", "Rinsing the mouth", "Washing the face"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which part of wudu is the very last step?', '["Wiping the ears", "Washing the feet", "Wiping the head", "Rinsing the mouth"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 5) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What do you recite right after finishing the washing?', '["Surat Al-Fatiha", "The testimony of faith (shahada)", "Ayat al-Kursi", "The call to prayer"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'According to the hadith quoted in this unit, what does Salah require to be accepted?', '["Wudu (ritual purification)", "Being in a mosque", "Fasting that day", "Reciting the entire Quran first"]'::jsonb, 0);
end $$;

insert into user_unit_progress (user_id, unit_id, status, started_at)
select u.id, (select id from units where title = 'Wudu — Ablution'), 'in_progress', now()
from users u
on conflict (user_id, unit_id) do nothing;
