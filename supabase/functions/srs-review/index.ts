// SRS scheduling — docs/api-design.md §2 (POST /functions/v1/srs/review)
// and docs/feature-specs.md §3. Runs server-side deliberately: the SM-2
// math can't be trusted to the client, or a modified app could always
// answer "easy" to dodge review load. Handles two actions:
//   - "expose": idempotently create an srs_items row on first exposure
//     to a vocab item / grammar point / letter (docs/database-schema.md
//     "every vocab_item and grammar_point a user is exposed to... gets a
//     corresponding srs_items row on first exposure").
//   - "review": grade a review and compute the next SM-2 schedule.
//
// Every request is scoped to the caller's own identity, taken from their
// verified JWT — never from a user_id in the request body.

import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return json({ error: "missing_auth" }, 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;

  // Verifies who's calling — this client only ever calls .auth.getUser(),
  // never touches a table with it.
  const callerClient = createClient(
    supabaseUrl,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader } } },
  );
  const { data: { user }, error: authError } = await callerClient.auth
    .getUser();
  if (authError || !user) return json({ error: "invalid_auth" }, 401);

  // Service-role client for the actual writes — bypasses RLS (srs_items
  // grants the client SELECT only, per docs/api-design.md §1), but every
  // query below is explicitly filtered to `user.id` from the verified
  // JWT above, so this never lets the caller touch another user's data.
  const db = createClient(
    supabaseUrl,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  if (body.action === "expose") return await handleExpose(db, user.id, body);
  if (body.action === "review") return await handleReview(db, user.id, body);
  return json({ error: "unknown_action" }, 400);
});

async function handleExpose(
  // deno-lint-ignore no-explicit-any
  db: any,
  userId: string,
  body: Record<string, unknown>,
): Promise<Response> {
  const vocabItemId = body.vocab_item_id as number | undefined;
  const grammarPointId = body.grammar_point_id as number | undefined;
  const letterId = body.letter_id as number | undefined;

  const provided = [vocabItemId, grammarPointId, letterId].filter(
    (v) => v != null,
  );
  if (provided.length !== 1) {
    return json({ error: "exactly_one_item_required" }, 400);
  }

  const column = vocabItemId != null
    ? "vocab_item_id"
    : grammarPointId != null
    ? "grammar_point_id"
    : "letter_id";
  const value = vocabItemId ?? grammarPointId ?? letterId;

  const { data: existing } = await db
    .from("srs_items")
    .select("id")
    .eq("user_id", userId)
    .eq(column, value)
    .maybeSingle();

  if (existing) return json({ srs_item_id: existing.id, created: false });

  const { data: inserted, error } = await db
    .from("srs_items")
    .insert({ user_id: userId, [column]: value })
    .select("id")
    .single();

  if (error) return json({ error: "insert_failed", message: error.message }, 500);
  return json({ srs_item_id: inserted.id, created: true });
}

async function handleReview(
  // deno-lint-ignore no-explicit-any
  db: any,
  userId: string,
  body: Record<string, unknown>,
): Promise<Response> {
  const srsItemId = body.srs_item_id as number | undefined;
  const qualityRating = body.quality_rating as number | undefined;
  const responseTimeMs = body.response_time_ms as number | undefined;

  if (
    typeof srsItemId !== "number" ||
    typeof qualityRating !== "number" ||
    qualityRating < 0 ||
    qualityRating > 5
  ) {
    return json({ error: "invalid_request" }, 400);
  }

  const { data: item, error: fetchError } = await db
    .from("srs_items")
    .select("ease_factor, interval_days, repetitions")
    .eq("id", srsItemId)
    .eq("user_id", userId) // ownership check — can't review someone else's item
    .maybeSingle();

  if (fetchError || !item) return json({ error: "not_found" }, 404);

  // SM-2 — docs/feature-specs.md §3, kept identical to that spec's
  // pseudocode so the two never drift silently apart.
  let easeFactor = item.ease_factor as number;
  let intervalDays = item.interval_days as number;
  let repetitions = item.repetitions as number;
  const q = qualityRating;

  if (q < 3) {
    repetitions = 0;
    intervalDays = 1;
  } else {
    if (repetitions === 0) intervalDays = 1;
    else if (repetitions === 1) intervalDays = 6;
    else intervalDays = Math.round(intervalDays * easeFactor);
    repetitions += 1;
  }
  easeFactor = Math.max(
    1.3,
    easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02)),
  );

  const dueAt = new Date(Date.now() + intervalDays * 24 * 60 * 60 * 1000)
    .toISOString();
  const now = new Date().toISOString();

  const { error: updateError } = await db
    .from("srs_items")
    .update({
      ease_factor: easeFactor,
      interval_days: intervalDays,
      repetitions,
      due_at: dueAt,
      last_reviewed_at: now,
    })
    .eq("id", srsItemId);

  if (updateError) {
    return json({ error: "update_failed", message: updateError.message }, 500);
  }

  await db.from("srs_review_log").insert({
    srs_item_id: srsItemId,
    quality_rating: qualityRating,
    response_time_ms: responseTimeMs ?? null,
  });

  return json({
    srs_item_id: srsItemId,
    ease_factor: easeFactor,
    interval_days: intervalDays,
    repetitions,
    due_at: dueAt,
  });
}
