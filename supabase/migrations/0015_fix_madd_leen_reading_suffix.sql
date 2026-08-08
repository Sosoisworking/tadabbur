-- Fixes a real bug in migration 0014: the 5 new diacritics (Alif/Waw/Yaa
-- Madd, Waw/Yaa Leen) never had reading_suffix set, so they silently
-- took the column's default '' — every quiz question's "correct" answer
-- collapsed to the bare consonant (e.g. "A" instead of "Aa" for Alif
-- Madd) instead of the actual long-vowel/diphthong reading, and the
-- grid's pronunciation labels in the Madd/Leen intro lessons were
-- wrong in the same way. Caught by spot-checking sample question
-- content against the live database after pushing 0014 — exactly the
-- verification step that's supposed to catch this class of mistake,
-- this time it actually did.

update diacritics set reading_suffix = 'aa' where name_en = 'Alif Madd';
update diacritics set reading_suffix = 'oo' where name_en = 'Waw Madd';
update diacritics set reading_suffix = 'ee' where name_en = 'Yaa Madd';
update diacritics set reading_suffix = 'aw' where name_en = 'Waw Leen';
update diacritics set reading_suffix = 'ay' where name_en = 'Yaa Leen';

-- Regenerate the affected quiz options with the corrected suffix.
-- Deleting and reinserting rather than UPDATE-ing options/correct_index
-- in place — same shape as the original generation loop, and simpler
-- than trying to surgically patch already-shuffled option arrays
-- (the app shuffles options client-side at fetch time, so nothing here
-- needs to preserve a specific stored order).
do $$
declare
  v_unit_id int;
  v_diacritic record;
  v_quiz_lesson_id int;
  v_letter record;
  v_options jsonb;
  v_exercise_id int;
  v_seq int;
begin
  select id into v_unit_id from units where title = 'Long Vowels & Diphthongs (Madd & Leen)';

  for v_diacritic in
    select id, name_en, mark_unicode, reading_suffix
    from diacritics
    where name_en in ('Alif Madd', 'Waw Madd', 'Yaa Madd', 'Waw Leen', 'Yaa Leen')
  loop
    select id into v_quiz_lesson_id from lessons where unit_id = v_unit_id and title = v_diacritic.name_en || ' Quiz';

    delete from exercise_attempts where exercise_id in (select id from exercises where lesson_id = v_quiz_lesson_id);
    delete from exercise_recall_quiz where exercise_id in (select id from exercises where lesson_id = v_quiz_lesson_id);
    delete from exercises where lesson_id = v_quiz_lesson_id;

    v_seq := 0;
    for v_letter in select id, isolated_form, base_consonant from letters order by sequence_order loop
      v_seq := v_seq + 1;
      v_options := jsonb_build_array(
        v_letter.base_consonant || v_diacritic.reading_suffix,
        v_letter.base_consonant || 'a',
        v_letter.base_consonant || 'i',
        v_letter.base_consonant || 'u'
      );
      insert into exercises (lesson_id, exercise_type, sequence_order) values (v_quiz_lesson_id, 'recall_quiz', v_seq) returning id into v_exercise_id;
      insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_letter_id)
      values (v_exercise_id, 'How do you read ' || v_letter.isolated_form || v_diacritic.mark_unicode || ' ?', v_options, 0, v_letter.id);
    end loop;
  end loop;
end $$;
