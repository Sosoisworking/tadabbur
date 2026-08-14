-- Adds the last batch of the 78-92 range to "Short Surahs": An-Naba
-- (78, 40 ayahs), 'Abasa (80, 42), An-Nazi'at (79, 46). Three rather
-- than four, because these are all that remained of that range after
-- migrations 0044-0046.
--
-- NOT yet the whole juz: a post-push coverage check against surahs
-- 78-114 found Al-'Alaq (96, 19 ayahs) was never added by any batch.
-- It slipped through because the batching was framed first as "every
-- surah with <=11 ayahs" (migrations 0036-0043) and then as "the
-- remaining 78-92 range" (0044-0047) — Al-'Alaq sits in neither, being
-- a 19-ayah surah numbered above 92. Migration 0048 adds it and
-- completes the juz.
--
-- Same verification discipline as every prior batch: Uthmani text
-- batched per chapter, Saheeh International translation (resource 20)
-- and transliteration (resource 57) fetched individually per verse
-- from Quran.com, restyled into this app's established convention.
-- WebFetch hit its session quota partway through 'Abasa's
-- transliteration fetches and recovered within the same session (same
-- as migration 0046's Al-Fajr), so no WebSearch fallback was needed —
-- noted per the established practice of documenting sourcing hiccups.
-- Live check before writing confirmed none of these 3 surahs have an
-- existing `surahs` or `ayat` row.
--
-- Built directly in the current lesson shape: prayer_step, one
-- reading_passage card per ayah, then a closing full-surah recap — no
-- recall_quiz (removed from the unit per migration 0041).

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (78, 'النبإ', 'An-Naba', 40, 'meccan'),
  (80, 'عبس', '''Abasa', 42, 'meccan'),
  (79, 'النازعات', 'An-Nazi''at', 46, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en, transliteration) values
  (78, 1, 'عَمَّ يَتَسَآءَلُونَ', 'عَمَّ يَتَسَآءَلُونَ', '[]'::jsonb,
   'About what are they asking one another?', '''Amma yatasaa-aloon'),
  (78, 2, 'عَنِ ٱلنَّبَإِ ٱلْعَظِيمِ', 'عَنِ ٱلنَّبَإِ ٱلْعَظِيمِ', '[]'::jsonb,
   'About the great news -', '''Anin-naba-il-''adheem'),
  (78, 3, 'ٱلَّذِى هُمْ فِيهِ مُخْتَلِفُونَ', 'ٱلَّذِى هُمْ فِيهِ مُخْتَلِفُونَ', '[]'::jsonb,
   'That over which they are in disagreement.', 'Alladhee hum feehi mukhtalifoon'),
  (78, 4, 'كَلَّا سَيَعْلَمُونَ', 'كَلَّا سَيَعْلَمُونَ', '[]'::jsonb,
   'No! They are going to know.', 'Kallaa saya''lamoon'),
  (78, 5, 'ثُمَّ كَلَّا سَيَعْلَمُونَ', 'ثُمَّ كَلَّا سَيَعْلَمُونَ', '[]'::jsonb,
   'Then, no! They are going to know.', 'Thumma kallaa saya''lamoon'),
  (78, 6, 'أَلَمْ نَجْعَلِ ٱلْأَرْضَ مِهَـٰدًا', 'أَلَمْ نَجْعَلِ ٱلْأَرْضَ مِهَـٰدًا', '[]'::jsonb,
   'Have We not made the earth a resting place?', 'Alam naj''alil-arda mihaadaa'),
  (78, 7, 'وَٱلْجِبَالَ أَوْتَادًا', 'وَٱلْجِبَالَ أَوْتَادًا', '[]'::jsonb,
   'And the mountains as stakes?', 'Wal-jibaala awtaadaa'),
  (78, 8, 'وَخَلَقْنَـٰكُمْ أَزْوَٰجًا', 'وَخَلَقْنَـٰكُمْ أَزْوَٰجًا', '[]'::jsonb,
   'And We created you in pairs.', 'Wa khalaqnaakum azwaajaa'),
  (78, 9, 'وَجَعَلْنَا نَوْمَكُمْ سُبَاتًا', 'وَجَعَلْنَا نَوْمَكُمْ سُبَاتًا', '[]'::jsonb,
   'And made your sleep [a means for] rest', 'Wa ja''alnaa nawmakum subaataa'),
  (78, 10, 'وَجَعَلْنَا ٱلَّيْلَ لِبَاسًا', 'وَجَعَلْنَا ٱلَّيْلَ لِبَاسًا', '[]'::jsonb,
   'And made the night as clothing.', 'Wa ja''alnal-layla libaasaa'),
  (78, 11, 'وَجَعَلْنَا ٱلنَّهَارَ مَعَاشًا', 'وَجَعَلْنَا ٱلنَّهَارَ مَعَاشًا', '[]'::jsonb,
   'And made the day for livelihood.', 'Wa ja''alnan-nahaara ma''aashaa'),
  (78, 12, 'وَبَنَيْنَا فَوْقَكُمْ سَبْعًا شِدَادًا', 'وَبَنَيْنَا فَوْقَكُمْ سَبْعًا شِدَادًا', '[]'::jsonb,
   'And constructed above you seven strong [heavens].', 'Wa banaynaa fawqakum sab''an shidaadaa'),
  (78, 13, 'وَجَعَلْنَا سِرَاجًا وَهَّاجًا', 'وَجَعَلْنَا سِرَاجًا وَهَّاجًا', '[]'::jsonb,
   'And made [therein] a burning lamp', 'Wa ja''alnaa siraajaw-wahhaajaa'),
  (78, 14, 'وَأَنزَلْنَا مِنَ ٱلْمُعْصِرَٰتِ مَآءً ثَجَّاجًا', 'وَأَنزَلْنَا مِنَ ٱلْمُعْصِرَٰتِ مَآءً ثَجَّاجًا', '[]'::jsonb,
   'And sent down, from the rain clouds, pouring water.', 'Wa anzalnaa minal-mu''siraati maa-an thajjaajaa'),
  (78, 15, 'لِّنُخْرِجَ بِهِۦ حَبًّا وَنَبَاتًا', 'لِّنُخْرِجَ بِهِۦ حَبًّا وَنَبَاتًا', '[]'::jsonb,
   'That We may bring forth thereby grain and vegetation.', 'Linukhrija bihee habbaw-wa nabaataa'),
  (78, 16, 'وَجَنَّـٰتٍ أَلْفَافًا', 'وَجَنَّـٰتٍ أَلْفَافًا', '[]'::jsonb,
   'And gardens of entwined growth.', 'Wa jannaatin alfaafaa'),
  (78, 17, 'إِنَّ يَوْمَ ٱلْفَصْلِ كَانَ مِيقَـٰتًا', 'إِنَّ يَوْمَ ٱلْفَصْلِ كَانَ مِيقَـٰتًا', '[]'::jsonb,
   'Indeed, the Day of Judgement is an appointed time -', 'Inna yawmal-fasli kaana meeqaataa'),
  (78, 18, 'يَوْمَ يُنفَخُ فِى ٱلصُّورِ فَتَأْتُونَ أَفْوَاجًا', 'يَوْمَ يُنفَخُ فِى ٱلصُّورِ فَتَأْتُونَ أَفْوَاجًا', '[]'::jsonb,
   'The Day the Horn is blown and you will come forth in multitudes', 'Yawma yunfakhu fis-soori fata-toona afwaajaa'),
  (78, 19, 'وَفُتِحَتِ ٱلسَّمَآءُ فَكَانَتْ أَبْوَٰبًا', 'وَفُتِحَتِ ٱلسَّمَآءُ فَكَانَتْ أَبْوَٰبًا', '[]'::jsonb,
   'And the heaven is opened and will become gateways.', 'Wa futihatis-samaa-u fakaanat abwaabaa'),
  (78, 20, 'وَسُيِّرَتِ ٱلْجِبَالُ فَكَانَتْ سَرَابًا', 'وَسُيِّرَتِ ٱلْجِبَالُ فَكَانَتْ سَرَابًا', '[]'::jsonb,
   'And the mountains are removed and will be [but] a mirage.', 'Wa suyyiratil-jibaalu fakaanat saraabaa'),
  (78, 21, 'إِنَّ جَهَنَّمَ كَانَتْ مِرْصَادًا', 'إِنَّ جَهَنَّمَ كَانَتْ مِرْصَادًا', '[]'::jsonb,
   'Indeed, Hell has been lying in wait', 'Inna jahannama kaanat mirsaadaa'),
  (78, 22, 'لِّلطَّـٰغِينَ مَـَٔابًا', 'لِّلطَّـٰغِينَ مَـَٔابًا', '[]'::jsonb,
   'For the transgressors, a place of return,', 'Littaagheena ma-aabaa'),
  (78, 23, 'لَّـٰبِثِينَ فِيهَآ أَحْقَابًا', 'لَّـٰبِثِينَ فِيهَآ أَحْقَابًا', '[]'::jsonb,
   'In which they will remain for ages [unending].', 'Laabitheena feehaa ahqaabaa'),
  (78, 24, 'لَّا يَذُوقُونَ فِيهَا بَرْدًا وَلَا شَرَابًا', 'لَّا يَذُوقُونَ فِيهَا بَرْدًا وَلَا شَرَابًا', '[]'::jsonb,
   'They will not taste therein [any] coolness or drink.', 'Laa yadhooqoona feehaa bardaw-wa laa sharaabaa'),
  (78, 25, 'إِلَّا حَمِيمًا وَغَسَّاقًا', 'إِلَّا حَمِيمًا وَغَسَّاقًا', '[]'::jsonb,
   'Except scalding water and [foul] purulence -', 'Illaa hameemaw-wa ghassaaqaa'),
  (78, 26, 'جَزَآءً وِفَاقًا', 'جَزَآءً وِفَاقًا', '[]'::jsonb,
   'An appropriate recompense.', 'Jazaa-aw-wifaaqaa'),
  (78, 27, 'إِنَّهُمْ كَانُوا۟ لَا يَرْجُونَ حِسَابًا', 'إِنَّهُمْ كَانُوا۟ لَا يَرْجُونَ حِسَابًا', '[]'::jsonb,
   'Indeed, they were not expecting an account', 'Innahum kaanoo laa yarjoona hisaabaa'),
  (78, 28, 'وَكَذَّبُوا۟ بِـَٔايَـٰتِنَا كِذَّابًا', 'وَكَذَّبُوا۟ بِـَٔايَـٰتِنَا كِذَّابًا', '[]'::jsonb,
   'And denied Our verses with [emphatic] denial.', 'Wa kadhdhaboo bi-aayaatinaa kidhdhaabaa'),
  (78, 29, 'وَكُلَّ شَىْءٍ أَحْصَيْنَـٰهُ كِتَـٰبًا', 'وَكُلَّ شَىْءٍ أَحْصَيْنَـٰهُ كِتَـٰبًا', '[]'::jsonb,
   'But all things We have enumerated in writing.', 'Wa kulla shay-in ahsaynaahu kitaabaa'),
  (78, 30, 'فَذُوقُوا۟ فَلَن نَّزِيدَكُمْ إِلَّا عَذَابًا', 'فَذُوقُوا۟ فَلَن نَّزِيدَكُمْ إِلَّا عَذَابًا', '[]'::jsonb,
   'So taste [the penalty], and never will We increase you except in torment.', 'Fadhooqoo falan nazeedakum illaa ''adhaabaa'),
  (78, 31, 'إِنَّ لِلْمُتَّقِينَ مَفَازًا', 'إِنَّ لِلْمُتَّقِينَ مَفَازًا', '[]'::jsonb,
   'Indeed, for the righteous is attainment', 'Inna lil-muttaqeena mafaazaa'),
  (78, 32, 'حَدَآئِقَ وَأَعْنَـٰبًا', 'حَدَآئِقَ وَأَعْنَـٰبًا', '[]'::jsonb,
   'Gardens and grapevines.', 'Hadaa-iqa wa a''naabaa'),
  (78, 33, 'وَكَوَاعِبَ أَتْرَابًا', 'وَكَوَاعِبَ أَتْرَابًا', '[]'::jsonb,
   'And full-breasted [companions] of equal age.', 'Wa kawaa''iba atraabaa'),
  (78, 34, 'وَكَأْسًا دِهَاقًا', 'وَكَأْسًا دِهَاقًا', '[]'::jsonb,
   'And a full cup.', 'Wa ka-san dihaaqaa'),
  (78, 35, 'لَّا يَسْمَعُونَ فِيهَا لَغْوًا وَلَا كِذَّٰبًا', 'لَّا يَسْمَعُونَ فِيهَا لَغْوًا وَلَا كِذَّٰبًا', '[]'::jsonb,
   'No ill speech will they hear therein or any falsehood -', 'Laa yasma''oona feehaa laghwaw-wa laa kidhdhaabaa'),
  (78, 36, 'جَزَآءً مِّن رَّبِّكَ عَطَآءً حِسَابًا', 'جَزَآءً مِّن رَّبِّكَ عَطَآءً حِسَابًا', '[]'::jsonb,
   '[As] reward from your Lord, [a generous] gift [made due by] account,', 'Jazaa-am-mir-rabbika ''ataa-an hisaabaa'),
  (78, 37, 'رَّبِّ ٱلسَّمَـٰوَٰتِ وَٱلْأَرْضِ وَمَا بَيْنَهُمَا ٱلرَّحْمَـٰنِ ۖ لَا يَمْلِكُونَ مِنْهُ خِطَابًا', 'رَّبِّ ٱلسَّمَـٰوَٰتِ وَٱلْأَرْضِ وَمَا بَيْنَهُمَا ٱلرَّحْمَـٰنِ ۖ لَا يَمْلِكُونَ مِنْهُ خِطَابًا', '[]'::jsonb,
   '[From] the Lord of the heavens and the earth and whatever is between them, the Most Merciful. They possess not from Him [authority for] speech.', 'Rabbis-samaawaati wal-ardi wa maa baynahumar-rahmaani laa yamlikoona minhu khitaabaa'),
  (78, 38, 'يَوْمَ يَقُومُ ٱلرُّوحُ وَٱلْمَلَـٰٓئِكَةُ صَفًّا ۖ لَّا يَتَكَلَّمُونَ إِلَّا مَنْ أَذِنَ لَهُ ٱلرَّحْمَـٰنُ وَقَالَ صَوَابًا', 'يَوْمَ يَقُومُ ٱلرُّوحُ وَٱلْمَلَـٰٓئِكَةُ صَفًّا ۖ لَّا يَتَكَلَّمُونَ إِلَّا مَنْ أَذِنَ لَهُ ٱلرَّحْمَـٰنُ وَقَالَ صَوَابًا', '[]'::jsonb,
   'The Day that the Spirit [i.e., Gabriel] and the angels will stand in rows, they will not speak except for one whom the Most Merciful permits, and he will say what is correct.', 'Yawma yaqoomur-roohu wal-malaa-ikatu saffal-laa yatakallamoona illaa man adhina lahur-rahmaanu wa qaala sawaabaa'),
  (78, 39, 'ذَٰلِكَ ٱلْيَوْمُ ٱلْحَقُّ ۖ فَمَن شَآءَ ٱتَّخَذَ إِلَىٰ رَبِّهِۦ مَـَٔابًا', 'ذَٰلِكَ ٱلْيَوْمُ ٱلْحَقُّ ۖ فَمَن شَآءَ ٱتَّخَذَ إِلَىٰ رَبِّهِۦ مَـَٔابًا', '[]'::jsonb,
   'That is the True [i.e., certain] Day; so he who wills may take to his Lord a [way of] return.', 'Dhaalikal-yawmul-haqqu faman shaa-at-takhadha ilaa rabbihee ma-aabaa'),
  (78, 40, 'إِنَّآ أَنذَرْنَـٰكُمْ عَذَابًا قَرِيبًا يَوْمَ يَنظُرُ ٱلْمَرْءُ مَا قَدَّمَتْ يَدَاهُ وَيَقُولُ ٱلْكَافِرُ يَـٰلَيْتَنِى كُنتُ تُرَٰبًۢا', 'إِنَّآ أَنذَرْنَـٰكُمْ عَذَابًا قَرِيبًا يَوْمَ يَنظُرُ ٱلْمَرْءُ مَا قَدَّمَتْ يَدَاهُ وَيَقُولُ ٱلْكَافِرُ يَـٰلَيْتَنِى كُنتُ تُرَٰبًۢا', '[]'::jsonb,
   'Indeed, We have warned you of an impending punishment on the Day when a man will observe what his hands have put forth and the disbeliever will say, "Oh, I wish that I were dust!"', 'Innaa andharnaakum ''adhaaban qareebay-yawma yandhurul-mar-u maa qaddamat yadaahu wa yaqoolul-kaafiru yaa laytanee kuntu turaabaa'),

  (80, 1, 'عَبَسَ وَتَوَلَّىٰٓ', 'عَبَسَ وَتَوَلَّىٰٓ', '[]'::jsonb,
   'He [i.e., the Prophet] frowned and turned away', '''Abasa wa tawallaa'),
  (80, 2, 'أَن جَآءَهُ ٱلْأَعْمَىٰ', 'أَن جَآءَهُ ٱلْأَعْمَىٰ', '[]'::jsonb,
   'Because there came to him the blind man, [interrupting].', 'An jaa-ahul-a''maa'),
  (80, 3, 'وَمَا يُدْرِيكَ لَعَلَّهُۥ يَزَّكَّىٰٓ', 'وَمَا يُدْرِيكَ لَعَلَّهُۥ يَزَّكَّىٰٓ', '[]'::jsonb,
   'But what would make you perceive, [O Muhammad], that perhaps he might be purified', 'Wa maa yudreeka la''allahoo yazzakkaa'),
  (80, 4, 'أَوْ يَذَّكَّرُ فَتَنفَعَهُ ٱلذِّكْرَىٰٓ', 'أَوْ يَذَّكَّرُ فَتَنفَعَهُ ٱلذِّكْرَىٰٓ', '[]'::jsonb,
   'Or be reminded and the remembrance would benefit him?', 'Aw yadhdhakkaru fatanfa''ahudh-dhikraa'),
  (80, 5, 'أَمَّا مَنِ ٱسْتَغْنَىٰ', 'أَمَّا مَنِ ٱسْتَغْنَىٰ', '[]'::jsonb,
   'As for he who thinks himself without need,', 'Ammaa manis-taghnaa'),
  (80, 6, 'فَأَنتَ لَهُۥ تَصَدَّىٰ', 'فَأَنتَ لَهُۥ تَصَدَّىٰ', '[]'::jsonb,
   'To him you give attention.', 'Fa-anta lahoo tasaddaa'),
  (80, 7, 'وَمَا عَلَيْكَ أَلَّا يَزَّكَّىٰ', 'وَمَا عَلَيْكَ أَلَّا يَزَّكَّىٰ', '[]'::jsonb,
   'And not upon you [is any blame] if he will not be purified.', 'Wa maa ''alayka allaa yazzakkaa'),
  (80, 8, 'وَأَمَّا مَن جَآءَكَ يَسْعَىٰ', 'وَأَمَّا مَن جَآءَكَ يَسْعَىٰ', '[]'::jsonb,
   'But as for he who came to you striving [for knowledge]', 'Wa ammaa man jaa-aka yas''aa'),
  (80, 9, 'وَهُوَ يَخْشَىٰ', 'وَهُوَ يَخْشَىٰ', '[]'::jsonb,
   'While he fears [Allah],', 'Wa huwa yakhshaa'),
  (80, 10, 'فَأَنتَ عَنْهُ تَلَهَّىٰ', 'فَأَنتَ عَنْهُ تَلَهَّىٰ', '[]'::jsonb,
   'From him you are distracted.', 'Fa-anta ''anhu talahhaa'),
  (80, 11, 'كَلَّآ إِنَّهَا تَذْكِرَةٌ', 'كَلَّآ إِنَّهَا تَذْكِرَةٌ', '[]'::jsonb,
   'No! Indeed, they [i.e., these verses] are a reminder;', 'Kallaa innahaa tadhkirah'),
  (80, 12, 'فَمَن شَآءَ ذَكَرَهُۥ', 'فَمَن شَآءَ ذَكَرَهُۥ', '[]'::jsonb,
   'So whoever wills may remember it.', 'Faman shaa-a dhakarah'),
  (80, 13, 'فِى صُحُفٍ مُّكَرَّمَةٍ', 'فِى صُحُفٍ مُّكَرَّمَةٍ', '[]'::jsonb,
   '[It is recorded] in honored sheets,', 'Fee suhufim-mukarramah'),
  (80, 14, 'مَّرْفُوعَةٍ مُّطَهَّرَةٍۭ', 'مَّرْفُوعَةٍ مُّطَهَّرَةٍۭ', '[]'::jsonb,
   'Exalted and purified,', 'Marfoo''atim-mutahharah'),
  (80, 15, 'بِأَيْدِى سَفَرَةٍ', 'بِأَيْدِى سَفَرَةٍ', '[]'::jsonb,
   '[Carried] by the hands of messenger-angels,', 'Bi-aydee safarah'),
  (80, 16, 'كِرَامٍۭ بَرَرَةٍ', 'كِرَامٍۭ بَرَرَةٍ', '[]'::jsonb,
   'Noble and dutiful.', 'Kiraamim-bararah'),
  (80, 17, 'قُتِلَ ٱلْإِنسَـٰنُ مَآ أَكْفَرَهُۥ', 'قُتِلَ ٱلْإِنسَـٰنُ مَآ أَكْفَرَهُۥ', '[]'::jsonb,
   'Destroyed [i.e., cursed] is man; how disbelieving is he.', 'Qutilal-insaanu maa akfarah'),
  (80, 18, 'مِنْ أَىِّ شَىْءٍ خَلَقَهُۥ', 'مِنْ أَىِّ شَىْءٍ خَلَقَهُۥ', '[]'::jsonb,
   'From what thing [i.e., substance] did He create him?', 'Min ayyi shay-in khalaqah'),
  (80, 19, 'مِن نُّطْفَةٍ خَلَقَهُۥ فَقَدَّرَهُۥ', 'مِن نُّطْفَةٍ خَلَقَهُۥ فَقَدَّرَهُۥ', '[]'::jsonb,
   'From a sperm-drop He created him and destined for him;', 'Min nutfatin khalaqahoo faqaddarah'),
  (80, 20, 'ثُمَّ ٱلسَّبِيلَ يَسَّرَهُۥ', 'ثُمَّ ٱلسَّبِيلَ يَسَّرَهُۥ', '[]'::jsonb,
   'Then He eased the way for him;', 'Thummas-sabeela yassarah'),
  (80, 21, 'ثُمَّ أَمَاتَهُۥ فَأَقْبَرَهُۥ', 'ثُمَّ أَمَاتَهُۥ فَأَقْبَرَهُۥ', '[]'::jsonb,
   'Then He causes his death and provides a grave for him.', 'Thumma amaatahoo fa-aqbarah'),
  (80, 22, 'ثُمَّ إِذَا شَآءَ أَنشَرَهُۥ', 'ثُمَّ إِذَا شَآءَ أَنشَرَهُۥ', '[]'::jsonb,
   'Then when He wills, He will resurrect him.', 'Thumma idhaa shaa-a ansharah'),
  (80, 23, 'كَلَّا لَمَّا يَقْضِ مَآ أَمَرَهُۥ', 'كَلَّا لَمَّا يَقْضِ مَآ أَمَرَهُۥ', '[]'::jsonb,
   'No! He [i.e., man] has not yet accomplished what He commanded him.', 'Kallaa lammaa yaqdi maa amarah'),
  (80, 24, 'فَلْيَنظُرِ ٱلْإِنسَـٰنُ إِلَىٰ طَعَامِهِۦٓ', 'فَلْيَنظُرِ ٱلْإِنسَـٰنُ إِلَىٰ طَعَامِهِۦٓ', '[]'::jsonb,
   'Then let mankind look at his food -', 'Falyandhuril-insaanu ilaa ta''aamih'),
  (80, 25, 'أَنَّا صَبَبْنَا ٱلْمَآءَ صَبًّا', 'أَنَّا صَبَبْنَا ٱلْمَآءَ صَبًّا', '[]'::jsonb,
   'How We poured down water in torrents,', 'Annaa sababnal-maa-a sabbaa'),
  (80, 26, 'ثُمَّ شَقَقْنَا ٱلْأَرْضَ شَقًّا', 'ثُمَّ شَقَقْنَا ٱلْأَرْضَ شَقًّا', '[]'::jsonb,
   'Then We broke open the earth, splitting [it with sprouts],', 'Thumma shaqaqnal-arda shaqqaa'),
  (80, 27, 'فَأَنۢبَتْنَا فِيهَا حَبًّا', 'فَأَنۢبَتْنَا فِيهَا حَبًّا', '[]'::jsonb,
   'And caused to grow within it grain', 'Fa-ambatnaa feehaa habbaa'),
  (80, 28, 'وَعِنَبًا وَقَضْبًا', 'وَعِنَبًا وَقَضْبًا', '[]'::jsonb,
   'And grapes and herbage', 'Wa ''inabaw-wa qadbaa'),
  (80, 29, 'وَزَيْتُونًا وَنَخْلًا', 'وَزَيْتُونًا وَنَخْلًا', '[]'::jsonb,
   'And olive and palm trees', 'Wa zaytoonaw-wa nakhlaa'),
  (80, 30, 'وَحَدَآئِقَ غُلْبًا', 'وَحَدَآئِقَ غُلْبًا', '[]'::jsonb,
   'And gardens of dense shrubbery', 'Wa hadaa-iqa ghulbaa'),
  (80, 31, 'وَفَـٰكِهَةً وَأَبًّا', 'وَفَـٰكِهَةً وَأَبًّا', '[]'::jsonb,
   'And fruit and grass -', 'Wa faakihataw-wa abbaa'),
  (80, 32, 'مَّتَـٰعًا لَّكُمْ وَلِأَنْعَـٰمِكُمْ', 'مَّتَـٰعًا لَّكُمْ وَلِأَنْعَـٰمِكُمْ', '[]'::jsonb,
   '[As] enjoyment [i.e., provision] for you and your grazing livestock.', 'Mataa''al-lakum wa li-an''aamikum'),
  (80, 33, 'فَإِذَا جَآءَتِ ٱلصَّآخَّةُ', 'فَإِذَا جَآءَتِ ٱلصَّآخَّةُ', '[]'::jsonb,
   'But when there comes the Deafening Blast', 'Fa-idhaa jaa-atis-saakhkhah'),
  (80, 34, 'يَوْمَ يَفِرُّ ٱلْمَرْءُ مِنْ أَخِيهِ', 'يَوْمَ يَفِرُّ ٱلْمَرْءُ مِنْ أَخِيهِ', '[]'::jsonb,
   'On the Day a man will flee from his brother', 'Yawma yafirrul-mar-u min akheeh'),
  (80, 35, 'وَأُمِّهِۦ وَأَبِيهِ', 'وَأُمِّهِۦ وَأَبِيهِ', '[]'::jsonb,
   'And his mother and his father', 'Wa ummihee wa abeeh'),
  (80, 36, 'وَصَـٰحِبَتِهِۦ وَبَنِيهِ', 'وَصَـٰحِبَتِهِۦ وَبَنِيهِ', '[]'::jsonb,
   'And his wife and his children,', 'Wa saahibatihee wa baneeh'),
  (80, 37, 'لِكُلِّ ٱمْرِئٍ مِّنْهُمْ يَوْمَئِذٍ شَأْنٌ يُغْنِيهِ', 'لِكُلِّ ٱمْرِئٍ مِّنْهُمْ يَوْمَئِذٍ شَأْنٌ يُغْنِيهِ', '[]'::jsonb,
   'For every man, that Day, will be a matter adequate for him.', 'Likullim-ri-im-minhum yawma-idhin sha-nuy-yughneeh'),
  (80, 38, 'وُجُوهٌ يَوْمَئِذٍ مُّسْفِرَةٌ', 'وُجُوهٌ يَوْمَئِذٍ مُّسْفِرَةٌ', '[]'::jsonb,
   '[Some] faces, that Day, will be bright -', 'Wujoohuy-yawma-idhim-musfirah'),
  (80, 39, 'ضَاحِكَةٌ مُّسْتَبْشِرَةٌ', 'ضَاحِكَةٌ مُّسْتَبْشِرَةٌ', '[]'::jsonb,
   'Laughing, rejoicing at good news.', 'Daahikatum-mustabshirah'),
  (80, 40, 'وَوُجُوهٌ يَوْمَئِذٍ عَلَيْهَا غَبَرَةٌ', 'وَوُجُوهٌ يَوْمَئِذٍ عَلَيْهَا غَبَرَةٌ', '[]'::jsonb,
   'And [other] faces, that Day, will have upon them dust.', 'Wa wujoohuy-yawma-idhin ''alayhaa ghabarah'),
  (80, 41, 'تَرْهَقُهَا قَتَرَةٌ', 'تَرْهَقُهَا قَتَرَةٌ', '[]'::jsonb,
   'Blackness will cover them.', 'Tarhaquhaa qatarah'),
  (80, 42, 'أُو۟لَـٰٓئِكَ هُمُ ٱلْكَفَرَةُ ٱلْفَجَرَةُ', 'أُو۟لَـٰٓئِكَ هُمُ ٱلْكَفَرَةُ ٱلْفَجَرَةُ', '[]'::jsonb,
   'Those are the disbelievers, the wicked ones.', 'Ulaa-ika humul-kafaratul-fajarah'),

  (79, 1, 'وَٱلنَّـٰزِعَـٰتِ غَرْقًا', 'وَٱلنَّـٰزِعَـٰتِ غَرْقًا', '[]'::jsonb,
   'By those [angels] who extract with violence', 'Wan-naazi''aati gharqaa'),
  (79, 2, 'وَٱلنَّـٰشِطَـٰتِ نَشْطًا', 'وَٱلنَّـٰشِطَـٰتِ نَشْطًا', '[]'::jsonb,
   'And [by] those who remove with ease', 'Wan-naashitaati nashtaa'),
  (79, 3, 'وَٱلسَّـٰبِحَـٰتِ سَبْحًا', 'وَٱلسَّـٰبِحَـٰتِ سَبْحًا', '[]'::jsonb,
   'And [by] those who glide [as if] swimming', 'Was-saabihaati sabhaa'),
  (79, 4, 'فَٱلسَّـٰبِقَـٰتِ سَبْقًا', 'فَٱلسَّـٰبِقَـٰتِ سَبْقًا', '[]'::jsonb,
   'And those who race each other in a race', 'Fas-saabiqaati sabqaa'),
  (79, 5, 'فَٱلْمُدَبِّرَٰتِ أَمْرًا', 'فَٱلْمُدَبِّرَٰتِ أَمْرًا', '[]'::jsonb,
   'And those who arrange [each] matter,', 'Fal-mudabbiraati amraa'),
  (79, 6, 'يَوْمَ تَرْجُفُ ٱلرَّاجِفَةُ', 'يَوْمَ تَرْجُفُ ٱلرَّاجِفَةُ', '[]'::jsonb,
   'On the Day the blast [of the Horn] will convulse [creation],', 'Yawma tarjufur-raajifah'),
  (79, 7, 'تَتْبَعُهَا ٱلرَّادِفَةُ', 'تَتْبَعُهَا ٱلرَّادِفَةُ', '[]'::jsonb,
   'There will follow it the subsequent [one].', 'Tatba''uhar-raadifah'),
  (79, 8, 'قُلُوبٌ يَوْمَئِذٍ وَاجِفَةٌ', 'قُلُوبٌ يَوْمَئِذٍ وَاجِفَةٌ', '[]'::jsonb,
   'Hearts, that Day, will tremble,', 'Quloobuy-yawma-idhiw-waajifah'),
  (79, 9, 'أَبْصَـٰرُهَا خَـٰشِعَةٌ', 'أَبْصَـٰرُهَا خَـٰشِعَةٌ', '[]'::jsonb,
   'Their eyes humbled.', 'Absaaruhaa khaashi''ah'),
  (79, 10, 'يَقُولُونَ أَءِنَّا لَمَرْدُودُونَ فِى ٱلْحَافِرَةِ', 'يَقُولُونَ أَءِنَّا لَمَرْدُودُونَ فِى ٱلْحَافِرَةِ', '[]'::jsonb,
   'They are [presently] saying, "Will we indeed be returned to [our] former state [of life]?', 'Yaqooloona a-innaa lamardoodoona fil-haafirah'),
  (79, 11, 'أَءِذَا كُنَّا عِظَـٰمًا نَّخِرَةً', 'أَءِذَا كُنَّا عِظَـٰمًا نَّخِرَةً', '[]'::jsonb,
   'Even if we should be decayed bones?', 'A-idhaa kunnaa ''idhaaman nakhirah'),
  (79, 12, 'قَالُوا۟ تِلْكَ إِذًا كَرَّةٌ خَاسِرَةٌ', 'قَالُوا۟ تِلْكَ إِذًا كَرَّةٌ خَاسِرَةٌ', '[]'::jsonb,
   'They say, "That, then, would be a losing return."', 'Qaaloo tilka idhan karratun khaasirah'),
  (79, 13, 'فَإِنَّمَا هِىَ زَجْرَةٌ وَٰحِدَةٌ', 'فَإِنَّمَا هِىَ زَجْرَةٌ وَٰحِدَةٌ', '[]'::jsonb,
   'Indeed, it will be but one shout,', 'Fa-innamaa hiya zajratuw-waahidah'),
  (79, 14, 'فَإِذَا هُم بِٱلسَّاهِرَةِ', 'فَإِذَا هُم بِٱلسَّاهِرَةِ', '[]'::jsonb,
   'And suddenly they will be [alert] upon the earth''s surface.', 'Fa-idhaa hum bis-saahirah'),
  (79, 15, 'هَلْ أَتَىٰكَ حَدِيثُ مُوسَىٰٓ', 'هَلْ أَتَىٰكَ حَدِيثُ مُوسَىٰٓ', '[]'::jsonb,
   'Has there reached you the story of Moses? -', 'Hal ataaka hadeethu moosaa'),
  (79, 16, 'إِذْ نَادَىٰهُ رَبُّهُۥ بِٱلْوَادِ ٱلْمُقَدَّسِ طُوًى', 'إِذْ نَادَىٰهُ رَبُّهُۥ بِٱلْوَادِ ٱلْمُقَدَّسِ طُوًى', '[]'::jsonb,
   'When his Lord called to him in the sacred valley of Tuwa,', 'Idh naadaahu rabbuhoo bil-waadil-muqaddasi tuwaa'),
  (79, 17, 'ٱذْهَبْ إِلَىٰ فِرْعَوْنَ إِنَّهُۥ طَغَىٰ', 'ٱذْهَبْ إِلَىٰ فِرْعَوْنَ إِنَّهُۥ طَغَىٰ', '[]'::jsonb,
   'Go to Pharaoh. Indeed, he has transgressed.', 'Idhhab ilaa fir''awna innahoo taghaa'),
  (79, 18, 'فَقُلْ هَل لَّكَ إِلَىٰٓ أَن تَزَكَّىٰ', 'فَقُلْ هَل لَّكَ إِلَىٰٓ أَن تَزَكَّىٰ', '[]'::jsonb,
   'And say to him, "Would you [be willing to] purify yourself', 'Faqul hal laka ilaa an tazakkaa'),
  (79, 19, 'وَأَهْدِيَكَ إِلَىٰ رَبِّكَ فَتَخْشَىٰ', 'وَأَهْدِيَكَ إِلَىٰ رَبِّكَ فَتَخْشَىٰ', '[]'::jsonb,
   'And let me guide you to your Lord so you would fear [Him]?"', 'Wa ahdiyaka ilaa rabbika fatakhshaa'),
  (79, 20, 'فَأَرَىٰهُ ٱلْـَٔايَةَ ٱلْكُبْرَىٰ', 'فَأَرَىٰهُ ٱلْـَٔايَةَ ٱلْكُبْرَىٰ', '[]'::jsonb,
   'And he showed him the greatest sign,', 'Fa-araahul-aayatal-kubraa'),
  (79, 21, 'فَكَذَّبَ وَعَصَىٰ', 'فَكَذَّبَ وَعَصَىٰ', '[]'::jsonb,
   'But he [i.e., Pharaoh] denied and disobeyed.', 'Fakadhdhaba wa ''asaa'),
  (79, 22, 'ثُمَّ أَدْبَرَ يَسْعَىٰ', 'ثُمَّ أَدْبَرَ يَسْعَىٰ', '[]'::jsonb,
   'Then he turned his back, striving [i.e., plotting].', 'Thumma adbara yas''aa'),
  (79, 23, 'فَحَشَرَ فَنَادَىٰ', 'فَحَشَرَ فَنَادَىٰ', '[]'::jsonb,
   'And he gathered [his people] and called out.', 'Fahashara fanaadaa'),
  (79, 24, 'فَقَالَ أَنَا۠ رَبُّكُمُ ٱلْأَعْلَىٰ', 'فَقَالَ أَنَا۠ رَبُّكُمُ ٱلْأَعْلَىٰ', '[]'::jsonb,
   'And said, "I am your most exalted lord."', 'Faqaala anaa rabbukumul-a''laa'),
  (79, 25, 'فَأَخَذَهُ ٱللَّهُ نَكَالَ ٱلْـَٔاخِرَةِ وَٱلْأُولَىٰٓ', 'فَأَخَذَهُ ٱللَّهُ نَكَالَ ٱلْـَٔاخِرَةِ وَٱلْأُولَىٰٓ', '[]'::jsonb,
   'So Allah seized him in exemplary punishment for the last and the first [transgression].', 'Fa-akhadhahullaahu nakaalal-aakhirati wal-oolaa'),
  (79, 26, 'إِنَّ فِى ذَٰلِكَ لَعِبْرَةً لِّمَن يَخْشَىٰٓ', 'إِنَّ فِى ذَٰلِكَ لَعِبْرَةً لِّمَن يَخْشَىٰٓ', '[]'::jsonb,
   'Indeed in that is a lesson [i.e., warning] for whoever would fear [Allah].', 'Inna fee dhaalika la''ibratal-limay-yakhshaa'),
  (79, 27, 'ءَأَنتُمْ أَشَدُّ خَلْقًا أَمِ ٱلسَّمَآءُ ۚ بَنَىٰهَا', 'ءَأَنتُمْ أَشَدُّ خَلْقًا أَمِ ٱلسَّمَآءُ ۚ بَنَىٰهَا', '[]'::jsonb,
   'Are you a more difficult creation or is the heaven? He constructed it.', 'A-antum ashaddu khalqan amis-samaa-u banaahaa'),
  (79, 28, 'رَفَعَ سَمْكَهَا فَسَوَّىٰهَا', 'رَفَعَ سَمْكَهَا فَسَوَّىٰهَا', '[]'::jsonb,
   'He raised its ceiling and proportioned it.', 'Rafa''a samkahaa fasawwaahaa'),
  (79, 29, 'وَأَغْطَشَ لَيْلَهَا وَأَخْرَجَ ضُحَىٰهَا', 'وَأَغْطَشَ لَيْلَهَا وَأَخْرَجَ ضُحَىٰهَا', '[]'::jsonb,
   'And He darkened its night and extracted its brightness.', 'Wa aghtasha laylahaa wa akhraja duhaahaa'),
  (79, 30, 'وَٱلْأَرْضَ بَعْدَ ذَٰلِكَ دَحَىٰهَآ', 'وَٱلْأَرْضَ بَعْدَ ذَٰلِكَ دَحَىٰهَآ', '[]'::jsonb,
   'And after that He spread the earth.', 'Wal-arda ba''da dhaalika dahaahaa'),
  (79, 31, 'أَخْرَجَ مِنْهَا مَآءَهَا وَمَرْعَىٰهَا', 'أَخْرَجَ مِنْهَا مَآءَهَا وَمَرْعَىٰهَا', '[]'::jsonb,
   'He extracted from it its water and its pasture,', 'Akhraja minhaa maa-ahaa wa mar''aahaa'),
  (79, 32, 'وَٱلْجِبَالَ أَرْسَىٰهَا', 'وَٱلْجِبَالَ أَرْسَىٰهَا', '[]'::jsonb,
   'And the mountains He set firmly', 'Wal-jibaala arsaahaa'),
  (79, 33, 'مَتَـٰعًا لَّكُمْ وَلِأَنْعَـٰمِكُمْ', 'مَتَـٰعًا لَّكُمْ وَلِأَنْعَـٰمِكُمْ', '[]'::jsonb,
   'As enjoyment [i.e., provision] for you and your grazing livestock.', 'Mataa''al-lakum wa li-an''aamikum'),
  (79, 34, 'فَإِذَا جَآءَتِ ٱلطَّآمَّةُ ٱلْكُبْرَىٰ', 'فَإِذَا جَآءَتِ ٱلطَّآمَّةُ ٱلْكُبْرَىٰ', '[]'::jsonb,
   'But when there comes the greatest Overwhelming Calamity', 'Fa-idhaa jaa-atit-taammatul-kubraa'),
  (79, 35, 'يَوْمَ يَتَذَكَّرُ ٱلْإِنسَـٰنُ مَا سَعَىٰ', 'يَوْمَ يَتَذَكَّرُ ٱلْإِنسَـٰنُ مَا سَعَىٰ', '[]'::jsonb,
   'The Day when man will remember that for which he strove,', 'Yawma yatadhakkarul-insaanu maa sa''aa'),
  (79, 36, 'وَبُرِّزَتِ ٱلْجَحِيمُ لِمَن يَرَىٰ', 'وَبُرِّزَتِ ٱلْجَحِيمُ لِمَن يَرَىٰ', '[]'::jsonb,
   'And Hellfire will be exposed for [all] those who see -', 'Wa burrizatil-jaheemu limay-yaraa'),
  (79, 37, 'فَأَمَّا مَن طَغَىٰ', 'فَأَمَّا مَن طَغَىٰ', '[]'::jsonb,
   'So as for he who transgressed', 'Fa-ammaa man taghaa'),
  (79, 38, 'وَءَاثَرَ ٱلْحَيَوٰةَ ٱلدُّنْيَا', 'وَءَاثَرَ ٱلْحَيَوٰةَ ٱلدُّنْيَا', '[]'::jsonb,
   'And preferred the life of the world,', 'Wa aatharal-hayaatad-dunyaa'),
  (79, 39, 'فَإِنَّ ٱلْجَحِيمَ هِىَ ٱلْمَأْوَىٰ', 'فَإِنَّ ٱلْجَحِيمَ هِىَ ٱلْمَأْوَىٰ', '[]'::jsonb,
   'Then indeed, Hellfire will be [his] refuge.', 'Fa-innal-jaheema hiyal-ma-waa'),
  (79, 40, 'وَأَمَّا مَنْ خَافَ مَقَامَ رَبِّهِۦ وَنَهَى ٱلنَّفْسَ عَنِ ٱلْهَوَىٰ', 'وَأَمَّا مَنْ خَافَ مَقَامَ رَبِّهِۦ وَنَهَى ٱلنَّفْسَ عَنِ ٱلْهَوَىٰ', '[]'::jsonb,
   'But as for he who feared the position of his Lord and prevented the soul from [unlawful] inclination,', 'Wa ammaa man khaafa maqaama rabbihee wa nahan-nafsa ''anil-hawaa'),
  (79, 41, 'فَإِنَّ ٱلْجَنَّةَ هِىَ ٱلْمَأْوَىٰ', 'فَإِنَّ ٱلْجَنَّةَ هِىَ ٱلْمَأْوَىٰ', '[]'::jsonb,
   'Then indeed, Paradise will be [his] refuge.', 'Fa-innal-jannata hiyal-ma-waa'),
  (79, 42, 'يَسْـَٔلُونَكَ عَنِ ٱلسَّاعَةِ أَيَّانَ مُرْسَىٰهَا', 'يَسْـَٔلُونَكَ عَنِ ٱلسَّاعَةِ أَيَّانَ مُرْسَىٰهَا', '[]'::jsonb,
   'They ask you, [O Muhammad], about the Hour: when is its arrival?', 'Yas-aloonaka ''anis-saa''ati ayyaana mursaahaa'),
  (79, 43, 'فِيمَ أَنتَ مِن ذِكْرَىٰهَآ', 'فِيمَ أَنتَ مِن ذِكْرَىٰهَآ', '[]'::jsonb,
   'In what [position] are you that you should mention it?', 'Feema anta min dhikraahaa'),
  (79, 44, 'إِلَىٰ رَبِّكَ مُنتَهَىٰهَآ', 'إِلَىٰ رَبِّكَ مُنتَهَىٰهَآ', '[]'::jsonb,
   'To your Lord is its finality.', 'Ilaa rabbika muntahaahaa'),
  (79, 45, 'إِنَّمَآ أَنتَ مُنذِرُ مَن يَخْشَىٰهَا', 'إِنَّمَآ أَنتَ مُنذِرُ مَن يَخْشَىٰهَا', '[]'::jsonb,
   'You are only a warner for those who fear it.', 'Innamaa anta mundhiru may-yakhshaahaa'),
  (79, 46, 'كَأَنَّهُمْ يَوْمَ يَرَوْنَهَا لَمْ يَلْبَثُوٓا۟ إِلَّا عَشِيَّةً أَوْ ضُحَىٰهَا', 'كَأَنَّهُمْ يَوْمَ يَرَوْنَهَا لَمْ يَلْبَثُوٓا۟ إِلَّا عَشِيَّةً أَوْ ضُحَىٰهَا', '[]'::jsonb,
   'It will be, on the Day they see it, as though they had not remained [in the world] except for an afternoon or a morning thereof.', 'Ka-annahum yawma yarawnahaa lam yalbathoo illaa ''ashiyyatan aw duhaahaa');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'An-Naba', 34, 18 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, '''Abasa', 35, 19 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'An-Nazi''at', 36, 21 from units where title = 'Short Surahs';

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
      ('An-Naba', 78::smallint, 1::smallint, 40::smallint),
      ('''Abasa', 80::smallint, 1::smallint, 42::smallint),
      ('An-Nazi''at', 79::smallint, 1::smallint, 46::smallint)
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
