-- Phase 1 of adapting "Arabic Qaida for Kids, Book 1" (Shaykha Dina
-- Essam / Quran Host) into real content: positional letter forms and
-- the emphatic ("heavy") letter flag, transcribed from the book's
-- Arabic Alphabet, Letter Recognition, and Letter Positions sections
-- (pages 1-5). Later phases cover harakat (Fathah/Kasrah/Dhammah/
-- Sukoon/Tanween/Shaddah), madd/leen letters, and applied reading.

alter table letters add column initial_form text;
alter table letters add column medial_form text;
alter table letters add column final_form text;
alter table letters add column is_emphatic boolean not null default false;

-- Non-connecting letters (ا د ذ ر ز و) don't join to a following
-- letter, so their "initial" form is identical to isolated, and
-- "medial" is identical to "final" — this isn't a data-entry
-- shortcut, it's linguistically correct: these six letters are why
-- Arabic cursive joining has exceptions at all.
update letters set initial_form = v.initial_form, medial_form = v.medial_form, final_form = v.final_form, is_emphatic = v.is_emphatic
from (values
  (1,  'ا', 'ا',  'ـا', 'ـا', false),  -- Alif
  (2,  'ب', 'بـ', 'ـبـ', 'ـب', false), -- Ba
  (3,  'ت', 'تـ', 'ـتـ', 'ـت', false), -- Ta
  (4,  'ث', 'ثـ', 'ـثـ', 'ـث', false), -- Tha
  (5,  'ج', 'جـ', 'ـجـ', 'ـج', false), -- Jim
  (6,  'ح', 'حـ', 'ـحـ', 'ـح', false), -- Ha
  (7,  'خ', 'خـ', 'ـخـ', 'ـخ', true),  -- Kha (emphatic)
  (8,  'د', 'د',  'ـد', 'ـد', false),  -- Dal
  (9,  'ذ', 'ذ',  'ـذ', 'ـذ', false),  -- Dhal
  (10, 'ر', 'ر',  'ـر', 'ـر', false),  -- Ra
  (11, 'ز', 'ز',  'ـز', 'ـز', false),  -- Zay
  (12, 'س', 'سـ', 'ـسـ', 'ـس', false), -- Sin
  (13, 'ش', 'شـ', 'ـشـ', 'ـش', false), -- Shin
  (14, 'ص', 'صـ', 'ـصـ', 'ـص', true),  -- Sad (emphatic)
  (15, 'ض', 'ضـ', 'ـضـ', 'ـض', true),  -- Dad (emphatic)
  (16, 'ط', 'طـ', 'ـطـ', 'ـط', true),  -- Ta emphatic
  (17, 'ظ', 'ظـ', 'ـظـ', 'ـظ', true),  -- Dha emphatic
  (18, 'ع', 'عـ', 'ـعـ', 'ـع', false), -- Ain
  (19, 'غ', 'غـ', 'ـغـ', 'ـغ', true),  -- Ghain (emphatic)
  (20, 'ف', 'فـ', 'ـفـ', 'ـف', false), -- Fa
  (21, 'ق', 'قـ', 'ـقـ', 'ـق', true),  -- Qaf (emphatic)
  (22, 'ك', 'كـ', 'ـكـ', 'ـك', false), -- Kaf
  (23, 'ل', 'لـ', 'ـلـ', 'ـل', false), -- Lam
  (24, 'م', 'مـ', 'ـمـ', 'ـم', false), -- Mim
  (25, 'ن', 'نـ', 'ـنـ', 'ـن', false), -- Nun
  (26, 'ه', 'هـ', 'ـهـ', 'ـه', false), -- Ha (haa)
  (27, 'و', 'و',  'ـو', 'ـو', false),  -- Waw
  (28, 'ي', 'يـ', 'ـيـ', 'ـي', false)  -- Ya
) as v(sequence_order, isolated_check, initial_form, medial_form, final_form, is_emphatic)
where letters.sequence_order = v.sequence_order;
