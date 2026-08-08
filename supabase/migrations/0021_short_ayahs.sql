-- Phase 6d, the last section of the Qaida book's table of contents:
-- Short Ayahs. Adds "Short Ayahs" as a third lesson in "Reading Marks &
-- Rules" (after The Word Allah, Completion of an Ayah) — the book
-- groups it with Completion of an Ayah under one "Sixth Section," and
-- it's the natural next step after those pausing rules: real short
-- verses to actually practice reading and pausing on.
--
-- This is the first curriculum content touching surahs other than
-- Al-Fatiha, so unlike every prior phase, real scripture accuracy was
-- the binding constraint, not transcription-risk-avoidance. Every one
-- of the book's 14 example fragments was independently identified and
-- verified against Quran.com's API (Uthmani text + Saheeh International
-- translation, the same source style Al-Fatiha's seed data already
-- uses) before being written here — not transcribed from the compressed
-- book image or recalled from memory. That process caught two things
-- worth recording:
--
--   1. Several fragments are exact phrase matches for MULTIPLE ayahs
--      across the Quran (e.g. "innAllaha kana 'aleeman hakeema" ends
--      dozens of verses) — resolved by noticing the book draws several
--      fragments from the very same short surah in a cluster (e.g.
--      three consecutive-ish ayahs from Al-Insan, three from
--      Al-Mursalat, two from Ar-Rahman, three from Al-Layl), which
--      made the correct verse unambiguous once cross-checked against
--      that pattern rather than any single fragment in isolation.
--   2. Four of the book's fragments (from 98:5, 76:24, 76:29, 76:30)
--      are not complete ayaht — they stop at a real pause point inside
--      a longer verse (in two cases exactly at an existing small waqf
--      mark in the canonical text). Per explicit user decision, the
--      app shows the COMPLETE ayah in these four cases rather than the
--      book's truncated wording — every word shown is authentic,
--      officially translated scripture, and this reuses the
--      reading_passage exercise type exactly as built for Al-Fatiha
--      (a start/end ayah range) with zero new Flutter code, rather
--      than inventing a partial-verse display+translation feature.
--
-- Surahs table gains 7 new rows (previously only Al-Fatiha existed).
-- ayah_count/revelation_type also verified against Quran.com's chapter
-- metadata, not assumed.

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (55, 'الرحمن', 'Ar-Rahman', 78, 'meccan'),
  (76, 'الانسان', 'Al-Insan', 31, 'medinan'),
  (77, 'المرسلات', 'Al-Mursalat', 50, 'meccan'),
  (85, 'البروج', 'Al-Buruj', 22, 'meccan'),
  (92, 'الليل', 'Al-Layl', 21, 'meccan'),
  (98, 'البينة', 'Al-Bayyinah', 8, 'medinan'),
  (100, 'العاديات', 'Al-Adiyat', 11, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en) values
  (77, 2, 'فَٱلْعَـٰصِفَـٰتِ عَصْفًا', 'فَٱلْعَـٰصِفَـٰتِ عَصْفًا', '[]'::jsonb,
   'And the winds that blow violently'),
  (55, 6, 'وَٱلنَّجْمُ وَٱلشَّجَرُ يَسْجُدَانِ', 'وَٱلنَّجْمُ وَٱلشَّجَرُ يَسْجُدَانِ', '[]'::jsonb,
   'And the stars and trees prostrate.'),
  (100, 7, 'وَإِنَّهُۥ عَلَىٰ ذَٰلِكَ لَشَهِيدٌ', 'وَإِنَّهُۥ عَلَىٰ ذَٰلِكَ لَشَهِيدٌ', '[]'::jsonb,
   'And indeed, he is to that a witness.'),
  (98, 5, 'وَمَآ أُمِرُوٓا۟ إِلَّا لِيَعْبُدُوا۟ ٱللَّهَ مُخْلِصِينَ لَهُ ٱلدِّينَ حُنَفَآءَ وَيُقِيمُوا۟ ٱلصَّلَوٰةَ وَيُؤْتُوا۟ ٱلزَّكَوٰةَ ۚ وَذَٰلِكَ دِينُ ٱلْقَيِّمَةِ',
   'وَمَآ أُمِرُوٓا۟ إِلَّا لِيَعْبُدُوا۟ ٱللَّهَ مُخْلِصِينَ لَهُ ٱلدِّينَ حُنَفَآءَ وَيُقِيمُوا۟ ٱلصَّلَوٰةَ وَيُؤْتُوا۟ ٱلزَّكَوٰةَ ۚ وَذَٰلِكَ دِينُ ٱلْقَيِّمَةِ', '[]'::jsonb,
   'And they were not commanded except to worship Allah, [being] sincere to Him in religion, inclining to truth, and to establish prayer and to give zakah. And that is the correct religion.'),
  (77, 7, 'إِنَّمَا تُوعَدُونَ لَوَٰقِعٌ', 'إِنَّمَا تُوعَدُونَ لَوَٰقِعٌ', '[]'::jsonb,
   'Indeed, what you are promised is to occur.'),
  (55, 10, 'وَٱلْأَرْضَ وَضَعَهَا لِلْأَنَامِ', 'وَٱلْأَرْضَ وَضَعَهَا لِلْأَنَامِ', '[]'::jsonb,
   'And the earth He laid [out] for the creatures.'),
  (77, 8, 'فَإِذَا ٱلنُّجُومُ طُمِسَتْ', 'فَإِذَا ٱلنُّجُومُ طُمِسَتْ', '[]'::jsonb,
   'So when the stars are obliterated'),
  (92, 12, 'إِنَّ عَلَيْنَا لَلْهُدَىٰ', 'إِنَّ عَلَيْنَا لَلْهُدَىٰ', '[]'::jsonb,
   'Indeed, [incumbent] upon Us is guidance.'),
  (76, 24, 'فَٱصْبِرْ لِحُكْمِ رَبِّكَ وَلَا تُطِعْ مِنْهُمْ ءَاثِمًا أَوْ كَفُورًا', 'فَٱصْبِرْ لِحُكْمِ رَبِّكَ وَلَا تُطِعْ مِنْهُمْ ءَاثِمًا أَوْ كَفُورًا', '[]'::jsonb,
   'So be patient for the decision of your Lord and do not obey from among them a sinner or ungrateful [disbeliever].'),
  (92, 5, 'فَأَمَّا مَنْ أَعْطَىٰ وَٱتَّقَىٰ', 'فَأَمَّا مَنْ أَعْطَىٰ وَٱتَّقَىٰ', '[]'::jsonb,
   'As for he who gives and fears Allah'),
  (76, 29, 'إِنَّ هَـٰذِهِۦ تَذْكِرَةٌ ۖ فَمَن شَآءَ ٱتَّخَذَ إِلَىٰ رَبِّهِۦ سَبِيلًا', 'إِنَّ هَـٰذِهِۦ تَذْكِرَةٌ ۖ فَمَن شَآءَ ٱتَّخَذَ إِلَىٰ رَبِّهِۦ سَبِيلًا', '[]'::jsonb,
   'Indeed, this is a reminder, so he who wills may take to his Lord a way.'),
  (92, 4, 'إِنَّ سَعْيَكُمْ لَشَتَّىٰ', 'إِنَّ سَعْيَكُمْ لَشَتَّىٰ', '[]'::jsonb,
   'Indeed, your efforts are diverse.'),
  (85, 6, 'إِذْ هُمْ عَلَيْهَا قُعُودٌ', 'إِذْ هُمْ عَلَيْهَا قُعُودٌ', '[]'::jsonb,
   'When they were sitting near it.'),
  (76, 30, 'وَمَا تَشَآءُونَ إِلَّآ أَن يَشَآءَ ٱللَّهُ ۚ إِنَّ ٱللَّهَ كَانَ عَلِيمًا حَكِيمًا', 'وَمَا تَشَآءُونَ إِلَّآ أَن يَشَآءَ ٱللَّهُ ۚ إِنَّ ٱللَّهَ كَانَ عَلِيمًا حَكِيمًا', '[]'::jsonb,
   'And you do not will except that Allah wills. Indeed, Allah is ever Knowing and Wise.');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Short Ayahs', 3, 10 from units where title = 'Reading Marks & Rules';

do $$
declare
  v_lesson_id int;
  v_exercise_id int;
  v_ayah_id bigint;
  v_seq int;
  v_ref record;
begin
  select l.id into v_lesson_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Reading Marks & Rules' and l.title = 'Short Ayahs';

  v_seq := 0;
  for v_ref in
    select * from (values
      (77, 2), (55, 6), (100, 7), (98, 5), (77, 7), (55, 10), (77, 8),
      (92, 12), (76, 24), (92, 5), (76, 29), (92, 4), (85, 6), (76, 30)
    ) as t(surah_number, ayah_number)
  loop
    v_seq := v_seq + 1;
    select id into v_ayah_id from ayat where surah_number = v_ref.surah_number and ayah_number = v_ref.ayah_number;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
    insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_ayah_id, v_ayah_id);
  end loop;

  -- Closing comprehension quiz — spans several different surahs, tests
  -- meaning rather than just recognizing the Arabic shape.
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', v_seq + 1) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'وَٱلنَّجْمُ وَٱلشَّجَرُ يَسْجُدَانِ — what does this ayah say prostrates to Allah?',
    '["The sun and moon", "The stars and trees", "The mountains and rivers", "The angels and jinn"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', v_seq + 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'فَأَمَّا مَنْ أَعْطَىٰ وَٱتَّقَىٰ — what kind of person does this ayah describe?',
    '["Someone who gives and is mindful of Allah", "Someone who lies and cheats", "Someone who travels far", "Someone who prays alone"]'::jsonb, 0);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', v_seq + 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'إِنَّ عَلَيْنَا لَلْهُدَىٰ — whose responsibility does this ayah say guidance is?',
    '["The Prophet''s", "Allah''s", "The angels''", "Every person''s own"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', v_seq + 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'وَإِنَّهُۥ عَلَىٰ ذَٰلِكَ لَشَهِيدٌ — what does this ayah say about man?',
    '["He is a witness to that", "He is forgetful of that", "He is grateful for that", "He is unaware of that"]'::jsonb, 0);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', v_seq + 5) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'إِذْ هُمْ عَلَيْهَا قُعُودٌ — what were they doing?',
    '["Sitting near it", "Running away from it", "Building it", "Destroying it"]'::jsonb, 0);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', v_seq + 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'إِنَّ سَعْيَكُمْ لَشَتَّىٰ — what does this ayah say about people''s efforts?',
    '["They are all identical", "They are diverse", "They are wasted", "They are rewarded equally"]'::jsonb, 1);
end $$;
