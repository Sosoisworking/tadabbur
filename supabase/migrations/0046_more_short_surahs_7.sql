-- Adds the third batch of the longer Juz Amma surahs to "Short
-- Surahs", continuing the shortest-first pacing from migrations
-- 0044-0045: Al-Ghashiyah (88, 26 ayahs), At-Takwir (81, 29), Al-Fajr
-- (89, 30), Al-Mutaffifin (83, 36).
--
-- Same verification discipline as every prior batch: Uthmani text
-- batched per chapter, Saheeh International translation (resource 20)
-- and transliteration (resource 57) fetched individually per verse
-- from Quran.com, restyled into this app's established convention.
-- WebFetch hit its session quota partway through Al-Fajr's
-- transliteration fetches (same as migration 0038's chapter 93/94/95
-- batch) and recovered on its own a few calls later within this same
-- session — no need to fall back to WebSearch this time, but noting
-- it per the established practice of documenting sourcing hiccups.
-- Live check before writing this migration confirmed none of these 4
-- surahs have an existing `surahs` or `ayat` row.
--
-- Built directly in the current lesson shape: prayer_step, one
-- reading_passage card per ayah, then a closing full-surah recap — no
-- recall_quiz (removed from the unit per migration 0041).

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (88, 'الغاشية', 'Al-Ghashiyah', 26, 'meccan'),
  (81, 'التكوير', 'At-Takwir', 29, 'meccan'),
  (89, 'الفجر', 'Al-Fajr', 30, 'meccan'),
  (83, 'المطففين', 'Al-Mutaffifin', 36, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en, transliteration) values
  (88, 1, 'هَلْ أَتَىٰكَ حَدِيثُ ٱلْغَـٰشِيَةِ', 'هَلْ أَتَىٰكَ حَدِيثُ ٱلْغَـٰشِيَةِ', '[]'::jsonb,
   'Has there reached you the report of the Overwhelming [event]?', 'Hal ataaka hadeethul-ghaashiyah'),
  (88, 2, 'وُجُوهٌ يَوْمَئِذٍ خَـٰشِعَةٌ', 'وُجُوهٌ يَوْمَئِذٍ خَـٰشِعَةٌ', '[]'::jsonb,
   '[Some] faces, that Day, will be humbled,', 'Wujoohuy-yawma-idhin khaashi''ah'),
  (88, 3, 'عَامِلَةٌ نَّاصِبَةٌ', 'عَامِلَةٌ نَّاصِبَةٌ', '[]'::jsonb,
   'Working [hard] and exhausted.', '''Aamilatun naasibah'),
  (88, 4, 'تَصْلَىٰ نَارًا حَامِيَةً', 'تَصْلَىٰ نَارًا حَامِيَةً', '[]'::jsonb,
   'They will [enter to] burn in an intensely hot Fire.', 'Taslaa naaran haamiyah'),
  (88, 5, 'تُسْقَىٰ مِنْ عَيْنٍ ءَانِيَةٍ', 'تُسْقَىٰ مِنْ عَيْنٍ ءَانِيَةٍ', '[]'::jsonb,
   'They will be given drink from a boiling spring.', 'Tusqaa min ''aynin aaniyah'),
  (88, 6, 'لَّيْسَ لَهُمْ طَعَامٌ إِلَّا مِن ضَرِيعٍ', 'لَّيْسَ لَهُمْ طَعَامٌ إِلَّا مِن ضَرِيعٍ', '[]'::jsonb,
   'For them there will be no food except from a poisonous, thorny plant', 'Laysa lahum ta''aamun illaa min daree'''),
  (88, 7, 'لَّا يُسْمِنُ وَلَا يُغْنَىٰ مِن جُوعٍ', 'لَّا يُسْمِنُ وَلَا يُغْنَىٰ مِن جُوعٍ', '[]'::jsonb,
   'Which neither nourishes nor avails against hunger.', 'Laa yusminu wa laa yughnee min joo'''),
  (88, 8, 'وُجُوهٌ يَوْمَئِذٍ نَّاعِمَةٌ', 'وُجُوهٌ يَوْمَئِذٍ نَّاعِمَةٌ', '[]'::jsonb,
   '[Other] faces, that Day, will show pleasure.', 'Wujoohuy-yawma-idhin naa''imah'),
  (88, 9, 'لِّسَعْيِهَا رَاضِيَةٌ', 'لِّسَعْيِهَا رَاضِيَةٌ', '[]'::jsonb,
   'With their effort [they are] satisfied', 'Lisa''yihaa raadiyah'),
  (88, 10, 'فِى جَنَّةٍ عَالِيَةٍ', 'فِى جَنَّةٍ عَالِيَةٍ', '[]'::jsonb,
   'In an elevated garden,', 'Fee jannatin ''aaliyah'),
  (88, 11, 'لَّا تَسْمَعُ فِيهَا لَـٰغِيَةً', 'لَّا تَسْمَعُ فِيهَا لَـٰغِيَةً', '[]'::jsonb,
   'Wherein they will hear no unsuitable speech.', 'Laa tasma''u feehaa laaghiyah'),
  (88, 12, 'فِيهَا عَيْنٌ جَارِيَةٌ', 'فِيهَا عَيْنٌ جَارِيَةٌ', '[]'::jsonb,
   'Within it is a flowing spring.', 'Feehaa ''aynun jaariyah'),
  (88, 13, 'فِيهَا سُرُرٌ مَّرْفُوعَةٌ', 'فِيهَا سُرُرٌ مَّرْفُوعَةٌ', '[]'::jsonb,
   'Within it are couches raised high', 'Feehaa sururum-marfoo''ah'),
  (88, 14, 'وَأَكْوَابٌ مَّوْضُوعَةٌ', 'وَأَكْوَابٌ مَّوْضُوعَةٌ', '[]'::jsonb,
   'And cups put in place', 'Wa akwaabum-mawdoo''ah'),
  (88, 15, 'وَنَمَارِقُ مَصْفُوفَةٌ', 'وَنَمَارِقُ مَصْفُوفَةٌ', '[]'::jsonb,
   'And cushions lined up', 'Wa namaariqu masfoofah'),
  (88, 16, 'وَزَرَابِىُّ مَبْثُوثَةٌ', 'وَزَرَابِىُّ مَبْثُوثَةٌ', '[]'::jsonb,
   'And carpets spread around.', 'Wa zaraabiyyu mabthoothah'),
  (88, 17, 'أَفَلَا يَنظُرُونَ إِلَى ٱلْإِبِلِ كَيْفَ خُلِقَتْ', 'أَفَلَا يَنظُرُونَ إِلَى ٱلْإِبِلِ كَيْفَ خُلِقَتْ', '[]'::jsonb,
   'Then do they not look at the camels - how they are created?', 'Afalaa yandhuroona ilal-ibili kayfa khuliqat'),
  (88, 18, 'وَإِلَى ٱلسَّمَآءِ كَيْفَ رُفِعَتْ', 'وَإِلَى ٱلسَّمَآءِ كَيْفَ رُفِعَتْ', '[]'::jsonb,
   'And at the sky - how it is raised?', 'Wa ilas-samaa-i kayfa rufi''at'),
  (88, 19, 'وَإِلَى ٱلْجِبَالِ كَيْفَ نُصِبَتْ', 'وَإِلَى ٱلْجِبَالِ كَيْفَ نُصِبَتْ', '[]'::jsonb,
   'And at the mountains - how they are erected?', 'Wa ilal-jibaali kayfa nusibat'),
  (88, 20, 'وَإِلَى ٱلْأَرْضِ كَيْفَ سُطِحَتْ', 'وَإِلَى ٱلْأَرْضِ كَيْفَ سُطِحَتْ', '[]'::jsonb,
   'And at the earth - how it is spread out?', 'Wa ilal-ardi kayfa sutihat'),
  (88, 21, 'فَذَكِّرْ إِنَّمَآ أَنتَ مُذَكِّرٌ', 'فَذَكِّرْ إِنَّمَآ أَنتَ مُذَكِّرٌ', '[]'::jsonb,
   'So remind, [O Muhammad]; you are only a reminder.', 'Fadhakkir innamaa anta mudhakkir'),
  (88, 22, 'لَّسْتَ عَلَيْهِم بِمُصَيْطِرٍ', 'لَّسْتَ عَلَيْهِم بِمُصَيْطِرٍ', '[]'::jsonb,
   'You are not over them a controller.', 'Lasta ''alayhim bimusaytir'),
  (88, 23, 'إِلَّا مَن تَوَلَّىٰ وَكَفَرَ', 'إِلَّا مَن تَوَلَّىٰ وَكَفَرَ', '[]'::jsonb,
   'However, he who turns away and disbelieves', 'Illaa man tawallaa wa kafar'),
  (88, 24, 'فَيُعَذِّبُهُ ٱللَّهُ ٱلْعَذَابَ ٱلْأَكْبَرَ', 'فَيُعَذِّبُهُ ٱللَّهُ ٱلْعَذَابَ ٱلْأَكْبَرَ', '[]'::jsonb,
   'Then Allah will punish him with the greatest punishment.', 'Fayu''adhdhibuhullaahul-''adhaabal-akbar'),
  (88, 25, 'إِنَّ إِلَيْنَآ إِيَابَهُمْ', 'إِنَّ إِلَيْنَآ إِيَابَهُمْ', '[]'::jsonb,
   'Indeed, to Us is their return.', 'Inna ilaynaa iyaabahum'),
  (88, 26, 'ثُمَّ إِنَّ عَلَيْنَا حِسَابَهُم', 'ثُمَّ إِنَّ عَلَيْنَا حِسَابَهُم', '[]'::jsonb,
   'Then indeed, upon Us is their account.', 'Thumma inna ''alaynaa hisaabahum'),

  (81, 1, 'إِذَا ٱلشَّمْسُ كُوِّرَتْ', 'إِذَا ٱلشَّمْسُ كُوِّرَتْ', '[]'::jsonb,
   'When the sun is wrapped up [in darkness]', 'Idhash-shamsu kuwwirat'),
  (81, 2, 'وَإِذَا ٱلنُّجُومُ ٱنكَدَرَتْ', 'وَإِذَا ٱلنُّجُومُ ٱنكَدَرَتْ', '[]'::jsonb,
   'And when the stars fall, dispersing,', 'Wa idhan-nujoomun-kadarat'),
  (81, 3, 'وَإِذَا ٱلْجِبَالُ سُيِّرَتْ', 'وَإِذَا ٱلْجِبَالُ سُيِّرَتْ', '[]'::jsonb,
   'And when the mountains are removed', 'Wa idhal-jibaalu suyyirat'),
  (81, 4, 'وَإِذَا ٱلْعِشَارُ عُطِّلَتْ', 'وَإِذَا ٱلْعِشَارُ عُطِّلَتْ', '[]'::jsonb,
   'And when full-term she-camels are neglected', 'Wa idhal-''ishaaru ''uttilat'),
  (81, 5, 'وَإِذَا ٱلْوُحُوشُ حُشِرَتْ', 'وَإِذَا ٱلْوُحُوشُ حُشِرَتْ', '[]'::jsonb,
   'And when the wild beasts are gathered', 'Wa idhal-wuhooshu hushirat'),
  (81, 6, 'وَإِذَا ٱلْبِحَارُ سُجِّرَتْ', 'وَإِذَا ٱلْبِحَارُ سُجِّرَتْ', '[]'::jsonb,
   'And when the seas are filled with flame', 'Wa idhal-bihaaru sujjirat'),
  (81, 7, 'وَإِذَا ٱلنُّفُوسُ زُوِّجَتْ', 'وَإِذَا ٱلنُّفُوسُ زُوِّجَتْ', '[]'::jsonb,
   'And when the souls are paired', 'Wa idhan-nufoosu zuwwijat'),
  (81, 8, 'وَإِذَا ٱلْمَوْءُۥدَةُ سُئِلَتْ', 'وَإِذَا ٱلْمَوْءُۥدَةُ سُئِلَتْ', '[]'::jsonb,
   'And when the girl [who was] buried alive is asked', 'Wa idhal-maw-oodatu su-ilat'),
  (81, 9, 'بِأَىِّ ذَنۢبٍ قُتِلَتْ', 'بِأَىِّ ذَنۢبٍ قُتِلَتْ', '[]'::jsonb,
   'For what sin she was killed', 'Bi-ayyi dhambin qutilat'),
  (81, 10, 'وَإِذَا ٱلصُّحُفُ نُشِرَتْ', 'وَإِذَا ٱلصُّحُفُ نُشِرَتْ', '[]'::jsonb,
   'And when the pages are spread [i.e., made public]', 'Wa idhas-suhufu nushirat'),
  (81, 11, 'وَإِذَا ٱلسَّمَآءُ كُشِطَتْ', 'وَإِذَا ٱلسَّمَآءُ كُشِطَتْ', '[]'::jsonb,
   'And when the sky is stripped away', 'Wa idhas-samaa-u kushitat'),
  (81, 12, 'وَإِذَا ٱلْجَحِيمُ سُعِّرَتْ', 'وَإِذَا ٱلْجَحِيمُ سُعِّرَتْ', '[]'::jsonb,
   'And when Hellfire is set ablaze', 'Wa idhal-jaheemu su''''irat'),
  (81, 13, 'وَإِذَا ٱلْجَنَّةُ أُزْلِفَتْ', 'وَإِذَا ٱلْجَنَّةُ أُزْلِفَتْ', '[]'::jsonb,
   'And when Paradise is brought near,', 'Wa idhal-jannatu uzlifat'),
  (81, 14, 'عَلِمَتْ نَفْسٌ مَّآ أَحْضَرَتْ', 'عَلِمَتْ نَفْسٌ مَّآ أَحْضَرَتْ', '[]'::jsonb,
   'A soul will [then] know what it has brought [with it].', '''Alimat nafsum-maa ahdarat'),
  (81, 15, 'فَلَآ أُقْسِمُ بِٱلْخُنَّسِ', 'فَلَآ أُقْسِمُ بِٱلْخُنَّسِ', '[]'::jsonb,
   'So I swear by the retreating stars -', 'Falaa uqsimu bil-khunnas'),
  (81, 16, 'ٱلْجَوَارِ ٱلْكُنَّسِ', 'ٱلْجَوَارِ ٱلْكُنَّسِ', '[]'::jsonb,
   'Those that run [their courses] and disappear [i.e., set]', 'Al-jawaaril-kunnas'),
  (81, 17, 'وَٱلَّيْلِ إِذَا عَسْعَسَ', 'وَٱلَّيْلِ إِذَا عَسْعَسَ', '[]'::jsonb,
   'And by the night as it closes in', 'Wallayli idhaa ''as''as'),
  (81, 18, 'وَٱلصُّبْحِ إِذَا تَنَفَّسَ', 'وَٱلصُّبْحِ إِذَا تَنَفَّسَ', '[]'::jsonb,
   'And by the dawn when it breathes [i.e., stirs]', 'Wassubhi idhaa tanaffas'),
  (81, 19, 'إِنَّهُۥ لَقَوْلُ رَسُولٍ كَرِيمٍ', 'إِنَّهُۥ لَقَوْلُ رَسُولٍ كَرِيمٍ', '[]'::jsonb,
   '[That] indeed, it [i.e., the Qur''an] is a word [conveyed by] a noble messenger [i.e., Gabriel]', 'Innahoo laqawlu rasoolin kareem'),
  (81, 20, 'ذِى قُوَّةٍ عِندَ ذِى ٱلْعَرْشِ مَكِينٍ', 'ذِى قُوَّةٍ عِندَ ذِى ٱلْعَرْشِ مَكِينٍ', '[]'::jsonb,
   '[Who is] possessed of power and with the Owner of the Throne, secure [in position],', 'Dhee quwwatin ''inda dhil-''arshi makeen'),
  (81, 21, 'مُّطَاعٍ ثَمَّ أَمِينٍ', 'مُّطَاعٍ ثَمَّ أَمِينٍ', '[]'::jsonb,
   'Obeyed there [in the heavens] and trustworthy.', 'Mutaa''in thamma ameen'),
  (81, 22, 'وَمَا صَاحِبُكُم بِمَجْنُونٍ', 'وَمَا صَاحِبُكُم بِمَجْنُونٍ', '[]'::jsonb,
   'And your companion [i.e., Prophet Muhammad] is not [at all] mad.', 'Wa maa saahibukum bimajnoon'),
  (81, 23, 'وَلَقَدْ رَءَاهُ بِٱلْأُفُقِ ٱلْمُبِينِ', 'وَلَقَدْ رَءَاهُ بِٱلْأُفُقِ ٱلْمُبِينِ', '[]'::jsonb,
   'And he has already seen him [i.e., Gabriel] in the clear horizon.', 'Wa laqad ra-aahu bil-ufuqil-mubeen'),
  (81, 24, 'وَمَا هُوَ عَلَى ٱلْغَيْبِ بِضَنِينٍ', 'وَمَا هُوَ عَلَى ٱلْغَيْبِ بِضَنِينٍ', '[]'::jsonb,
   'And he [i.e., Muhammad] is not a withholder of [knowledge of] the unseen.', 'Wa maa huwa ''alal-ghaybi bidaneen'),
  (81, 25, 'وَمَا هُوَ بِقَوْلِ شَيْطَـٰنٍ رَّجِيمٍ', 'وَمَا هُوَ بِقَوْلِ شَيْطَـٰنٍ رَّجِيمٍ', '[]'::jsonb,
   'And it [i.e., the Qur''an] is not the word of a devil, expelled [from the heavens].', 'Wa maa huwa biqawli shaytaanir-rajeem'),
  (81, 26, 'فَأَيْنَ تَذْهَبُونَ', 'فَأَيْنَ تَذْهَبُونَ', '[]'::jsonb,
   'So where are you going?', 'Fa-ayna tadhhaboon'),
  (81, 27, 'إِنْ هُوَ إِلَّا ذِكْرٌ لِّلْعَـٰلَمِينَ', 'إِنْ هُوَ إِلَّا ذِكْرٌ لِّلْعَـٰلَمِينَ', '[]'::jsonb,
   'It is not except a reminder to the worlds', 'In huwa illaa dhikrul-lil-''aalameen'),
  (81, 28, 'لِمَن شَآءَ مِنكُمْ أَن يَسْتَقِيمَ', 'لِمَن شَآءَ مِنكُمْ أَن يَسْتَقِيمَ', '[]'::jsonb,
   'For whoever wills among you to take a right course.', 'Liman shaa-a minkum ay-yastaqeem'),
  (81, 29, 'وَمَا تَشَآءُونَ إِلَّآ أَن يَشَآءَ ٱللَّهُ رَبُّ ٱلْعَـٰلَمِينَ', 'وَمَا تَشَآءُونَ إِلَّآ أَن يَشَآءَ ٱللَّهُ رَبُّ ٱلْعَـٰلَمِينَ', '[]'::jsonb,
   'And you do not will except that Allah wills - Lord of the worlds.', 'Wa maa tashaa-oona illaa ay-yashaa-allaahu rabbul-''aalameen'),

  (89, 1, 'وَٱلْفَجْرِ', 'وَٱلْفَجْرِ', '[]'::jsonb,
   'By the dawn', 'Wal-fajr'),
  (89, 2, 'وَلَيَالٍ عَشْرٍ', 'وَلَيَالٍ عَشْرٍ', '[]'::jsonb,
   'And [by] ten nights', 'Wa layaalin ''ashr'),
  (89, 3, 'وَٱلشَّفْعِ وَٱلْوَتْرِ', 'وَٱلشَّفْعِ وَٱلْوَتْرِ', '[]'::jsonb,
   'And [by] the even [number] and the odd', 'Wash-shaf''i wal-witr'),
  (89, 4, 'وَٱلَّيْلِ إِذَا يَسْرِ', 'وَٱلَّيْلِ إِذَا يَسْرِ', '[]'::jsonb,
   'And [by] the night when it passes,', 'Wallayli idhaa yasr'),
  (89, 5, 'هَلْ فِى ذَٰلِكَ قَسَمٌ لِّذِى حِجْرٍ', 'هَلْ فِى ذَٰلِكَ قَسَمٌ لِّذِى حِجْرٍ', '[]'::jsonb,
   'Is there [not] in [all] that an oath [sufficient] for one of perception?', 'Hal fee dhaalika qasamul-lidhee hijr'),
  (89, 6, 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِعَادٍ', 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِعَادٍ', '[]'::jsonb,
   'Have you not considered how your Lord dealt with Aad -', 'Alam tara kayfa fa''ala rabbuka bi-''aad'),
  (89, 7, 'إِرَمَ ذَاتِ ٱلْعِمَادِ', 'إِرَمَ ذَاتِ ٱلْعِمَادِ', '[]'::jsonb,
   '[With] Iram - who had lofty pillars,', 'Irama dhaatil-''imaad'),
  (89, 8, 'ٱلَّتِى لَمْ يُخْلَقْ مِثْلُهَا فِى ٱلْبِلَـٰدِ', 'ٱلَّتِى لَمْ يُخْلَقْ مِثْلُهَا فِى ٱلْبِلَـٰدِ', '[]'::jsonb,
   'The likes of whom had never been created in the land?', 'Allatee lam yukhlaq mithluhaa fil-bilaad'),
  (89, 9, 'وَثَمُودَ ٱلَّذِينَ جَابُوا۟ ٱلصَّخْرَ بِٱلْوَادِ', 'وَثَمُودَ ٱلَّذِينَ جَابُوا۟ ٱلصَّخْرَ بِٱلْوَادِ', '[]'::jsonb,
   'And [with] Thamud, who carved out the rocks in the valley?', 'Wa thamoodal-ladheena jaabus-sakhra bil-waad'),
  (89, 10, 'وَفِرْعَوْنَ ذِى ٱلْأَوْتَادِ', 'وَفِرْعَوْنَ ذِى ٱلْأَوْتَادِ', '[]'::jsonb,
   'And [with] Pharaoh, owner of the stakes?', 'Wa fir''awna dheel-awtaad'),
  (89, 11, 'ٱلَّذِينَ طَغَوْا۟ فِى ٱلْبِلَـٰدِ', 'ٱلَّذِينَ طَغَوْا۟ فِى ٱلْبِلَـٰدِ', '[]'::jsonb,
   '[All of] whom oppressed within the lands', 'Alladheena taghaw fil-bilaad'),
  (89, 12, 'فَأَكْثَرُوا۟ فِيهَا ٱلْفَسَادَ', 'فَأَكْثَرُوا۟ فِيهَا ٱلْفَسَادَ', '[]'::jsonb,
   'And increased therein the corruption.', 'Fa-aktharoo feehal-fasaad'),
  (89, 13, 'فَصَبَّ عَلَيْهِمْ رَبُّكَ سَوْطَ عَذَابٍ', 'فَصَبَّ عَلَيْهِمْ رَبُّكَ سَوْطَ عَذَابٍ', '[]'::jsonb,
   'So your Lord poured upon them a scourge of punishment.', 'Fasabba ''alayhim rabbuka sawta ''adhaab'),
  (89, 14, 'إِنَّ رَبَّكَ لَبِٱلْمِرْصَادِ', 'إِنَّ رَبَّكَ لَبِٱلْمِرْصَادِ', '[]'::jsonb,
   'Indeed, your Lord is in observation.', 'Inna rabbaka labil-mirsaad'),
  (89, 15, 'فَأَمَّا ٱلْإِنسَـٰنُ إِذَا مَا ٱبْتَلَىٰهُ رَبُّهُۥ فَأَكْرَمَهُۥ وَنَعَّمَهُۥ فَيَقُولُ رَبِّىٓ أَكْرَمَنِ', 'فَأَمَّا ٱلْإِنسَـٰنُ إِذَا مَا ٱبْتَلَىٰهُ رَبُّهُۥ فَأَكْرَمَهُۥ وَنَعَّمَهُۥ فَيَقُولُ رَبِّىٓ أَكْرَمَنِ', '[]'::jsonb,
   'And as for man, when his Lord tries him and [thus] is generous to him and favors him, he says, "My Lord has honored me."', 'Fa-ammal-insaanu idhaa mab-talaahu rabbuhoo fa-akramahoo wa na''''amahoo fayaqoolu rabbee akraman'),
  (89, 16, 'وَأَمَّآ إِذَا مَا ٱبْتَلَىٰهُ فَقَدَرَ عَلَيْهِ رِزْقَهُۥ فَيَقُولُ رَبِّىٓ أَهَـٰنَنِ', 'وَأَمَّآ إِذَا مَا ٱبْتَلَىٰهُ فَقَدَرَ عَلَيْهِ رِزْقَهُۥ فَيَقُولُ رَبِّىٓ أَهَـٰنَنِ', '[]'::jsonb,
   'But when He tries him and restricts his provision, he says, "My Lord has humiliated me."', 'Wa ammaa idhaa mab-talaahu faqadara ''alayhi rizqahoo fayaqoolu rabbee ahaanan'),
  (89, 17, 'كَلَّا ۖ بَل لَّا تُكْرِمُونَ ٱلْيَتِيمَ', 'كَلَّا ۖ بَل لَّا تُكْرِمُونَ ٱلْيَتِيمَ', '[]'::jsonb,
   'No! But you do not honor the orphan', 'Kallaa bal laa tukrimoonal-yateem'),
  (89, 18, 'وَلَا تَحَـٰٓضُّونَ عَلَىٰ طَعَامِ ٱلْمِسْكِينِ', 'وَلَا تَحَـٰٓضُّونَ عَلَىٰ طَعَامِ ٱلْمِسْكِينِ', '[]'::jsonb,
   'And you do not encourage one another to feed the poor.', 'Wa laa tahaaddoona ''alaa ta''aamil-miskeen'),
  (89, 19, 'وَتَأْكُلُونَ ٱلتُّرَاثَ أَكْلًا لَّمًّا', 'وَتَأْكُلُونَ ٱلتُّرَاثَ أَكْلًا لَّمًّا', '[]'::jsonb,
   'And you consume inheritance, devouring [it] altogether,', 'Wa ta-kuloonat-turaatha aklal-lammaa'),
  (89, 20, 'وَتُحِبُّونَ ٱلْمَالَ حُبًّا جَمًّا', 'وَتُحِبُّونَ ٱلْمَالَ حُبًّا جَمًّا', '[]'::jsonb,
   'And you love wealth with immense love.', 'Wa tuhibboonal-maala hubban jammaa'),
  (89, 21, 'كَلَّآ إِذَا دُكَّتِ ٱلْأَرْضُ دَكًّا دَكًّا', 'كَلَّآ إِذَا دُكَّتِ ٱلْأَرْضُ دَكًّا دَكًّا', '[]'::jsonb,
   'No! When the earth has been leveled - pounded and crushed', 'Kallaa idhaa dukkatil-ardu dakkan dakkaa'),
  (89, 22, 'وَجَآءَ رَبُّكَ وَٱلْمَلَكُ صَفًّا صَفًّا', 'وَجَآءَ رَبُّكَ وَٱلْمَلَكُ صَفًّا صَفًّا', '[]'::jsonb,
   'And your Lord has come and the angels, rank upon rank,', 'Wa jaa-a rabbuka wal-malaku saffan saffaa'),
  (89, 23, 'وَجِا۟ىٓءَ يَوْمَئِذٍۭ بِجَهَنَّمَ ۚ يَوْمَئِذٍ يَتَذَكَّرُ ٱلْإِنسَـٰنُ وَأَنَّىٰ لَهُ ٱلذِّكْرَىٰ', 'وَجِا۟ىٓءَ يَوْمَئِذٍۭ بِجَهَنَّمَ ۚ يَوْمَئِذٍ يَتَذَكَّرُ ٱلْإِنسَـٰنُ وَأَنَّىٰ لَهُ ٱلذِّكْرَىٰ', '[]'::jsonb,
   'And brought [within view], that Day, is Hell - that Day, man will remember, but how [i.e., what good] to him will be the remembrance?', 'Wa jee-a yawma-idhim-bijahannama yawma-idhiy-yatadhakkarul-insaanu wa annaa lahudh-dhikraa'),
  (89, 24, 'يَقُولُ يَـٰلَيْتَنِى قَدَّمْتُ لِحَيَاتِى', 'يَقُولُ يَـٰلَيْتَنِى قَدَّمْتُ لِحَيَاتِى', '[]'::jsonb,
   'He will say, "Oh, I wish I had sent ahead [some good] for my life."', 'Yaqoolu yaa laytanee qaddamtu lihayaatee'),
  (89, 25, 'فَيَوْمَئِذٍ لَّا يُعَذِّبُ عَذَابَهُۥٓ أَحَدٌ', 'فَيَوْمَئِذٍ لَّا يُعَذِّبُ عَذَابَهُۥٓ أَحَدٌ', '[]'::jsonb,
   'So on that Day, none will punish [as severely] as His punishment,', 'Fayawma-idhil-laa yu''adhdhibu ''adhaabahoo ahad'),
  (89, 26, 'وَلَا يُوثِقُ وَثَاقَهُۥٓ أَحَدٌ', 'وَلَا يُوثِقُ وَثَاقَهُۥٓ أَحَدٌ', '[]'::jsonb,
   'And none will bind [as severely] as His binding [of the evildoers].', 'Wa laa yoothiqu wathaaqahoo ahad'),
  (89, 27, 'يَـٰٓأَيَّتُهَا ٱلنَّفْسُ ٱلْمُطْمَئِنَّةُ', 'يَـٰٓأَيَّتُهَا ٱلنَّفْسُ ٱلْمُطْمَئِنَّةُ', '[]'::jsonb,
   '[To the righteous it will be said], "O reassured soul,"', 'Yaa ayyatuhan-nafsul-mutma-innah'),
  (89, 28, 'ٱرْجِعِىٓ إِلَىٰ رَبِّكِ رَاضِيَةً مَّرْضِيَّةً', 'ٱرْجِعِىٓ إِلَىٰ رَبِّكِ رَاضِيَةً مَّرْضِيَّةً', '[]'::jsonb,
   'Return to your Lord, well-pleased and pleasing [to Him],', 'Irji''ee ilaa rabbiki raadiyatam-mardiyyah'),
  (89, 29, 'فَٱدْخُلِى فِى عِبَـٰدِى', 'فَٱدْخُلِى فِى عِبَـٰدِى', '[]'::jsonb,
   'And enter among My [righteous] servants', 'Fadkhulee fee ''ibaadee'),
  (89, 30, 'وَٱدْخُلِى جَنَّتِى', 'وَٱدْخُلِى جَنَّتِى', '[]'::jsonb,
   'And enter My Paradise.', 'Wadkhulee jannatee'),

  (83, 1, 'وَيْلٌ لِّلْمُطَفِّفِينَ', 'وَيْلٌ لِّلْمُطَفِّفِينَ', '[]'::jsonb,
   'Woe to those who give less [than due]', 'Waylul-lil-mutaffifeen'),
  (83, 2, 'ٱلَّذِينَ إِذَا ٱكْتَالُوا۟ عَلَى ٱلنَّاسِ يَسْتَوْفُونَ', 'ٱلَّذِينَ إِذَا ٱكْتَالُوا۟ عَلَى ٱلنَّاسِ يَسْتَوْفُونَ', '[]'::jsonb,
   'Who, when they take a measure from people, take in full.', 'Alladheena idhak-taaloo ''alan-naasi yastawfoon'),
  (83, 3, 'وَإِذَا كَالُوهُمْ أَو وَّزَنُوهُمْ يُخْسِرُونَ', 'وَإِذَا كَالُوهُمْ أَو وَّزَنُوهُمْ يُخْسِرُونَ', '[]'::jsonb,
   'But if they give by measure or by weight to them, they cause loss.', 'Wa idhaa kaaloohum aw wazanoohum yukhsiroon'),
  (83, 4, 'أَلَا يَظُنُّ أُو۟لَـٰٓئِكَ أَنَّهُم مَّبْعُوثُونَ', 'أَلَا يَظُنُّ أُو۟لَـٰٓئِكَ أَنَّهُم مَّبْعُوثُونَ', '[]'::jsonb,
   'Do they not think that they will be resurrected', 'Alaa yadhunnu ulaa-ika annahum mab''oothoon'),
  (83, 5, 'لِيَوْمٍ عَظِيمٍ', 'لِيَوْمٍ عَظِيمٍ', '[]'::jsonb,
   'For a tremendous Day -', 'Liyawmin ''adheem'),
  (83, 6, 'يَوْمَ يَقُومُ ٱلنَّاسُ لِرَبِّ ٱلْعَـٰلَمِينَ', 'يَوْمَ يَقُومُ ٱلنَّاسُ لِرَبِّ ٱلْعَـٰلَمِينَ', '[]'::jsonb,
   'The Day when mankind will stand before the Lord of the worlds?', 'Yawma yaqoomun-naasu lirabbil-''aalameen'),
  (83, 7, 'كَلَّآ إِنَّ كِتَـٰبَ ٱلْفُجَّارِ لَفِى سِجِّينٍ', 'كَلَّآ إِنَّ كِتَـٰبَ ٱلْفُجَّارِ لَفِى سِجِّينٍ', '[]'::jsonb,
   'No! Indeed, the record of the wicked is in sijjeen.', 'Kallaa inna kitaabal-fujjaari lafee sijjeen'),
  (83, 8, 'وَمَآ أَدْرَىٰكَ مَا سِجِّينٌ', 'وَمَآ أَدْرَىٰكَ مَا سِجِّينٌ', '[]'::jsonb,
   'And what can make you know what is sijjeen?', 'Wa maa adraaka maa sijjeen'),
  (83, 9, 'كِتَـٰبٌ مَّرْقُومٌ', 'كِتَـٰبٌ مَّرْقُومٌ', '[]'::jsonb,
   'It is [their destination recorded in] a register inscribed.', 'Kitaabum-marqoom'),
  (83, 10, 'وَيْلٌ يَوْمَئِذٍ لِّلْمُكَذِّبِينَ', 'وَيْلٌ يَوْمَئِذٍ لِّلْمُكَذِّبِينَ', '[]'::jsonb,
   'Woe, that Day, to the deniers,', 'Wayluy-yawma-idhil-lil-mukadhdhibeen'),
  (83, 11, 'ٱلَّذِينَ يُكَذِّبُونَ بِيَوْمِ ٱلدِّينِ', 'ٱلَّذِينَ يُكَذِّبُونَ بِيَوْمِ ٱلدِّينِ', '[]'::jsonb,
   'Who deny the Day of Recompense.', 'Alladheena yukadhdhiboona biyawmid-deen'),
  (83, 12, 'وَمَا يُكَذِّبُ بِهِۦٓ إِلَّا كُلُّ مُعْتَدٍ أَثِيمٍ', 'وَمَا يُكَذِّبُ بِهِۦٓ إِلَّا كُلُّ مُعْتَدٍ أَثِيمٍ', '[]'::jsonb,
   'And none deny it except every sinful transgressor.', 'Wa maa yukadhdhibu bihee illaa kullu mu''tadin atheem'),
  (83, 13, 'إِذَا تُتْلَىٰ عَلَيْهِ ءَايَـٰتُنَا قَالَ أَسَـٰطِيرُ ٱلْأَوَّلِينَ', 'إِذَا تُتْلَىٰ عَلَيْهِ ءَايَـٰتُنَا قَالَ أَسَـٰطِيرُ ٱلْأَوَّلِينَ', '[]'::jsonb,
   'When Our verses are recited to him, he says, "Legends of the former peoples."', 'Idhaa tutlaa ''alayhi aayaatunaa qaala asaateerul-awwaleen'),
  (83, 14, 'كَلَّا ۖ بَلْ ۜ رَانَ عَلَىٰ قُلُوبِهِم مَّا كَانُوا۟ يَكْسِبُونَ', 'كَلَّا ۖ بَلْ ۜ رَانَ عَلَىٰ قُلُوبِهِم مَّا كَانُوا۟ يَكْسِبُونَ', '[]'::jsonb,
   'No! Rather, the stain has covered their hearts of that which they were earning.', 'Kallaa bal raana ''alaa quloobihim maa kaanoo yaksiboon'),
  (83, 15, 'كَلَّآ إِنَّهُمْ عَن رَّبِّهِمْ يَوْمَئِذٍ لَّمَحْجُوبُونَ', 'كَلَّآ إِنَّهُمْ عَن رَّبِّهِمْ يَوْمَئِذٍ لَّمَحْجُوبُونَ', '[]'::jsonb,
   'No! Indeed, from their Lord, that Day, they will be partitioned.', 'Kallaa innahum ''ar-rabbihim yawma-idhil-lamahjooboon'),
  (83, 16, 'ثُمَّ إِنَّهُمْ لَصَالُوا۟ ٱلْجَحِيمِ', 'ثُمَّ إِنَّهُمْ لَصَالُوا۟ ٱلْجَحِيمِ', '[]'::jsonb,
   'Then indeed, they will [enter and] burn in Hellfire.', 'Thumma innahum lasaalul-jaheem'),
  (83, 17, 'ثُمَّ يُقَالُ هَـٰذَا ٱلَّذِى كُنتُم بِهِۦ تُكَذِّبُونَ', 'ثُمَّ يُقَالُ هَـٰذَا ٱلَّذِى كُنتُم بِهِۦ تُكَذِّبُونَ', '[]'::jsonb,
   'This is what you used to deny.', 'Thumma yuqaalu haadhal-ladhee kuntum bihee tukadhdhiboon'),
  (83, 18, 'كَلَّآ إِنَّ كِتَـٰبَ ٱلْأَبْرَارِ لَفِى عِلِّيِّينَ', 'كَلَّآ إِنَّ كِتَـٰبَ ٱلْأَبْرَارِ لَفِى عِلِّيِّينَ', '[]'::jsonb,
   'No! Indeed, the record of the righteous is in illiyyun.', 'Kallaa inna kitaabal-abraari lafee ''illiyyeen'),
  (83, 19, 'وَمَآ أَدْرَىٰكَ مَا عِلِّيُّونَ', 'وَمَآ أَدْرَىٰكَ مَا عِلِّيُّونَ', '[]'::jsonb,
   'And what can make you know what is illiyyun?', 'Wa maa adraaka maa ''illiyyoon'),
  (83, 20, 'كِتَـٰبٌ مَّرْقُومٌ', 'كِتَـٰبٌ مَّرْقُومٌ', '[]'::jsonb,
   'It is [their destination recorded in] a register inscribed', 'Kitaabum-marqoom'),
  (83, 21, 'يَشْهَدُهُ ٱلْمُقَرَّبُونَ', 'يَشْهَدُهُ ٱلْمُقَرَّبُونَ', '[]'::jsonb,
   'Which is witnessed by those brought near [to Allah].', 'Yashhaduhul-muqarraboon'),
  (83, 22, 'إِنَّ ٱلْأَبْرَارَ لَفِى نَعِيمٍ', 'إِنَّ ٱلْأَبْرَارَ لَفِى نَعِيمٍ', '[]'::jsonb,
   'Indeed, the righteous will be in pleasure', 'Innal-abraara lafee na''eem'),
  (83, 23, 'عَلَى ٱلْأَرَآئِكِ يَنظُرُونَ', 'عَلَى ٱلْأَرَآئِكِ يَنظُرُونَ', '[]'::jsonb,
   'On adorned couches, observing.', '''Alal-araa-iki yandhuroon'),
  (83, 24, 'تَعْرِفُ فِى وُجُوهِهِمْ نَضْرَةَ ٱلنَّعِيمِ', 'تَعْرِفُ فِى وُجُوهِهِمْ نَضْرَةَ ٱلنَّعِيمِ', '[]'::jsonb,
   'You will recognize in their faces the radiance of pleasure.', 'Ta''rifu fee wujoohihim nadratan-na''eem'),
  (83, 25, 'يُسْقَوْنَ مِن رَّحِيقٍ مَّخْتُومٍ', 'يُسْقَوْنَ مِن رَّحِيقٍ مَّخْتُومٍ', '[]'::jsonb,
   'They will be given to drink [pure] wine [which was] sealed.', 'Yusqawna mir-raheeqim-makhtoom'),
  (83, 26, 'خِتَـٰمُهُۥ مِسْكٌ ۚ وَفِى ذَٰلِكَ فَلْيَتَنَافَسِ ٱلْمُتَنَـٰفِسُونَ', 'خِتَـٰمُهُۥ مِسْكٌ ۚ وَفِى ذَٰلِكَ فَلْيَتَنَافَسِ ٱلْمُتَنَـٰفِسُونَ', '[]'::jsonb,
   'The last of it is musk. So for this let the competitors compete.', 'Khitaamuhoo miskuw-wa fee dhaalika falyatanaafasil-mutanaafisoon'),
  (83, 27, 'وَمِزَاجُهُۥ مِن تَسْنِيمٍ', 'وَمِزَاجُهُۥ مِن تَسْنِيمٍ', '[]'::jsonb,
   'And its mixture is of Tasneem', 'Wa mizaajuhoo min tasneem'),
  (83, 28, 'عَيْنًا يَشْرَبُ بِهَا ٱلْمُقَرَّبُونَ', 'عَيْنًا يَشْرَبُ بِهَا ٱلْمُقَرَّبُونَ', '[]'::jsonb,
   'A spring from which those near [to Allah] drink.', '''Aynay-yashrabu bihal-muqarraboon'),
  (83, 29, 'إِنَّ ٱلَّذِينَ أَجْرَمُوا۟ كَانُوا۟ مِنَ ٱلَّذِينَ ءَامَنُوا۟ يَضْحَكُونَ', 'إِنَّ ٱلَّذِينَ أَجْرَمُوا۟ كَانُوا۟ مِنَ ٱلَّذِينَ ءَامَنُوا۟ يَضْحَكُونَ', '[]'::jsonb,
   'Indeed, those who committed crimes used to laugh at those who believed.', 'Innal-ladheena ajramoo kaanoo minal-ladheena aamanoo yadhakoon'),
  (83, 30, 'وَإِذَا مَرُّوا۟ بِهِمْ يَتَغَامَزُونَ', 'وَإِذَا مَرُّوا۟ بِهِمْ يَتَغَامَزُونَ', '[]'::jsonb,
   'And when they passed by them, they would exchange derisive glances.', 'Wa idhaa marroo bihim yataghaamazoon'),
  (83, 31, 'وَإِذَا ٱنقَلَبُوٓا۟ إِلَىٰٓ أَهْلِهِمُ ٱنقَلَبُوا۟ فَكِهِينَ', 'وَإِذَا ٱنقَلَبُوٓا۟ إِلَىٰٓ أَهْلِهِمُ ٱنقَلَبُوا۟ فَكِهِينَ', '[]'::jsonb,
   'And when they returned to their people, they would return jesting.', 'Wa idhan-qalaboo ilaa ahlihimun-qalaboo faakiheen'),
  (83, 32, 'وَإِذَا رَأَوْهُمْ قَالُوٓا۟ إِنَّ هَـٰٓؤُلَآءِ لَضَآلُّونَ', 'وَإِذَا رَأَوْهُمْ قَالُوٓا۟ إِنَّ هَـٰٓؤُلَآءِ لَضَآلُّونَ', '[]'::jsonb,
   'Indeed, those are truly lost.', 'Wa idhaa ra-awhum qaaloo inna haa-ulaa-i ladaalloon'),
  (83, 33, 'وَمَآ أُرْسِلُوا۟ عَلَيْهِمْ حَـٰفِظِينَ', 'وَمَآ أُرْسِلُوا۟ عَلَيْهِمْ حَـٰفِظِينَ', '[]'::jsonb,
   'But they had not been sent as guardians over them.', 'Wa maa ursiloo ''alayhim haafidheen'),
  (83, 34, 'فَٱلْيَوْمَ ٱلَّذِينَ ءَامَنُوا۟ مِنَ ٱلْكُفَّارِ يَضْحَكُونَ', 'فَٱلْيَوْمَ ٱلَّذِينَ ءَامَنُوا۟ مِنَ ٱلْكُفَّارِ يَضْحَكُونَ', '[]'::jsonb,
   'So Today those who believed are laughing at the disbelievers,', 'Falyawmal-ladheena aamanoo minal-kuffaari yadhakoon'),
  (83, 35, 'عَلَى ٱلْأَرَآئِكِ يَنظُرُونَ', 'عَلَى ٱلْأَرَآئِكِ يَنظُرُونَ', '[]'::jsonb,
   'On adorned couches, observing.', '''Alal-araa-iki yandhuroon'),
  (83, 36, 'هَلْ ثُوِّبَ ٱلْكُفَّارُ مَا كَانُوا۟ يَفْعَلُونَ', 'هَلْ ثُوِّبَ ٱلْكُفَّارُ مَا كَانُوا۟ يَفْعَلُونَ', '[]'::jsonb,
   'Have the disbelievers [not] been rewarded [this Day] for what they used to do?', 'Hal thuwwibal-kuffaaru maa kaanoo yaf''aloon');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Ghashiyah', 30, 13 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'At-Takwir', 31, 14 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Fajr', 32, 15 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Mutaffifin', 33, 17 from units where title = 'Short Surahs';

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
      ('Al-Ghashiyah', 88::smallint, 1::smallint, 26::smallint),
      ('At-Takwir', 81::smallint, 1::smallint, 29::smallint),
      ('Al-Fajr', 89::smallint, 1::smallint, 30::smallint),
      ('Al-Mutaffifin', 83::smallint, 1::smallint, 36::smallint)
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
