-- Makes the diacritic reading grids (Fathah/Kasrah/.../Dhammatain)
-- show a pronunciation label under each glyph, not just the Arabic
-- text on its own. Data-driven rather than hardcoded per-diacritic
-- logic in the app: letters.base_consonant is the same mapping already
-- used inline in migrations 0011 and 0012 (now made authoritative,
-- stored once instead of redefined in every migration that needs it),
-- and diacritics.reading_suffix says what to append to that base for
-- each mark. The app just concatenates base_consonant + reading_suffix
-- — no "if diacritic == Fathah then +a" branching anywhere in Dart.

alter table letters add column base_consonant text;

update letters set base_consonant = v.base_consonant
from (values
  (1,  'A'),  (2,  'B'),  (3,  'T'),  (4,  'Th'), (5,  'J'),
  (6,  'H'),  (7,  'Kh'), (8,  'D'),  (9,  'Dh'), (10, 'R'),
  (11, 'Z'),  (12, 'S'),  (13, 'Sh'), (14, 'S'),  (15, 'D'),
  (16, 'T'),  (17, 'Dh'), (18, 'A'),  (19, 'Gh'), (20, 'F'),
  (21, 'Q'),  (22, 'K'),  (23, 'L'),  (24, 'M'),  (25, 'N'),
  (26, 'H'),  (27, 'W'),  (28, 'Y')
) as v(sequence_order, base_consonant)
where letters.sequence_order = v.sequence_order;

alter table letters alter column base_consonant set not null;

alter table diacritics add column reading_suffix text not null default '';

update diacritics set reading_suffix = 'a' where name_en = 'Fathah';
update diacritics set reading_suffix = 'i' where name_en = 'Kasrah';
update diacritics set reading_suffix = 'u' where name_en = 'Dhammah';
update diacritics set reading_suffix = '' where name_en = 'Sukoon'; -- bare consonant, no vowel
update diacritics set reading_suffix = 'an' where name_en = 'Fathatain';
update diacritics set reading_suffix = 'in' where name_en = 'Kasratain';
update diacritics set reading_suffix = 'un' where name_en = 'Dhammatain';
