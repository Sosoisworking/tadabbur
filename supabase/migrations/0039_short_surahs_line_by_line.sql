-- Restructures every lesson in the "Short Surahs" unit (16 lessons)
-- from "show the whole surah in one reading_passage block" into
-- line-by-line learning: one reading_passage card per ayah, then the
-- existing full-surah card repositioned as a closing "put it all
-- together" recap, then the quiz. Per user request (first of two
-- chosen directions — spaced-repetition review integration is a
-- separate, larger follow-up).
--
-- Uses only the existing reading_passage exercise type (already
-- supports a single-ayah range via start_ayah_id = end_ayah_id, the
-- same mechanism used for Al-Fatiha's recitation step in the Salah
-- unit) — no schema change, no new exercise type, no new Arabic/
-- translation/transliteration content to verify, since every ayah
-- referenced here is already-verified data in the ayat table. This is
-- pure re-slicing of existing content, not new scripture.
--
-- Deliberately does NOT delete and recreate the existing reading_passage
-- or recall_quiz exercises: a live check before writing this migration
-- found 8 exercises across these 16 lessons already have real
-- exercise_attempts rows (from testing). Instead, the existing
-- full-surah reading_passage is repositioned (not deleted) to become
-- the closing recap card, and the existing quiz repositioned after
-- it — both keep their ids and attempt history. Only the N new
-- per-ayah cards are freshly inserted.
--
-- Written as one dynamic loop over every lesson in the unit rather
-- than 16 sets of hardcoded per-surah statements: each lesson's own
-- existing reading_passage row already encodes its surah_number and
-- ayah range, so nothing needs to be hardcoded or looked up from
-- memory — less error-prone than retyping 16 surahs' ayah counts by
-- hand. Existing rows are staged through a temporary sequence_order
-- (+1000) first, standard collision-safe pattern for this project,
-- before the new per-ayah cards claim positions 2..N+1 and the
-- existing two rows take their final N+2/N+3 slots.

do $$
declare
  v_lesson record;
  v_old_passage_id int;
  v_old_quiz_id int;
  v_start_ayah_id bigint;
  v_end_ayah_id bigint;
  v_surah_number smallint;
  v_start_ayah_number smallint;
  v_end_ayah_number smallint;
  v_ayah record;
  v_seq int;
  v_new_exercise_id int;
  v_short_surahs_unit_id int;
begin
  select id into v_short_surahs_unit_id from units where title = 'Short Surahs';

  for v_lesson in
    select l.id as lesson_id from lessons l where l.unit_id = v_short_surahs_unit_id
  loop
    select e.id, erp.start_ayah_id, erp.end_ayah_id
      into v_old_passage_id, v_start_ayah_id, v_end_ayah_id
      from exercises e join exercise_reading_passage erp on erp.exercise_id = e.id
      where e.lesson_id = v_lesson.lesson_id;

    select e.id into v_old_quiz_id
      from exercises e where e.lesson_id = v_lesson.lesson_id and e.exercise_type = 'recall_quiz';

    select surah_number, ayah_number into v_surah_number, v_start_ayah_number from ayat where id = v_start_ayah_id;
    select ayah_number into v_end_ayah_number from ayat where id = v_end_ayah_id;

    -- Stage the two existing exercises out of the way of the new
    -- per-ayah cards before touching anything.
    update exercises set sequence_order = sequence_order + 1000 where id in (v_old_passage_id, v_old_quiz_id);

    v_seq := 1; -- position 1 is the existing prayer_step, untouched
    for v_ayah in
      select id from ayat where surah_number = v_surah_number
        and ayah_number between v_start_ayah_number and v_end_ayah_number
      order by ayah_number
    loop
      v_seq := v_seq + 1;
      insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson.lesson_id, 'reading_passage', v_seq) returning id into v_new_exercise_id;
      insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_new_exercise_id, v_ayah.id, v_ayah.id);
    end loop;

    -- Existing full-surah reading_passage becomes the closing recap
    -- card; existing quiz stays last.
    v_seq := v_seq + 1;
    update exercises set sequence_order = v_seq where id = v_old_passage_id;
    v_seq := v_seq + 1;
    update exercises set sequence_order = v_seq where id = v_old_quiz_id;
  end loop;
end $$;
