-- Splits "Short Surahs for Prayer" (one lesson covering all 4 surahs)
-- into 4 separate lessons, one per surah, per user request.
--
-- Does NOT delete and recreate lesson 56: it already has real
-- lesson_attempts rows (ids 73, 75, from live testing) referencing it
-- via a plain foreign key with no cascade — deleting it would either
-- violate that FK or silently destroy a real completion record.
-- Instead, lesson 56 is repurposed as the Al-Kawthar lesson (its
-- Al-Kawthar exercises stay, renumbered 1-3; the other 9 exercises
-- move out to 3 new lessons), which keeps its id and existing attempt
-- history intact and pointing at real content, not an empty shell.
--
-- Each new lesson keeps the same 3-exercise shape the combined lesson
-- already used per surah: a prayer_step instruction, the
-- reading_passage recitation, and that surah's comprehension question
-- — moved via plain lesson_id/sequence_order updates, not deleted and
-- reinserted, so nothing about the content itself changes.

update lessons set title = 'Al-Kawthar', estimated_minutes = 4 where id = 56;

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select unit_id, 'Al-Ikhlas', 2, 4 from lessons where id = 56;
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select unit_id, 'Al-Falaq', 3, 4 from lessons where id = 56;
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select unit_id, 'An-Nas', 4, 4 from lessons where id = 56;

-- Move the other 3 surahs' exercises out of lesson 56 FIRST — while
-- any of them (e.g. id 778, originally sequence_order 3) still sit in
-- lesson 56, they occupy positions the Al-Kawthar renumbering below
-- needs; moving them to their new lesson_id first frees those
-- positions before lesson 56 is touched, so no +1000 staging is
-- needed for the within-lesson-56 renumber that follows.

-- Al-Ikhlas
update exercises set lesson_id = (select id from lessons where title = 'Al-Ikhlas'), sequence_order = 1 where id = 778;
update exercises set lesson_id = (select id from lessons where title = 'Al-Ikhlas'), sequence_order = 2 where id = 779;
update exercises set lesson_id = (select id from lessons where title = 'Al-Ikhlas'), sequence_order = 3 where id = 785;

-- Al-Falaq
update exercises set lesson_id = (select id from lessons where title = 'Al-Falaq'), sequence_order = 1 where id = 780;
update exercises set lesson_id = (select id from lessons where title = 'Al-Falaq'), sequence_order = 2 where id = 781;
update exercises set lesson_id = (select id from lessons where title = 'Al-Falaq'), sequence_order = 3 where id = 786;

-- An-Nas
update exercises set lesson_id = (select id from lessons where title = 'An-Nas'), sequence_order = 1 where id = 782;
update exercises set lesson_id = (select id from lessons where title = 'An-Nas'), sequence_order = 2 where id = 783;
update exercises set lesson_id = (select id from lessons where title = 'An-Nas'), sequence_order = 3 where id = 787;

-- Al-Kawthar (lesson 56): now safe to renumber its own 3 remaining
-- exercises (original sequence_order 1, 2, 9 — no collision, since
-- everything else has just been moved out of this lesson_id).
update exercises set sequence_order = 1 where id = 776; -- Recite Surat Al-Kawthar (prayer_step)
update exercises set sequence_order = 2 where id = 777; -- reading_passage
update exercises set sequence_order = 3 where id = 784; -- comprehension quiz
