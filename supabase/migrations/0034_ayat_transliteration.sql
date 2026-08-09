-- Adds transliteration to every ayah currently in the ayat table (39
-- rows: Al-Fatiha's 7, Short Ayahs' 14, Short Surahs' 18), per user
-- request. Every other piece of recited content in the app already
-- carries a transliteration (vocab_items, exercise_prayer_step) —
-- ayat was the one gap, since it predates that convention.
--
-- Sourcing: Al-Fatiha's 7 ayahs reuse the exact transliteration
-- already written out in migration 0026 (Salah unit, "Recite Surat
-- Al-Fatiha" step), rather than re-deriving it — that text came from
-- the Prayer Guide book itself and is already in the app's own
-- established style. The remaining 32 ayahs were fetched individually
-- (not batched — same discipline as every other ayah-content
-- migration in this project) from Quran.com's Transliteration
-- resource (id 57, api.quran.com/api/v4/quran/translations/57), then
-- restyled from that resource's academic convention (e.g. "Bismi
-- Allahi arrahmani arraheem") into the common Islamic transliteration
-- style already used everywhere else in this app (e.g. "Bismillaahir-
-- rahmaanir-raheem") — capitalized word starts, apostrophe for
-- ayn/hamza, doubled vowels for long vowels, elided/assimilated
-- article joins written as pronounced. Word choice cross-checked
-- against Al-Ikhlas, Al-Falaq, An-Nas, and Al-Kawthar's standard,
-- extremely well-known transliterations (these four are among the
-- most widely memorized and printed texts in Islam) before restyling,
-- not just mechanically reformatted from the API text.

alter table ayat add column transliteration text;

update ayat set transliteration = v.transliteration from (values
  (1, 1, 'Bismillaahir-rahmaanir-raheem'),
  (1, 2, 'Al-hamdu lillaahi rabbil ''aalameen'),
  (1, 3, 'Ar-rahmaanir-raheem'),
  (1, 4, 'Maaliki yawmiddeen'),
  (1, 5, 'Iyyaaka na''budu wa iyyaaka nasta''een'),
  (1, 6, 'Ihdinas-siraatal mustaqeem'),
  (1, 7, 'Siraatal-ladheena an''amta ''alayhim ghayril maghdoobi ''alayhim wa lad-daalleen'),
  (77, 2, 'Fal-''aasifaati ''asfaa'),
  (55, 6, 'Wan-najmu wash-shajaru yasjudaan'),
  (100, 7, 'Wa innahu ''alaa dhaalika lashaheed'),
  (98, 5, 'Wa maa umiroo illaa liya''budullaaha mukhliseena lahud-deena hunafaa''a wa yuqeemus-salaata wa yu''toz-zakaata wa dhaalika deenul-qayyimah'),
  (77, 7, 'Innamaa too''adoona lawaaqi'''),
  (55, 10, 'Wal-arda wada''ahaa lil-anaam'),
  (77, 8, 'Fa-idhan-nujoomu tumisat'),
  (92, 12, 'Inna ''alaynaa lal-hudaa'),
  (76, 24, 'Fasbir lihukmi rabbika wa laa tuti'' minhum aathiman aw kafoora'),
  (92, 5, 'Fa-ammaa man a''taa wattaqaa'),
  (76, 29, 'Inna haadhihi tadhkiratun faman shaa-a ittakhadha ilaa rabbihi sabeelaa'),
  (92, 4, 'Inna sa''yakum lashattaa'),
  (85, 6, 'Idh hum ''alayhaa qu''ood'),
  (76, 30, 'Wa maa tashaa-oona illaa ay-yashaa-allaahu innallaaha kaana ''aleeman hakeemaa'),
  (108, 1, 'Innaa a''taynaakal kawthar'),
  (108, 2, 'Fasalli lirabbika wanhar'),
  (108, 3, 'Inna shaani-aka huwal abtar'),
  (112, 1, 'Qul huwallaahu ahad'),
  (112, 2, 'Allaahus-samad'),
  (112, 3, 'Lam yalid wa lam yoolad'),
  (112, 4, 'Wa lam yakul-lahu kufuwan ahad'),
  (113, 1, 'Qul a''oodhu birabbil falaq'),
  (113, 2, 'Min sharri maa khalaq'),
  (113, 3, 'Wa min sharri ghaasiqin idhaa waqab'),
  (113, 4, 'Wa min sharrin-naffaathaati fil ''uqad'),
  (113, 5, 'Wa min sharri haasidin idhaa hasad'),
  (114, 1, 'Qul a''oodhu birabbin naas'),
  (114, 2, 'Malikin naas'),
  (114, 3, 'Ilaahin naas'),
  (114, 4, 'Min sharril waswaasil khannaas'),
  (114, 5, 'Alladhee yuwaswisu fee sudoorin naas'),
  (114, 6, 'Minal jinnati wan naas')
) as v(surah_number, ayah_number, transliteration)
where ayat.surah_number = v.surah_number and ayat.ayah_number = v.ayah_number;

alter table ayat alter column transliteration set not null;
