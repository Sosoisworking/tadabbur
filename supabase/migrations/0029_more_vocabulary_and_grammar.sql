-- Expands Core Vocabulary & Grammar (migration 0022) with the next
-- tier of high-frequency words and two grammar concepts deliberately
-- deferred out of the first pass.
--
-- Word selection: same methodology and source as migration 0022 (the
-- Quranic Arabic Corpus lemma frequency list, corpus.quran.com/lemmas.jsp)
-- — the next 10 highest-frequency words not yet taught, after
-- excluding ones already covered. Several of these are a deliberately
-- grouped "confusable cluster": مَن vs. مِن (already taught) are a
-- homograph pair distinguished only by vowel marks, and إِنّ/إِن/أَن/أَنّ
-- differ only by hamza type and shaddah — exactly the kind of
-- near-identical words worth teaching together, with each other as
-- quiz distractors, rather than in isolation where the contrast is
-- lost. root_letters stays null throughout, same rule as migration
-- 0022's particle lesson: these are mabniyy (indeclinable) function
-- words, not derived from a root.
--
-- Grammar: الَّذِي (the relative pronoun) and the possessive pronoun
-- suffixes (my/your/his/her/our/their) were both explicitly named as
-- deferred in migration 0022's header comment ("pure grammatical-
-- relation words better taught as grammar points than flashcards").
-- This migration is that follow-through. Two of the six grammar cards
-- link real Al-Fatiha example ayahs already in the ayat table (ids 5
-- and 7) rather than inventing illustrative text.
--
-- New lesson "More Grammar" interleaves concept+quiz per card, same
-- pattern as the existing "Basic Grammar" lesson — six independent
-- concepts doesn't warrant splitting into a separate quiz lesson.

insert into vocab_items (arabic_text, transliteration, root_letters, wazn_pattern, meaning_en, frequency_rank, audio_url) values
  ('مَن', 'man', null, null, 'who (relative or interrogative pronoun) — contrast with مِن ("from"), a homograph distinguished only by its vowel marks', 12, 'placeholder/audio-not-yet-recorded.mp3'),
  ('إِنّ', 'inna', null, null, 'indeed, verily — an emphatic particle that opens a statement', 4, 'placeholder/audio-not-yet-recorded.mp3'),
  ('إِن', 'in', null, null, 'if (conditional particle)', 13, 'placeholder/audio-not-yet-recorded.mp3'),
  ('أَن', 'an', null, null, 'that (introduces a subordinate clause, usually before a verb)', 14, 'placeholder/audio-not-yet-recorded.mp3'),
  ('أَنّ', 'anna', null, null, 'that (emphatic version of أَن)', 23, 'placeholder/audio-not-yet-recorded.mp3'),
  ('إِذَا', 'idha', null, null, 'when, if', 20, 'placeholder/audio-not-yet-recorded.mp3'),
  ('إِذ', 'idh', null, null, 'when (referring to a moment in the past)', 40, 'placeholder/audio-not-yet-recorded.mp3'),
  ('لَم', 'lam', null, null, 'not (negates a verb in the past tense)', 25, 'placeholder/audio-not-yet-recorded.mp3'),
  ('بَيْن', 'bayn', null, null, 'between, among', 37, 'placeholder/audio-not-yet-recorded.mp3'),
  ('نَاس', 'nas', null, null, 'people, mankind', 39, 'placeholder/audio-not-yet-recorded.mp3');

insert into grammar_points (code, category, title_en, explanation_short, explanation_full) values
  ('relative_pronoun', 'nahw', 'The Relative Pronoun: الَّذِي',
   'الَّذِي means "who/that/which" — it introduces a description of a noun already mentioned, and changes form depending on gender and number.',
   'الَّذِي (alladhi) is a relative pronoun — it connects a noun to a clause that describes it, similar to "who," "which," or "that" in English. It''s one of the most common words in the Quran. Like many Arabic words, it changes form to match what it''s describing: الَّذِي for a single masculine noun, الَّتِي for a single feminine noun, and الَّذِينَ for a group of masculine nouns — the form you''ll see most often, since it frequently describes groups of people, "those who...". You''ve already read its masculine plural form in Al-Fatiha''s own final ayah.'),
  ('possessive_suffix_i', 'sarf', 'My — The Suffix ـِي',
   'Attaching ـِي to the end of a noun means "my" — كِتَابٌ ("a book") becomes كِتَابِي ("my book").',
   'Arabic doesn''t use a separate word for "my" — instead a short suffix, ـِي, attaches directly to the end of a noun, replacing whatever case ending it would otherwise carry. كِتَابٌ ("a book") becomes كِتَابِي ("my book"); رَبٌّ ("a Lord") becomes رَبِّي ("my Lord") — one of the most frequently repeated phrases in the Quran.'),
  ('possessive_suffix_ka_ki', 'sarf', 'Your — The Suffixes ـَكَ and ـِك',
   'ـَكَ means "your" when speaking to a male, ـِك when speaking to a female — both attach to the end of a noun the same way ـِي does for "my."',
   'Like ـِي ("my"), the suffixes for "your" attach directly to a noun — but Arabic distinguishes who you''re speaking to. ـَكَ (-ka) is "your" when addressing a male: رَبُّكَ, "your Lord" (to a man). ـِك (-ki) is "your" when addressing a female: رَبُّكِ, "your Lord" (to a woman). You''ve already met -ka in Al-Fatiha itself: إِيَّاكَ نَعْبُدُ, "You alone we worship" — the -ka suffix there attaches to إِيَّا, a special pronoun base used to move the object before the verb for emphasis.'),
  ('possessive_suffix_hu_ha', 'sarf', 'His and Her — The Suffixes ـُهُ and ـُهَا',
   'ـُهُ means "his," ـُهَا means "her" — both attach to a noun the same way as the other possessive suffixes.',
   'ـُهُ (-hu) means "his": رَبُّهُ, "his Lord." ـُهَا (-haa) means "her": رَبُّهَا, "her Lord." These are two of the most common possessive suffixes in the Quran, since so much of the text describes what belongs to or is done by a third person — he, she, it.'),
  ('possessive_suffix_na', 'sarf', 'Our — The Suffix ـَنَا',
   'ـَنَا means "our" — رَبُّنَا, "our Lord," is one of the most recognizable possessive-suffix words in the Quran.',
   'ـَنَا (-naa) attaches to a noun to mean "our." رَبُّنَا ("our Lord") opens dozens of supplications throughout the Quran. You''ve already met the closely related word رَبَّنَا in Salah itself, in the phrase said after rising from ruku'': رَبَّنَا وَلَكَ الْحَمْدُ, "Our Lord, and to You belongs all praise."'),
  ('possessive_suffix_hum', 'sarf', 'Their — The Suffix ـُهُمْ',
   'ـُهُمْ means "their," referring to a group — رَبُّهُمْ, "their Lord."',
   'ـُهُمْ (-hum) attaches to a noun to mean "their," referring to a group. رَبُّهُمْ means "their Lord." Like هُمْ ("they") as a standalone word, the ـُهُمْ ending always signals more than one person is being talked about.');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'More Essential Particles', 6, 8 from units where title = 'Core Vocabulary & Grammar';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'More Essential Particles Quiz', 7, 10 from units where title = 'Core Vocabulary & Grammar';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'More Grammar: Relative Pronoun & Possessive Suffixes', 8, 10 from units where title = 'Core Vocabulary & Grammar';

do $$
declare
  v_particles_id int;
  v_particles_quiz_id int;
  v_grammar_id int;
  v_exercise_id int;
  v_word record;
  v_seq int;
  v_relative_id int;
  v_suffix_i_id int;
  v_suffix_ka_id int;
  v_suffix_hu_id int;
  v_suffix_na_id int;
  v_suffix_hum_id int;
  v_fatiha5_id bigint;
  v_fatiha7_id bigint;
begin
  select l.id into v_particles_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Core Vocabulary & Grammar' and l.title = 'More Essential Particles';
  select l.id into v_particles_quiz_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Core Vocabulary & Grammar' and l.title = 'More Essential Particles Quiz';
  select l.id into v_grammar_id from lessons l join units u on u.id = l.unit_id
    where u.title = 'Core Vocabulary & Grammar' and l.title = 'More Grammar: Relative Pronoun & Possessive Suffixes';
  select id into v_relative_id from grammar_points where code = 'relative_pronoun';
  select id into v_suffix_i_id from grammar_points where code = 'possessive_suffix_i';
  select id into v_suffix_ka_id from grammar_points where code = 'possessive_suffix_ka_ki';
  select id into v_suffix_hu_id from grammar_points where code = 'possessive_suffix_hu_ha';
  select id into v_suffix_na_id from grammar_points where code = 'possessive_suffix_na';
  select id into v_suffix_hum_id from grammar_points where code = 'possessive_suffix_hum';
  select id into v_fatiha5_id from ayat where surah_number = 1 and ayah_number = 5;
  select id into v_fatiha7_id from ayat where surah_number = 1 and ayah_number = 7;

  -- More Essential Particles: teach, ordered by true corpus frequency.
  v_seq := 0;
  for v_word in
    select id from vocab_items where arabic_text in ('مَن','إِنّ','إِن','أَن','أَنّ','إِذَا','إِذ','لَم','بَيْن','نَاس')
    order by frequency_rank
  loop
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_id, 'vocab_card', v_seq) returning id into v_exercise_id;
    insert into exercise_vocab_card (exercise_id, vocab_item_id) values (v_exercise_id, v_word.id);
  end loop;

  -- Quiz: transliteration format (not meaning), matching the
  -- established fix from migration 0023. Distractors are hand-picked,
  -- deliberately drawing on the confusable cluster (إنّ/إن/أن/أنّ) as
  -- each other's wrong answers.
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 1) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is مَن؟', '["man", "idha", "lam", "bayn"]'::jsonb, 0, id from vocab_items where arabic_text = 'مَن';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is إِنّ؟', '["in", "an", "inna", "anna"]'::jsonb, 2, id from vocab_items where arabic_text = 'إِنّ';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 3) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is إِن؟', '["inna", "in", "an", "idh"]'::jsonb, 1, id from vocab_items where arabic_text = 'إِن';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is أَن؟', '["anna", "in", "man", "an"]'::jsonb, 3, id from vocab_items where arabic_text = 'أَن';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 5) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is أَنّ؟', '["an", "inna", "anna", "idha"]'::jsonb, 2, id from vocab_items where arabic_text = 'أَنّ';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is إِذَا؟', '["idh", "lam", "idha", "nas"]'::jsonb, 2, id from vocab_items where arabic_text = 'إِذَا';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 7) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is إِذ؟', '["idha", "bayn", "man", "idh"]'::jsonb, 3, id from vocab_items where arabic_text = 'إِذ';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is لَم؟', '["lam", "in", "an", "nas"]'::jsonb, 0, id from vocab_items where arabic_text = 'لَم';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 9) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is بَيْن؟', '["nas", "bayn", "idh", "man"]'::jsonb, 1, id from vocab_items where arabic_text = 'بَيْن';

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_particles_quiz_id, 'recall_quiz', 10) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index, tested_vocab_item_id)
  select v_exercise_id, 'What is نَاس؟', '["bayn", "lam", "idha", "nas"]'::jsonb, 3, id from vocab_items where arabic_text = 'نَاس';

  -- More Grammar: interleaved concept + quiz, same pattern as the
  -- existing "Basic Grammar" lesson.
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'grammar_explanation', 1) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_relative_id, v_fatiha7_id);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'recall_quiz', 2) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What does الَّذِي mean?', '["Who/that/which", "This/that (pointing)", "My/your/his", "Between"]'::jsonb, 0);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'grammar_explanation', 3) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_suffix_i_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'recall_quiz', 4) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What does the suffix ـِي mean when attached to a noun?', '["Your", "My", "His", "Our"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'grammar_explanation', 5) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_suffix_ka_id, v_fatiha5_id);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'recall_quiz', 6) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'If you attach ـَكَ to a word while speaking to a woman, is that correct?', '["Yes, ـَكَ always works", "No, you should use ـِك for a woman", "No, you should use ـُهَا instead", "Yes, but only in the Qur''an"]'::jsonb, 1);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'grammar_explanation', 7) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_suffix_hu_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'recall_quiz', 8) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What does رَبُّهَا mean?', '["My Lord", "Your Lord", "His Lord", "Her Lord"]'::jsonb, 3);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'grammar_explanation', 9) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_suffix_na_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'recall_quiz', 10) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What does رَبَّنَا mean?', '["Our Lord", "Their Lord", "His Lord", "My Lord"]'::jsonb, 0);

  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'grammar_explanation', 11) returning id into v_exercise_id;
  insert into exercise_grammar_explanation (exercise_id, grammar_point_id, example_ayah_id) values (v_exercise_id, v_suffix_hum_id, null);
  insert into exercises (lesson_id, exercise_type, sequence_order) values (v_grammar_id, 'recall_quiz', 12) returning id into v_exercise_id;
  insert into exercise_recall_quiz (exercise_id, question, options, correct_option_index)
  values (v_exercise_id, 'What does ـُهُمْ mean when attached to a noun?', '["My", "His", "Their", "Your"]'::jsonb, 2);
end $$;
