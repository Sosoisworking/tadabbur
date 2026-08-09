-- Phase 2 of the Prayer Guide adaptation (part 1 of 2): the Salah unit
-- itself. Split across two migrations for reviewability, given the
-- size — this one covers understanding Salah, its prerequisites, and
-- the complete first rak'ah (11 steps, matching the book's own
-- numbering exactly); part 2 (next migration) covers the second
-- rak'ah, Tashahhud, completing the prayer, and a closing quiz.
--
-- Reuses knowledge_card and prayer_step (both built in migration 0025
-- for the Wudu unit) — no new exercise types needed here.
--
-- Step 3 of the first rak'ah ("recite Surat Al-Fatiha") does NOT
-- re-type Al-Fatiha's 7 ayahs as prayer_step content — it's a short
-- instruction prayer_step immediately followed by a reading_passage
-- exercise reusing Al-Fatiha's existing ayat (ids 1-7, migration
-- 0002). Zero new data, and reading_passage's per-ayah translation
-- display is strictly better here than a flat instruction card would
-- be, since the learner already studied this exact text in the
-- Al-Fatiha unit.
--
-- All recited phrases here are standard, fixed liturgical wording
-- (takbir, tasbih, tashahhud phrases used identically by virtually
-- every praying Muslim) — not per-verse Quranic text needing API
-- sourcing the way Short Ayahs required.

insert into knowledge_points (code, category, title_en, explanation_short, explanation_full) values
  ('salah_definition', 'salah', 'What Is Salah?',
   'Salah is the second pillar of Islam — the formal, five-times-daily prayer that connects a Muslim directly to Allah.',
   'The word Salah comes from an Arabic root meaning connection — Salah is literally a Muslim''s direct link to their Creator. It''s the second pillar of Islam, the first priority after believing in Allah''s oneness and Muhammad''s prophethood, and it''s the very first thing a person will be asked about on the Day of Judgment: the Prophet (peace be upon him) said that if it is good, the rest of a person''s deeds will be good; if it is deficient, the rest will be deficient.'),
  ('salah_who_must_pray', 'salah', 'Who Must Pray',
   'Salah is obligatory on every sane adult Muslim — someone is considered an adult once they reach puberty.',
   'Prayer becomes obligatory the moment a person reaches puberty, marked by any one of four signs: wet dreams, pubic hair, menstruation (for girls), or simply reaching 15 lunar years of age — whichever comes first. Before that point a child isn''t yet required to pray, though building the habit early is encouraged.'),
  ('salah_daily_five', 'salah', 'The Five Daily Prayers',
   'Fajr (2 units), Dhuhr (4), Asr (4), Maghrib (3), and Isha (4) — each prayed within its own fixed window of time.',
   'The five obligatory prayers each have their own name, time window, and number of compulsory rak''ahs (units): Fajr, the dawn prayer, after dawn and before sunrise (2 units). Dhuhr, the noon prayer, once the sun begins to decline from its peak (4 units). Asr, the afternoon prayer, midway between noon and sunset (4 units). Maghrib, the sunset prayer, right after sunset (3 units). Isha, the night prayer, from nightfall until dawn, though earlier is preferred (4 units). It''s best to pray each one as soon as its window opens rather than delaying without a valid reason.'),
  ('salah_compulsory_sunnah', 'salah', 'Compulsory and Sunnah Prayers',
   'Alongside the compulsory rak''ahs, extra sunnah (recommended) rak''ahs are prayed before and/or after several prayers — rewarded if prayed, but not sinful to skip.',
   'Beyond the compulsory rak''ahs, the Prophet (peace be upon him) regularly prayed extra sunnah rak''ahs before and/or after several of the five prayers — highly recommended and richly rewarded, but not obligatory; skipping them isn''t a sin the way skipping a compulsory rak''ah is. One practical detail worth knowing early: in the first two rak''ahs of Fajr, Maghrib, and Isha specifically, the Qur''anic recitation is said aloud; every other rak''ah, in every prayer, is recited silently.'),
  ('salah_prerequisites_clothing', 'salah', 'Before You Begin: Clothing and Cleanliness',
   'A man must cover from navel to knees plus both shoulders; a woman must cover her whole body except her hands and face — and the body, clothes, and place of prayer must all be free of impurities.',
   'Before starting Salah, a few physical conditions must be met. Clothing: a man must cover the area between his navel and his knees, as well as both shoulders, in loose, non-transparent garments; a woman must cover her entire body except her hands and face, also in loose, non-transparent garments. Cleanliness: the body, the clothing being worn, and the place of prayer must all be free from impurities before starting.'),
  ('salah_prerequisites_state', 'salah', 'Before You Begin: Purity, Timing, and Direction',
   'Beyond clothing and cleanliness, three more conditions apply: being in a state of wudu, the prayer''s time having actually started, and facing the Qiblah (the direction of the Ka''bah in Makkah).',
   'Three more conditions round out the prerequisites for Salah. Purity: the Prophet (peace be upon him) said Allah does not accept prayer without purity (Muslim) — wudu must be intact. Timing: the prayer can only be performed once its specific time window has begun; Allah says in the Qur''an, "Verily, the prayer is enjoined on the believers at fixed times" (An-Nisa 4:103). Direction: wherever a Muslim is in the world, they face the Qiblah — the direction of the Ka''bah in Makkah — using a compass or app if needed. It''s also recommended to pray toward some kind of partition (a sutrah) when praying alone in an open area.');

insert into units (track_id, unit_type, title, sequence_order)
select id, 'thematic', 'Salah — The Prayer', 10 from tracks where code = 'quranic_arabic';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Understanding Salah', 1, 6 from units where title = 'Salah — The Prayer';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Before You Begin', 2, 4 from units where title = 'Salah — The Prayer';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'The First Rak''ah: Standing and Reciting', 3, 6 from units where title = 'Salah — The Prayer';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'The First Rak''ah: Bowing and Prostrating', 4, 8 from units where title = 'Salah — The Prayer';

do $$
declare
  v_understanding_id int;
  v_before_id int;
  v_standing_id int;
  v_bowing_id int;
  v_exercise_id int;
  v_kp record;
  v_seq int;
  v_fatiha1_id bigint;
  v_fatiha7_id bigint;
begin
  select l.id into v_understanding_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Salah — The Prayer' and l.title = 'Understanding Salah';
  select l.id into v_before_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Salah — The Prayer' and l.title = 'Before You Begin';
  select l.id into v_standing_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Salah — The Prayer' and l.title = 'The First Rak''ah: Standing and Reciting';
  select l.id into v_bowing_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Salah — The Prayer' and l.title = 'The First Rak''ah: Bowing and Prostrating';
  select id into v_fatiha1_id from ayat where surah_number = 1 and ayah_number = 1;
  select id into v_fatiha7_id from ayat where surah_number = 1 and ayah_number = 7;

  -- Understanding Salah: 4 knowledge cards, book order.
  v_seq := 0;
  for v_kp in
    select id, code from knowledge_points
    where code in ('salah_definition','salah_who_must_pray','salah_daily_five','salah_compulsory_sunnah')
    order by array_position(array['salah_definition','salah_who_must_pray','salah_daily_five','salah_compulsory_sunnah'], code)
  loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_understanding_id, 'knowledge_card', v_seq) returning id into v_exercise_id;
    insert into exercise_knowledge_card (exercise_id, knowledge_point_id) values (v_exercise_id, v_kp.id);
  end loop;

  -- Before You Begin: 2 knowledge cards.
  v_seq := 0;
  for v_kp in
    select id, code from knowledge_points
    where code in ('salah_prerequisites_clothing','salah_prerequisites_state')
    order by array_position(array['salah_prerequisites_clothing','salah_prerequisites_state'], code)
  loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_before_id, 'knowledge_card', v_seq) returning id into v_exercise_id;
    insert into exercise_knowledge_card (exercise_id, knowledge_point_id) values (v_exercise_id, v_kp.id);
  end loop;

  -- First Rak'ah, Standing and Reciting: steps 1-4.
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_standing_id, 'prayer_step', 1) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'In the standing position, raise both hands so your fingertips are in line with your shoulders or ears, palms facing outward. Then say:',
    'اللَّهُ أَكْبَرُ', 'Allaahu Akbar', 'Allah is Greatest');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_standing_id, 'prayer_step', 2) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'Place your hands on your chest, right hand over left. Then say:',
    'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ', 'A''oothu billaahi minash-shaytaanir-rajeem', 'I seek refuge with Allah from Satan the accursed');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_standing_id, 'prayer_step', 3) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en)
  values (v_exercise_id, 'Recite Surat Al-Fatiha — the same surah from the Al-Fatiha unit.');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_standing_id, 'reading_passage', 4) returning id into v_exercise_id;
  insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_fatiha1_id, v_fatiha7_id);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_standing_id, 'prayer_step', 5) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en)
  values (v_exercise_id, 'In the first two rak''ahs only, you may then recite another short surah from the Qur''an. (A dedicated lesson on short surahs for prayer is coming soon.)');

  -- First Rak'ah, Bowing and Prostrating: steps 5-11 (book numbering).
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_bowing_id, 'prayer_step', 1) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'Raise both hands again as in the opening takbir, then say:',
    'اللَّهُ أَكْبَرُ', 'Allaahu Akbar', 'Allah is Greatest');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_bowing_id, 'prayer_step', 2) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en, repeat_count)
  values (v_exercise_id, 'Bend into the bowing position (ruku''), back flat, hands resting on the knees. Say the following:',
    'سُبْحَانَ رَبِّيَ الْعَظِيمِ', 'Subhaana Rabbiyal ''Atheem', 'Glory be to my Lord the Supreme', 3);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_bowing_id, 'prayer_step', 3) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'Rise from the bowing position back to standing, saying:',
    'سَمِعَ اللَّهُ لِمَنْ حَمِدَهُ', 'Sami''-Allaahu liman hamidah', 'Allah listens to the one who praises Him');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_bowing_id, 'prayer_step', 4) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en)
  values (v_exercise_id, 'Once standing, with your hands at your sides, say:',
    'رَبَّنَا وَلَكَ الْحَمْدُ', 'Rabbanaa wa lakal hamd', 'Our Lord, and to You belongs all praise');

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_bowing_id, 'prayer_step', 5) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en, repeat_count)
  values (v_exercise_id, 'Say Allahu Akbar as you go down into prostration (sujood) — nose and forehead touching the ground, palms flat with fingers together, knees on the floor, toes upright. Once in position, say:',
    'سُبْحَانَ رَبِّيَ الْأَعْلَى', 'Subhaana Rabbiyal A''laa', 'Glory be to my Lord Most High', 3);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_bowing_id, 'prayer_step', 6) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en, repeat_count)
  values (v_exercise_id, 'Rise into a sitting position saying Allahu Akbar. Sit on your left thigh, left foot flat along the ground, right foot upright with toes facing the Qiblah, hands resting on the knees. Then say:',
    'رَبِّ اغْفِرْ لِي', 'Rabbighfir lee', 'Oh Allah, forgive me', 3);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_bowing_id, 'prayer_step', 7) returning id into v_exercise_id;
  insert into exercise_prayer_step (exercise_id, instruction_en, arabic_text, transliteration, translation_en, repeat_count)
  values (v_exercise_id, 'Go into prostration a second time the same way as before, saying Allahu Akbar, then repeat:',
    'سُبْحَانَ رَبِّيَ الْأَعْلَى', 'Subhaana Rabbiyal A''laa', 'Glory be to my Lord Most High', 3);
end $$;

insert into user_unit_progress (user_id, unit_id, status, started_at)
select u.id, (select id from units where title = 'Salah — The Prayer'), 'in_progress', now()
from users u
on conflict (user_id, unit_id) do nothing;
