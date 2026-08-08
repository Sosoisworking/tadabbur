-- First vocabulary/grammar unit — the start of the "comprehension" phase
-- of this track, distinct from every prior unit (0001-0021), which was
-- entirely about learning to READ (script, vowel marks, tajweed
-- basics). Script literacy is now essentially complete; almost no
-- general vocabulary or grammar has been taught yet (only Al-Fatiha's
-- own 6 words). This is original curriculum design, not book
-- adaptation — there's no Qaida-book page to transcribe from, so the
-- word list itself needed sourcing and verification.
--
-- Word selection: the 12 particles + 12 nouns below are drawn from the
-- Quranic Arabic Corpus's lemma frequency list (corpus.quran.com/lemmas.jsp),
-- an academic morphological resource — not guessed from memory or
-- picked arbitrarily. They're the highest-frequency, highest
-- comprehension-value words available after excluding: proper nouns
-- already taught (الله), words already taught as vocab (رَبّ — reused
-- below via its existing vocab_item id rather than duplicated), and
-- pure grammatical-relation words better taught as grammar points than
-- flashcards (الَّذِي، ذَٰلِكَ، هَٰذَا — see the grammar lesson).
--
-- root_letters is populated only for the noun lesson (content words
-- genuinely have roots worth surfacing) and left null throughout the
-- particle lesson — Arabic particles are mabniyy (indeclinable), not
-- derived from a triliteral root the way nouns/verbs are, so a root
-- there would be fabricated, not simplified. wazn_pattern is left null
-- for every new row here (unlike Al-Fatiha's vocab_items) — several of
-- these nouns have genuinely contested classical morphological
-- analyses (e.g. آيَة، سَمَاء), and getting that wrong is a worse
-- failure mode than just not claiming it.
--
-- Structure follows the "teach, then comprehensive separate quiz"
-- pattern established for the Alphabet/Vowel Marks units (not
-- interleaved single-item quizzes) for the two vocab lessons, but the
-- grammar lesson interleaves concept+quiz directly per exercise,
-- matching how every grammar_explanation lesson so far (Word Allah,
-- Completion of an Ayah) has worked — few enough concepts that
-- splitting into a separate quiz lesson would be overkill.

insert into vocab_items (arabic_text, transliteration, root_letters, wazn_pattern, meaning_en, frequency_rank, audio_url) values
  ('مِن', 'min', null, null, 'from, of', 1, 'placeholder/audio-not-yet-recorded.mp3'),
  ('فِي', 'fi', null, null, 'in, within', 3, 'placeholder/audio-not-yet-recorded.mp3'),
  ('عَلَى', 'ala', null, null, 'on, upon, against', 5, 'placeholder/audio-not-yet-recorded.mp3'),
  ('إِلَى', 'ila', null, null, 'to, toward', 10, 'placeholder/audio-not-yet-recorded.mp3'),
  ('عَن', 'an', null, null, 'about, away from', 17, 'placeholder/audio-not-yet-recorded.mp3'),
  ('لَا', 'la', null, null, 'no, not', 7, 'placeholder/audio-not-yet-recorded.mp3'),
  ('مَا', 'ma', null, null, 'what, that which — also used as "not"', 8, 'placeholder/audio-not-yet-recorded.mp3'),
  ('إِلَّا', 'illa', null, null, 'except, unless', 15, 'placeholder/audio-not-yet-recorded.mp3'),
  ('قَد', 'qad', null, null, 'indeed; [with a past-tense verb] already', 19, 'placeholder/audio-not-yet-recorded.mp3'),
  ('أَو', 'aw', null, null, 'or', 35, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ثُمَّ', 'thumma', null, null, 'then, thereafter', 26, 'placeholder/audio-not-yet-recorded.mp3'),
  ('كُلّ', 'kull', null, null, 'every, all, each', 24, 'placeholder/audio-not-yet-recorded.mp3'),
  ('يَوْم', 'yawm', 'ي-و-م', null, 'day', 29, 'placeholder/audio-not-yet-recorded.mp3'),
  ('أَرْض', 'ard', 'أ-ر-ض', null, 'earth, land', 18, 'placeholder/audio-not-yet-recorded.mp3'),
  ('قَوْم', 'qawm', 'ق-و-م', null, 'people, nation', 21, 'placeholder/audio-not-yet-recorded.mp3'),
  ('ءَايَة', 'ayah', null, null, 'sign, verse', 22, 'placeholder/audio-not-yet-recorded.mp3'),
  ('عَذَاب', 'adhab', 'ع-ذ-ب', null, 'punishment, torment', 30, 'placeholder/audio-not-yet-recorded.mp3'),
  ('رَسُول', 'rasul', 'ر-س-ل', null, 'messenger', 27, 'placeholder/audio-not-yet-recorded.mp3'),
  ('سَمَاء', 'sama', 'س-م-و', null, 'sky, heaven', 32, 'placeholder/audio-not-yet-recorded.mp3'),
  ('نَفْس', 'nafs', 'ن-ف-س', null, 'self, soul', 33, 'placeholder/audio-not-yet-recorded.mp3'),
  ('شَيْء', 'shay', 'ش-ي-ء', null, 'thing', 34, 'placeholder/audio-not-yet-recorded.mp3'),
  ('كِتَاب', 'kitab', 'ك-ت-ب', null, 'book, scripture', 36, 'placeholder/audio-not-yet-recorded.mp3'),
  ('حَقّ', 'haqq', 'ح-ق-ق', null, 'truth, right', 38, 'placeholder/audio-not-yet-recorded.mp3');

insert into grammar_points (code, category, title_en, explanation_short, explanation_full) values
  ('definite_article', 'sarf', 'The Definite Article: ال',
   'Attaching ال to the front of a noun makes it definite — كِتَابٌ ("a book") becomes الْكِتَابُ ("the book").',
   'Arabic has no separate word for "the." Instead, the two letters ال (Alif-Laam) attach directly to the front of a noun, turning an indefinite noun ("a book," "a messenger") into a definite one ("the book," "the messenger"). You''ve already seen this constantly — الرَّحْمَٰنِ, الرَّحِيمِ, and الْحَمْدُ in Al-Fatiha''s opening ayahs are all ordinary words (Rahman, Raheem, Hamd) with ال attached. Recognizing ال is one of the single highest-value reading skills in Quranic Arabic: once you can spot it, you can mentally strip it off and look up the word underneath.'),
  ('gender_marking', 'sarf', 'Masculine and Feminine Nouns',
   'Most Arabic nouns are masculine by default; adding ة (Taa Marboutah) to the end usually makes a noun feminine — رَسُولٌ ("a messenger," masc.) vs. رِسَالَةٌ ("a message," fem.).',
   'Every Arabic noun has a grammatical gender, masculine or feminine, even for things with no natural gender of their own, like "book" or "sun." Masculine is the default, unmarked form. Feminine nouns are usually marked by adding ة (Taa Marboutah) to the end — you''ve already met this letter shape in "Completion of an Ayah," where it''s pronounced as a plain Haa when a reciter pauses on it. Recognizing ة is a quick, reliable signal that a noun is feminine, which matters because adjectives and verbs describing that noun need to match its gender too.'),
  ('demonstrative_pronouns', 'nahw', 'This and That: هَٰذَا and ذَٰلِكَ',
   'هَٰذَا means "this" (something near); ذَٰلِكَ means "that" (something farther away, or already mentioned) — both point at something instead of naming it.',
   'هَٰذَا (hādhā) and ذَٰلِكَ (dhālika) are demonstrative pronouns — words that point at something rather than naming it outright. هَٰذَا is used for something near or immediately present ("this"), while ذَٰلِكَ points to something more distant, or something already mentioned earlier ("that"). Both appear constantly throughout the Quran, often opening a sentence to introduce or refer back to an idea.');

insert into units (track_id, unit_type, title, sequence_order)
select id, 'thematic', 'Core Vocabulary & Grammar', 8 from tracks where code = 'quranic_arabic';

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Essential Particles', 1, 8 from units where title = 'Core Vocabulary & Grammar';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Essential Particles Quiz', 2, 10 from units where title = 'Core Vocabulary & Grammar';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Common Nouns', 3, 8 from units where title = 'Core Vocabulary & Grammar';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Common Nouns Quiz', 4, 10 from units where title = 'Core Vocabulary & Grammar';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Basic Grammar: Articles, Gender & Demonstratives', 5, 8 from units where title = 'Core Vocabulary & Grammar';

do $$
declare
  v_unit_id int;
  v_particles_id int;
  v_particles_quiz_id int;
  v_nouns_id int;
  v_nouns_quiz_id int;
  v_grammar_id int;
  v_exercise_id int;
  v_seq int;
  v_word record;
  v_rab_id int;
  v_definite_article_id int;
  v_gender_id int;
  v_demonstrative_id int;
  v_fatiha_ayah2_id bigint;
begin
  select id into v_unit_id from units where title = 'Core Vocabulary & Grammar';
  select id into v_particles_id from lessons where unit_id = v_unit_id and title = 'Essential Particles';
  select id into v_particles_quiz_id from lessons where unit_id = v_unit_id and title = 'Essential Particles Quiz';
  select id into v_nouns_id from lessons where unit_id = v_unit_id and title = 'Common Nouns';
  select id into v_nouns_quiz_id from lessons where unit_id = v_unit_id and title = 'Common Nouns Quiz';
  select id into v_grammar_id from lessons where unit_id = v_unit_id and title = 'Basic Grammar: Articles, Gender & Demonstratives';
  select id into v_rab_id from vocab_items where arabic_text = 'رَبّ';
  select id into v_definite_article_id from grammar_points where code = 'definite_article';
  select id into v_gender_id from grammar_points where code = 'gender_marking';
  select id into v_demonstrative_id from grammar_points where code = 'demonstrative_pronouns';
  select id into v_fatiha_ayah2_id from ayat where surah_number = 1 and ayah_number = 2;

  -- Essential Particles: teach, ordered by true corpus frequency
  -- (highest-value word first) per docs/feature-specs.md's stated
  -- sequencing intent.
  v_seq := 0;
  for v_word in
    select id from vocab_items where arabic_text in ('مِن','فِي','عَلَى','إِلَى','عَن','لَا','مَا','إِلَّا','قَد','أَو','ثُمَّ','كُلّ')
    order by frequency_rank
  loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_id, 'vocab_card', v_seq) returning id into v_exercise_id;
    insert into exercise_vocab_card (exercise_id, vocab_item_id) values (v_exercise_id, v_word.id);
  end loop;

  -- Essential Particles Quiz: comprehensive, one question per word.
  -- Distractors are hand-picked from other words in this same lesson
  -- (not randomly generated) so each set of options is a deliberate,
  -- reviewable choice rather than whatever a random draw produced.
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 1) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does مِن mean?', '["from, of", "in, within", "to, toward", "or"]'::jsonb, 0, id from vocab_items where arabic_text = 'مِن';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does فِي mean?', '["in, within", "on, upon", "except, unless", "then, thereafter"]'::jsonb, 0, id from vocab_items where arabic_text = 'فِي';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does عَلَى mean?', '["to, toward", "on, upon, against", "every, all", "about, away from"]'::jsonb, 1, id from vocab_items where arabic_text = 'عَلَى';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does إِلَى mean?', '["to, toward", "from, of", "no, not", "or"]'::jsonb, 0, id from vocab_items where arabic_text = 'إِلَى';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 5) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does عَن mean?', '["indeed; already", "about, away from", "in, within", "except, unless"]'::jsonb, 1, id from vocab_items where arabic_text = 'عَن';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does لَا mean?', '["no, not", "or", "then, thereafter", "every, all"]'::jsonb, 0, id from vocab_items where arabic_text = 'لَا';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 7) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does مَا mean?', '["except, unless", "what, that which — also used as \"not\"", "on, upon", "to, toward"]'::jsonb, 1, id from vocab_items where arabic_text = 'مَا';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does إِلَّا mean?', '["except, unless", "from, of", "about, away from", "indeed; already"]'::jsonb, 0, id from vocab_items where arabic_text = 'إِلَّا';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 9) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does قَد mean?', '["or", "every, all", "indeed; already", "in, within"]'::jsonb, 2, id from vocab_items where arabic_text = 'قَد';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 10) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does أَو mean?', '["or", "no, not", "then, thereafter", "to, toward"]'::jsonb, 0, id from vocab_items where arabic_text = 'أَو';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 11) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does ثُمَّ mean?', '["then, thereafter", "except, unless", "on, upon", "what, that which"]'::jsonb, 0, id from vocab_items where arabic_text = 'ثُمَّ';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 12) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does كُلّ mean?', '["every, all, each", "from, of", "about, away from", "or"]'::jsonb, 0, id from vocab_items where arabic_text = 'كُلّ';

  -- Common Nouns: reuses the existing رَبّ vocab_item (id from
  -- Al-Fatiha's seed data, migration 0002) instead of inserting a
  -- duplicate row — same word, same SRS-tracked item.
  v_seq := 0;
  for v_word in
    select id from vocab_items where id = v_rab_id or arabic_text in ('يَوْم','أَرْض','قَوْم','ءَايَة','عَذَاب','رَسُول','سَمَاء','نَفْس','شَيْء','كِتَاب','حَقّ')
    order by frequency_rank
  loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_id, 'vocab_card', v_seq) returning id into v_exercise_id;
    insert into exercise_vocab_card (exercise_id, vocab_item_id) values (v_exercise_id, v_word.id);
  end loop;

  -- Common Nouns Quiz: same hand-picked-distractor approach as the
  -- particles quiz above.
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 1) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does رَبّ mean?', '["Lord, Sustainer", "day", "sky, heaven", "thing"]'::jsonb, 0, v_rab_id;

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does يَوْم mean?', '["earth, land", "day", "messenger", "truth, right"]'::jsonb, 1, id from vocab_items where arabic_text = 'يَوْم';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does أَرْض mean?', '["earth, land", "sign, verse", "self, soul", "book, scripture"]'::jsonb, 0, id from vocab_items where arabic_text = 'أَرْض';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does قَوْم mean?', '["punishment, torment", "people, nation", "sky, heaven", "day"]'::jsonb, 1, id from vocab_items where arabic_text = 'قَوْم';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 5) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does ءَايَة mean?', '["sign, verse", "thing", "earth, land", "Lord, Sustainer"]'::jsonb, 0, id from vocab_items where arabic_text = 'ءَايَة';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does عَذَاب mean?', '["messenger", "punishment, torment", "self, soul", "truth, right"]'::jsonb, 1, id from vocab_items where arabic_text = 'عَذَاب';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 7) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does رَسُول mean?', '["messenger", "book, scripture", "people, nation", "day"]'::jsonb, 0, id from vocab_items where arabic_text = 'رَسُول';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does سَمَاء mean?', '["self, soul", "sky, heaven", "punishment, torment", "sign, verse"]'::jsonb, 1, id from vocab_items where arabic_text = 'سَمَاء';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 9) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does نَفْس mean?', '["self, soul", "earth, land", "messenger", "thing"]'::jsonb, 0, id from vocab_items where arabic_text = 'نَفْس';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 10) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does شَيْء mean?', '["truth, right", "thing", "day", "Lord, Sustainer"]'::jsonb, 1, id from vocab_items where arabic_text = 'شَيْء';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 11) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does كِتَاب mean?', '["book, scripture", "sky, heaven", "people, nation", "punishment, torment"]'::jsonb, 0, id from vocab_items where arabic_text = 'كِتَاب';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 12) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What does حَقّ mean?', '["self, soul", "sign, verse", "truth, right", "messenger"]'::jsonb, 2, id from vocab_items where arabic_text = 'حَقّ';

  -- Basic Grammar: interleaved concept + quiz, same pattern as every
  -- other grammar_explanation lesson in this track.
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'grammar_explanation', 1) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_definite_article_id, v_fatiha_ayah2_id);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What does attaching ال to the front of a noun do?',
    '["Makes it plural", "Makes it definite (\"the\")", "Makes it feminine", "Turns it into a question"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'grammar_explanation', 3) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_gender_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which letter, added to the end of a noun, usually marks it as feminine?',
    '["ت", "ة", "ه", "ا"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'grammar_explanation', 5) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_demonstrative_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'Which word means "this" (something near)?',
    '["ذَٰلِكَ", "هَٰذَا", "الَّذِي", "كُلّ"]'::jsonb, 1);
end $$;

insert into user_unit_progress (user_id, unit_id, status, started_at)
select u.id, (select id from units where title = 'Core Vocabulary & Grammar'), 'in_progress', now()
from users u
on conflict (user_id, unit_id) do nothing;
