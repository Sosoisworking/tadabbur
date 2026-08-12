-- Adds Al-Qari'ah (101, 11 ayahs) to the "Short Surahs" unit, per user
-- request — the last of the short (<=11 ayah) Juz Amma surahs not yet
-- covered after migrations 0036-0038 and 0042.
--
-- Same verification discipline as those migrations: Uthmani text
-- batched per chapter from Quran.com, Saheeh International translation
-- (resource 20) and transliteration (resource 57) fetched individually
-- per verse, restyled into this app's established convention. Live
-- check before writing this migration confirmed surah 101 has no
-- existing `surahs` or `ayat` row (unlike 98/100 in migration 0042).
-- Built directly in the current lesson shape: prayer_step, one
-- reading_passage card per ayah, then a closing full-surah recap — no
-- recall_quiz (removed from the unit entirely in migration 0041).

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (101, 'القارعة', 'Al-Qari''ah', 11, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en, transliteration) values
  (101, 1, 'ٱلْقَارِعَةُ', 'ٱلْقَارِعَةُ', '[]'::jsonb,
   'The Striking Calamity -', 'Al-qaari''ah'),
  (101, 2, 'مَا ٱلْقَارِعَةُ', 'مَا ٱلْقَارِعَةُ', '[]'::jsonb,
   'What is the Striking Calamity?', 'Mal-qaari''ah'),
  (101, 3, 'وَمَآ أَدْرَىٰكَ مَا ٱلْقَارِعَةُ', 'وَمَآ أَدْرَىٰكَ مَا ٱلْقَارِعَةُ', '[]'::jsonb,
   'And what can make you know what is the Striking Calamity?', 'Wa maa adraaka mal-qaari''ah'),
  (101, 4, 'يَوْمَ يَكُونُ ٱلنَّاسُ كَٱلْفَرَاشِ ٱلْمَبْثُوثِ', 'يَوْمَ يَكُونُ ٱلنَّاسُ كَٱلْفَرَاشِ ٱلْمَبْثُوثِ', '[]'::jsonb,
   'It is the Day when people will be like moths, dispersed', 'Yawma yakoonun-naasu kal-faraashil-mabthooth'),
  (101, 5, 'وَتَكُونُ ٱلْجِبَالُ كَٱلْعِهْنِ ٱلْمَنفُوشِ', 'وَتَكُونُ ٱلْجِبَالُ كَٱلْعِهْنِ ٱلْمَنفُوشِ', '[]'::jsonb,
   'And the mountains will be like wool, fluffed up.', 'Wa takoonul-jibaalu kal-''ihnil-manfoosh'),
  (101, 6, 'فَأَمَّا مَن ثَقُلَتْ مَوَٰزِينُهُۥ', 'فَأَمَّا مَن ثَقُلَتْ مَوَٰزِينُهُۥ', '[]'::jsonb,
   'Then as for one whose scales are heavy [with good deeds],', 'Fa-ammaa man thaqulat mawaazeenuh'),
  (101, 7, 'فَهُوَ فِى عِيشَةٍ رَّاضِيَةٍ', 'فَهُوَ فِى عِيشَةٍ رَّاضِيَةٍ', '[]'::jsonb,
   'He will be in a pleasant life.', 'Fahuwa fee ''eeshatir-raadiyah'),
  (101, 8, 'وَأَمَّا مَنْ خَفَّتْ مَوَٰزِينُهُۥ', 'وَأَمَّا مَنْ خَفَّتْ مَوَٰزِينُهُۥ', '[]'::jsonb,
   'But as for one whose scales are light,', 'Wa ammaa man khaffat mawaazeenuh'),
  (101, 9, 'فَأُمُّهُۥ هَاوِيَةٌ', 'فَأُمُّهُۥ هَاوِيَةٌ', '[]'::jsonb,
   'His refuge will be an abyss.', 'Fa-ummuhu haawiyah'),
  (101, 10, 'وَمَآ أَدْرَىٰكَ مَا هِيَهْ', 'وَمَآ أَدْرَىٰكَ مَا هِيَهْ', '[]'::jsonb,
   'And what can make you know what that is?', 'Wa maa adraaka maa hiyah'),
  (101, 11, 'نَارٌ حَامِيَةٌۢ', 'نَارٌ حَامِيَةٌۢ', '[]'::jsonb,
   'It is a Fire, intensely hot.', 'Naarun haamiyah');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Qari''ah', 21, 6 from units where title = 'Short Surahs';

do $$
declare
  v_lesson_id int;
  v_exercise_id int;
  v_ayah record;
  v_start_id bigint;
  v_end_id bigint;
  v_seq int;
begin
  select l.id into v_lesson_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Short Surahs' and l.title = 'Al-Qari''ah';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'prayer_step', 1) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en) values (v_exercise_id, 'Recite Surat Al-Qari''ah:');

  v_seq := 1;
  for v_ayah in
    select id from ayat where surah_number = 101 order by ayah_number
  loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
    insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_ayah.id, v_ayah.id);
  end loop;

  select id into v_start_id from ayat where surah_number = 101 and ayah_number = 1;
  select id into v_end_id from ayat where surah_number = 101 and ayah_number = 11;
  v_seq := v_seq + 1;
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
  insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_start_id, v_end_id);
end $$;
