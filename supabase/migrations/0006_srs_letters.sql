-- Extends the spaced-repetition system to schedule alphabet letters
-- alongside vocab_items/grammar_points — the original schema only
-- planned for the latter two, but letters (added after the initial
-- schema) are exactly the kind of content that benefits most from
-- spaced review (recognition drilling).

alter table srs_items add column letter_id int references letters(id);

-- Found dynamically rather than guessing Postgres' auto-generated name
-- for the original table-level CHECK constraint — got this wrong once
-- already in migration 0003 by assuming a naming convention that turned
-- out not to apply to unnamed constraints.
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
  check (num_nonnulls(vocab_item_id, grammar_point_id, letter_id) = 1);

create unique index srs_items_user_letter_uq on srs_items(user_id, letter_id) where letter_id is not null;

-- No RLS change needed: srs_items already restricts the client to
-- SELECT on its own rows (docs/api-design.md §1) — writes go through the
-- srs-review Edge Function, which uses the service role key and verifies
-- the caller's JWT itself rather than trusting a client-supplied user_id.
