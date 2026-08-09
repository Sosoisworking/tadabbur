-- Phase 3 (final phase) of the Prayer Guide adaptation: the four short
-- surahs the book recommends reciting after Al-Fatiha in the first two
-- rak'ahs — fulfills the forward reference left in migration 0026
-- ("A dedicated lesson on short surahs for prayer is coming soon").
--
-- Same verification discipline as Short Ayahs (migration 0021): every
-- ayah's Uthmani text and Saheeh International translation was fetched
-- individually from Quran.com's API (not batched — a batched
-- translation fetch produced two off-by-one verse mismatches during
-- Short Ayahs, since caught and now avoided by design), not
-- transcribed from the book image or recalled from memory. Chapter
-- metadata (ayah_count, revelation_type) verified against Quran.com's
-- chapter endpoint the same way.
--
-- Translations here strip the source API's stray unbalanced quote
-- marks (Saheeh International opens a quotation at "Say" in ayah 1 of
-- Al-Ikhlas/Al-Falaq/An-Nas and doesn't close it until several ayahs
-- later, since it's one continuous quoted statement in the original
-- publication) — this app displays one ayah's translation per row
-- independently, so an unclosed quote mark would read as a typo, not
-- a stylistic choice. The underlying wording is untouched.
--
-- New lesson "Short Surahs for Prayer" in the existing Salah unit
-- (sequence_order 9, after Salah Quiz) rather than a new unit — this
-- is Salah content, not a new pedagogical phase. Each surah gets a
-- short prayer_step instruction card immediately followed by a
-- reading_passage exercise, the same pairing already used for the
-- Al-Fatiha recitation step in migration 0026.

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (108, 'الكوثر', 'Al-Kawthar', 3, 'meccan'),
  (112, 'الإخلاص', 'Al-Ikhlas', 4, 'meccan'),
  (113, 'الفلق', 'Al-Falaq', 5, 'meccan'),
  (114, 'الناس', 'An-Nas', 6, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en) values
  (108, 1, 'إِنَّآ أَعْطَيْنَـٰكَ ٱلْكَوْثَرَ', 'إِنَّآ أَعْطَيْنَـٰكَ ٱلْكَوْثَرَ', '[]'::jsonb,
   'Indeed, We have granted you, [O Muhammad], al-Kawthar.'),
  (108, 2, 'فَصَلِّ لِرَبِّكَ وَٱنْحَرْ', 'فَصَلِّ لِرَبِّكَ وَٱنْحَرْ', '[]'::jsonb,
   'So pray to your Lord and offer sacrifice [to Him alone].'),
  (108, 3, 'إِنَّ شَانِئَكَ هُوَ ٱلْأَبْتَرُ', 'إِنَّ شَانِئَكَ هُوَ ٱلْأَبْتَرُ', '[]'::jsonb,
   'Indeed, your enemy is the one cut off.'),
  (112, 1, 'قُلْ هُوَ ٱللَّهُ أَحَدٌ', 'قُلْ هُوَ ٱللَّهُ أَحَدٌ', '[]'::jsonb,
   'Say, He is Allah, [who is] One,'),
  (112, 2, 'ٱللَّهُ ٱلصَّمَدُ', 'ٱللَّهُ ٱلصَّمَدُ', '[]'::jsonb,
   'Allah, the Eternal Refuge.'),
  (112, 3, 'لَمْ يَلِدْ وَلَمْ يُولَدْ', 'لَمْ يَلِدْ وَلَمْ يُولَدْ', '[]'::jsonb,
   'He neither begets nor is born,'),
  (112, 4, 'وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ', 'وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ', '[]'::jsonb,
   'Nor is there to Him any equivalent.'),
  (113, 1, 'قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ', 'قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ', '[]'::jsonb,
   'Say, I seek refuge in the Lord of daybreak'),
  (113, 2, 'مِن شَرِّ مَا خَلَقَ', 'مِن شَرِّ مَا خَلَقَ', '[]'::jsonb,
   'From the evil of that which He created'),
  (113, 3, 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ', 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ', '[]'::jsonb,
   'And from the evil of darkness when it settles'),
  (113, 4, 'وَمِن شَرِّ ٱلنَّفَّـٰثَـٰتِ فِى ٱلْعُقَدِ', 'وَمِن شَرِّ ٱلنَّفَّـٰثَـٰتِ فِى ٱلْعُقَدِ', '[]'::jsonb,
   'And from the evil of the blowers in knots'),
  (113, 5, 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ', 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ', '[]'::jsonb,
   'And from the evil of an envier when he envies.'),
  (114, 1, 'قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ', 'قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ', '[]'::jsonb,
   'Say, I seek refuge in the Lord of mankind,'),
  (114, 2, 'مَلِكِ ٱلنَّاسِ', 'مَلِكِ ٱلنَّاسِ', '[]'::jsonb,
   'The Sovereign of mankind,'),
  (114, 3, 'إِلَـٰهِ ٱلنَّاسِ', 'إِلَـٰهِ ٱلنَّاسِ', '[]'::jsonb,
   'The God of mankind,'),
  (114, 4, 'مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ', 'مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ', '[]'::jsonb,
   'From the evil of the retreating whisperer —'),
  (114, 5, 'ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ', 'ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ', '[]'::jsonb,
   'Who whispers [evil] into the breasts of mankind —'),
  (114, 6, 'مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ', 'مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ', '[]'::jsonb,
   'From among the jinn and mankind');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Short Surahs for Prayer', 9, 8 from units where title = 'Salah — The Prayer';

do $$
declare
  v_lesson_id int;
  v_exercise_id int;
  v_seq int;
  v_surah record;
  v_start_id bigint;
  v_end_id bigint;
begin
  select l.id into v_lesson_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Salah — The Prayer' and l.title = 'Short Surahs for Prayer';

  v_seq := 0;
  for v_surah in
    select * from (values
      (108, 'Al-Kawthar', 1, 3),
      (112, 'Al-Ikhlas', 1, 4),
      (113, 'Al-Falaq', 1, 5),
      (114, 'An-Nas', 1, 6)
    ) as t(surah_number, surah_name, first_ayah, last_ayah)
  loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'prayer_step', v_seq) returning id into v_exercise_id;
    insert into exercise_prayer_step (exercise_id, instruction_en) values (v_exercise_id, 'Recite Surat ' || v_surah.surah_name || ':');

    v_seq := v_seq + 1;
    select id into v_start_id from ayat where surah_number = v_surah.surah_number and ayah_number = v_surah.first_ayah;
    select id into v_end_id from ayat where surah_number = v_surah.surah_number and ayah_number = v_surah.last_ayah;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
    insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_start_id, v_end_id);
  end loop;

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', v_seq + 1) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Surat Al-Kawthar tells the Prophet to do what?',
    '["Fast and give charity", "Pray to his Lord and offer sacrifice", "Travel to Makkah", "Recite the Qur''an aloud"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', v_seq + 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Surat Al-Ikhlas — which says Allah neither begets nor is born, and has no equal — is about what?',
    '["The Day of Judgment", "The oneness and uniqueness of Allah", "The story of a prophet", "The five daily prayers"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', v_seq + 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'In Surat Al-Falaq, what kinds of things does the reciter seek refuge from?',
    '["Hunger and thirst", "Various evils, including envy", "Losing track of prayer times", "Forgetting the Qur''an"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'recall_quiz', v_seq + 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Surat An-Nas asks for refuge from whispering that comes from which two groups?',
    '["Angels and humans", "The jinn and mankind", "Animals and plants", "Prophets and scholars"]'::jsonb, 1);
end $$;
