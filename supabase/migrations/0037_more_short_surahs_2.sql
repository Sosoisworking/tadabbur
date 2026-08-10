-- Adds 4 more short surahs to the "Short Surahs" unit, continuing the
-- tier started in migration 0036: Al-Fil (105, 5 ayahs), Al-Masad
-- (111, 5 ayahs), Al-Qadr (97, 5 ayahs), Ash-Sharh (94, 8 ayahs). Same
-- verification discipline as every prior ayah-content migration:
-- chapter metadata, Uthmani text, Saheeh International translation,
-- and transliteration (Quran.com resource 57, restyled into this
-- app's established common-convention style) all fetched individually,
-- cross-checked against these surahs' own well-known standard
-- transliterations before committing. One label mismatch caught
-- during verification: the fetch tool's own summary mislabeled
-- chapter 94's content as "Ad-Duha" — the verse text itself (starting
-- "Alam nashrah laka sadrak") is unambiguously Ash-Sharh, independently
-- confirmed both by the chapters endpoint (94 = Ash-Sharh) and by
-- recognizing the text directly; the tool's auto-generated label was
-- wrong, not the underlying data. A reminder to verify actual verse
-- content, not a summarizing tool's title for it.
--
-- One lesson per surah, ordered by ayah count ascending (Al-Fil,
-- Al-Masad, Al-Qadr all tie at 5 — ordered Al-Fil first since it
-- continues directly from Quraysh's theme, already taught), each with
-- the same 3-exercise shape as every lesson in this unit: prayer_step
-- instruction, reading_passage recitation, comprehension quiz.

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (105, 'الفيل', 'Al-Fil', 5, 'meccan'),
  (111, 'المسد', 'Al-Masad', 5, 'meccan'),
  (97, 'القدر', 'Al-Qadr', 5, 'meccan'),
  (94, 'الشرح', 'Ash-Sharh', 8, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en, transliteration) values
  (105, 1, 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَـٰبِ ٱلْفِيلِ', 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَـٰبِ ٱلْفِيلِ', '[]'::jsonb,
   'Have you not considered how your Lord dealt with the companions of the elephant?', 'Alam tara kayfa fa''ala rabbuka bi-ashaabil feel'),
  (105, 2, 'أَلَمْ يَجْعَلْ كَيْدَهُمْ فِى تَضْلِيلٍ', 'أَلَمْ يَجْعَلْ كَيْدَهُمْ فِى تَضْلِيلٍ', '[]'::jsonb,
   'Did He not make their plan into misguidance?', 'Alam yaj''al kaydahum fee tadleel'),
  (105, 3, 'وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ', 'وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ', '[]'::jsonb,
   'And He sent against them birds in flocks,', 'Wa arsala ''alayhim tayran abaabeel'),
  (105, 4, 'تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ', 'تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ', '[]'::jsonb,
   'Striking them with stones of hard clay,', 'Tarmeehim bihijaaratim min sijjeel'),
  (105, 5, 'فَجَعَلَهُمْ كَعَصْفٍ مَّأْكُولٍۭ', 'فَجَعَلَهُمْ كَعَصْفٍ مَّأْكُولٍۭ', '[]'::jsonb,
   'And He made them like eaten straw.', 'Faja''alahum ka''asfim ma''kool'),
  (111, 1, 'تَبَّتْ يَدَآ أَبِى لَهَبٍ وَتَبَّ', 'تَبَّتْ يَدَآ أَبِى لَهَبٍ وَتَبَّ', '[]'::jsonb,
   'May the hands of Abu Lahab be ruined, and ruined is he.', 'Tabbat yadaa abee lahabin wa tabb'),
  (111, 2, 'مَآ أَغْنَىٰ عَنْهُ مَالُهُۥ وَمَا كَسَبَ', 'مَآ أَغْنَىٰ عَنْهُ مَالُهُۥ وَمَا كَسَبَ', '[]'::jsonb,
   'His wealth will not avail him or that which he gained.', 'Maa aghnaa ''anhu maaluhu wa maa kasab'),
  (111, 3, 'سَيَصْلَىٰ نَارًا ذَاتَ لَهَبٍ', 'سَيَصْلَىٰ نَارًا ذَاتَ لَهَبٍ', '[]'::jsonb,
   'He will burn in a Fire of blazing flame', 'Sayaslaa naaran dhaata lahab'),
  (111, 4, 'وَٱمْرَأَتُهُۥ حَمَّالَةَ ٱلْحَطَبِ', 'وَٱمْرَأَتُهُۥ حَمَّالَةَ ٱلْحَطَبِ', '[]'::jsonb,
   'And his wife as well - the carrier of firewood.', 'Wamra-atuhu hammaalatal hatab'),
  (111, 5, 'فِى جِيدِهَا حَبْلٌ مِّن مَّسَدٍۭ', 'فِى جِيدِهَا حَبْلٌ مِّن مَّسَدٍۭ', '[]'::jsonb,
   'Around her neck is a rope of twisted fiber.', 'Fee jeedihaa hablum mim masad'),
  (97, 1, 'إِنَّآ أَنزَلْنَـٰهُ فِى لَيْلَةِ ٱلْقَدْرِ', 'إِنَّآ أَنزَلْنَـٰهُ فِى لَيْلَةِ ٱلْقَدْرِ', '[]'::jsonb,
   'Indeed, We sent it down during the Night of Decree.', 'Innaa anzalnaahu fee laylatil qadr'),
  (97, 2, 'وَمَآ أَدْرَىٰكَ مَا لَيْلَةُ ٱلْقَدْرِ', 'وَمَآ أَدْرَىٰكَ مَا لَيْلَةُ ٱلْقَدْرِ', '[]'::jsonb,
   'And what can make you know what is the Night of Decree?', 'Wa maa adraaka maa laylatul qadr'),
  (97, 3, 'لَيْلَةُ ٱلْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ', 'لَيْلَةُ ٱلْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ', '[]'::jsonb,
   'The Night of Decree is better than a thousand months.', 'Laylatul qadri khayrum min alfi shahr'),
  (97, 4, 'تَنَزَّلُ ٱلْمَلَـٰٓئِكَةُ وَٱلرُّوحُ فِيهَا بِإِذْنِ رَبِّهِم مِّن كُلِّ أَمْرٍ', 'تَنَزَّلُ ٱلْمَلَـٰٓئِكَةُ وَٱلرُّوحُ فِيهَا بِإِذْنِ رَبِّهِم مِّن كُلِّ أَمْرٍ', '[]'::jsonb,
   'The angels and the Spirit descend therein by permission of their Lord for every matter.', 'Tanazzalul malaa-ikatu war-roohu feehaa bi-idhni rabbihim min kulli amr'),
  (97, 5, 'سَلَـٰمٌ هِىَ حَتَّىٰ مَطْلَعِ ٱلْفَجْرِ', 'سَلَـٰمٌ هِىَ حَتَّىٰ مَطْلَعِ ٱلْفَجْرِ', '[]'::jsonb,
   'Peace it is until the emergence of dawn.', 'Salaamun hiya hattaa matla''il fajr'),
  (94, 1, 'أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ', 'أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ', '[]'::jsonb,
   'Did We not expand for you your breast?', 'Alam nashrah laka sadrak'),
  (94, 2, 'وَوَضَعْنَا عَنكَ وِزْرَكَ', 'وَوَضَعْنَا عَنكَ وِزْرَكَ', '[]'::jsonb,
   'And We removed from you your burden', 'Wa wada''naa ''anka wizrak'),
  (94, 3, 'ٱلَّذِىٓ أَنقَضَ ظَهْرَكَ', 'ٱلَّذِىٓ أَنقَضَ ظَهْرَكَ', '[]'::jsonb,
   'Which had weighed upon your back', 'Alladhee anqada dhahrak'),
  (94, 4, 'وَرَفَعْنَا لَكَ ذِكْرَكَ', 'وَرَفَعْنَا لَكَ ذِكْرَكَ', '[]'::jsonb,
   'And raised high for you your repute.', 'Wa rafa''naa laka dhikrak'),
  (94, 5, 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا', 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا', '[]'::jsonb,
   'For indeed, with hardship will be ease.', 'Fa-inna ma''al-''usri yusraa'),
  (94, 6, 'إِنَّ مَعَ ٱلْعُسْرِ يُسْرًا', 'إِنَّ مَعَ ٱلْعُسْرِ يُسْرًا', '[]'::jsonb,
   'Indeed, with hardship will be ease.', 'Inna ma''al-''usri yusraa'),
  (94, 7, 'فَإِذَا فَرَغْتَ فَٱنصَبْ', 'فَإِذَا فَرَغْتَ فَٱنصَبْ', '[]'::jsonb,
   'So when you have finished your duties, then stand up for worship.', 'Fa-idhaa faraghta fansab'),
  (94, 8, 'وَإِلَىٰ رَبِّكَ فَٱرْغَب', 'وَإِلَىٰ رَبِّكَ فَٱرْغَب', '[]'::jsonb,
   'And to your Lord direct your longing.', 'Wa ilaa rabbika farghab');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Fil', 9, 4 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Masad', 10, 4 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Qadr', 11, 4 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Ash-Sharh', 12, 5 from units where title = 'Short Surahs';

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
      ('Al-Fil', 105, 1, 5, 'What happened to the ''companions of the elephant'' in Surat Al-Fil?',
        '["They successfully destroyed the Ka''bah", "Allah sent birds that struck them with stones, destroying them", "They converted to Islam", "They built a great empire"]', 1),
      ('Al-Masad', 111, 1, 5, 'Who is Surat Al-Masad specifically about?',
        '["A righteous companion of the Prophet", "Abu Lahab and his wife, who opposed the Prophet", "The Prophet''s own family", "The people of Quraysh in general"]', 1),
      ('Al-Qadr', 97, 1, 5, 'What does Surat Al-Qadr say about the Night of Decree (Laylatul Qadr)?',
        '["It is better than a thousand months", "It happens once in a person''s lifetime", "It is the night the Prophet was born", "It marks the start of the Hijri calendar"]', 0),
      ('Ash-Sharh', 94, 1, 8, 'What does Surat Ash-Sharh promise comes with hardship?',
        '["Wealth", "Ease", "Long life", "Fame"]', 1)
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
