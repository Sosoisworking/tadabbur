-- Adds the first batch of the longer Juz Amma surahs to "Short Surahs"
-- per user request to add the rest of the Juz Amma surahs, paced in
-- batches of 4 ordered shortest-first (confirmed with the user given
-- the size jump from the <=11-ayah surahs added so far to this
-- 15-46-ayah tier): Ash-Shams (91, 15 ayahs), At-Tariq (86, 17),
-- Al-Infitar (82, 19), Al-A'la (87, 19).
--
-- Same verification discipline as every prior batch: Uthmani text
-- batched per chapter, Saheeh International translation (resource 20)
-- and transliteration (resource 57) fetched individually per verse
-- from Quran.com, restyled into this app's established convention.
-- WebFetch's own auto-generated summary mislabeled chapter 91 as
-- "Ad-Dhuhaa" in several of its verse-level responses even though the
-- fetched verse text and verse_key (91:1-91:15) are unambiguously
-- Ash-Shams — same "trust verse content, not the tool's generated
-- title" situation as migration 0037's chapter 94 mislabel. Live check
-- before writing this migration confirmed none of these 4 surahs have
-- an existing `surahs` or `ayat` row.
--
-- Built directly in the current lesson shape: prayer_step, one
-- reading_passage card per ayah, then a closing full-surah recap — no
-- recall_quiz (removed from the unit per migration 0041).

insert into surahs (number, name_arabic, name_english, ayah_count, revelation_type) values
  (91, 'الشمس', 'Ash-Shams', 15, 'meccan'),
  (86, 'الطارق', 'At-Tariq', 17, 'meccan'),
  (82, 'الإنفطار', 'Al-Infitar', 19, 'meccan'),
  (87, 'الأعلى', 'Al-A''la', 19, 'meccan');

insert into ayat (surah_number, ayah_number, text_uthmani, text_diacritized, tajweed_markup, translation_en, transliteration) values
  (91, 1, 'وَٱلشَّمْسِ وَضُحَىٰهَا', 'وَٱلشَّمْسِ وَضُحَىٰهَا', '[]'::jsonb,
   'By the sun and its brightness', 'Washshamsi wa duhaahaa'),
  (91, 2, 'وَٱلْقَمَرِ إِذَا تَلَىٰهَا', 'وَٱلْقَمَرِ إِذَا تَلَىٰهَا', '[]'::jsonb,
   'And [by] the moon when it follows it', 'Wal-qamari idhaa talaahaa'),
  (91, 3, 'وَٱلنَّهَارِ إِذَا جَلَّىٰهَا', 'وَٱلنَّهَارِ إِذَا جَلَّىٰهَا', '[]'::jsonb,
   'And [by] the day when it displays it', 'Wannahaari idhaa jallaahaa'),
  (91, 4, 'وَٱلَّيْلِ إِذَا يَغْشَىٰهَا', 'وَٱلَّيْلِ إِذَا يَغْشَىٰهَا', '[]'::jsonb,
   'And [by] the night when it covers [i.e., conceals] it', 'Wallayli idhaa yaghshaahaa'),
  (91, 5, 'وَٱلسَّمَآءِ وَمَا بَنَىٰهَا', 'وَٱلسَّمَآءِ وَمَا بَنَىٰهَا', '[]'::jsonb,
   'And [by] the sky and He who constructed it', 'Wassamaa-i wa maa banaahaa'),
  (91, 6, 'وَٱلْأَرْضِ وَمَا طَحَىٰهَا', 'وَٱلْأَرْضِ وَمَا طَحَىٰهَا', '[]'::jsonb,
   'And [by] the earth and He who spread it', 'Wal-ardi wa maa tahaahaa'),
  (91, 7, 'وَنَفْسٍ وَمَا سَوَّىٰهَا', 'وَنَفْسٍ وَمَا سَوَّىٰهَا', '[]'::jsonb,
   'And [by] the soul and He who proportioned it', 'Wa nafsin wa maa sawwaahaa'),
  (91, 8, 'فَأَلْهَمَهَا فُجُورَهَا وَتَقْوَىٰهَا', 'فَأَلْهَمَهَا فُجُورَهَا وَتَقْوَىٰهَا', '[]'::jsonb,
   'And inspired it [with discernment of] its wickedness and its righteousness,', 'Fa-alhamahaa fujoorahaa wa taqwaahaa'),
  (91, 9, 'قَدْ أَفْلَحَ مَن زَكَّىٰهَا', 'قَدْ أَفْلَحَ مَن زَكَّىٰهَا', '[]'::jsonb,
   'He has succeeded who purifies it,', 'Qad aflaha man zakkaahaa'),
  (91, 10, 'وَقَدْ خَابَ مَن دَسَّىٰهَا', 'وَقَدْ خَابَ مَن دَسَّىٰهَا', '[]'::jsonb,
   'And he has failed who instills it [with corruption].', 'Wa qad khaaba man dassaahaa'),
  (91, 11, 'كَذَّبَتْ ثَمُودُ بِطَغْوَىٰهَآ', 'كَذَّبَتْ ثَمُودُ بِطَغْوَىٰهَآ', '[]'::jsonb,
   'Thamud denied [their prophet] by reason of their transgression,', 'Kadhdhabat thamoodu bitaghwaahaa'),
  (91, 12, 'إِذِ ٱنۢبَعَثَ أَشْقَىٰهَا', 'إِذِ ٱنۢبَعَثَ أَشْقَىٰهَا', '[]'::jsonb,
   'When the most wretched of them was sent forth.', 'Idhin-ba''atha ashqaahaa'),
  (91, 13, 'فَقَالَ لَهُمْ رَسُولُ ٱللَّهِ نَاقَةَ ٱللَّهِ وَسُقْيَـٰهَا', 'فَقَالَ لَهُمْ رَسُولُ ٱللَّهِ نَاقَةَ ٱللَّهِ وَسُقْيَـٰهَا', '[]'::jsonb,
   'And the messenger of Allah [i.e., Salih] said to them, "[Do not harm] the she-camel of Allah or [prevent her from] her drink."', 'Faqaala lahum rasoolullaahi naaqatallaahi wa suqyaahaa'),
  (91, 14, 'فَكَذَّبُوهُ فَعَقَرُوهَا فَدَمْدَمَ عَلَيْهِمْ رَبُّهُم بِذَنۢبِهِمْ فَسَوَّىٰهَا', 'فَكَذَّبُوهُ فَعَقَرُوهَا فَدَمْدَمَ عَلَيْهِمْ رَبُّهُم بِذَنۢبِهِمْ فَسَوَّىٰهَا', '[]'::jsonb,
   'But they denied him and hamstrung her. So their Lord brought down upon them destruction for their sin and made it equal [upon all of them].', 'Fakadhdhaboohu fa-''aqaroohaa fadamdama ''alayhim rabbuhum bidhanbihim fasawwaahaa'),
  (91, 15, 'وَلَا يَخَافُ عُقْبَـٰهَا', 'وَلَا يَخَافُ عُقْبَـٰهَا', '[]'::jsonb,
   'And He does not fear the consequence thereof.', 'Wa laa yakhaafu ''uqbaahaa'),

  (86, 1, 'وَٱلسَّمَآءِ وَٱلطَّارِقِ', 'وَٱلسَّمَآءِ وَٱلطَّارِقِ', '[]'::jsonb,
   'By the sky and the night comer', 'Wassamaa-i wattaariq'),
  (86, 2, 'وَمَآ أَدْرَىٰكَ مَا ٱلطَّارِقُ', 'وَمَآ أَدْرَىٰكَ مَا ٱلطَّارِقُ', '[]'::jsonb,
   'And what can make you know what is the night comer?', 'Wa maa adraaka mat-taariq'),
  (86, 3, 'ٱلنَّجْمُ ٱلثَّاقِبُ', 'ٱلنَّجْمُ ٱلثَّاقِبُ', '[]'::jsonb,
   'It is the piercing star', 'Annajmuth-thaaqib'),
  (86, 4, 'إِن كُلُّ نَفْسٍ لَّمَّا عَلَيْهَا حَافِظٌ', 'إِن كُلُّ نَفْسٍ لَّمَّا عَلَيْهَا حَافِظٌ', '[]'::jsonb,
   'There is no soul but that it has over it a protector.', 'In kullu nafsin lammaa ''alayhaa haafidh'),
  (86, 5, 'فَلْيَنظُرِ ٱلْإِنسَـٰنُ مِمَّ خُلِقَ', 'فَلْيَنظُرِ ٱلْإِنسَـٰنُ مِمَّ خُلِقَ', '[]'::jsonb,
   'So let man observe from what he was created.', 'Falyandhuril-insaanu mimma khuliq'),
  (86, 6, 'خُلِقَ مِن مَّآءٍ دَافِقٍ', 'خُلِقَ مِن مَّآءٍ دَافِقٍ', '[]'::jsonb,
   'He was created from a fluid, ejected,', 'Khuliqa min maa-in daafiq'),
  (86, 7, 'يَخْرُجُ مِنۢ بَيْنِ ٱلصُّلْبِ وَٱلتَّرَآئِبِ', 'يَخْرُجُ مِنۢ بَيْنِ ٱلصُّلْبِ وَٱلتَّرَآئِبِ', '[]'::jsonb,
   'Emerging from between the backbone and the ribs.', 'Yakhruju min bayni-sulbi wattaraa-ib'),
  (86, 8, 'إِنَّهُۥ عَلَىٰ رَجْعِهِۦ لَقَادِرٌ', 'إِنَّهُۥ عَلَىٰ رَجْعِهِۦ لَقَادِرٌ', '[]'::jsonb,
   'Indeed, He [i.e., Allah], to return him [to life], is Able.', 'Innahu ''alaa raj''ihee laqaadir'),
  (86, 9, 'يَوْمَ تُبْلَى ٱلسَّرَآئِرُ', 'يَوْمَ تُبْلَى ٱلسَّرَآئِرُ', '[]'::jsonb,
   'The Day when secrets will be put on trial', 'Yawma tublas-saraa-ir'),
  (86, 10, 'فَمَا لَهُۥ مِن قُوَّةٍ وَلَا نَاصِرٍ', 'فَمَا لَهُۥ مِن قُوَّةٍ وَلَا نَاصِرٍ', '[]'::jsonb,
   'Then he [i.e., man] will have no power or any helper.', 'Famaa lahu min quwwatin wa laa naasir'),
  (86, 11, 'وَٱلسَّمَآءِ ذَاتِ ٱلرَّجْعِ', 'وَٱلسَّمَآءِ ذَاتِ ٱلرَّجْعِ', '[]'::jsonb,
   'By the sky which sends back', 'Wassamaa-i dhaatir-raj'''),
  (86, 12, 'وَٱلْأَرْضِ ذَاتِ ٱلصَّدْعِ', 'وَٱلْأَرْضِ ذَاتِ ٱلصَّدْعِ', '[]'::jsonb,
   'And [by] the earth which splits,', 'Wal-ardi dhaatis-sad'''),
  (86, 13, 'إِنَّهُۥ لَقَوْلٌ فَصْلٌ', 'إِنَّهُۥ لَقَوْلٌ فَصْلٌ', '[]'::jsonb,
   'Indeed, it [i.e., the Qur''an] is a decisive statement,', 'Innahu laqawlun fasl'),
  (86, 14, 'وَمَا هُوَ بِٱلْهَزْلِ', 'وَمَا هُوَ بِٱلْهَزْلِ', '[]'::jsonb,
   'And it is not amusement.', 'Wa maa huwa bil-hazl'),
  (86, 15, 'إِنَّهُمْ يَكِيدُونَ كَيْدًا', 'إِنَّهُمْ يَكِيدُونَ كَيْدًا', '[]'::jsonb,
   'Indeed, they are planning a plan,', 'Innahum yakeedoona kaydaa'),
  (86, 16, 'وَأَكِيدُ كَيْدًا', 'وَأَكِيدُ كَيْدًا', '[]'::jsonb,
   'But I am planning a plan.', 'Wa akeedu kaydaa'),
  (86, 17, 'فَمَهِّلِ ٱلْكَـٰفِرِينَ أَمْهِلْهُمْ رُوَيْدًۢا', 'فَمَهِّلِ ٱلْكَـٰفِرِينَ أَمْهِلْهُمْ رُوَيْدًۢا', '[]'::jsonb,
   'So allow time for the disbelievers. Leave them awhile.', 'Famahhilil-kaafireena amhilhum ruwaydaa'),

  (82, 1, 'إِذَا ٱلسَّمَآءُ ٱنفَطَرَتْ', 'إِذَا ٱلسَّمَآءُ ٱنفَطَرَتْ', '[]'::jsonb,
   'When the sky breaks apart', 'Idhas-samaa-un-fatarat'),
  (82, 2, 'وَإِذَا ٱلْكَوَاكِبُ ٱنتَثَرَتْ', 'وَإِذَا ٱلْكَوَاكِبُ ٱنتَثَرَتْ', '[]'::jsonb,
   'And when the stars fall, scattering,', 'Wa idhal-kawaakibun-tatharat'),
  (82, 3, 'وَإِذَا ٱلْبِحَارُ فُجِّرَتْ', 'وَإِذَا ٱلْبِحَارُ فُجِّرَتْ', '[]'::jsonb,
   'And when the seas are erupted', 'Wa idhal-bihaaru fujjirat'),
  (82, 4, 'وَإِذَا ٱلْقُبُورُ بُعْثِرَتْ', 'وَإِذَا ٱلْقُبُورُ بُعْثِرَتْ', '[]'::jsonb,
   'And when the [contents of] graves are scattered [i.e., exposed],', 'Wa idhal-quboru bu''thirat'),
  (82, 5, 'عَلِمَتْ نَفْسٌ مَّا قَدَّمَتْ وَأَخَّرَتْ', 'عَلِمَتْ نَفْسٌ مَّا قَدَّمَتْ وَأَخَّرَتْ', '[]'::jsonb,
   'A soul will [then] know what it has put forth and kept back.', '''Alimat nafsum-maa qaddamat wa akhkharat'),
  (82, 6, 'يَـٰٓأَيُّهَا ٱلْإِنسَـٰنُ مَا غَرَّكَ بِرَبِّكَ ٱلْكَرِيمِ', 'يَـٰٓأَيُّهَا ٱلْإِنسَـٰنُ مَا غَرَّكَ بِرَبِّكَ ٱلْكَرِيمِ', '[]'::jsonb,
   'O mankind, what has deceived you concerning your Lord, the Generous,', 'Yaa ayyuhal-insaanu maa gharraka birabbikal-kareem'),
  (82, 7, 'ٱلَّذِى خَلَقَكَ فَسَوَّىٰكَ فَعَدَلَكَ', 'ٱلَّذِى خَلَقَكَ فَسَوَّىٰكَ فَعَدَلَكَ', '[]'::jsonb,
   'Who created you, proportioned you, and balanced you?', 'Alladhee khalaqaka fasawwaaka fa-''adalak'),
  (82, 8, 'فِىٓ أَىِّ صُورَةٍ مَّا شَآءَ رَكَّبَكَ', 'فِىٓ أَىِّ صُورَةٍ مَّا شَآءَ رَكَّبَكَ', '[]'::jsonb,
   'In whatever form He willed has He assembled you.', 'Fee ayyi sooratim-maa shaa-a rakkabak'),
  (82, 9, 'كَلَّا بَلْ تُكَذِّبُونَ بِٱلدِّينِ', 'كَلَّا بَلْ تُكَذِّبُونَ بِٱلدِّينِ', '[]'::jsonb,
   'No! But you deny the Recompense.', 'Kallaa bal tukadhdhiboona bid-deen'),
  (82, 10, 'وَإِنَّ عَلَيْكُمْ لَحَـٰفِظِينَ', 'وَإِنَّ عَلَيْكُمْ لَحَـٰفِظِينَ', '[]'::jsonb,
   'And indeed, [appointed] over you are keepers,', 'Wa inna ''alaykum lahaafidheen'),
  (82, 11, 'كِرَامًا كَـٰتِبِينَ', 'كِرَامًا كَـٰتِبِينَ', '[]'::jsonb,
   'Noble and recording;', 'Kiraaman kaatibeen'),
  (82, 12, 'يَعْلَمُونَ مَا تَفْعَلُونَ', 'يَعْلَمُونَ مَا تَفْعَلُونَ', '[]'::jsonb,
   'They know whatever you do.', 'Ya''lamoona maa taf''aloon'),
  (82, 13, 'إِنَّ ٱلْأَبْرَارَ لَفِى نَعِيمٍ', 'إِنَّ ٱلْأَبْرَارَ لَفِى نَعِيمٍ', '[]'::jsonb,
   'Indeed, the righteous will be in pleasure,', 'Innal-abraara lafee na''eem'),
  (82, 14, 'وَإِنَّ ٱلْفُجَّارَ لَفِى جَحِيمٍ', 'وَإِنَّ ٱلْفُجَّارَ لَفِى جَحِيمٍ', '[]'::jsonb,
   'And indeed, the wicked will be in Hellfire.', 'Wa innal-fujjaara lafee jaheem'),
  (82, 15, 'يَصْلَوْنَهَا يَوْمَ ٱلدِّينِ', 'يَصْلَوْنَهَا يَوْمَ ٱلدِّينِ', '[]'::jsonb,
   'They will [enter to] burn therein on the Day of Recompense,', 'Yaslawnahaa yawmad-deen'),
  (82, 16, 'وَمَا هُمْ عَنْهَا بِغَآئِبِينَ', 'وَمَا هُمْ عَنْهَا بِغَآئِبِينَ', '[]'::jsonb,
   'And never therefrom will they be absent.', 'Wa maa hum ''anhaa bighaa-ibeen'),
  (82, 17, 'وَمَآ أَدْرَىٰكَ مَا يَوْمُ ٱلدِّينِ', 'وَمَآ أَدْرَىٰكَ مَا يَوْمُ ٱلدِّينِ', '[]'::jsonb,
   'And what can make you know what is the Day of Recompense?', 'Wa maa adraaka maa yawmud-deen'),
  (82, 18, 'ثُمَّ مَآ أَدْرَىٰكَ مَا يَوْمُ ٱلدِّينِ', 'ثُمَّ مَآ أَدْرَىٰكَ مَا يَوْمُ ٱلدِّينِ', '[]'::jsonb,
   'Then, what can make you know what is the Day of Recompense?', 'Thumma maa adraaka maa yawmud-deen'),
  (82, 19, 'يَوْمَ لَا تَمْلِكُ نَفْسٌ لِّنَفْسٍ شَيْـًٔا ۖ وَٱلْأَمْرُ يَوْمَئِذٍ لِّلَّهِ', 'يَوْمَ لَا تَمْلِكُ نَفْسٌ لِّنَفْسٍ شَيْـًٔا ۖ وَٱلْأَمْرُ يَوْمَئِذٍ لِّلَّهِ', '[]'::jsonb,
   'It is the Day when a soul will not possess for another soul [power to do] a thing; and the command, that Day, is [entirely] with Allah.', 'Yawma laa tamliku nafsul-linafsin shay-aa, wal-amru yawma-idhil-lillah'),

  (87, 1, 'سَبِّحِ ٱسْمَ رَبِّكَ ٱلْأَعْلَى', 'سَبِّحِ ٱسْمَ رَبِّكَ ٱلْأَعْلَى', '[]'::jsonb,
   'Exalt the name of your Lord, the Most High,', 'Sabbihisma rabbikal-a''laa'),
  (87, 2, 'ٱلَّذِى خَلَقَ فَسَوَّىٰ', 'ٱلَّذِى خَلَقَ فَسَوَّىٰ', '[]'::jsonb,
   'Who created and proportioned', 'Alladhee khalaqa fasawwaa'),
  (87, 3, 'وَٱلَّذِى قَدَّرَ فَهَدَىٰ', 'وَٱلَّذِى قَدَّرَ فَهَدَىٰ', '[]'::jsonb,
   'And who destined and [then] guided', 'Walladhee qaddara fahadaa'),
  (87, 4, 'وَٱلَّذِىٓ أَخْرَجَ ٱلْمَرْعَىٰ', 'وَٱلَّذِىٓ أَخْرَجَ ٱلْمَرْعَىٰ', '[]'::jsonb,
   'And who brings out the pasture', 'Walladhee akhrajal-mar''aa'),
  (87, 5, 'فَجَعَلَهُۥ غُثَآءً أَحْوَىٰ', 'فَجَعَلَهُۥ غُثَآءً أَحْوَىٰ', '[]'::jsonb,
   'And [then] makes it black stubble.', 'Faja''alahu ghuthaa-an ahwaa'),
  (87, 6, 'سَنُقْرِئُكَ فَلَا تَنسَىٰٓ', 'سَنُقْرِئُكَ فَلَا تَنسَىٰٓ', '[]'::jsonb,
   'We will make you recite, [O Muhammad], and you will not forget,', 'Sanuqri-uka falaa tansaa'),
  (87, 7, 'إِلَّا مَا شَآءَ ٱللَّهُ ۚ إِنَّهُۥ يَعْلَمُ ٱلْجَهْرَ وَمَا يَخْفَىٰ', 'إِلَّا مَا شَآءَ ٱللَّهُ ۚ إِنَّهُۥ يَعْلَمُ ٱلْجَهْرَ وَمَا يَخْفَىٰ', '[]'::jsonb,
   'Except what Allah should will. Indeed, He knows what is declared and what is hidden.', 'Illaa maa shaa-allaahu innahu ya''lamul-jahra wa maa yakhfaa'),
  (87, 8, 'وَنُيَسِّرُكَ لِلْيُسْرَىٰ', 'وَنُيَسِّرُكَ لِلْيُسْرَىٰ', '[]'::jsonb,
   'And We will ease you toward ease.', 'Wa nuyassiruka lil-yusraa'),
  (87, 9, 'فَذَكِّرْ إِن نَّفَعَتِ ٱلذِّكْرَىٰ', 'فَذَكِّرْ إِن نَّفَعَتِ ٱلذِّكْرَىٰ', '[]'::jsonb,
   'So remind, if the reminder should benefit;', 'Fadhakkir in nafa''atidh-dhikraa'),
  (87, 10, 'سَيَذَّكَّرُ مَن يَخْشَىٰ', 'سَيَذَّكَّرُ مَن يَخْشَىٰ', '[]'::jsonb,
   'He who fears [Allah] will be reminded.', 'Sayadhdhakkaru man yakhshaa'),
  (87, 11, 'وَيَتَجَنَّبُهَا ٱلْأَشْقَى', 'وَيَتَجَنَّبُهَا ٱلْأَشْقَى', '[]'::jsonb,
   'But the wretched one will avoid it', 'Wa yatajannabuhal-ashqaa'),
  (87, 12, 'ٱلَّذِى يَصْلَى ٱلنَّارَ ٱلْكُبْرَىٰ', 'ٱلَّذِى يَصْلَى ٱلنَّارَ ٱلْكُبْرَىٰ', '[]'::jsonb,
   '[He] who will [enter and] burn in the greatest Fire,', 'Alladhee yaslan-naaral-kubraa'),
  (87, 13, 'ثُمَّ لَا يَمُوتُ فِيهَا وَلَا يَحْيَىٰ', 'ثُمَّ لَا يَمُوتُ فِيهَا وَلَا يَحْيَىٰ', '[]'::jsonb,
   'Neither dying therein nor living.', 'Thumma laa yamootu feehaa wa laa yahyaa'),
  (87, 14, 'قَدْ أَفْلَحَ مَن تَزَكَّىٰ', 'قَدْ أَفْلَحَ مَن تَزَكَّىٰ', '[]'::jsonb,
   'He has certainly succeeded who purifies himself', 'Qad aflaha man tazakkaa'),
  (87, 15, 'وَذَكَرَ ٱسْمَ رَبِّهِۦ فَصَلَّىٰ', 'وَذَكَرَ ٱسْمَ رَبِّهِۦ فَصَلَّىٰ', '[]'::jsonb,
   'And mentions the name of his Lord and prays.', 'Wa dhakara isma rabbihee fasallaa'),
  (87, 16, 'بَلْ تُؤْثِرُونَ ٱلْحَيَوٰةَ ٱلدُّنْيَا', 'بَلْ تُؤْثِرُونَ ٱلْحَيَوٰةَ ٱلدُّنْيَا', '[]'::jsonb,
   'But you prefer the worldly life,', 'Bal tu''thiroonal-hayaatad-dunyaa'),
  (87, 17, 'وَٱلْـَٔاخِرَةُ خَيْرٌ وَأَبْقَىٰٓ', 'وَٱلْـَٔاخِرَةُ خَيْرٌ وَأَبْقَىٰٓ', '[]'::jsonb,
   'While the Hereafter is better and more enduring.', 'Wal-aakhiratu khayrun wa abqaa'),
  (87, 18, 'إِنَّ هَـٰذَا لَفِى ٱلصُّحُفِ ٱلْأُولَىٰ', 'إِنَّ هَـٰذَا لَفِى ٱلصُّحُفِ ٱلْأُولَىٰ', '[]'::jsonb,
   'Indeed, this is in the former scriptures,', 'Inna haadhaa lafis-suhufil-oolaa'),
  (87, 19, 'صُحُفِ إِبْرَٰهِيمَ وَمُوسَىٰ', 'صُحُفِ إِبْرَٰهِيمَ وَمُوسَىٰ', '[]'::jsonb,
   'The scriptures of Abraham and Moses.', 'Suhufi ibraaheema wa moosaa');

insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Ash-Shams', 22, 8 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'At-Tariq', 23, 9 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-Infitar', 24, 10 from units where title = 'Short Surahs';
insert into lessons (unit_id, title, sequence_order, estimated_minutes)
select id, 'Al-A''la', 25, 10 from units where title = 'Short Surahs';

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
      ('Ash-Shams', 91::smallint, 1::smallint, 15::smallint),
      ('At-Tariq', 86::smallint, 1::smallint, 17::smallint),
      ('Al-Infitar', 82::smallint, 1::smallint, 19::smallint),
      ('Al-A''la', 87::smallint, 1::smallint, 19::smallint)
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
