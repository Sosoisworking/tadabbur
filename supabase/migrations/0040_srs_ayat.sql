-- Extends the spaced-repetition system to schedule individual ayat
-- alongside vocab_items/grammar_points/letters, per user request
-- (second of two chosen "make each Surah easier to learn" directions
-- — line-by-line chunking, migration 0039, was the first). Granularity
-- decision (per-ayah vs per-surah, put to the user explicitly): each
-- of the new per-ayah reading_passage cards from migration 0039 is its
-- own SRS item, mirroring how vocab_card/letter_card already expose on
-- completion. This is the same fork-in-the-road that letters hit in
-- migration 0006 (added after the original schema only planned for
-- vocab_items/grammar_points) — same fix, same pattern.

alter table srs_items add column ayah_id bigint references ayat(id);

-- Dynamic lookup, not a hardcoded constraint name — 0006 already found
-- the original unnamed constraint had drifted from any guessable
-- naming convention, and 0006 itself named its replacement
-- srs_items_check, but this looks it up fresh rather than assuming
-- that name still holds today.
do $$
declare
  v_constraint_name text;
begin
  select conname into v_constraint_name
  from pg_constraint
  where conrelid = 'public.srs_items'::regclass
    and contype = 'c'
    and pg_get_constraintdef(oid) like '%num_nonnulls%';

  if v_constraint_name is not null then
    execute format('alter table srs_items drop constraint %I', v_constraint_name);
  end if;
end $$;

alter table srs_items add constraint srs_items_check
  check (num_nonnulls(vocab_item_id, grammar_point_id, letter_id, ayah_id) = 1);

create unique index srs_items_user_ayah_uq on srs_items(user_id, ayah_id) where ayah_id is not null;

-- No RLS change needed, same reasoning as 0006: srs_items already
-- restricts the client to SELECT on its own rows; writes go through
-- the srs-review Edge Function under the service role key.
