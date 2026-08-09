-- Third vocabulary tier in Core Vocabulary & Grammar. Migrations 0022
-- and 0029 together taught every particle/noun in the Quranic Arabic
-- Corpus's top 40 lemmas by frequency (corpus.quran.com/lemmas.jsp)
-- except الله (excluded, already known), الَّذِي/ذَٰلِكَ/هَٰذَا (taught as
-- grammar points, not vocab cards). This migration continues into
-- ranks 41-70, the same source and methodology, confirmed by paging
-- the corpus site (?page=1 = ranks 1-50, ?page=2 = ranks 51-100) —
-- not estimated or continued from memory.
--
-- Skipped from this range: duplicate words already taught under a
-- different grammatical sense (مَن at rank 45 is the same word as the
-- rank-12 مَن already taught; إِن at 69 and إِلَّا at 77 are likewise
-- repeats), and proper nouns (مُوسَىٰ, "Moses," rank 58) — a name isn't
-- the kind of vocabulary this unit is building.
--
-- Same split as before: function words (several are technically
-- "adverbial nouns" — قَبْل، بَعْد، عِنْد، مَعَ، غَيْر، دُون — but behave
-- like prepositions the way بَيْن already did in migration 0029, so
-- they're grouped with particles by function, not strict part of
-- speech) in one lesson, content nouns in another. root_letters null
-- throughout the particles lesson (same mabniyy reasoning as before);
-- populated for the nouns lesson where confident.

insert into vocab_items (arabic_text, transliteration, root_letters, wazn_pattern, meaning_en, frequency_rank, audio_url) values
  ('لَو', 'law', null, null, 'if (a hypothetical or unlikely condition — different from إِن and إِذَا)', 44, 'placeholder/audio-not-yet-recorded.mp3'),
  ('أَم', 'am', null, null, 'or (used specifically in questions, e.g. "is it this or that?")', 57, 'placeholder/audio-not-yet-recorded.mp3'),
  ('عِنْد', 'ind', null, null, 'at, with, in the possession of', 48, 'placeholder/audio-not-yet-recorded.mp3'),
  ('مَعَ', 'ma''a', null, null, 'with, together with', 49, 'placeholder/audio-not-yet-recorded.mp3'),
  ('قَبْل', 'qabl', null, null, 'before', 42, 'placeholder/audio-not-yet-recorded.mp3'),
  ('بَعْد', 'ba''d', null, null, 'after', 61, 'placeholder/audio-not-yet-recorded.mp3'),
  ('غَيْر', 'ghayr', null, null, 'other than, not', 56, 'placeholder/audio-not-yet-recorded.mp3'),
  ('دُون', 'doon', null, null, 'besides, without, lower than', 59, 'placeholder/audio-not-yet-recorded.mp3'),
  ('لَعَلّ', 'la''alla', null, null, 'perhaps, so that (expresses hope or purpose)', 65, 'placeholder/audio-not-yet-recorded.mp3'),
  ('أَيُّهَا', 'ayyuha', null, null, 'O (a vocative particle for addressing someone directly, e.g. "O you who believe")', 52, 'placeholder/audio-not-yet-recorded.mp3'),
  ('سَبِيل', 'sabeel', 'س-ب-ل', null, 'way, path', 46, 'placeholder/audio-not-yet-recorded.mp3'),
  ('أَمْر', 'amr', 'أ-م-ر', null, 'matter, affair, command', 47, 'placeholder/audio-not-yet-recorded.mp3'),
  ('بَعْض', 'ba''d', 'ب-ع-ض', null, 'some, a part of', 50, 'placeholder/audio-not-yet-recorded.mp3'),
  ('إِلَٰه', 'ilah', 'أ-ل-ه', null, 'god, deity — as in لَا إِلَٰهَ إِلَّا اللَّه', 54, 'placeholder/audio-not-yet-recorded.mp3'),
  ('نَار', 'nar', 'ن-و-ر', null, 'fire', 55, 'placeholder/audio-not-yet-recorded.mp3'),
  ('قَلْب', 'qalb', 'ق-ل-ب', null, 'heart', 62, 'placeholder/audio-not-yet-recorded.mp3'),
  ('عَبْد', 'abd', 'ع-ب-د', null, 'servant, slave', 63, 'placeholder/audio-not-yet-recorded.mp3'),
  ('أَهْل', 'ahl', 'أ-ه-ل', null, 'family, people (of a place)', 64, 'placeholder/audio-not-yet-recorded.mp3'),
  ('يَد', 'yad', 'ي-د-ي', null, 'hand', 67, 'placeholder/audio-not-yet-recorded.mp3'),
  ('رَحْمَة', 'rahmah', 'ر-ح-م', null, 'mercy', 70, 'placeholder/audio-not-yet-recorded.mp3');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Additional Particles', 9, 8 from units where title = 'Core Vocabulary & Grammar';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Additional Particles Quiz', 10, 10 from units where title = 'Core Vocabulary & Grammar';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Additional Nouns', 11, 8 from units where title = 'Core Vocabulary & Grammar';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Additional Nouns Quiz', 12, 10 from units where title = 'Core Vocabulary & Grammar';

do $$
declare
  v_particles_id int;
  v_particles_quiz_id int;
  v_nouns_id int;
  v_nouns_quiz_id int;
  v_exercise_id int;
  v_word record;
  v_seq int;
begin
  select l.id into v_particles_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Core Vocabulary & Grammar' and l.title = 'Additional Particles';
  select l.id into v_particles_quiz_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Core Vocabulary & Grammar' and l.title = 'Additional Particles Quiz';
  select l.id into v_nouns_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Core Vocabulary & Grammar' and l.title = 'Additional Nouns';
  select l.id into v_nouns_quiz_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Core Vocabulary & Grammar' and l.title = 'Additional Nouns Quiz';

  -- Additional Particles: teach, ordered by true corpus frequency.
  v_seq := 0;
  for v_word in
    select id from vocab_items where arabic_text in ('لَو','أَم','عِنْد','مَعَ','قَبْل','بَعْد','غَيْر','دُون','لَعَلّ','أَيُّهَا')
    order by frequency_rank
  loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_id, 'vocab_card', v_seq) returning id into v_exercise_id;
    insert into exercise_vocab_card (exercise_id, vocab_item_id) values (v_exercise_id, v_word.id);
  end loop;

  -- Quiz: transliteration format, hand-picked distractors.
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 1) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is قَبْل؟', '["ba''d", "qabl", "ind", "ma''a"]'::jsonb, 1, id from vocab_items where arabic_text = 'قَبْل';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is لَو؟', '["law", "am", "doon", "ghayr"]'::jsonb, 0, id from vocab_items where arabic_text = 'لَو';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is عِنْد؟', '["ma''a", "ind", "ayyuha", "la''alla"]'::jsonb, 1, id from vocab_items where arabic_text = 'عِنْد';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is مَعَ؟', '["qabl", "ba''d", "ma''a", "law"]'::jsonb, 2, id from vocab_items where arabic_text = 'مَعَ';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 5) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is أَم؟', '["am", "ind", "doon", "ayyuha"]'::jsonb, 0, id from vocab_items where arabic_text = 'أَم';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is غَيْر؟', '["ghayr", "law", "ma''a", "la''alla"]'::jsonb, 0, id from vocab_items where arabic_text = 'غَيْر';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 7) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is بَعْد؟', '["qabl", "ba''d", "am", "ind"]'::jsonb, 1, id from vocab_items where arabic_text = 'بَعْد';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is دُون؟', '["doon", "ghayr", "law", "qabl"]'::jsonb, 0, id from vocab_items where arabic_text = 'دُون';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 9) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is لَعَلّ؟', '["ayyuha", "am", "la''alla", "doon"]'::jsonb, 2, id from vocab_items where arabic_text = 'لَعَلّ';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 10) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is أَيُّهَا؟', '["ind", "la''alla", "ma''a", "ayyuha"]'::jsonb, 3, id from vocab_items where arabic_text = 'أَيُّهَا';

  -- Additional Nouns
  v_seq := 0;
  for v_word in
    select id from vocab_items where arabic_text in ('سَبِيل','أَمْر','بَعْض','إِلَٰه','نَار','قَلْب','عَبْد','أَهْل','يَد','رَحْمَة')
    order by frequency_rank
  loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_id, 'vocab_card', v_seq) returning id into v_exercise_id;
    insert into exercise_vocab_card (exercise_id, vocab_item_id) values (v_exercise_id, v_word.id);
  end loop;

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 1) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is سَبِيل؟', '["sabeel", "amr", "ba''d", "ilah"]'::jsonb, 0, id from vocab_items where arabic_text = 'سَبِيل';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is أَمْر؟', '["nar", "amr", "qalb", "yad"]'::jsonb, 1, id from vocab_items where arabic_text = 'أَمْر';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is بَعْض؟', '["abd", "ahl", "ba''d", "rahmah"]'::jsonb, 2, id from vocab_items where arabic_text = 'بَعْض';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is إِلَٰه؟', '["ilah", "sabeel", "nar", "amr"]'::jsonb, 0, id from vocab_items where arabic_text = 'إِلَٰه';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 5) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is نَار؟', '["qalb", "nar", "yad", "ba''d"]'::jsonb, 1, id from vocab_items where arabic_text = 'نَار';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is قَلْب؟', '["abd", "ilah", "qalb", "ahl"]'::jsonb, 2, id from vocab_items where arabic_text = 'قَلْب';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 7) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is عَبْد؟', '["amr", "abd", "sabeel", "rahmah"]'::jsonb, 1, id from vocab_items where arabic_text = 'عَبْد';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is أَهْل؟', '["yad", "nar", "ahl", "qalb"]'::jsonb, 2, id from vocab_items where arabic_text = 'أَهْل';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 9) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is يَد؟', '["ba''d", "ilah", "abd", "yad"]'::jsonb, 3, id from vocab_items where arabic_text = 'يَد';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_nouns_quiz_id, 'recall_quiz', 10) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is رَحْمَة؟', '["sabeel", "amr", "rahmah", "nar"]'::jsonb, 2, id from vocab_items where arabic_text = 'رَحْمَة';
end $$;
