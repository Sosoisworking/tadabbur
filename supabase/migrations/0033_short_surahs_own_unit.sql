-- Moves "Short Surahs for Prayer" out of Salah — The Prayer into its
-- own dedicated unit, per user request. The content (Al-Kawthar,
-- Al-Ikhlas, Al-Falaq, An-Nas as full reading_passage recitations) is
-- distinct enough from Salah's step-by-step procedure to stand on its
-- own — similar to how Al-Fatiha itself has its own unit rather than
-- being folded into whatever unit first mentions it.
--
-- New unit placed at sequence_order 11, right after Salah — The
-- Prayer rather than after Basic Verbs: it preserves the narrative
-- that motivated this content in the first place ("The First Rak'ah:
-- Standing and Reciting" step 4: "you may then recite another short
-- surah") — learn to pray (Wudu, Salah), then learn more surahs to
-- recite in that prayer. Basic Verbs stays the closing capstone unit;
-- moving it out of the way to 12 is a plain single-step update since
-- that slot is empty, no staging needed.
--
-- The lesson itself (id 56) is relocated via a plain unit_id/
-- sequence_order update, not deleted and recreated — same exercises,
-- same ids, so nothing about its content changes. Salah's remaining
-- lessons (ids 51-55) then shift down one position each to close the
-- gap left at position 4; done in ascending order specifically because
-- lesson 56 is moved OUT of the unit first, freeing position 4 before
-- lesson 51 needs it, then each subsequent move frees the next
-- position in turn — no unique(unit_id, sequence_order) collision at
-- any step, so no +1000 staging needed here (unlike migration 0032's
-- rotations, where multiple lessons swapped into slots still occupied
-- by each other).

update units set sequence_order = 12 where title = 'Basic Verbs';

insert into units (track_id, unit_type, title, sequence_order)
select id, 'thematic', 'Short Surahs', 11 from tracks where code = 'quranic_arabic';

update lessons set unit_id = (select id from units where title = 'Short Surahs'), sequence_order = 1
  where id = 56; -- Short Surahs for Prayer

update lessons set sequence_order = 4 where id = 51; -- The First Rak'ah: Bowing and Prostrating
update lessons set sequence_order = 5 where id = 52; -- The Second Rak'ah
update lessons set sequence_order = 6 where id = 53; -- Tashahhud — The Sitting Recitation
update lessons set sequence_order = 7 where id = 54; -- Completing the Prayer
update lessons set sequence_order = 8 where id = 55; -- Salah Quiz

insert into user_unit_progress (user_id, unit_id, status, started_at)
select u.id, (select id from units where title = 'Short Surahs'), 'in_progress', now()
from users u
on conflict (user_id, unit_id) do nothing;
