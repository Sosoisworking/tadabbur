-- Adds 4 more short surahs to the "Short Surahs" unit, continuing the
-- tier started in migrations 0036/0037: Ad-Duha (93, 11 ayahs — Ash-
-- Sharh's companion piece, historically revealed together), At-Tin
-- (95, 8 ayahs), Al-Humazah (104, 9 ayahs), Al-Ma'un (107, 7 ayahs).
--
-- Sourcing note, different from every prior ayah-content migration:
-- the WebFetch tool's session quota was exhausted partway through
-- fetching transliterations (Quran.com resource 57 was reachable for
-- Uthmani text and Saheeh International translation — both fully
-- fetched and verified per the usual individual-verse discipline —
-- but not for most of the 35 transliterations). Rather than block on
-- the quota reset, transliteration for this batch was cross-verified
-- via WebSearch against multiple independent transliteration sources
-- per surah (not a single source, and not memory alone), then
-- restyled into this app's established common-convention style the
-- same way every prior batch was. Ad-Duha and At-Tin in particular are
-- both extremely well-known, commonly memorized surahs independently
-- recognized with high confidence; Al-Humazah and Al-Ma'un were
-- cross-checked the same way despite being slightly less universally
-- memorized. Uthmani text and translation carry the same verification
-- confidence as every prior migration; only the transliteration
-- sourcing method differs, and is called out here for transparency.
--
-- One lesson per surah, ordered by ayah count ascending, same
-- 3-exercise shape as every lesson in this unit.

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (107, 'الماعون', 'Al-Ma''un', 7, 'meccan'),
  (95, 'التين', 'At-Tin', 8, 'meccan'),
  (104, 'الهمزة', 'Al-Humazah', 9, 'meccan'),
  (93, 'الضحى', 'Ad-Duha', 11, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en, transliteration) values
  (107, 1, 'أَرَءَيْتَ ٱلَّذِى يُكَذِّبُ بِٱلدِّينِ', 'أَرَءَيْتَ ٱلَّذِى يُكَذِّبُ بِٱلدِّينِ', '[]'::jsonb,
   'Have you seen the one who denies the Recompense?', 'Ara-aytal ladhee yukadhdhibu biddeen'),
  (107, 2, 'فَذَٰلِكَ ٱلَّذِى يَدُعُّ ٱلْيَتِيمَ', 'فَذَٰلِكَ ٱلَّذِى يَدُعُّ ٱلْيَتِيمَ', '[]'::jsonb,
   'For that is the one who drives away the orphan', 'Fadhaalikal ladhee yadu''ul yateem'),
  (107, 3, 'وَلَا يَحُضُّ عَلَىٰ طَعَامِ ٱلْمِسْكِينِ', 'وَلَا يَحُضُّ عَلَىٰ طَعَامِ ٱلْمِسْكِينِ', '[]'::jsonb,
   'And does not encourage the feeding of the poor.', 'Wa laa yahuddu ''alaa ta''aamil miskeen'),
  (107, 4, 'فَوَيْلٌ لِّلْمُصَلِّينَ', 'فَوَيْلٌ لِّلْمُصَلِّينَ', '[]'::jsonb,
   'So woe to those who pray', 'Fawaylul lil musalleen'),
  (107, 5, 'ٱلَّذِينَ هُمْ عَن صَلَاتِهِمْ سَاهُونَ', 'ٱلَّذِينَ هُمْ عَن صَلَاتِهِمْ سَاهُونَ', '[]'::jsonb,
   'But who are heedless of their prayer', 'Alladheena hum ''an salaatihim saahoon'),
  (107, 6, 'ٱلَّذِينَ هُمْ يُرَآءُونَ', 'ٱلَّذِينَ هُمْ يُرَآءُونَ', '[]'::jsonb,
   'Those who make show of their deeds', 'Alladheena hum yuraa-oon'),
  (107, 7, 'وَيَمْنَعُونَ ٱلْمَاعُونَ', 'وَيَمْنَعُونَ ٱلْمَاعُونَ', '[]'::jsonb,
   'And withhold simple assistance.', 'Wa yamna''oonal maa''oon'),
  (95, 1, 'وَٱلتِّينِ وَٱلزَّيْتُونِ', 'وَٱلتِّينِ وَٱلزَّيْتُونِ', '[]'::jsonb,
   'By the fig and the olive', 'Wat-teeni waz-zaytoon'),
  (95, 2, 'وَطُورِ سِينِينَ', 'وَطُورِ سِينِينَ', '[]'::jsonb,
   'And by Mount Sinai', 'Wa toori seeneen'),
  (95, 3, 'وَهَـٰذَا ٱلْبَلَدِ ٱلْأَمِينِ', 'وَهَـٰذَا ٱلْبَلَدِ ٱلْأَمِينِ', '[]'::jsonb,
   'And by this secure city (Makkah),', 'Wa haadhal baladil ameen'),
  (95, 4, 'لَقَدْ خَلَقْنَا ٱلْإِنسَـٰنَ فِىٓ أَحْسَنِ تَقْوِيمٍ', 'لَقَدْ خَلَقْنَا ٱلْإِنسَـٰنَ فِىٓ أَحْسَنِ تَقْوِيمٍ', '[]'::jsonb,
   'We have certainly created man in the best of stature;', 'Laqad khalaqnal insaana fee ahsani taqweem'),
  (95, 5, 'ثُمَّ رَدَدْنَـٰهُ أَسْفَلَ سَـٰفِلِينَ', 'ثُمَّ رَدَدْنَـٰهُ أَسْفَلَ سَـٰفِلِينَ', '[]'::jsonb,
   'Then We return him to the lowest of the low,', 'Thumma radadnaahu asfala saafileen'),
  (95, 6, 'إِلَّا ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ فَلَهُمْ أَجْرٌ غَيْرُ مَمْنُونٍ', 'إِلَّا ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ فَلَهُمْ أَجْرٌ غَيْرُ مَمْنُونٍ', '[]'::jsonb,
   'Except for those who believe and do righteous deeds, for they will have a reward uninterrupted.', 'Illal-ladheena aamanoo wa ''amilus-saalihaati falahum ajrun ghayru mamnoon'),
  (95, 7, 'فَمَا يُكَذِّبُكَ بَعْدُ بِٱلدِّينِ', 'فَمَا يُكَذِّبُكَ بَعْدُ بِٱلدِّينِ', '[]'::jsonb,
   'So what yet causes you to deny the Recompense?', 'Fa maa yukadhdhibuka ba''du biddeen'),
  (95, 8, 'أَلَيْسَ ٱللَّهُ بِأَحْكَمِ ٱلْحَـٰكِمِينَ', 'أَلَيْسَ ٱللَّهُ بِأَحْكَمِ ٱلْحَـٰكِمِينَ', '[]'::jsonb,
   'Is not Allah the most just of judges?', 'Alaysal-laahu bi-ahkamil haakimeen'),
  (104, 1, 'وَيْلٌ لِّكُلِّ هُمَزَةٍ لُّمَزَةٍ', 'وَيْلٌ لِّكُلِّ هُمَزَةٍ لُّمَزَةٍ', '[]'::jsonb,
   'Woe to every scorner and mocker', 'Waylul likulli humazatil lumazah'),
  (104, 2, 'ٱلَّذِى جَمَعَ مَالًا وَعَدَّدَهُۥ', 'ٱلَّذِى جَمَعَ مَالًا وَعَدَّدَهُۥ', '[]'::jsonb,
   'Who collects wealth and continuously counts it.', 'Alladhee jama''a maalanw wa ''addadah'),
  (104, 3, 'يَحْسَبُ أَنَّ مَالَهُۥٓ أَخْلَدَهُۥ', 'يَحْسَبُ أَنَّ مَالَهُۥٓ أَخْلَدَهُۥ', '[]'::jsonb,
   'He thinks that his wealth will make him immortal.', 'Yahsabu anna maalahoo akhladah'),
  (104, 4, 'كَلَّا ۖ لَيُنۢبَذَنَّ فِى ٱلْحُطَمَةِ', 'كَلَّا ۖ لَيُنۢبَذَنَّ فِى ٱلْحُطَمَةِ', '[]'::jsonb,
   'No! He will surely be thrown into the Crusher.', 'Kallaa layunbadhanna fil hutamah'),
  (104, 5, 'وَمَآ أَدْرَىٰكَ مَا ٱلْحُطَمَةُ', 'وَمَآ أَدْرَىٰكَ مَا ٱلْحُطَمَةُ', '[]'::jsonb,
   'And what can make you know what is the Crusher?', 'Wa maa adraaka mal hutamah'),
  (104, 6, 'نَارُ ٱللَّهِ ٱلْمُوقَدَةُ', 'نَارُ ٱللَّهِ ٱلْمُوقَدَةُ', '[]'::jsonb,
   'It is the fire of Allah, eternally fueled,', 'Naarullaahil mooqadah'),
  (104, 7, 'ٱلَّتِى تَطَّلِعُ عَلَى ٱلْأَفْـِٔدَةِ', 'ٱلَّتِى تَطَّلِعُ عَلَى ٱلْأَفْـِٔدَةِ', '[]'::jsonb,
   'Which mounts directed at the hearts.', 'Allatee tattali''u ''alal af-idah'),
  (104, 8, 'إِنَّهَا عَلَيْهِم مُّؤْصَدَةٌ', 'إِنَّهَا عَلَيْهِم مُّؤْصَدَةٌ', '[]'::jsonb,
   'Indeed, it will be closed down upon them', 'Innahaa ''alayhim mu-sadah'),
  (104, 9, 'فِى عَمَدٍ مُّمَدَّدَةٍۭ', 'فِى عَمَدٍ مُّمَدَّدَةٍۭ', '[]'::jsonb,
   'In extended columns.', 'Fee ''amadim mumaddadah'),
  (93, 1, 'وَٱلضُّحَىٰ', 'وَٱلضُّحَىٰ', '[]'::jsonb,
   'By the morning brightness', 'Wadh-dhuhaa'),
  (93, 2, 'وَٱلَّيْلِ إِذَا سَجَىٰ', 'وَٱلَّيْلِ إِذَا سَجَىٰ', '[]'::jsonb,
   'And by the night when it covers with darkness,', 'Wal-layli idhaa sajaa'),
  (93, 3, 'مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ', 'مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ', '[]'::jsonb,
   'Your Lord has not taken leave of you, nor has He detested you.', 'Maa wadda''aka rabbuka wa maa qalaa'),
  (93, 4, 'وَلَلْـَٔاخِرَةُ خَيْرٌ لَّكَ مِنَ ٱلْأُولَىٰ', 'وَلَلْـَٔاخِرَةُ خَيْرٌ لَّكَ مِنَ ٱلْأُولَىٰ', '[]'::jsonb,
   'And the Hereafter is better for you than the first life.', 'Wa lal-aakhiratu khayrul laka minal-oolaa'),
  (93, 5, 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰٓ', 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰٓ', '[]'::jsonb,
   'And your Lord is going to give you, and you will be satisfied.', 'Wa lasawfa yu''teeka rabbuka fatardaa'),
  (93, 6, 'أَلَمْ يَجِدْكَ يَتِيمًا فَـَٔاوَىٰ', 'أَلَمْ يَجِدْكَ يَتِيمًا فَـَٔاوَىٰ', '[]'::jsonb,
   'Did He not find you an orphan and give you refuge?', 'Alam yajidka yateeman fa-aawaa'),
  (93, 7, 'وَوَجَدَكَ ضَآلًّا فَهَدَىٰ', 'وَوَجَدَكَ ضَآلًّا فَهَدَىٰ', '[]'::jsonb,
   'And He found you lost and guided you,', 'Wa wajadaka daaallan fahadaa'),
  (93, 8, 'وَوَجَدَكَ عَآئِلًا فَأَغْنَىٰ', 'وَوَجَدَكَ عَآئِلًا فَأَغْنَىٰ', '[]'::jsonb,
   'And He found you poor and made you self-sufficient.', 'Wa wajadaka ''aa-ilan fa-aghnaa'),
  (93, 9, 'فَأَمَّا ٱلْيَتِيمَ فَلَا تَقْهَرْ', 'فَأَمَّا ٱلْيَتِيمَ فَلَا تَقْهَرْ', '[]'::jsonb,
   'So as for the orphan, do not oppress him.', 'Fa-ammal yateema falaa taqhar'),
  (93, 10, 'وَأَمَّا ٱلسَّآئِلَ فَلَا تَنْهَرْ', 'وَأَمَّا ٱلسَّآئِلَ فَلَا تَنْهَرْ', '[]'::jsonb,
   'And as for the petitioner, do not repel him.', 'Wa ammas-saa-ila falaa tanhar'),
  (93, 11, 'وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ', 'وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ', '[]'::jsonb,
   'But as for the favor of your Lord, report it.', 'Wa ammaa bini''mati rabbika fahaddith');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Ma''un', 13, 4 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'At-Tin', 14, 5 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Humazah', 15, 5 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Ad-Duha', 16, 6 from units where title = 'Short Surahs';

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
      ('Al-Ma''un', 107, 1, 7, 'According to Surat Al-Ma''un, what should true worship be paired with?',
        '["Wealth and status", "Caring for orphans and helping the needy", "Long fasting", "Silence"]', 1),
      ('At-Tin', 95, 1, 8, 'According to Surat At-Tin, in what form did Allah create humanity?',
        '["The lowest of the low", "The best of stature", "Equal to angels", "Without any purpose"]', 1),
      ('Al-Humazah', 104, 1, 9, 'What does Surat Al-Humazah warn against?',
        '["Praying too much", "Slandering others and obsessively hoarding wealth", "Traveling too far", "Eating too much"]', 1),
      ('Ad-Duha', 93, 1, 11, 'What does Surat Ad-Duha instruct regarding orphans and those who ask for help?',
        '["Ignore them", "Do not oppress the orphan, and do not turn away the one who asks", "Give them all your wealth", "Send them away"]', 1)
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
