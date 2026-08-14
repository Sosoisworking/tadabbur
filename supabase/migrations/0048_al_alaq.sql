-- Adds Al-'Alaq (96, 19 ayahs) to "Short Surahs" — the surah of the
-- very first revelation ("Iqra bismi rabbikal-ladhee khalaq").
--
-- This one was MISSED by every prior batch, found by a post-push
-- coverage check that compared the `surahs` table against the full
-- 78-114 range after migration 0047. The gap came from how the work
-- was framed: migrations 0036-0043 covered "every Juz Amma surah with
-- <= 11 ayahs", and 0044-0047 covered "the remaining 78-92 range".
-- Al-'Alaq is a 19-ayah surah numbered 96, so it fell outside both
-- descriptions and was never enumerated. Only checking coverage
-- against the actual 78-114 range — rather than trusting the
-- batch-by-batch bookkeeping — surfaced it. With this migration Juz
-- Amma is genuinely complete: all 37 surahs (78-114), 37 lessons.
--
-- Same verification discipline as every prior batch: Uthmani text
-- batched per chapter, Saheeh International translation (resource 20)
-- and transliteration (resource 57) fetched individually per verse
-- from Quran.com, restyled into this app's established convention.
-- Live check before writing confirmed surah 96 had no existing
-- `surahs` or `ayat` row.
--
-- 96:19 carries a sajdah mark (۩) in the Uthmani text — stripped from
-- text_diacritized, same as migration 0045 did for Al-Inshiqaq 84:21,
-- since that glyph is a recitation instruction rather than part of
-- the verse's letters.
--
-- Built directly in the current lesson shape: prayer_step, one
-- reading_passage card per ayah, then a closing full-surah recap — no
-- recall_quiz (removed from the unit per migration 0041).

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (96, 'العلق', 'Al-''Alaq', 19, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en, transliteration) values
  (96, 1, 'ٱقْرَأْ بِٱسْمِ رَبِّكَ ٱلَّذِى خَلَقَ', 'ٱقْرَأْ بِٱسْمِ رَبِّكَ ٱلَّذِى خَلَقَ', '[]'::jsonb,
   'Recite in the name of your Lord who created', 'Iqra bismi rabbikal-ladhee khalaq'),
  (96, 2, 'خَلَقَ ٱلْإِنسَـٰنَ مِنْ عَلَقٍ', 'خَلَقَ ٱلْإِنسَـٰنَ مِنْ عَلَقٍ', '[]'::jsonb,
   'Created man from a clinging substance.', 'Khalaqal-insaana min ''alaq'),
  (96, 3, 'ٱقْرَأْ وَرَبُّكَ ٱلْأَكْرَمُ', 'ٱقْرَأْ وَرَبُّكَ ٱلْأَكْرَمُ', '[]'::jsonb,
   'Recite, and your Lord is the most Generous -', 'Iqra wa rabbukal-akram'),
  (96, 4, 'ٱلَّذِى عَلَّمَ بِٱلْقَلَمِ', 'ٱلَّذِى عَلَّمَ بِٱلْقَلَمِ', '[]'::jsonb,
   'Who taught by the pen -', 'Alladhee ''allama bil-qalam'),
  (96, 5, 'عَلَّمَ ٱلْإِنسَـٰنَ مَا لَمْ يَعْلَمْ', 'عَلَّمَ ٱلْإِنسَـٰنَ مَا لَمْ يَعْلَمْ', '[]'::jsonb,
   'Taught man that which he knew not.', '''Allamal-insaana maa lam ya''lam'),
  (96, 6, 'كَلَّآ إِنَّ ٱلْإِنسَـٰنَ لَيَطْغَىٰٓ', 'كَلَّآ إِنَّ ٱلْإِنسَـٰنَ لَيَطْغَىٰٓ', '[]'::jsonb,
   'No! [But] indeed, man transgresses', 'Kallaa innal-insaana layatghaa'),
  (96, 7, 'أَن رَّءَاهُ ٱسْتَغْنَىٰٓ', 'أَن رَّءَاهُ ٱسْتَغْنَىٰٓ', '[]'::jsonb,
   'Because he sees himself self-sufficient.', 'Ar-ra-aahus-taghnaa'),
  (96, 8, 'إِنَّ إِلَىٰ رَبِّكَ ٱلرُّجْعَىٰٓ', 'إِنَّ إِلَىٰ رَبِّكَ ٱلرُّجْعَىٰٓ', '[]'::jsonb,
   'Indeed, to your Lord is the return.', 'Inna ilaa rabbikar-ruj''aa'),
  (96, 9, 'أَرَءَيْتَ ٱلَّذِى يَنْهَىٰ', 'أَرَءَيْتَ ٱلَّذِى يَنْهَىٰ', '[]'::jsonb,
   'Have you seen the one who forbids', 'Ara-aytal-ladhee yanhaa'),
  (96, 10, 'عَبْدًا إِذَا صَلَّىٰٓ', 'عَبْدًا إِذَا صَلَّىٰٓ', '[]'::jsonb,
   'A servant when he prays?', '''Abdan idhaa sallaa'),
  (96, 11, 'أَرَءَيْتَ إِن كَانَ عَلَى ٱلْهُدَىٰٓ', 'أَرَءَيْتَ إِن كَانَ عَلَى ٱلْهُدَىٰٓ', '[]'::jsonb,
   'Have you seen if he is upon guidance', 'Ara-ayta in kaana ''alal-hudaa'),
  (96, 12, 'أَوْ أَمَرَ بِٱلتَّقْوَىٰٓ', 'أَوْ أَمَرَ بِٱلتَّقْوَىٰٓ', '[]'::jsonb,
   'Or enjoins righteousness?', 'Aw amara bit-taqwaa'),
  (96, 13, 'أَرَءَيْتَ إِن كَذَّبَ وَتَوَلَّىٰٓ', 'أَرَءَيْتَ إِن كَذَّبَ وَتَوَلَّىٰٓ', '[]'::jsonb,
   'Have you seen if he denies and turns away -', 'Ara-ayta in kadhdhaba wa tawallaa'),
  (96, 14, 'أَلَمْ يَعْلَم بِأَنَّ ٱللَّهَ يَرَىٰ', 'أَلَمْ يَعْلَم بِأَنَّ ٱللَّهَ يَرَىٰ', '[]'::jsonb,
   'Does he not know that Allah sees?', 'Alam ya''lam bi-annallaaha yaraa'),
  (96, 15, 'كَلَّا لَئِن لَّمْ يَنتَهِ لَنَسْفَعًۢا بِٱلنَّاصِيَةِ', 'كَلَّا لَئِن لَّمْ يَنتَهِ لَنَسْفَعًۢا بِٱلنَّاصِيَةِ', '[]'::jsonb,
   'No! If he does not desist, We will surely drag him by the forelock -', 'Kallaa la-il-lam yantahi lanasfa''am bin-naasiyah'),
  (96, 16, 'نَاصِيَةٍ كَـٰذِبَةٍ خَاطِئَةٍ', 'نَاصِيَةٍ كَـٰذِبَةٍ خَاطِئَةٍ', '[]'::jsonb,
   'A lying, sinning forelock.', 'Naasiyatin kaadhibatin khaati-ah'),
  (96, 17, 'فَلْيَدْعُ نَادِيَهُۥ', 'فَلْيَدْعُ نَادِيَهُۥ', '[]'::jsonb,
   'Then let him call his associates;', 'Falyad''u naadiyah'),
  (96, 18, 'سَنَدْعُ ٱلزَّبَانِيَةَ', 'سَنَدْعُ ٱلزَّبَانِيَةَ', '[]'::jsonb,
   'We will call the angels of Hell.', 'Sanad''uz-zabaaniyah'),
  (96, 19, 'كَلَّا لَا تُطِعْهُ وَٱسْجُدْ وَٱقْتَرِب ۩', 'كَلَّا لَا تُطِعْهُ وَٱسْجُدْ وَٱقْتَرِب', '[]'::jsonb,
   'No! Do not obey him. But prostrate and draw near [to Allah].', 'Kallaa laa tuti''hu wasjud waqtarib');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-''Alaq', 37, 10 from units where title = 'Short Surahs';

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
    where u.title = 'Short Surahs' and l.title = 'Al-''Alaq';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'prayer_step', 1) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en) values (v_exercise_id, 'Recite Surat Al-''Alaq:');

  v_seq := 1;
  for v_ayah in
    select id from ayat where surah_number = 96 order by ayah_number
  loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
    insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_ayah.id, v_ayah.id);
  end loop;

  select id into v_start_id from ayat where surah_number = 96 and ayah_number = 1;
  select id into v_end_id from ayat where surah_number = 96 and ayah_number = 19;
  v_seq := v_seq + 1;
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
  insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_start_id, v_end_id);
end $$;
