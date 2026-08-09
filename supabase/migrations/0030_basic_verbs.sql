-- New unit: Basic Verbs — the biggest deferred piece of the
-- comprehension track (flagged when Core Vocabulary & Grammar shipped:
-- "verb conjugation basics, still the biggest deferred piece"). Arabic
-- verb morphology is a genuinely large topic; this is a deliberately
-- scoped FIRST pass — recognizing the two tenses and their most common
-- person markers — not the full conjugation paradigm (dual forms,
-- every person/gender/number combination, weak/hollow roots, derived
-- verb forms). That fuller treatment is future work if this proves
-- valuable.
--
-- category is 'sarf' throughout (morphology — word formation/
-- conjugation — same category already used for the possessive
-- suffixes in migration 0029), not 'nahw' (syntax).
--
-- Three of six grammar cards link real ayahs already in the ayat
-- table rather than inventing example verbs: خَلَقَ from Al-Falaq
-- (id 30), and نَعْبُدُ/نَسْتَعِينُ from Al-Fatiha (id 5) plus يُوَسْوِسُ
-- from An-Nas (id 38) for the present-tense prefix examples — all
-- fetched from the live DB before writing this migration to guarantee
-- byte-for-byte matching diacritization with what's already taught,
-- rather than retyped from memory.
--
-- Three lessons (Introduction, Past Tense, Present Tense), each with
-- 2 concept+quiz pairs — same interleaved concept+quiz pattern as
-- every other grammar_explanation lesson in this track, and matching
-- Reading Marks & Rules' precedent of splitting genuinely distinct
-- sub-topics into separate lessons rather than one long list.

insert into grammar_points (code, category, title_en, explanation_short, explanation_full) values
  ('verb_roots', 'sarf', 'Verbs Come From Three-Letter Roots',
   'Almost every Arabic verb is built from a three-letter root that carries the core meaning — the same root system you''ve already seen used for nouns.',
   'You''ve already met root letters on vocabulary words like رَسُول (root ر-س-ل) and كِتَاب (root ك-ت-ب) — the same root system builds verbs too. The root ك-ت-ب ("writing") is the base for كَتَبَ ("he wrote"), يَكْتُبُ ("he writes"), and كِتَاب ("a book") — three different words sharing one root and one core meaning. Recognizing a verb''s three root letters, even buried inside prefixes and suffixes, is one of the most valuable skills for building real Quranic vocabulary: once you can strip away the grammar, you can look up the root.'),
  ('verb_two_tenses', 'sarf', 'Two Tenses: Past and Present',
   'Arabic verbs have two main tenses: الْمَاضِي (past, "he did") and الْمُضَارِع (present, "he does/is doing") — each built by attaching different letters to the same three-letter root.',
   'Unlike English, which mostly builds tense with helper words ("did," "is doing"), Arabic changes the verb itself. الْمَاضِي (al-maadi, the past tense) attaches suffixes to the root: كَتَبَ ("he wrote"). الْمُضَارِع (al-mudaari'', the present tense) attaches prefixes instead: يَكْتُبُ ("he writes" or "he is writing"). Learning to recognize these two patterns — suffixes for past, prefixes for present — unlocks a huge amount of Quranic text, since verbs appear constantly.'),
  ('past_tense_he', 'sarf', 'Past Tense: He/It Did',
   'The base form of a past-tense verb (no prefix or suffix) means "he/it did" — e.g. خَلَقَ, "He created."',
   'The simplest past-tense form — no prefix, no suffix — refers to "he" or "it" as the one who did the action. This is also the form used as a verb''s "dictionary entry" when you look one up. You''ve already read this exact form in Surat Al-Falaq: مِن شَرِّ مَا خَلَقَ, "from the evil of that which He created" — خَلَقَ (khalaqa) is the root خ-ل-ق with no extra letters, meaning simply "He created."'),
  ('past_tense_suffixes', 'sarf', 'Past Tense: She, You, I, We, They',
   'Adding a suffix to the base past-tense form changes who did the action: ـَتْ (she), ـْتَ (you, masc.), ـْتُ (I), ـْنَا (we), ـُوا (they).',
   'Once you recognize the base "he did" form, everything else is that same form plus a suffix. خَلَقَ ("he created") becomes خَلَقَتْ ("she created"), خَلَقْتَ ("you created," to a man), خَلَقْتُ ("I created"), خَلَقْنَا ("we created"), خَلَقُوا ("they created"). The suffix does all the work — the root خ-ل-ق never changes.'),
  ('present_tense_prefixes', 'sarf', 'Present Tense: The Four Prefix Letters',
   'Every present-tense verb starts with one of four prefix letters: ي (he/it/they), ت (she/you), أ (I), ن (we) — often remembered by the word أَنَيْتُ (anaytu).',
   'Present-tense verbs are built by attaching a prefix letter to the root instead of a suffix. The four prefixes are ي (ya-, "he/it," also used for "they"), ت (ta-, "she" or "you"), أ (a-, "I"), and ن (na-, "we") — Arabic teachers often group them into the memorable word أَنَيْتُ ("anaytu"). Spotting one of these four letters at the very start of a word is often the fastest way to recognize you''re looking at a present-tense verb.'),
  ('present_tense_examples', 'sarf', 'Present Tense in Al-Fatiha and An-Nas',
   'نَعْبُدُ ("we worship") and نَسْتَعِينُ ("we seek help") both open with ن — "we." يُوَسْوِسُ ("he whispers") opens with ي — "he."',
   'You''ve already read present-tense verbs without necessarily noticing the pattern. In Al-Fatiha: إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ, "You alone we worship and You alone we ask for help" — both نَعْبُدُ and نَسْتَعِينُ start with ن, "we." In Surat An-Nas: الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ, "who whispers into the breasts of mankind" — يُوَسْوِسُ starts with ي, "he."');

insert into units (track_id, unit_type, title, sequence_order)
select id, 'thematic', 'Basic Verbs', 11 from tracks where code = 'quranic_arabic';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'How Arabic Verbs Work', 1, 6 from units where title = 'Basic Verbs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'The Past Tense: الْمَاضِي', 2, 6 from units where title = 'Basic Verbs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'The Present Tense: الْمُضَارِع', 3, 6 from units where title = 'Basic Verbs';

do $$
declare
  v_intro_id int;
  v_past_id int;
  v_present_id int;
  v_exercise_id int;
  v_roots_id int;
  v_tenses_id int;
  v_past_he_id int;
  v_past_suffixes_id int;
  v_present_prefixes_id int;
  v_present_examples_id int;
  v_falaq2_id bigint;
  v_nas5_id bigint;
begin
  select l.id into v_intro_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Basic Verbs' and l.title = 'How Arabic Verbs Work';
  select l.id into v_past_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Basic Verbs' and l.title = 'The Past Tense: الْمَاضِي';
  select l.id into v_present_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Basic Verbs' and l.title = 'The Present Tense: الْمُضَارِع';
  select id into v_roots_id from grammar_points where code = 'verb_roots';
  select id into v_tenses_id from grammar_points where code = 'verb_two_tenses';
  select id into v_past_he_id from grammar_points where code = 'past_tense_he';
  select id into v_past_suffixes_id from grammar_points where code = 'past_tense_suffixes';
  select id into v_present_prefixes_id from grammar_points where code = 'present_tense_prefixes';
  select id into v_present_examples_id from grammar_points where code = 'present_tense_examples';
  select id into v_falaq2_id from ayat where surah_number = 113 and ayah_number = 2;
  select id into v_nas5_id from ayat where surah_number = 114 and ayah_number = 5;

  -- How Arabic Verbs Work
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_intro_id, 'grammar_explanation', 1) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_roots_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_intro_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What do the words كَتَبَ, يَكْتُبُ, and كِتَاب have in common?',
    '["They''re all the same word", "They share the same three-letter root", "They''re all verbs", "They''re all nouns"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_intro_id, 'grammar_explanation', 3) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_tenses_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_intro_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What does الْمُضَارِع mean?',
    '["Past tense", "Present tense", "A root letter", "A noun"]'::jsonb, 1);

  -- The Past Tense
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_past_id, 'grammar_explanation', 1) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_past_he_id, v_falaq2_id);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_past_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What does خَلَقَ mean?',
    '["He creates (ongoing)", "He created", "She created", "They created"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_past_id, 'grammar_explanation', 3) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_past_suffixes_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_past_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which suffix makes a past-tense verb mean "I did"?',
    '["ـَتْ", "ـُوا", "ـْتُ", "ـْنَا"]'::jsonb, 2);

  -- The Present Tense
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_present_id, 'grammar_explanation', 1) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_present_prefixes_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_present_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which prefix letter means "I" on a present-tense verb?',
    '["ي", "ت", "أ", "ن"]'::jsonb, 2);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_present_id, 'grammar_explanation', 3) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_present_examples_id, v_nas5_id);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_present_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'In نَعْبُدُ, what does the ن prefix tell you?',
    '["He/it", "She/you", "I", "We"]'::jsonb, 3);
end $$;

insert into user_unit_progress (user_id, unit_id, status, started_at)
select u.id, (select id from units where title = 'Basic Verbs'), 'in_progress', now()
from users u
on conflict (user_id, unit_id) do nothing;
