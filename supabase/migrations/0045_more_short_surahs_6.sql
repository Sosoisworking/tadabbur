-- Adds the second batch of the longer Juz Amma surahs to "Short
-- Surahs", continuing the shortest-first pacing from migration 0044:
-- Al-Balad (90, 20 ayahs), Al-Layl (92, 21), Al-Buruj (85, 22),
-- Al-Inshiqaq (84, 25).
--
-- Same verification discipline as every prior batch: Uthmani text
-- batched per chapter, Saheeh International translation (resource 20)
-- and transliteration (resource 57) fetched individually per verse
-- from Quran.com, restyled into this app's established convention.
--
-- Live check before writing this migration found, same situation as
-- migration 0042's surahs 98/100: Al-Layl (92) and Al-Buruj (85)
-- already had a `surahs` row and a few `ayat` rows (92:4, 92:5, 92:12,
-- 85:6) seeded elsewhere as grammar_explanation examples. Those four
-- rows are left untouched here — only the other 18 (92) / 21 (85)
-- ayat are inserted, and the per-ayah exercise loop picks up the
-- existing rows dynamically by surah_number/ayah_number range. Al-84
-- (Al-Inshiqaq) 84:2 and 84:5 are intentionally identical text in the
-- Quran itself (a repeated refrain after both the sky and the earth
-- "have listened to their Lord and were obligated to") — not a fetch
-- duplication error.
--
-- Built directly in the current lesson shape: prayer_step, one
-- reading_passage card per ayah, then a closing full-surah recap — no
-- recall_quiz (removed from the unit per migration 0041).

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (90, 'البلد', 'Al-Balad', 20, 'meccan'),
  (84, 'الإنشقاق', 'Al-Inshiqaq', 25, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en, transliteration) values
  (90, 1, 'لَآ أُقْسِمُ بِهَـٰذَا ٱلْبَلَدِ', 'لَآ أُقْسِمُ بِهَـٰذَا ٱلْبَلَدِ', '[]'::jsonb,
   'I swear by this city [i.e., Makkah]', 'Laa uqsimu bihaadhal-balad'),
  (90, 2, 'وَأَنتَ حِلٌّۢ بِهَـٰذَا ٱلْبَلَدِ', 'وَأَنتَ حِلٌّۢ بِهَـٰذَا ٱلْبَلَدِ', '[]'::jsonb,
   'And you, [O Muhammad], are free of restriction in this city', 'Wa anta hillum bihaadhal-balad'),
  (90, 3, 'وَوَالِدٍ وَمَا وَلَدَ', 'وَوَالِدٍ وَمَا وَلَدَ', '[]'::jsonb,
   'And [by] the father and that which was born [of him],', 'Wa waalidin wa maa walad'),
  (90, 4, 'لَقَدْ خَلَقْنَا ٱلْإِنسَـٰنَ فِى كَبَدٍ', 'لَقَدْ خَلَقْنَا ٱلْإِنسَـٰنَ فِى كَبَدٍ', '[]'::jsonb,
   'We have certainly created man into hardship.', 'Laqad khalaqnal-insaana fee kabad'),
  (90, 5, 'أَيَحْسَبُ أَن لَّن يَقْدِرَ عَلَيْهِ أَحَدٌ', 'أَيَحْسَبُ أَن لَّن يَقْدِرَ عَلَيْهِ أَحَدٌ', '[]'::jsonb,
   'Does he think that never will anyone overcome him?', 'Ayahsabu al-lay yaqdira ''alayhi ahad'),
  (90, 6, 'يَقُولُ أَهْلَكْتُ مَالًا لُّبَدًا', 'يَقُولُ أَهْلَكْتُ مَالًا لُّبَدًا', '[]'::jsonb,
   'He says, "I have spent wealth in abundance."', 'Yaqoolu ahlaktu maalal-lubadaa'),
  (90, 7, 'أَيَحْسَبُ أَن لَّمْ يَرَهُۥٓ أَحَدٌ', 'أَيَحْسَبُ أَن لَّمْ يَرَهُۥٓ أَحَدٌ', '[]'::jsonb,
   'Does he think that no one has seen him?', 'Ayahsabu al-lam yarahu ahad'),
  (90, 8, 'أَلَمْ نَجْعَل لَّهُۥ عَيْنَيْنِ', 'أَلَمْ نَجْعَل لَّهُۥ عَيْنَيْنِ', '[]'::jsonb,
   'Have We not made for him two eyes?', 'Alam naj''al lahu ''aynayn'),
  (90, 9, 'وَلِسَانًا وَشَفَتَيْنِ', 'وَلِسَانًا وَشَفَتَيْنِ', '[]'::jsonb,
   'And a tongue and two lips?', 'Wa lisaanan wa shafatayn'),
  (90, 10, 'وَهَدَيْنَـٰهُ ٱلنَّجْدَيْنِ', 'وَهَدَيْنَـٰهُ ٱلنَّجْدَيْنِ', '[]'::jsonb,
   'And have shown him the two ways?', 'Wa hadaynaahun-najdayn'),
  (90, 11, 'فَلَا ٱقْتَحَمَ ٱلْعَقَبَةَ', 'فَلَا ٱقْتَحَمَ ٱلْعَقَبَةَ', '[]'::jsonb,
   'But he has not broken through the difficult pass.', 'Falaq-tahamal-''aqabah'),
  (90, 12, 'وَمَآ أَدْرَىٰكَ مَا ٱلْعَقَبَةُ', 'وَمَآ أَدْرَىٰكَ مَا ٱلْعَقَبَةُ', '[]'::jsonb,
   'And what can make you know what is [breaking through] the difficult pass?', 'Wa maa adraaka mal-''aqabah'),
  (90, 13, 'فَكُّ رَقَبَةٍ', 'فَكُّ رَقَبَةٍ', '[]'::jsonb,
   'It is the freeing of a slave', 'Fakku raqabah'),
  (90, 14, 'أَوْ إِطْعَـٰمٌ فِى يَوْمٍ ذِى مَسْغَبَةٍ', 'أَوْ إِطْعَـٰمٌ فِى يَوْمٍ ذِى مَسْغَبَةٍ', '[]'::jsonb,
   'Or feeding on a day of severe hunger', 'Aw it''aamun fee yawmin dhee masghabah'),
  (90, 15, 'يَتِيمًا ذَا مَقْرَبَةٍ', 'يَتِيمًا ذَا مَقْرَبَةٍ', '[]'::jsonb,
   'An orphan of near relationship', 'Yateeman dhaa maqrabah'),
  (90, 16, 'أَوْ مِسْكِينًا ذَا مَتْرَبَةٍ', 'أَوْ مِسْكِينًا ذَا مَتْرَبَةٍ', '[]'::jsonb,
   'Or a needy person in misery', 'Aw miskeenan dhaa matrabah'),
  (90, 17, 'ثُمَّ كَانَ مِنَ ٱلَّذِينَ ءَامَنُوا۟ وَتَوَاصَوْا۟ بِٱلصَّبْرِ وَتَوَاصَوْا۟ بِٱلْمَرْحَمَةِ', 'ثُمَّ كَانَ مِنَ ٱلَّذِينَ ءَامَنُوا۟ وَتَوَاصَوْا۟ بِٱلصَّبْرِ وَتَوَاصَوْا۟ بِٱلْمَرْحَمَةِ', '[]'::jsonb,
   'And then being among those who believed and advised one another to patience and advised one another to compassion.', 'Thumma kaana minal-ladheena aamanoo wa tawaasaw bis-sabri wa tawaasaw bil-marhamah'),
  (90, 18, 'أُو۟لَـٰٓئِكَ أَصْحَـٰبُ ٱلْمَيْمَنَةِ', 'أُو۟لَـٰٓئِكَ أَصْحَـٰبُ ٱلْمَيْمَنَةِ', '[]'::jsonb,
   'Those are the companions of the right.', 'Ulaa-ika as-haabul-maymanah'),
  (90, 19, 'وَٱلَّذِينَ كَفَرُوا۟ بِـَٔايَـٰتِنَا هُمْ أَصْحَـٰبُ ٱلْمَشْـَٔمَةِ', 'وَٱلَّذِينَ كَفَرُوا۟ بِـَٔايَـٰتِنَا هُمْ أَصْحَـٰبُ ٱلْمَشْـَٔمَةِ', '[]'::jsonb,
   'But they who disbelieved in Our signs - those are the companions of the left.', 'Wal-ladheena kafaroo bi-aayaatinaa hum as-haabul-mash-amah'),
  (90, 20, 'عَلَيْهِمْ نَارٌ مُّؤْصَدَةٌۢ', 'عَلَيْهِمْ نَارٌ مُّؤْصَدَةٌۢ', '[]'::jsonb,
   'Over them will be fire closed in.', '''Alayhim naarum-mu-sadah'),

  (92, 1, 'وَٱلَّيْلِ إِذَا يَغْشَىٰ', 'وَٱلَّيْلِ إِذَا يَغْشَىٰ', '[]'::jsonb,
   'By the night when it covers', 'Wallayli idhaa yaghshaa'),
  (92, 2, 'وَٱلنَّهَارِ إِذَا تَجَلَّىٰ', 'وَٱلنَّهَارِ إِذَا تَجَلَّىٰ', '[]'::jsonb,
   'And [by] the day when it appears', 'Wannahaari idhaa tajallaa'),
  (92, 3, 'وَمَا خَلَقَ ٱلذَّكَرَ وَٱلْأُنثَىٰٓ', 'وَمَا خَلَقَ ٱلذَّكَرَ وَٱلْأُنثَىٰٓ', '[]'::jsonb,
   'And [by] He who created the male and female,', 'Wa maa khalaqadh-dhakara wal-unthaa'),
  (92, 6, 'وَصَدَّقَ بِٱلْحُسْنَىٰ', 'وَصَدَّقَ بِٱلْحُسْنَىٰ', '[]'::jsonb,
   'And believes in the best [reward],', 'Wa saddaqa bil-husnaa'),
  (92, 7, 'فَسَنُيَسِّرُهُۥ لِلْيُسْرَىٰ', 'فَسَنُيَسِّرُهُۥ لِلْيُسْرَىٰ', '[]'::jsonb,
   'We will ease him toward ease.', 'Fasanuyassiruhu lil-yusraa'),
  (92, 8, 'وَأَمَّا مَنۢ بَخِلَ وَٱسْتَغْنَىٰ', 'وَأَمَّا مَنۢ بَخِلَ وَٱسْتَغْنَىٰ', '[]'::jsonb,
   'But as for he who withholds and considers himself free of need', 'Wa ammaa mam-bakhila wastaghnaa'),
  (92, 9, 'وَكَذَّبَ بِٱلْحُسْنَىٰ', 'وَكَذَّبَ بِٱلْحُسْنَىٰ', '[]'::jsonb,
   'And denies the best [reward],', 'Wa kadhdhaba bil-husnaa'),
  (92, 10, 'فَسَنُيَسِّرُهُۥ لِلْعُسْرَىٰ', 'فَسَنُيَسِّرُهُۥ لِلْعُسْرَىٰ', '[]'::jsonb,
   'We will ease him toward difficulty.', 'Fasanuyassiruhu lil-''usraa'),
  (92, 11, 'وَمَا يُغْنِى عَنْهُ مَالُهُۥٓ إِذَا تَرَدَّىٰٓ', 'وَمَا يُغْنِى عَنْهُ مَالُهُۥٓ إِذَا تَرَدَّىٰٓ', '[]'::jsonb,
   'And what will his wealth avail him when he falls?', 'Wa maa yughnee ''anhu maaluhoo idhaa taraddaa'),
  (92, 13, 'وَإِنَّ لَنَا لَلْـَٔاخِرَةَ وَٱلْأُولَىٰ', 'وَإِنَّ لَنَا لَلْـَٔاخِرَةَ وَٱلْأُولَىٰ', '[]'::jsonb,
   'And indeed, to us belongs the Hereafter and the first [life].', 'Wa inna lanaa lal-aakhirata wal-oolaa'),
  (92, 14, 'فَأَنذَرْتُكُمْ نَارًا تَلَظَّىٰ', 'فَأَنذَرْتُكُمْ نَارًا تَلَظَّىٰ', '[]'::jsonb,
   'So I have warned you of a Fire which is blazing.', 'Fa-andhartukum naaran taladdhaa'),
  (92, 15, 'لَا يَصْلَىٰهَآ إِلَّا ٱلْأَشْقَى', 'لَا يَصْلَىٰهَآ إِلَّا ٱلْأَشْقَى', '[]'::jsonb,
   'None will [enter to] burn therein except the most wretched one', 'Laa yaslaahaa illal-ashqaa'),
  (92, 16, 'ٱلَّذِى كَذَّبَ وَتَوَلَّىٰ', 'ٱلَّذِى كَذَّبَ وَتَوَلَّىٰ', '[]'::jsonb,
   'Who had denied and turned away.', 'Alladhee kadhdhaba wa tawallaa'),
  (92, 17, 'وَسَيُجَنَّبُهَا ٱلْأَتْقَى', 'وَسَيُجَنَّبُهَا ٱلْأَتْقَى', '[]'::jsonb,
   'But the righteous one will avoid it', 'Wa sayujannabuhal-atqaa'),
  (92, 18, 'ٱلَّذِى يُؤْتِى مَالَهُۥ يَتَزَكَّىٰ', 'ٱلَّذِى يُؤْتِى مَالَهُۥ يَتَزَكَّىٰ', '[]'::jsonb,
   '[He] who gives [from] his wealth to purify himself', 'Alladhee yu''tee maalahoo yatazakkaa'),
  (92, 19, 'وَمَا لِأَحَدٍ عِندَهُۥ مِن نِّعْمَةٍ تُجْزَىٰٓ', 'وَمَا لِأَحَدٍ عِندَهُۥ مِن نِّعْمَةٍ تُجْزَىٰٓ', '[]'::jsonb,
   'And not [giving] for anyone who has [done him] a favor to be rewarded', 'Wa maa li-ahadin ''indahoo min ni''matin tujzaa'),
  (92, 20, 'إِلَّا ٱبْتِغَآءَ وَجْهِ رَبِّهِ ٱلْأَعْلَىٰ', 'إِلَّا ٱبْتِغَآءَ وَجْهِ رَبِّهِ ٱلْأَعْلَىٰ', '[]'::jsonb,
   'But only seeking the face [i.e., acceptance] of his Lord, Most High.', 'Illab-tighaa-a wajhi rabbihil-a''laa'),
  (92, 21, 'وَلَسَوْفَ يَرْضَىٰ', 'وَلَسَوْفَ يَرْضَىٰ', '[]'::jsonb,
   'And he is going to be satisfied.', 'Wa lasawfa yardaa'),

  (85, 1, 'وَٱلسَّمَآءِ ذَاتِ ٱلْبُرُوجِ', 'وَٱلسَّمَآءِ ذَاتِ ٱلْبُرُوجِ', '[]'::jsonb,
   'By the sky containing great stars', 'Wassamaa-i dhaatil-burooj'),
  (85, 2, 'وَٱلْيَوْمِ ٱلْمَوْعُودِ', 'وَٱلْيَوْمِ ٱلْمَوْعُودِ', '[]'::jsonb,
   'And [by] the promised Day', 'Wal-yawmil-maw''ood'),
  (85, 3, 'وَشَاهِدٍ وَمَشْهُودٍ', 'وَشَاهِدٍ وَمَشْهُودٍ', '[]'::jsonb,
   'And [by] the witness and what is witnessed,', 'Wa shaahidin wa mashhood'),
  (85, 4, 'قُتِلَ أَصْحَـٰبُ ٱلْأُخْدُودِ', 'قُتِلَ أَصْحَـٰبُ ٱلْأُخْدُودِ', '[]'::jsonb,
   'Destroyed [i.e., cursed] were the companions of the trench', 'Qutila as-haabul-ukhdood'),
  (85, 5, 'ٱلنَّارِ ذَاتِ ٱلْوَقُودِ', 'ٱلنَّارِ ذَاتِ ٱلْوَقُودِ', '[]'::jsonb,
   '[Containing] the fire full of fuel,', 'An-naari dhaatil-waqood'),
  (85, 7, 'وَهُمْ عَلَىٰ مَا يَفْعَلُونَ بِٱلْمُؤْمِنِينَ شُهُودٌ', 'وَهُمْ عَلَىٰ مَا يَفْعَلُونَ بِٱلْمُؤْمِنِينَ شُهُودٌ', '[]'::jsonb,
   'And they, to what they were doing against the believers, were witnesses.', 'Wa hum ''alaa maa yaf''aloona bil-mu-mineena shuhood'),
  (85, 8, 'وَمَا نَقَمُوا۟ مِنْهُمْ إِلَّآ أَن يُؤْمِنُوا۟ بِٱللَّهِ ٱلْعَزِيزِ ٱلْحَمِيدِ', 'وَمَا نَقَمُوا۟ مِنْهُمْ إِلَّآ أَن يُؤْمِنُوا۟ بِٱللَّهِ ٱلْعَزِيزِ ٱلْحَمِيدِ', '[]'::jsonb,
   'And they resented them not except because they believed in Allah, the Exalted in Might, the Praiseworthy,', 'Wa maa naqamoo minhum illaa ay-yu-minoo billaahil-''azeezil-hameed'),
  (85, 9, 'ٱلَّذِى لَهُۥ مُلْكُ ٱلسَّمَـٰوَٰتِ وَٱلْأَرْضِ ۚ وَٱللَّهُ عَلَىٰ كُلِّ شَىْءٍ شَهِيدٌ', 'ٱلَّذِى لَهُۥ مُلْكُ ٱلسَّمَـٰوَٰتِ وَٱلْأَرْضِ ۚ وَٱللَّهُ عَلَىٰ كُلِّ شَىْءٍ شَهِيدٌ', '[]'::jsonb,
   'To whom belongs the dominion of the heavens and the earth. And Allah, over all things, is Witness.', 'Alladhee lahoo mulkus-samaawaati wal-ardi wallaahu ''alaa kulli shay-in shaheed'),
  (85, 10, 'إِنَّ ٱلَّذِينَ فَتَنُوا۟ ٱلْمُؤْمِنِينَ وَٱلْمُؤْمِنَـٰتِ ثُمَّ لَمْ يَتُوبُوا۟ فَلَهُمْ عَذَابُ جَهَنَّمَ وَلَهُمْ عَذَابُ ٱلْحَرِيقِ', 'إِنَّ ٱلَّذِينَ فَتَنُوا۟ ٱلْمُؤْمِنِينَ وَٱلْمُؤْمِنَـٰتِ ثُمَّ لَمْ يَتُوبُوا۟ فَلَهُمْ عَذَابُ جَهَنَّمَ وَلَهُمْ عَذَابُ ٱلْحَرِيقِ', '[]'::jsonb,
   'Indeed, those who have tortured the believing men and believing women and then have not repented will have the punishment of Hell, and they will have the punishment of the Burning Fire.', 'Innal-ladheena fatanul-mu-mineena wal-mu-minaati thumma lam yatooboo falahum ''adhaabu jahannama wa lahum ''adhaabul-hareeq'),
  (85, 11, 'إِنَّ ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ لَهُمْ جَنَّـٰتٌ تَجْرِى مِن تَحْتِهَا ٱلْأَنْهَـٰرُ ۚ ذَٰلِكَ ٱلْفَوْزُ ٱلْكَبِيرُ', 'إِنَّ ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ لَهُمْ جَنَّـٰتٌ تَجْرِى مِن تَحْتِهَا ٱلْأَنْهَـٰرُ ۚ ذَٰلِكَ ٱلْفَوْزُ ٱلْكَبِيرُ', '[]'::jsonb,
   'Indeed, those who have believed and done righteous deeds will have gardens beneath which rivers flow. That is the great attainment.', 'Innal-ladheena aamanoo wa ''amilus-saalihaati lahum jannaatun tajree min tahtihal-anhaaru dhaalikal-fawzul-kabeer'),
  (85, 12, 'إِنَّ بَطْشَ رَبِّكَ لَشَدِيدٌ', 'إِنَّ بَطْشَ رَبِّكَ لَشَدِيدٌ', '[]'::jsonb,
   'Indeed, the assault [i.e., vengeance] of your Lord is severe.', 'Inna batsha rabbika lashadeed'),
  (85, 13, 'إِنَّهُۥ هُوَ يُبْدِئُ وَيُعِيدُ', 'إِنَّهُۥ هُوَ يُبْدِئُ وَيُعِيدُ', '[]'::jsonb,
   'Indeed, it is He who originates [creation] and repeats.', 'Innahoo huwa yubdi-u wa yu''eed'),
  (85, 14, 'وَهُوَ ٱلْغَفُورُ ٱلْوَدُودُ', 'وَهُوَ ٱلْغَفُورُ ٱلْوَدُودُ', '[]'::jsonb,
   'And He is the Forgiving, the Affectionate,', 'Wa huwal-ghafoorul-wadood'),
  (85, 15, 'ذُو ٱلْعَرْشِ ٱلْمَجِيدُ', 'ذُو ٱلْعَرْشِ ٱلْمَجِيدُ', '[]'::jsonb,
   'Honorable Owner of the Throne,', 'Dhul-''arshil-majeed'),
  (85, 16, 'فَعَّالٌ لِّمَا يُرِيدُ', 'فَعَّالٌ لِّمَا يُرِيدُ', '[]'::jsonb,
   'Effecter of what He intends.', 'Fa''aalul-limaa yureed'),
  (85, 17, 'هَلْ أَتَىٰكَ حَدِيثُ ٱلْجُنُودِ', 'هَلْ أَتَىٰكَ حَدِيثُ ٱلْجُنُودِ', '[]'::jsonb,
   'Has there reached you the story of the soldiers -', 'Hal ataaka hadeethul-junood'),
  (85, 18, 'فِرْعَوْنَ وَثَمُودَ', 'فِرْعَوْنَ وَثَمُودَ', '[]'::jsonb,
   '[Those of] Pharaoh and Thamud?', 'Fir''awna wa thamood'),
  (85, 19, 'بَلِ ٱلَّذِينَ كَفَرُوا۟ فِى تَكْذِيبٍ', 'بَلِ ٱلَّذِينَ كَفَرُوا۟ فِى تَكْذِيبٍ', '[]'::jsonb,
   'But they who disbelieve are in [persistent] denial,', 'Balil-ladheena kafaroo fee takdheeb'),
  (85, 20, 'وَٱللَّهُ مِن وَرَآئِهِم مُّحِيطٌۢ', 'وَٱللَّهُ مِن وَرَآئِهِم مُّحِيطٌۢ', '[]'::jsonb,
   'While Allah encompasses them from behind.', 'Wallaahu miw-waraa-ihim muheet'),
  (85, 21, 'بَلْ هُوَ قُرْءَانٌ مَّجِيدٌ', 'بَلْ هُوَ قُرْءَانٌ مَّجِيدٌ', '[]'::jsonb,
   'But this is an honored Qur''an', 'Bal huwa qur-aanum-majeed'),
  (85, 22, 'فِى لَوْحٍ مَّحْفُوظٍۭ', 'فِى لَوْحٍ مَّحْفُوظٍۭ', '[]'::jsonb,
   '[Inscribed] in a Preserved Slate.', 'Fee lawhim-mahfoodh'),

  (84, 1, 'إِذَا ٱلسَّمَآءُ ٱنشَقَّتْ', 'إِذَا ٱلسَّمَآءُ ٱنشَقَّتْ', '[]'::jsonb,
   'When the sky has split [open]', 'Idhas-samaa-un-shaqqat'),
  (84, 2, 'وَأَذِنَتْ لِرَبِّهَا وَحُقَّتْ', 'وَأَذِنَتْ لِرَبِّهَا وَحُقَّتْ', '[]'::jsonb,
   'And has listened [i.e., responded] to its Lord and was obligated [to do so]', 'Wa adhinat li-rabbihaa wa huqqat'),
  (84, 3, 'وَإِذَا ٱلْأَرْضُ مُدَّتْ', 'وَإِذَا ٱلْأَرْضُ مُدَّتْ', '[]'::jsonb,
   'And when the earth has been extended', 'Wa idhal-ardu muddat'),
  (84, 4, 'وَأَلْقَتْ مَا فِيهَا وَتَخَلَّتْ', 'وَأَلْقَتْ مَا فِيهَا وَتَخَلَّتْ', '[]'::jsonb,
   'And has cast out that within it and relinquished [it].', 'Wa alqat maa feehaa wa takhallat'),
  (84, 5, 'وَأَذِنَتْ لِرَبِّهَا وَحُقَّتْ', 'وَأَذِنَتْ لِرَبِّهَا وَحُقَّتْ', '[]'::jsonb,
   'And has listened [i.e., responded] to its Lord and was obligated [to do so] -', 'Wa adhinat li-rabbihaa wa huqqat'),
  (84, 6, 'يَـٰٓأَيُّهَا ٱلْإِنسَـٰنُ إِنَّكَ كَادِحٌ إِلَىٰ رَبِّكَ كَدْحًا فَمُلَـٰقِيهِ', 'يَـٰٓأَيُّهَا ٱلْإِنسَـٰنُ إِنَّكَ كَادِحٌ إِلَىٰ رَبِّكَ كَدْحًا فَمُلَـٰقِيهِ', '[]'::jsonb,
   'O mankind, indeed you are laboring toward your Lord with [great] exertion and will meet it.', 'Yaa ayyuhal-insaanu innaka kaadihun ilaa rabbika kadhan famulaaqeeh'),
  (84, 7, 'فَأَمَّا مَنْ أُوتِىَ كِتَـٰبَهُۥ بِيَمِينِهِۦ', 'فَأَمَّا مَنْ أُوتِىَ كِتَـٰبَهُۥ بِيَمِينِهِۦ', '[]'::jsonb,
   'Then as for he who is given his record in his right hand,', 'Fa-ammaa man ootiya kitaabahoo biyameenih'),
  (84, 8, 'فَسَوْفَ يُحَاسَبُ حِسَابًا يَسِيرًا', 'فَسَوْفَ يُحَاسَبُ حِسَابًا يَسِيرًا', '[]'::jsonb,
   'He will be judged with an easy account', 'Fasawfa yuhaasabu hisaaban yaseeraa'),
  (84, 9, 'وَيَنقَلِبُ إِلَىٰٓ أَهْلِهِۦ مَسْرُورًا', 'وَيَنقَلِبُ إِلَىٰٓ أَهْلِهِۦ مَسْرُورًا', '[]'::jsonb,
   'And return to his people in happiness.', 'Wa yanqalibu ilaa ahlihee masrooraa'),
  (84, 10, 'وَأَمَّا مَنْ أُوتِىَ كِتَـٰبَهُۥ وَرَآءَ ظَهْرِهِۦ', 'وَأَمَّا مَنْ أُوتِىَ كِتَـٰبَهُۥ وَرَآءَ ظَهْرِهِۦ', '[]'::jsonb,
   'But as for he who is given his record behind his back,', 'Wa ammaa man ootiya kitaabahoo waraa-a dhahrih'),
  (84, 11, 'فَسَوْفَ يَدْعُوا۟ ثُبُورًا', 'فَسَوْفَ يَدْعُوا۟ ثُبُورًا', '[]'::jsonb,
   'He will cry out for destruction', 'Fasawfa yad''oo thubooraa'),
  (84, 12, 'وَيَصْلَىٰ سَعِيرًا', 'وَيَصْلَىٰ سَعِيرًا', '[]'::jsonb,
   'And [enter to] burn in a Blaze.', 'Wa yaslaa sa''eeraa'),
  (84, 13, 'إِنَّهُۥ كَانَ فِىٓ أَهْلِهِۦ مَسْرُورًا', 'إِنَّهُۥ كَانَ فِىٓ أَهْلِهِۦ مَسْرُورًا', '[]'::jsonb,
   'Indeed, he had [once] been among his people in happiness;', 'Innahoo kaana fee ahlihee masrooraa'),
  (84, 14, 'إِنَّهُۥ ظَنَّ أَن لَّن يَحُورَ', 'إِنَّهُۥ ظَنَّ أَن لَّن يَحُورَ', '[]'::jsonb,
   'Indeed, he had thought he would never return [to Allah].', 'Innahoo dhanna al-lay yahoor'),
  (84, 15, 'بَلَىٰٓ إِنَّ رَبَّهُۥ كَانَ بِهِۦ بَصِيرًا', 'بَلَىٰٓ إِنَّ رَبَّهُۥ كَانَ بِهِۦ بَصِيرًا', '[]'::jsonb,
   'But yes! Indeed, his Lord was ever, of him, Seeing.', 'Balaa inna rabbahoo kaana bihee baseeraa'),
  (84, 16, 'فَلَآ أُقْسِمُ بِٱلشَّفَقِ', 'فَلَآ أُقْسِمُ بِٱلشَّفَقِ', '[]'::jsonb,
   'So I swear by the twilight glow', 'Falaa uqsimu bish-shafaq'),
  (84, 17, 'وَٱلَّيْلِ وَمَا وَسَقَ', 'وَٱلَّيْلِ وَمَا وَسَقَ', '[]'::jsonb,
   'And [by] the night and what it envelops', 'Wallayli wa maa wasaq'),
  (84, 18, 'وَٱلْقَمَرِ إِذَا ٱتَّسَقَ', 'وَٱلْقَمَرِ إِذَا ٱتَّسَقَ', '[]'::jsonb,
   'And [by] the moon when it becomes full', 'Wal-qamari idhat-tasaq'),
  (84, 19, 'لَتَرْكَبُنَّ طَبَقًا عَن طَبَقٍ', 'لَتَرْكَبُنَّ طَبَقًا عَن طَبَقٍ', '[]'::jsonb,
   '[That] you will surely embark upon [i.e., experience] state after state.', 'Latarkabunna tabaqan ''an tabaq'),
  (84, 20, 'فَمَا لَهُمْ لَا يُؤْمِنُونَ', 'فَمَا لَهُمْ لَا يُؤْمِنُونَ', '[]'::jsonb,
   'So what is [the matter] with them [that] they do not believe,', 'Famaa lahum laa yu-minoon'),
  (84, 21, 'وَإِذَا قُرِئَ عَلَيْهِمُ ٱلْقُرْءَانُ لَا يَسْجُدُونَ ۩', 'وَإِذَا قُرِئَ عَلَيْهِمُ ٱلْقُرْءَانُ لَا يَسْجُدُونَ', '[]'::jsonb,
   'And when the Qur''an is recited to them, they do not prostrate [to Allah]?', 'Wa idhaa quri-a ''alayhimul-qur-aanu laa yasjudoon'),
  (84, 22, 'بَلِ ٱلَّذِينَ كَفَرُوا۟ يُكَذِّبُونَ', 'بَلِ ٱلَّذِينَ كَفَرُوا۟ يُكَذِّبُونَ', '[]'::jsonb,
   'But those who have disbelieved deny,', 'Balil-ladheena kafaroo yukadhdhiboon'),
  (84, 23, 'وَٱللَّهُ أَعْلَمُ بِمَا يُوعُونَ', 'وَٱللَّهُ أَعْلَمُ بِمَا يُوعُونَ', '[]'::jsonb,
   'And Allah is most knowing of what they keep within themselves.', 'Wallaahu a''lamu bimaa yoo''oon'),
  (84, 24, 'فَبَشِّرْهُم بِعَذَابٍ أَلِيمٍ', 'فَبَشِّرْهُم بِعَذَابٍ أَلِيمٍ', '[]'::jsonb,
   'So give them tidings of a painful punishment,', 'Fabashshirhum bi-''adhaabin aleem'),
  (84, 25, 'إِلَّا ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ لَهُمْ أَجْرٌ غَيْرُ مَمْنُونٍۭ', 'إِلَّا ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ لَهُمْ أَجْرٌ غَيْرُ مَمْنُونٍۭ', '[]'::jsonb,
   'Except for those who believe and do righteous deeds. For them is a reward uninterrupted.', 'Illal-ladheena aamanoo wa ''amilus-saalihaati lahum ajrun ghayru mamnoon');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Balad', 26, 10 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Layl', 27, 10 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Buruj', 28, 11 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Inshiqaq', 29, 12 from units where title = 'Short Surahs';

do $$
declare
  v_row record;
  v_lesson_id int;
  v_exercise_id int;
  v_ayah record;
  v_start_id bigint;
  v_end_id bigint;
  v_seq int;
begin
  for v_row in
    select * from (values
      ('Al-Balad', 90::smallint, 1::smallint, 20::smallint),
      ('Al-Layl', 92::smallint, 1::smallint, 21::smallint),
      ('Al-Buruj', 85::smallint, 1::smallint, 22::smallint),
      ('Al-Inshiqaq', 84::smallint, 1::smallint, 25::smallint)
    ) as t(lesson_title, surah_number, first_ayah, last_ayah)
  loop
    select l.id into v_lesson_id from lessons l join units u on u.id = l.unit_id
      where u.title = 'Short Surahs' and l.title = v_row.lesson_title;

    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'prayer_step', 1) returning id into v_exercise_id;
    insert into exercise_prayer_step (exercise_id, instruction_en) values (v_exercise_id, 'Recite Surat ' || v_row.lesson_title || ':');

    v_seq := 1;
    for v_ayah in
      select id from ayat where surah_number = v_row.surah_number
        and ayah_number between v_row.first_ayah and v_row.last_ayah
      order by ayah_number
    loop
      v_seq := v_seq + 1;
      insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
      insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_ayah.id, v_ayah.id);
    end loop;

    select id into v_start_id from ayat where surah_number = v_row.surah_number and ayah_number = v_row.first_ayah;
    select id into v_end_id from ayat where surah_number = v_row.surah_number and ayah_number = v_row.last_ayah;
    v_seq := v_seq + 1;
    insert into exercises (lesson_id, exercise_type, sequence_order) values (v_lesson_id, 'reading_passage', v_seq) returning id into v_exercise_id;
    insert into exercise_reading_passage (exercise_id, start_ayah_id, end_ayah_id) values (v_exercise_id, v_start_id, v_end_id);
  end loop;
end $$;
