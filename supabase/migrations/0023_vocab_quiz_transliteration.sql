-- Reworks the two vocabulary quizzes added in migration 0022 (Essential
-- Particles Quiz, Common Nouns Quiz) per explicit user feedback: quiz
-- questions should test reading recognition ("What is مِن؟" -> "min")
-- rather than meaning/translation ("What does مِن mean?" -> "from, of").
-- This brings vocab quizzes in line with how every other quiz in the
-- app already works (letter/diacritic quizzes test "how do you read
-- this," not "what does this mean") — meaning-testing was the outlier,
-- not the norm.
--
-- Updates existing rows in place rather than deleting and reinserting —
-- same exercise_id, same tested_vocab_item_id (SRS linkage unaffected),
-- only question/options/correct_option_index change.
--
-- Scoped by lesson_id (38 = Essential Particles Quiz, 40 = Common Nouns
-- Quiz), not just tested_vocab_item_id: رَبّ's vocab_item_id is also
-- referenced by an original Al-Fatiha quiz question (exercise 5,
-- migration 0002, "What does رَبّ mean?") which must NOT be touched —
-- confirmed via a live query before writing this migration that exactly
-- two rows share that vocab_item_id, only one of which belongs here.

update exercise_recall_quiz erq set
  question = 'What is مِن؟', options = '["min", "fi", "ala", "aw"]'::jsonb, correct_option_index = 0
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'مِن');

update exercise_recall_quiz erq set
  question = 'What is فِي؟', options = '["fi", "min", "ila", "thumma"]'::jsonb, correct_option_index = 0
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'فِي');

update exercise_recall_quiz erq set
  question = 'What is عَلَى؟', options = '["ala", "ila", "kull", "an"]'::jsonb, correct_option_index = 0
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'عَلَى');

update exercise_recall_quiz erq set
  question = 'What is إِلَى؟', options = '["ala", "min", "ila", "la"]'::jsonb, correct_option_index = 2
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'إِلَى');

update exercise_recall_quiz erq set
  question = 'What is عَن؟', options = '["qad", "an", "ala", "illa"]'::jsonb, correct_option_index = 1
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'عَن');

update exercise_recall_quiz erq set
  question = 'What is لَا؟', options = '["aw", "thumma", "la", "kull"]'::jsonb, correct_option_index = 2
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'لَا');

update exercise_recall_quiz erq set
  question = 'What is مَا؟', options = '["illa", "ala", "ma", "ila"]'::jsonb, correct_option_index = 2
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'مَا');

update exercise_recall_quiz erq set
  question = 'What is إِلَّا؟', options = '["illa", "min", "an", "qad"]'::jsonb, correct_option_index = 0
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'إِلَّا');

update exercise_recall_quiz erq set
  question = 'What is قَد؟', options = '["aw", "kull", "qad", "fi"]'::jsonb, correct_option_index = 2
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'قَد');

update exercise_recall_quiz erq set
  question = 'What is أَو؟', options = '["aw", "la", "thumma", "ila"]'::jsonb, correct_option_index = 0
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'أَو');

update exercise_recall_quiz erq set
  question = 'What is ثُمَّ؟', options = '["illa", "ala", "thumma", "ma"]'::jsonb, correct_option_index = 2
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'ثُمَّ');

update exercise_recall_quiz erq set
  question = 'What is كُلّ؟', options = '["min", "an", "kull", "aw"]'::jsonb, correct_option_index = 2
from exercises e where erq.exercise_id = e.id and e.lesson_id = 38 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'كُلّ');

update exercise_recall_quiz erq set
  question = 'What is رَبّ؟', options = '["Rabb", "yawm", "sama", "shay"]'::jsonb, correct_option_index = 0
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = 2;

update exercise_recall_quiz erq set
  question = 'What is يَوْم؟', options = '["ard", "rasul", "yawm", "haqq"]'::jsonb, correct_option_index = 2
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'يَوْم');

update exercise_recall_quiz erq set
  question = 'What is أَرْض؟', options = '["ard", "ayah", "nafs", "kitab"]'::jsonb, correct_option_index = 0
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'أَرْض');

update exercise_recall_quiz erq set
  question = 'What is قَوْم؟', options = '["adhab", "sama", "qawm", "yawm"]'::jsonb, correct_option_index = 2
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'قَوْم');

update exercise_recall_quiz erq set
  question = 'What is ءَايَة؟', options = '["shay", "ard", "ayah", "Rabb"]'::jsonb, correct_option_index = 2
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'ءَايَة');

update exercise_recall_quiz erq set
  question = 'What is عَذَاب؟', options = '["rasul", "adhab", "nafs", "haqq"]'::jsonb, correct_option_index = 1
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'عَذَاب');

update exercise_recall_quiz erq set
  question = 'What is رَسُول؟', options = '["rasul", "kitab", "qawm", "yawm"]'::jsonb, correct_option_index = 0
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'رَسُول');

update exercise_recall_quiz erq set
  question = 'What is سَمَاء؟', options = '["nafs", "sama", "adhab", "ayah"]'::jsonb, correct_option_index = 1
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'سَمَاء');

update exercise_recall_quiz erq set
  question = 'What is نَفْس؟', options = '["ard", "rasul", "nafs", "shay"]'::jsonb, correct_option_index = 2
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'نَفْس');

update exercise_recall_quiz erq set
  question = 'What is شَيْء؟', options = '["haqq", "shay", "yawm", "Rabb"]'::jsonb, correct_option_index = 1
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'شَيْء');

update exercise_recall_quiz erq set
  question = 'What is كِتَاب؟', options = '["kitab", "sama", "qawm", "adhab"]'::jsonb, correct_option_index = 0
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'كِتَاب');

update exercise_recall_quiz erq set
  question = 'What is حَقّ؟', options = '["nafs", "ayah", "haqq", "rasul"]'::jsonb, correct_option_index = 2
from exercises e where erq.exercise_id = e.id and e.lesson_id = 40 and erq.tested_vocab_item_id = (select id from vocab_items where arabic_text = 'حَقّ');
