-- Splits every Short Surahs lesson longer than 15 ayahs into roughly
-- equal parts, per user request to make the app "easier to learn
-- from." Data-driven, not a guess: lesson_attempts showed 0/8
-- completions on lessons with 20+ exercises, vs. 45% on 10-19 and 22%
-- on 1-9 — completion falls off a cliff exactly where these lessons
-- sit (Ash-Shams at 15 ayahs / 17 exercises is the largest lesson
-- that stays intact; everything above it gets split).
--
-- 15 ayahs/part keeps every resulting lesson at or under 17 exercises
-- (prayer_step + up to 15 ayah cards + 1 recap), inside the
-- best-performing size band. Parts are split as evenly as possible
-- (ceil(total/15) parts, remainder ayahs distributed to the first few
-- parts) rather than always maxing out the first part and leaving a
-- small tail.
--
-- Design, since this is new structure not used elsewhere in the app
-- yet:
--   - Part 1 REUSES the original lesson's id (renamed "<Surah> — Part
--     N", matching the em-dash subtitle style already used for unit
--     names like "Al-Fatiha — The Opening"). Parts 2+ are new lesson
--     rows. This mirrors migration 0035's repurpose-rather-than-
--     recreate approach for the same reason: don't manufacture a
--     reason to lose a stable id.
--   - Every part gets its own prayer_step + per-ayah reading_passage
--     cards, same shape as any other lesson in the unit.
--   - Every part's closing recap covers just that part's own ayah
--     range, EXCEPT the last part, whose recap covers the entire
--     surah — so finishing a split surah still ends with the "recite
--     the whole thing" moment every other lesson in the unit has,
--     not just a recap of the final fragment.
--   - A live check before writing this migration confirmed zero
--     lesson_attempts and zero exercise_attempts on any of the
--     lessons this touches (all real attempt history in the unit
--     sits on the short, unsplit lessons at the front) — so existing
--     exercises for split lessons are deleted and rebuilt rather than
--     staged/moved, which would be needless complexity with nothing
--     to preserve.
--   - Nothing is hardcoded per-surah: each lesson's surah_number and
--     total ayah count are read from its own existing exercises/ayat
--     before anything is touched, and the split point math runs the
--     same for every lesson. A lesson with <=15 ayahs computes to
--     exactly 1 "part" and is left completely untouched.
--
-- sequence_order for the whole unit is recomputed at the end from a
-- pre-migration snapshot (every lesson's original position) combined
-- with each part's number, via the standard collision-safe pattern
-- for this project: stage everything to a high offset first, then
-- assign final consecutive values in one pass.

do $$
declare
  v_unit_id int;
  v_lesson record;
  v_surah_number smallint;
  v_total_ayahs int;
  v_num_parts int;
  v_base_size int;
  v_remainder int;
  v_part int;
  v_part_size int;
  v_part_start_ayah smallint;
  v_part_end_ayah smallint;
  v_running_ayah smallint;
  v_part_lesson_id int;
  v_exercise_id int;
  v_ayah record;
  v_start_id bigint;
  v_end_id bigint;
  v_seq int;
  v_full_start_id bigint;
  v_full_end_id bigint;
begin
  select id into v_unit_id from units where title = 'Short Surahs';

  create temporary table orig_order as
    select id, sequence_order as orig_seq, estimated_minutes as orig_minutes, title as orig_title
    from lessons where unit_id = v_unit_id;

  create temporary table split_map (
    lesson_id int primary key,
    base_lesson_id int not null,
    part_number int not null
  );

  -- Stage every lesson in the unit out of the way so no intermediate
  -- insert/renumber step in this block can collide with
  -- unique(unit_id, sequence_order).
  update lessons set sequence_order = sequence_order + 100000 where unit_id = v_unit_id;

  for v_lesson in select id, orig_title from orig_order order by orig_seq loop
    -- Derive this lesson's surah_number/total ayah count from its own
    -- existing content rather than any hardcoded list.
    select a.surah_number into v_surah_number
      from exercises e
      join exercise_reading_passage erp on erp.exercise_id = e.id
      join ayat a on a.id = erp.start_ayah_id
      where e.lesson_id = v_lesson.id
      limit 1;

    select count(*) into v_total_ayahs from ayat where surah_number = v_surah_number;

    v_num_parts := ceil(v_total_ayahs::numeric / 15);

    if v_num_parts <= 1 then
      continue; -- already within the target size, leave entirely untouched
    end if;

    v_base_size := v_total_ayahs / v_num_parts;
    v_remainder := v_total_ayahs % v_num_parts;

    select id into v_full_start_id from ayat where surah_number = v_surah_number and ayah_number = 1;
    select id into v_full_end_id from ayat where surah_number = v_surah_number and ayah_number = v_total_ayahs;

    -- Nothing here has attempt history (checked live before writing
    -- this migration) — safe to delete and rebuild outright.
    delete from exercise_prayer_step where exercise_id in (select id from exercises where lesson_id = v_lesson.id);
    delete from exercise_reading_passage where exercise_id in (select id from exercises where lesson_id = v_lesson.id);
    delete from exercises where lesson_id = v_lesson.id;

    v_running_ayah := 1;
    for v_part in 1..v_num_parts loop
      v_part_size := v_base_size + (case when v_part <= v_remainder then 1 else 0 end);
      v_part_start_ayah := v_running_ayah;
      v_part_end_ayah := v_running_ayah + v_part_size - 1;
      v_running_ayah := v_part_end_ayah + 1;

      if v_part = 1 then
        v_part_lesson_id := v_lesson.id;
        update lessons set
          title = v_lesson.orig_title || ' — Part ' || v_part,
          estimated_minutes = greatest(1, round((select orig_minutes from orig_order where id = v_lesson.id) * v_part_size::numeric / v_total_ayahs))
        where id = v_part_lesson_id;
      else
        insert into lessons (unit_id, title, sequence_order, estimated_minutes)
        values (
          v_unit_id,
          v_lesson.orig_title || ' — Part ' || v_part,
          900000 + v_lesson.id * 10 + v_part, -- placeholder, overwritten in the final renumber pass below
          greatest(1, round((select orig_minutes from orig_order where id = v_lesson.id) * v_part_size::numeric / v_total_ayahs))
        )
        returning id into v_part_lesson_id;
      end if;

      insert into split_map (lesson_id, base_lesson_id, part_number) values (v_part_lesson_id, v_lesson.id, v_part);

      insert into exercises (lesson_id, exercise_type, sequence_order) values (v_part_lesson_id, 'prayer_step', 1) returning id into v_exercise_id;
      insert into exercise_prayer_step (exercise_id, instruction_en)
        values (v_exercise_id, 'Recite Surat ' || v_lesson.orig_title || ' (Part ' || v_part || ' of ' || v_num_parts || '):');

      v_seq := 1;
      for v_ayah in
        select id from ayat where surah_number = v_surah_number
          and ayah_number between v_part_start_ayah and v_part_end_ayah
        order by ayah_number
      loop
        v_seq := v_seq + 1;
        insert into exercises (lesson_id, exercise_type, sequence_order) values (v_part_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
        insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_ayah.id, v_ayah.id);
      end loop;

      v_seq := v_seq + 1;
      if v_part = v_num_parts then
        -- Final part: recap the whole surah, not just this fragment.
        insert into exercises (lesson_id, exercise_type, sequence_order) values (v_part_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
        insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_full_start_id, v_full_end_id);
      else
        select id into v_start_id from ayat where surah_number = v_surah_number and ayah_number = v_part_start_ayah;
        select id into v_end_id from ayat where surah_number = v_surah_number and ayah_number = v_part_end_ayah;
        insert into exercises (lesson_id, exercise_type, sequence_order) values (v_part_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
        insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_start_id, v_end_id);
      end if;
    end loop;
  end loop;

  -- Final renumber: sort_key = original position * 100 + part number
  -- (0 for lessons never split), so parts land consecutively right
  -- where their original lesson used to sit.
  with ranked as (
    select
      l.id,
      (coalesce(oo_self.orig_seq, oo_base.orig_seq) * 100 + coalesce(sm.part_number, 0)) as sort_key
    from lessons l
    left join split_map sm on sm.lesson_id = l.id
    left join orig_order oo_self on oo_self.id = l.id
    left join orig_order oo_base on oo_base.id = sm.base_lesson_id
    where l.unit_id = v_unit_id
  ),
  final_order as (
    select id, row_number() over (order by sort_key) as rn from ranked
  )
  update lessons set sequence_order = final_order.rn
  from final_order
  where lessons.id = final_order.id;

  drop table orig_order;
  drop table split_map;
end $$;
