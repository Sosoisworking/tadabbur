-- Adds 4 more short surahs to the "Short Surahs" unit, per user
-- request — a natural next tier after Al-Kawthar/Al-Ikhlas/Al-Falaq/
-- An-Nas: An-Nasr (110, 3 ayahs), Al-'Asr (103, 3 ayahs), Quraysh
-- (106, 4 ayahs), Al-Kafirun (109, 6 ayahs). All four are extremely
-- short, commonly memorized, and a standard next step in beginner
-- Quran curricula after the first four short surahs.
--
-- Same verification discipline as migrations 0021/0028: chapter
-- metadata, Uthmani text, Saheeh International translation (resource
-- 20), and transliteration (resource 57, restyled into this app's
-- established common-convention style) all fetched individually from
-- Quran.com, not transcribed from memory — then cross-checked against
-- these particular surahs' own extremely well-known standard
-- transliterations (Al-Kafirun, Al-'Asr, An-Nasr, and Quraysh are
-- among the most widely memorized short surahs in Islam) before
-- committing to the restyled wording, same as migration 0034.
--
-- One lesson per surah (prayer_step instruction + reading_passage +
-- comprehension quiz — the same 3-exercise shape every lesson in this
-- unit already uses), ordered by ayah count ascending, matching how
-- the original four lessons were ordered.

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (110, 'النصر', 'An-Nasr', 3, 'medinan'),
  (103, 'العصر', 'Al-''Asr', 3, 'meccan'),
  (106, 'قريش', 'Quraysh', 4, 'meccan'),
  (109, 'الكافرون', 'Al-Kafirun', 6, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en, transliteration) values
  (110, 1, 'إِذَا جَآءَ نَصْرُ ٱللَّهِ وَٱلْفَتْحُ', 'إِذَا جَآءَ نَصْرُ ٱللَّهِ وَٱلْفَتْحُ', '[]'::jsonb,
   'When the victory of Allah has come and the conquest,', 'Idhaa jaa-a nasrullaahi wal-fath'),
  (110, 2, 'وَرَأَيْتَ ٱلنَّاسَ يَدْخُلُونَ فِى دِينِ ٱللَّهِ أَفْوَاجًا', 'وَرَأَيْتَ ٱلنَّاسَ يَدْخُلُونَ فِى دِينِ ٱللَّهِ أَفْوَاجًا', '[]'::jsonb,
   'And you see the people entering into the religion of Allah in multitudes,', 'Wa ra-aytan naasa yadkhuloona fee deenillaahi afwaajaa'),
  (110, 3, 'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَٱسْتَغْفِرْهُ ۚ إِنَّهُۥ كَانَ تَوَّابًۢا', 'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَٱسْتَغْفِرْهُ ۚ إِنَّهُۥ كَانَ تَوَّابًۢا', '[]'::jsonb,
   'Then exalt Him with praise of your Lord and ask forgiveness of Him. Indeed, He is ever Accepting of Repentance.', 'Fasabbih bihamdi rabbika wastaghfirh, innahu kaana tawwaabaa'),
  (103, 1, 'وَٱلْعَصْرِ', 'وَٱلْعَصْرِ', '[]'::jsonb,
   'By time,', 'Wal-''asr'),
  (103, 2, 'إِنَّ ٱلْإِنسَـٰنَ لَفِى خُسْرٍ', 'إِنَّ ٱلْإِنسَـٰنَ لَفِى خُسْرٍ', '[]'::jsonb,
   'Indeed, mankind is in loss,', 'Innal-insaana lafee khusr'),
  (103, 3, 'إِلَّا ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ وَتَوَاصَوْا۟ بِٱلْحَقِّ وَتَوَاصَوْا۟ بِٱلصَّبْرِ', 'إِلَّا ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ وَتَوَاصَوْا۟ بِٱلْحَقِّ وَتَوَاصَوْا۟ بِٱلصَّبْرِ', '[]'::jsonb,
   'Except for those who have believed and done righteous deeds and advised each other to truth and advised each other to patience.', 'Illal-ladheena aamanoo wa ''amilus-saalihaati wa tawaasaw bil-haqqi wa tawaasaw bis-sabr'),
  (106, 1, 'لِإِيلَـٰفِ قُرَيْشٍ', 'لِإِيلَـٰفِ قُرَيْشٍ', '[]'::jsonb,
   'For the accustomed security of the Quraysh', 'Li-eelaafi quraysh'),
  (106, 2, 'إِۦلَـٰفِهِمْ رِحْلَةَ ٱلشِّتَآءِ وَٱلصَّيْفِ', 'إِۦلَـٰفِهِمْ رِحْلَةَ ٱلشِّتَآءِ وَٱلصَّيْفِ', '[]'::jsonb,
   'Their accustomed security in the caravan of winter and summer', 'Eelaafihim rihlatash-shitaa-i was-sayf'),
  (106, 3, 'فَلْيَعْبُدُوا۟ رَبَّ هَـٰذَا ٱلْبَيْتِ', 'فَلْيَعْبُدُوا۟ رَبَّ هَـٰذَا ٱلْبَيْتِ', '[]'::jsonb,
   'Let them worship the Lord of this House,', 'Falya''budoo rabba haadhal-bayt'),
  (106, 4, 'ٱلَّذِىٓ أَطْعَمَهُم مِّن جُوعٍ وَءَامَنَهُم مِّنْ خَوْفٍۭ', 'ٱلَّذِىٓ أَطْعَمَهُم مِّن جُوعٍ وَءَامَنَهُم مِّنْ خَوْفٍۭ', '[]'::jsonb,
   'Who has fed them, saving them from hunger and made them safe, saving them from fear.', 'Alladhee at''amahum min joo''in wa aamanahum min khawf'),
  (109, 1, 'قُلْ يَـٰٓأَيُّهَا ٱلْكَـٰفِرُونَ', 'قُلْ يَـٰٓأَيُّهَا ٱلْكَـٰفِرُونَ', '[]'::jsonb,
   'Say, O disbelievers,', 'Qul yaa ayyuhal kaafiroon'),
  (109, 2, 'لَآ أَعْبُدُ مَا تَعْبُدُونَ', 'لَآ أَعْبُدُ مَا تَعْبُدُونَ', '[]'::jsonb,
   'I do not worship what you worship.', 'Laa a''budu maa ta''budoon'),
  (109, 3, 'وَلَآ أَنتُمْ عَـٰبِدُونَ مَآ أَعْبُدُ', 'وَلَآ أَنتُمْ عَـٰبِدُونَ مَآ أَعْبُدُ', '[]'::jsonb,
   'Nor are you worshippers of what I worship.', 'Wa laa antum ''aabidoona maa a''bud'),
  (109, 4, 'وَلَآ أَنَا۠ عَابِدٌ مَّا عَبَدتُّمْ', 'وَلَآ أَنَا۠ عَابِدٌ مَّا عَبَدتُّمْ', '[]'::jsonb,
   'Nor will I be a worshipper of what you worship.', 'Wa laa anaa ''aabidum maa ''abadtum'),
  (109, 5, 'وَلَآ أَنتُمْ عَـٰبِدُونَ مَآ أَعْبُدُ', 'وَلَآ أَنتُمْ عَـٰبِدُونَ مَآ أَعْبُدُ', '[]'::jsonb,
   'Nor will you be worshippers of what I worship.', 'Wa laa antum ''aabidoona maa a''bud'),
  (109, 6, 'لَكُمْ دِينُكُمْ وَلِىَ دِينِ', 'لَكُمْ دِينُكُمْ وَلِىَ دِينِ', '[]'::jsonb,
   'For you is your religion, and for me is my religion.', 'Lakum deenukum wa liya deen');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'An-Nasr', 5, 4 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-''Asr', 6, 4 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Quraysh', 7, 4 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Kafirun', 8, 5 from units where title = 'Short Surahs';

do $$
declare
  v_exercise_id int;
  v_lesson_id int;
  v_start_id bigint;
  v_end_id bigint;
  v_row record;
begin
  for v_row in
    select * from (values
      ('An-Nasr', 110, 1, 3, 'What does Surat An-Nasr describe?',
        '["A description of Paradise", "Allah''s victory and people entering the religion in multitudes", "The story of an army", "The five daily prayers"]', 1),
      ('Al-''Asr', 103, 1, 3, 'According to Surat Al-''Asr, what keeps a person from being ''in loss''?',
        '["Wealth and status", "Faith, good deeds, and encouraging truth and patience", "Physical strength", "Knowledge alone"]', 1),
      ('Quraysh', 106, 1, 4, 'What is Surat Quraysh a reminder to do?',
        '["Fast during winter", "Worship the Lord of this House, who fed and secured them", "Travel to new lands", "Avoid trade caravans"]', 1),
      ('Al-Kafirun', 109, 1, 6, 'What is the main message of Surat Al-Kafirun?',
        '["A call to fight disbelievers", "A clear declaration that the Prophet will not worship what they worship, and they have their own way", "A story about the Prophet''s childhood", "A description of the Day of Judgment"]', 1)
    ) as t(lesson_title, surah_number, first_ayah, last_ayah, question, options, correct_index)
  loop
    select l.id into v_lesson_id from lessons l join units u on u.id = l.unit_id
      where u.title = 'Short Surahs' and l.title = v_row.lesson_title;

    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'prayer_step', 1) returning id into v_exercise_id;
    insert into exercise_prayer_step (exercise_id, instruction_en) values (v_exercise_id, 'Recite Surat ' || v_row.lesson_title || ':');

    select id into v_start_id from ayat where surah_number = v_row.surah_number and ayah_number = v_row.first_ayah;
    select id into v_end_id from ayat where surah_number = v_row.surah_number and ayah_number = v_row.last_ayah;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'reading_passage', 2) returning id into v_exercise_id;
    insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_start_id, v_end_id);

    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', 3) returning id into v_exercise_id;
    insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
    values (v_exercise_id, v_row.question, v_row.options::jsonb, v_row.correct_index);
  end loop;
end $$;
