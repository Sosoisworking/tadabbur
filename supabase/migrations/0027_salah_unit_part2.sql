-- Phase 2 of the Prayer Guide adaptation (part 2 of 2): the second
-- rak'ah, Tashahhud, completing the prayer, and a closing quiz —
-- continuing directly from migration 0026's four lessons.
--
-- Tashahhud note: the book's own printed step numbers for this
-- recitation skip from 4 straight to 6 (confirmed by re-rendering that
-- page at high resolution — a numbering typo in the source, not
-- missing content or a mis-crop on this end). This migration uses its
-- own sequential 1-6 exercise numbering rather than reproducing that
-- gap, since sequence_order here is this app's own ordering, not a
-- transcription of the book's printed labels.
--
-- The Durood (blessings on the Prophet) is reproduced as 2 cards, not
-- the book's 10 separately-numbered fragments — it's the well-known,
-- fully standardized Salawat Ibrahimiyyah, and grouping each half's
-- fragments back into one flowing sentence (matching how Al-Fatiha and
-- other multi-clause content is shown elsewhere in this app) reads far
-- better than 10 near-identical two-word cards would.

insert into knowledge_points (code, category, title_en, explanation_short, explanation_full) values
  ('salah_after_two_rakahs', 'salah', 'What Happens After Two Rak''ahs?',
   'Fajr ends after 2 rak''ahs. Dhuhr, Asr, and Isha continue for 2 more (reciting only Al-Fatiha, no extra surah). Maghrib continues for 1 more.',
   'What comes after the second rak''ah depends on which prayer you''re praying. Fajr is only 2 rak''ahs, so the prayer is completed right after the Tashahhud that follows the second rak''ah. Dhuhr, Asr, and Isha are each 4 rak''ahs, so after the Tashahhud you stand for a third and then a fourth rak''ah — in both of these, only Al-Fatiha is recited, with no additional surah afterward. Maghrib is 3 rak''ahs, so there''s just one more rak''ah after the second, also Al-Fatiha only, before the prayer is completed.');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'The Second Rak''ah', 5, 5 from units where title = 'Salah — The Prayer';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Tashahhud — The Sitting Recitation', 6, 6 from units where title = 'Salah — The Prayer';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Completing the Prayer', 7, 6 from units where title = 'Salah — The Prayer';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Salah Quiz', 8, 8 from units where title = 'Salah — The Prayer';

do $$
declare
  v_second_id int;
  v_tashahhud_id int;
  v_completing_id int;
  v_quiz_id int;
  v_exercise_id int;
  v_after_two_id int;
begin
  select l.id into v_second_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Salah — The Prayer' and l.title = 'The Second Rak''ah';
  select l.id into v_tashahhud_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Salah — The Prayer' and l.title = 'Tashahhud — The Sitting Recitation';
  select l.id into v_completing_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Salah — The Prayer' and l.title = 'Completing the Prayer';
  select l.id into v_quiz_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Salah — The Prayer' and l.title = 'Salah Quiz';
  select id into v_after_two_id from knowledge_points where code = 'salah_after_two_rakahs';

  -- The Second Rak'ah
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_second_id, 'knowledge_card', 1) returning id into v_exercise_id;
  insert into exercise_knowledge_card (exercise_id, knowledge_point_id) values (v_exercise_id, v_after_two_id);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_second_id, 'prayer_step', 2) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'Stand up from the sitting or prostrating position. As you rise, say:',
    'اللَّهُ أَكْبَرُ', 'Allaahu Akbar', 'Allah is Greatest');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_second_id, 'prayer_step', 3) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en)
  values (v_exercise_id, 'Repeat steps 3 through 11 from the first rak''ah.');

  -- Tashahhud: intro step + 6 recitation parts (own sequential
  -- numbering — see migration header note on the book's 4-to-6 gap).
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_tashahhud_id, 'prayer_step', 1) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'After the last prostration of an even-numbered rak''ah, say Allahu Akbar and sit — left foot flat along the ground, right foot upright — then raise your right index finger.',
    'اللَّهُ أَكْبَرُ', 'Allaahu Akbar', 'Allah is Greatest');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_tashahhud_id, 'prayer_step', 2) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'Now recite the Tashahhud, starting with:',
    'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ', 'Attahiyyaatu lillaahi wassalawaatu wattayyibaatu',
    'All compliments, prayers, and pure words are due to Allah');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_tashahhud_id, 'prayer_step', 3) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'Continue:',
    'السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ', 'Assalaamu ''alayka ayyuhan-nabiyyu wa rahmatullaahi wabarakaatuh',
    'Peace be upon you, Oh Prophet, and the mercy of Allah and His blessings');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_tashahhud_id, 'prayer_step', 4) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'Continue:',
    'السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ', 'Assalaamu ''alaynaa wa ''alaa ''ibaadillaahis saaliheen',
    'Peace be upon us and on the righteous slaves of Allah');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_tashahhud_id, 'prayer_step', 5) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'Then the testimony of faith:',
    'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ', 'Ash-hadu allaa ilaaha illallaah',
    'I bear witness that there is no god worthy of worship except Allah');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_tashahhud_id, 'prayer_step', 6) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'And finally:',
    'وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ', 'wa ash-hadu anna Muhammadan ''abduhu wa rasooluh',
    'And I bear witness that Muhammad is His slave and Messenger');

  -- Completing the Prayer: Durood (2 cards), Tasleem, post-prayer dhikr (3 cards).
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_completing_id, 'prayer_step', 1) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'In the final rak''ah, after the Tashahhud, send prayers upon the Prophet:',
    'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
    'Allahumma salli ''ala Muhammadin wa ''ala aali Muhammadin kamaa sallayta ''ala Ibraaheema wa ''ala aali Ibraaheema innaka Hameedun Majeed',
    'O Allah, send prayers upon Muhammad and upon the family of Muhammad, as You sent prayers upon Ibrahim and upon the family of Ibrahim. Indeed, You are Praiseworthy and Glorious.');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_completing_id, 'prayer_step', 2) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'Then send blessings upon him:',
    'اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
    'Allahumma baarik ''ala Muhammadin wa ''ala aali Muhammadin kamaa baarakta ''ala Ibraaheema wa ''ala aali Ibraaheema innaka Hameedun Majeed',
    'O Allah, send blessings upon Muhammad and upon the family of Muhammad, as You sent blessings upon Ibrahim and upon the family of Ibrahim. Indeed, You are Praiseworthy and Glorious.');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_completing_id, 'prayer_step', 3) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en, repeat_count)
  values (v_exercise_id, 'Turn your head to the right and say the following, then turn to the left and say it again — this completes the prayer:',
    'السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ', 'Assalaamu ''alaykum wa rahmatullah', 'May Allah''s peace and mercy be upon you', 2);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_completing_id, 'prayer_step', 4) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en, repeat_count)
  values (v_exercise_id, 'It''s recommended to follow the prayer with this remembrance:',
    'سُبْحَانَ اللَّهِ', 'Subhaan Allah', 'Glory be to Allah', 33);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_completing_id, 'prayer_step', 5) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en, repeat_count)
  values (v_exercise_id, 'Then:',
    'الْحَمْدُ لِلَّهِ', 'Al-hamdu lillah', 'Praise be to Allah', 33);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_completing_id, 'prayer_step', 6) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en, repeat_count)
  values (v_exercise_id, 'And finally:',
    'اللَّهُ أَكْبَرُ', 'Allaahu Akbar', 'Allah is the greatest', 34);

  -- Salah Quiz
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_id, 'recall_quiz', 1) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What do you do after standing up for the second rak''ah?',
    '["Recite the Tashahhud", "Repeat steps 3 to 11 from the first rak''ah", "Say the Tasleem", "Go straight into sujood"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'In a 4-rak''ah prayer like Dhuhr, what is recited in the 3rd and 4th rak''ahs?',
    '["Only Al-Fatiha", "Al-Fatiha plus another surah", "The Tashahhud", "Nothing is recited"]'::jsonb, 0);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What do you raise during the Tashahhud?',
    '["Both hands", "Your right index finger", "Your voice", "Nothing"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which phrase opens the Tashahhud?',
    '["Allahu Akbar", "Attahiyyaatu lillaahi wassalawaatu wattayyibaatu", "Subhaana Rabbiyal ''Atheem", "Assalaamu ''alaykum"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_id, 'recall_quiz', 5) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What does the Tashahhud''s testimony of faith declare?',
    '["That Ramadan has begun", "That there is no god but Allah and Muhammad is His messenger", "That the prayer is complete", "That wudu is still valid"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What is recited in the Durood, right after the Tashahhud?',
    '["Ayat al-Kursi", "Blessings upon the Prophet Muhammad and his family", "Surat Al-Ikhlas", "The call to prayer"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_id, 'recall_quiz', 7) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'How is the prayer formally ended?',
    '["By standing up and walking away", "By saying Assalaamu ''alaykum wa rahmatullah, turning right then left", "By saying Bismillah", "By making sujood one more time"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'After the Tasleem, how many times is it recommended to say "Subhaan Allah"?',
    '["3", "10", "33", "100"]'::jsonb, 2);
end $$;
