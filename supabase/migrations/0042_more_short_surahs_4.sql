-- Adds 4 more short surahs to the "Short Surahs" unit, per user
-- request: Al-Bayyinah (98, 8 ayahs), Az-Zalzalah (99, 8 ayahs),
-- Al-'Adiyat (100, 11 ayahs), At-Takathur (102, 8 ayahs) — the next
-- tier of short, commonly-taught Juz Amma surahs after the batches in
-- migrations 0036-0038.
--
-- Same verification discipline as those migrations: chapter metadata,
-- Uthmani text (batched per chapter, reliable), Saheeh International
-- translation (resource 20) and transliteration (resource 57) all
-- fetched individually per verse from Quran.com, restyled into this
-- app's established transliteration convention. Translation/
-- transliteration for Az-Zalzalah and At-Takathur additionally
-- cross-checked against independently-worded sources (esinislam.com,
-- fajr-quran.com summaries); Al-Bayyinah/Al-'Adiyat cross-checked
-- against a second site that mirrors Quran.com's own resource 57
-- verbatim, confirming no transcription error was introduced when
-- copying the fetched text into this migration.
--
-- Unlike migrations 0036-0038, lessons here are built directly in the
-- CURRENT target shape rather than the original shape those went
-- through later restructuring (0039) and quiz removal (0041) to
-- reach: prayer_step, then one reading_passage card per ayah, then a
-- closing full-surah reading_passage recap. No recall_quiz — that
-- exercise type was removed from every Short Surahs lesson per user
-- request (migration 0041) and there's no reason to add it back here.
--
-- Surahs 98 and 100 turned out to already have a row in `surahs`
-- (matching metadata) and a single `ayat` row each (98:5, id 11;
-- 100:7, id 10) — seeded elsewhere as a grammar_explanation example
-- ayah, discovered via a live check before writing the insert
-- statements below. Both existing ayat rows' translation/
-- transliteration were spot-checked against this migration's
-- independently-fetched-and-restyled text for the same two verses and
-- matched almost verbatim, confirming the restyling here is
-- consistent with house convention. Only 99 and 102 need a `surahs`
-- row, and only the other 7 (98) / 10 (100) ayat are inserted here —
-- the existing rows are left untouched and simply picked up by the
-- per-ayah exercise loop below, which selects from `ayat` by
-- surah_number/ayah_number range rather than assuming everything it
-- needs was just inserted in this same migration.

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (99, 'الزلزلة', 'Az-Zalzalah', 8, 'medinan'),
  (102, 'التكاثر', 'At-Takathur', 8, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en, transliteration) values
  (98, 1, 'لَمْ يَكُنِ ٱلَّذِينَ كَفَرُوا۟ مِنْ أَهْلِ ٱلْكِتَـٰبِ وَٱلْمُشْرِكِينَ مُنفَكِّينَ حَتَّىٰ تَأْتِيَهُمُ ٱلْبَيِّنَةُ', 'لَمْ يَكُنِ ٱلَّذِينَ كَفَرُوا۟ مِنْ أَهْلِ ٱلْكِتَـٰبِ وَٱلْمُشْرِكِينَ مُنفَكِّينَ حَتَّىٰ تَأْتِيَهُمُ ٱلْبَيِّنَةُ', '[]'::jsonb,
   'Those who disbelieved among the People of the Scripture and the polytheists were not to be parted [from misbelief] until there came to them clear evidence', 'Lam yakunil-ladheena kafaroo min ahlil-kitaabi wal-mushrikeena munfakkeena hattaa ta''tiyahumul-bayyinah'),
  (98, 2, 'رَسُولٌ مِّنَ ٱللَّهِ يَتْلُوا۟ صُحُفًا مُّطَهَّرَةً', 'رَسُولٌ مِّنَ ٱللَّهِ يَتْلُوا۟ صُحُفًا مُّطَهَّرَةً', '[]'::jsonb,
   'A Messenger from Allah, reciting purified scriptures', 'Rasoolum minallaahi yatloo suhufam mutahharah'),
  (98, 3, 'فِيهَا كُتُبٌ قَيِّمَةٌ', 'فِيهَا كُتُبٌ قَيِّمَةٌ', '[]'::jsonb,
   'Within which are correct writings [i.e., rulings and laws].', 'Feehaa kutubun qayyimah'),
  (98, 4, 'وَمَا تَفَرَّقَ ٱلَّذِينَ أُوتُوا۟ ٱلْكِتَـٰبَ إِلَّا مِنۢ بَعْدِ مَا جَآءَتْهُمُ ٱلْبَيِّنَةُ', 'وَمَا تَفَرَّقَ ٱلَّذِينَ أُوتُوا۟ ٱلْكِتَـٰبَ إِلَّا مِنۢ بَعْدِ مَا جَآءَتْهُمُ ٱلْبَيِّنَةُ', '[]'::jsonb,
   'Nor did those who were given the Scripture become divided until after there had come to them clear evidence.', 'Wa maa tafarraqal-ladheena ootul-kitaaba illaa mim ba''di maa jaa-at-humul-bayyinah'),
  (98, 6, 'إِنَّ ٱلَّذِينَ كَفَرُوا۟ مِنْ أَهْلِ ٱلْكِتَـٰبِ وَٱلْمُشْرِكِينَ فِى نَارِ جَهَنَّمَ خَـٰلِدِينَ فِيهَآ ۚ أُو۟لَـٰٓئِكَ هُمْ شَرُّ ٱلْبَرِيَّةِ', 'إِنَّ ٱلَّذِينَ كَفَرُوا۟ مِنْ أَهْلِ ٱلْكِتَـٰبِ وَٱلْمُشْرِكِينَ فِى نَارِ جَهَنَّمَ خَـٰلِدِينَ فِيهَآ ۚ أُو۟لَـٰٓئِكَ هُمْ شَرُّ ٱلْبَرِيَّةِ', '[]'::jsonb,
   'Indeed, they who disbelieved among the People of the Scripture and the polytheists will be in the fire of Hell, abiding eternally therein. Those are the worst of creatures.', 'Innal-ladheena kafaroo min ahlil-kitaabi wal-mushrikeena fee naari jahannama khaalideena feehaa, ulaa-ika hum sharrul-bariyyah'),
  (98, 7, 'إِنَّ ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ أُو۟لَـٰٓئِكَ هُمْ خَيْرُ ٱلْبَرِيَّةِ', 'إِنَّ ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ أُو۟لَـٰٓئِكَ هُمْ خَيْرُ ٱلْبَرِيَّةِ', '[]'::jsonb,
   'Indeed, they who have believed and done righteous deeds - those are the best of creatures.', 'Innal-ladheena aamanoo wa ''amilus-saalihaati ulaa-ika hum khayrul-bariyyah'),
  (98, 8, 'جَزَآؤُهُمْ عِندَ رَبِّهِمْ جَنَّـٰتُ عَدْنٍ تَجْرِى مِن تَحْتِهَا ٱلْأَنْهَـٰرُ خَـٰلِدِينَ فِيهَآ أَبَدًا ۖ رَّضِىَ ٱللَّهُ عَنْهُمْ وَرَضُوا۟ عَنْهُ ۚ ذَٰلِكَ لِمَنْ خَشِىَ رَبَّهُۥ', 'جَزَآؤُهُمْ عِندَ رَبِّهِمْ جَنَّـٰتُ عَدْنٍ تَجْرِى مِن تَحْتِهَا ٱلْأَنْهَـٰرُ خَـٰلِدِينَ فِيهَآ أَبَدًا ۖ رَّضِىَ ٱللَّهُ عَنْهُمْ وَرَضُوا۟ عَنْهُ ۚ ذَٰلِكَ لِمَنْ خَشِىَ رَبَّهُۥ', '[]'::jsonb,
   'Their reward with their Lord will be gardens of perpetual residence beneath which rivers flow, wherein they will abide forever, Allah being pleased with them and they with Him. That is for whoever has feared his Lord.', 'Jazaa-uhum ''inda rabbihim jannaatu ''adnin tajree min tahtihal-anhaaru khaalideena feehaa abadaa, radiyallaahu ''anhum wa radoo ''anhu, dhaalika liman khashiya rabbah'),

  (99, 1, 'إِذَا زُلْزِلَتِ ٱلْأَرْضُ زِلْزَالَهَا', 'إِذَا زُلْزِلَتِ ٱلْأَرْضُ زِلْزَالَهَا', '[]'::jsonb,
   'When the earth is shaken with its [final] earthquake', 'Idhaa zulzilatil-ardu zilzaalahaa'),
  (99, 2, 'وَأَخْرَجَتِ ٱلْأَرْضُ أَثْقَالَهَا', 'وَأَخْرَجَتِ ٱلْأَرْضُ أَثْقَالَهَا', '[]'::jsonb,
   'And the earth discharges its burdens', 'Wa akhrajatil-ardu athqaalahaa'),
  (99, 3, 'وَقَالَ ٱلْإِنسَـٰنُ مَا لَهَا', 'وَقَالَ ٱلْإِنسَـٰنُ مَا لَهَا', '[]'::jsonb,
   'And man says, "What is [wrong] with it?"', 'Wa qaalal-insaanu maa lahaa'),
  (99, 4, 'يَوْمَئِذٍ تُحَدِّثُ أَخْبَارَهَا', 'يَوْمَئِذٍ تُحَدِّثُ أَخْبَارَهَا', '[]'::jsonb,
   'That Day, it will report its news', 'Yawma-idhin tuhaddithu akhbaarahaa'),
  (99, 5, 'بِأَنَّ رَبَّكَ أَوْحَىٰ لَهَا', 'بِأَنَّ رَبَّكَ أَوْحَىٰ لَهَا', '[]'::jsonb,
   'Because your Lord has inspired [i.e., commanded] it.', 'Bi-anna rabbaka awhaa lahaa'),
  (99, 6, 'يَوْمَئِذٍ يَصْدُرُ ٱلنَّاسُ أَشْتَاتًا لِّيُرَوْا۟ أَعْمَـٰلَهُمْ', 'يَوْمَئِذٍ يَصْدُرُ ٱلنَّاسُ أَشْتَاتًا لِّيُرَوْا۟ أَعْمَـٰلَهُمْ', '[]'::jsonb,
   'That Day, the people will depart separated [into categories] to be shown [the result of] their deeds.', 'Yawma-idhin yasdurun-naasu ashtaatan liyuraw a''maalahum'),
  (99, 7, 'فَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُۥ', 'فَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُۥ', '[]'::jsonb,
   'So whoever does an atom''s weight of good will see it,', 'Faman ya''mal mithqaala dharratin khayran yarah'),
  (99, 8, 'وَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ شَرًّا يَرَهُۥ', 'وَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ شَرًّا يَرَهُۥ', '[]'::jsonb,
   'And whoever does an atom''s weight of evil will see it.', 'Wa man ya''mal mithqaala dharratin sharran yarah'),

  (100, 1, 'وَٱلْعَـٰدِيَـٰتِ ضَبْحًا', 'وَٱلْعَـٰدِيَـٰتِ ضَبْحًا', '[]'::jsonb,
   'By the racers, panting,', 'Wal-''aadiyaati dabhaa'),
  (100, 2, 'فَٱلْمُورِيَـٰتِ قَدْحًا', 'فَٱلْمُورِيَـٰتِ قَدْحًا', '[]'::jsonb,
   'And the producers of sparks [when] striking', 'Fal-mooriyaati qadhaa'),
  (100, 3, 'فَٱلْمُغِيرَٰتِ صُبْحًا', 'فَٱلْمُغِيرَٰتِ صُبْحًا', '[]'::jsonb,
   'And the chargers at dawn,', 'Fal-mugheeraati subhaa'),
  (100, 4, 'فَأَثَرْنَ بِهِۦ نَقْعًا', 'فَأَثَرْنَ بِهِۦ نَقْعًا', '[]'::jsonb,
   'Stirring up thereby [clouds of] dust,', 'Fa-atharna bihee naq''aa'),
  (100, 5, 'فَوَسَطْنَ بِهِۦ جَمْعًا', 'فَوَسَطْنَ بِهِۦ جَمْعًا', '[]'::jsonb,
   'Arriving thereby in the center collectively,', 'Fawasatna bihee jam''aa'),
  (100, 6, 'إِنَّ ٱلْإِنسَـٰنَ لِرَبِّهِۦ لَكَنُودٌ', 'إِنَّ ٱلْإِنسَـٰنَ لِرَبِّهِۦ لَكَنُودٌ', '[]'::jsonb,
   'Indeed mankind, to his Lord, is ungrateful.', 'Innal-insaana lirabbihee lakanood'),
  (100, 8, 'وَإِنَّهُۥ لِحُبِّ ٱلْخَيْرِ لَشَدِيدٌ', 'وَإِنَّهُۥ لِحُبِّ ٱلْخَيْرِ لَشَدِيدٌ', '[]'::jsonb,
   'And indeed he is, in love of wealth, intense.', 'Wa innahu lihubbil-khayri lashadeed'),
  (100, 9, 'أَفَلَا يَعْلَمُ إِذَا بُعْثِرَ مَا فِى ٱلْقُبُورِ', 'أَفَلَا يَعْلَمُ إِذَا بُعْثِرَ مَا فِى ٱلْقُبُورِ', '[]'::jsonb,
   'But does he not know that when the contents of the graves are scattered', 'Afalaa ya''lamu idhaa bu''thira maa fil-quboor'),
  (100, 10, 'وَحُصِّلَ مَا فِى ٱلصُّدُورِ', 'وَحُصِّلَ مَا فِى ٱلصُّدُورِ', '[]'::jsonb,
   'And that within the breasts is obtained,', 'Wa hussila maa fis-sudoor'),
  (100, 11, 'إِنَّ رَبَّهُم بِهِمْ يَوْمَئِذٍ لَّخَبِيرٌۢ', 'إِنَّ رَبَّهُم بِهِمْ يَوْمَئِذٍ لَّخَبِيرٌۢ', '[]'::jsonb,
   'Indeed, their Lord with them, that Day, is [fully] Aware.', 'Inna rabbahum bihim yawma-idhil-lakhabeer'),

  (102, 1, 'أَلْهَىٰكُمُ ٱلتَّكَاثُرُ', 'أَلْهَىٰكُمُ ٱلتَّكَاثُرُ', '[]'::jsonb,
   'Competition in [worldly] increase diverts you', 'Alhaakumut-takaathur'),
  (102, 2, 'حَتَّىٰ زُرْتُمُ ٱلْمَقَابِرَ', 'حَتَّىٰ زُرْتُمُ ٱلْمَقَابِرَ', '[]'::jsonb,
   'Until you visit the graveyards.', 'Hattaa zurtumul-maqaabir'),
  (102, 3, 'كَلَّا سَوْفَ تَعْلَمُونَ', 'كَلَّا سَوْفَ تَعْلَمُونَ', '[]'::jsonb,
   'No! You are going to know.', 'Kallaa sawfa ta''lamoon'),
  (102, 4, 'ثُمَّ كَلَّا سَوْفَ تَعْلَمُونَ', 'ثُمَّ كَلَّا سَوْفَ تَعْلَمُونَ', '[]'::jsonb,
   'Then, no! You are going to know.', 'Thumma kallaa sawfa ta''lamoon'),
  (102, 5, 'كَلَّا لَوْ تَعْلَمُونَ عِلْمَ ٱلْيَقِينِ', 'كَلَّا لَوْ تَعْلَمُونَ عِلْمَ ٱلْيَقِينِ', '[]'::jsonb,
   'No! If you only knew with knowledge of certainty...', 'Kallaa law ta''lamoona ''ilmal-yaqeen'),
  (102, 6, 'لَتَرَوُنَّ ٱلْجَحِيمَ', 'لَتَرَوُنَّ ٱلْجَحِيمَ', '[]'::jsonb,
   'You will surely see the Hellfire.', 'Latarawunnal-jaheem'),
  (102, 7, 'ثُمَّ لَتَرَوُنَّهَا عَيْنَ ٱلْيَقِينِ', 'ثُمَّ لَتَرَوُنَّهَا عَيْنَ ٱلْيَقِينِ', '[]'::jsonb,
   'Then you will surely see it with the eye of certainty.', 'Thumma latarawunnahaa ''aynal-yaqeen'),
  (102, 8, 'ثُمَّ لَتُسْـَٔلُنَّ يَوْمَئِذٍ عَنِ ٱلنَّعِيمِ', 'ثُمَّ لَتُسْـَٔلُنَّ يَوْمَئِذٍ عَنِ ٱلنَّعِيمِ', '[]'::jsonb,
   'Then you will surely be asked that Day about pleasure.', 'Thumma latus-alunna yawma-idhin ''anin-na''eem');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Bayyinah', 17, 5 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Az-Zalzalah', 18, 5 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-''Adiyat', 19, 6 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'At-Takathur', 20, 5 from units where title = 'Short Surahs';

do $$
declare
  v_row record;
  v_lesson_id int;
  v_exercise_id int;
  v_ayah record;
  v_start_id bigint;
  v_end_id bigint;
  v_seq int;
begin
  for v_row in
    select * from (values
      ('Al-Bayyinah', 98::smallint, 1::smallint, 8::smallint),
      ('Az-Zalzalah', 99::smallint, 1::smallint, 8::smallint),
      ('Al-''Adiyat', 100::smallint, 1::smallint, 11::smallint),
      ('At-Takathur', 102::smallint, 1::smallint, 8::smallint)
    ) as t(lesson_title, surah_number, first_ayah, last_ayah)
  loop
    select l.id into v_lesson_id from lessons l join units u on u.id = l.unit_id
      where u.title = 'Short Surahs' and l.title = v_row.lesson_title;

    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'prayer_step', 1) returning id into v_exercise_id;
    insert into exercise_prayer_step (exercise_id, instruction_en) values (v_exercise_id, 'Recite Surat ' || v_row.lesson_title || ':');

    v_seq := 1;
    for v_ayah in
      select id from ayat where surah_number = v_row.surah_number
        and ayah_number between v_row.first_ayah and v_row.last_ayah
      order by ayah_number
    loop
      v_seq := v_seq + 1;
      insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
      insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_ayah.id, v_ayah.id);
    end loop;

    select id into v_start_id from ayat where surah_number = v_row.surah_number and ayah_number = v_row.first_ayah;
    select id into v_end_id from ayat where surah_number = v_row.surah_number and ayah_number = v_row.last_ayah;
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
    insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_start_id, v_end_id);
  end loop;
end $$;
