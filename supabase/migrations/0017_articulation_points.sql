-- Adds the articulation point (makhraj) — where in the mouth/throat
-- each letter is pronounced — for all 28 letters, from the Qaida
-- book's reference table. Enriches the existing letters table (same
-- pattern as base_consonant, positional forms, is_emphatic) rather
-- than a new exercise type: this is letter metadata, displayed
-- alongside what letter_card exercises already show.

alter table letters add column articulation_point text;

update letters set articulation_point = v.articulation_point
from (values
  (1,  'The empty space in the mouth and throat.'),
  (2,  'The inner part of the lips where they meet (moist part).'),
  (3,  'The top of the tip of the tongue touches the gums behind the two upper incisors (front central teeth).'),
  (4,  'The tip of the tongue touches the bottom edge of the two upper incisors (front central teeth).'),
  (5,  'The middle of the tongue touches the upper palate.'),
  (6,  'The middle part of the throat, halfway between the beginning and the end of the throat.'),
  (7,  'The top of the throat, closest to the mouth.'),
  (8,  'The top of the tip of the tongue touches the gums behind the two upper incisors (front central teeth).'),
  (9,  'The tip of the tongue touches the bottom edge of the front two upper central teeth.'),
  (10, 'The tip of the tongue touches the upper hard palate at the front of the mouth.'),
  (11, 'The tip of the tongue touches the top edge of the front two lower central incisors.'),
  (12, 'The tip of the tongue touches the top edge of the two front lower central incisors.'),
  (13, 'The middle of the tongue touches the upper palate.'),
  (14, 'The tip of the tongue touches the top edge of the front two lower central incisors.'),
  (15, 'The sides of the tongue touch the gums of the upper back teeth (molars).'),
  (16, 'The top of the tip of the tongue touches the gums behind the two upper incisors (front central teeth).'),
  (17, 'The tip of the tongue touches the bottom edge of the two upper incisors (front central teeth).'),
  (18, 'The middle part of the throat, halfway between the beginning and the end of the throat.'),
  (19, 'The top of the throat, closest to the mouth.'),
  (20, 'The bottom edge of the upper front teeth meets the inner bottom lip.'),
  (21, 'Raising the back of the tongue to touch the upper palate.'),
  (22, 'Raising the back of the tongue to touch the upper palate, a little further forward than Qaf.'),
  (23, 'The front sides and tip of the tongue touch the gums of the upper front incisors.'),
  (24, 'Closing the two lips together.'),
  (25, 'The tip of the tongue touches the gum of the two upper incisors (front central teeth).'),
  (26, 'The bottom of the throat, closest to the chest.'),
  (27, 'Circling of the two lips without meeting completely.'),
  (28, 'The middle of the tongue touches the upper palate.')
) as v(sequence_order, articulation_point)
where letters.sequence_order = v.sequence_order;

alter table letters alter column articulation_point set not null;
