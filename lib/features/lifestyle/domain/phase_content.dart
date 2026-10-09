import 'package:flutter_period_tracker/features/cycle_tracking/domain/cycle_phase.dart';

class PhaseContent {
  final CyclePhase phase;

  final String title;
  final String description;
  final String hormoneOverview;

  // 1. Edzés & Mozgás
  final List<String> recommendedWorkouts;
  final List<String> workoutsToAvoid;
  final String intensityGuide;

  // 2. Táplálkozás & Mikrotápanyagok
  final List<String> recommendedFoods;
  final List<String> keyNutrients;
  final String hydrationAdvice;

  // 3. Mentális egészség & Stresszkezelés
  final List<String> mentalWellnessTips;
  final String socialEnergy;

  // 4. Bőrápolás & Szépség
  final String skinState;
  final List<String> skincareTips;

  // 5. Alvás, Energia & Vitaminok
  final String energyLevel;
  final List<String> vitaminsAndSupplements;
  final String sleepAdvice;

  const PhaseContent({
    required this.phase,
    required this.title,
    required this.description,
    required this.hormoneOverview,
    required this.recommendedWorkouts,
    required this.workoutsToAvoid,
    required this.intensityGuide,
    required this.recommendedFoods,
    required this.keyNutrients,
    required this.hydrationAdvice,
    required this.mentalWellnessTips,
    required this.socialEnergy,
    required this.skinState,
    required this.skincareTips,
    required this.energyLevel,
    required this.vitaminsAndSupplements,
    required this.sleepAdvice,
  });
}

/// Fázisonkénti életmód-tartalom (csak adat, logika nélkül).
/// Később JSON assetbe vagy távoli forrásba költöztethető.
abstract final class PhaseContents {
  static PhaseContent of(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return const PhaseContent(
          phase: CyclePhase.menstrual,

          title: 'Menstruációs fázis',
          description:
              'A menstruáció idején az ösztrogén és a progeszteron szintje '
              'alacsonyabb. Egyesek ilyenkor fáradtabbnak, érzékenyebbnek '
              'vagy kevésbé energikusnak érzik magukat, míg mások kevés '
              'változást tapasztalnak.',

          hormoneOverview:
              'A menstruáció a ciklus kezdetét jelenti. A korábbi ciklusban '
              'meg nem termékenyült petesejt után a méhnyálkahártya leválik. '
              'Az ösztrogén- és progeszteronszint ebben az időszakban '
              'alacsony.',

          recommendedWorkouts: [
            'Könnyű séta',
            'Kímélő jóga és nyújtás',
            'Mobilitási gyakorlatok',
            'Könnyű Pilates',
            'Laza kerékpározás',
          ],

          workoutsToAvoid: [
            'A számodra szokatlanul megterhelő edzés',
            'Edzés akkor, ha erős fájdalom vagy rosszullét miatt nem esik jól',
          ],

          intensityGuide:
              'Alacsony vagy közepes intenzitás lehet kényelmesebb. '
              'Ha jól érzed magad, a megszokott edzésedet is folytathatod; '
              'a tüneteid legyenek az elsődleges visszajelzés.',

          recommendedFoods: [
            'Vasban gazdag ételek: húsok, hüvelyesek, tofu, leveles zöldségek',
            'C-vitaminban gazdag ételek: paprika, citrusfélék, bogyós gyümölcsök',
            'Teljes értékű gabonák',
            'Zöldségek és gyümölcsök',
            'Fehérjében gazdag ételek',
            'Meleg levesek és egytálételek, ha ezek ilyenkor jobban esnek',
          ],

          keyNutrients: [
            'Vas – különösen fontos lehet erős menstruáció esetén',
            'C-vitamin – segíti a növényi eredetű vas felszívódását',
            'Magnézium – az étrend részeként hozzájárulhat a megfelelő izomműködéshez',
            'Fehérje – az általános regeneráció és teltségérzet támogatására',
          ],

          hydrationAdvice:
              'Igyál rendszeresen a nap folyamán. A szükséges folyadékmennyiség '
              'egyénenként változik, és az aktivitás, a hőmérséklet és az étrend '
              'is befolyásolja.',

          mentalWellnessTips: [
            'Adj magadnak több pihenőt, ha fáradtabbnak érzed magad',
            'Próbálj ki rövid relaxációt vagy légzőgyakorlatot',
            'A naplózás segíthet követni a visszatérő tüneteket',
            'Ne hasonlítsd a saját energiaszintedet másokéhoz',
          ],

          socialEnergy:
              'Lehet, hogy kevésbé vágysz társas programokra, de ez egyéni. '
              'Válaszd azt a társas aktivitást, ami tényleg jól esik.',

          skinState:
              'A bőr állapota a ciklus során változhat, de ezek a változások '
              'nem mindenkinél ugyanolyanok.',

          skincareTips: [
            'Használj kímélő, illatmentes tisztítót, ha érzékenyebb a bőröd',
            'Száraz bőr esetén használj hidratáló krémet',
            'Kerüld a túlzott dörzsölést és a felesleges hámlasztást',
            'Napközben használj széles spektrumú fényvédőt',
          ],

          energyLevel: 'Egyéni – egyesek ilyenkor alacsonyabb energiaszintről számolnak be.',

          vitaminsAndSupplements: [
            'Nincs általánosan szükséges menstruációs étrend-kiegészítő',
            'Vas pótlását csak egyéni szükséglet alapján érdemes mérlegelni',
            'Magnéziumbevitel elsősorban kiegyensúlyozott étrenddel biztosítható',
            'Tartós vagy erős tünetek esetén érdemes szakemberrel egyeztetni',
          ],

          sleepAdvice:
              'Törekedj rendszeres alvásra és elegendő pihenésre. Ha a menstruáció '
              'alatt rosszabbul alszol, segíthet a megszokott lefekvési rutin '
              'és a nyugodt, hűvös hálókörnyezet.',
        );

      case CyclePhase.follicular:
        return const PhaseContent(
          phase: CyclePhase.follicular,

          title: 'Follikuláris fázis',
          description:
              'A menstruáció után a tüszők fejlődése folytatódik, miközben '
              'az ösztrogénszint általában emelkedni kezd. Sokan fokozatosan '
              'több energiát éreznek, de az egyéni különbségek jelentősek.',

          hormoneOverview:
              'A follikuláris fázisban az FSH segíti a petefészekben található '
              'tüszők fejlődését. Az egyik domináns tüsző kiválasztódik, az '
              'ösztrogénszint pedig fokozatosan emelkedik.',

          recommendedWorkouts: [
            'Erősítő edzés',
            'Funkcionális edzés',
            'Futás',
            'Kerékpározás',
            'Dinamikus jóga',
            'Tánc vagy csoportos edzés',
          ],

          workoutsToAvoid: ['Túledzés és elégtelen regeneráció'],

          intensityGuide:
              'Ha energikusnak érzed magad, fokozatosan növelheted az edzés '
              'intenzitását. Ne a ciklusnap határozza meg automatikusan a '
              'terhelést; a teljesítményed és regenerációd legyen az irányadó.',

          recommendedFoods: [
            'Színes zöldségek',
            'Gyümölcsök',
            'Hüvelyesek',
            'Teljes értékű gabonák',
            'Tojás, hal, hús vagy növényi fehérjeforrások',
            'Fermentált élelmiszerek, ha jól tolerálod őket',
            'Olajos magvak',
          ],

          keyNutrients: [
            'Fehérje',
            'Rost',
            'Omega-3 zsírsavakban gazdag ételek',
            'Vas',
            'Kalcium',
            'Magnézium',
          ],

          hydrationAdvice:
              'Tartsd fenn a rendszeres folyadékbevitelt. Intenzívebb edzés, '
              'meleg idő vagy fokozott izzadás esetén több folyadékra lehet szükséged.',

          mentalWellnessTips: [
            'Használd ki a számodra kedvezőbb energiaszintet',
            'Tervezd meg a következő hetek fontosabb feladatait',
            'Próbálj ki új mozgásformát vagy hobbit, ha kedved van hozzá',
            'A nagyobb koncentrációt igénylő feladatokat akkorra időzítsd, amikor a legjobban tudsz fókuszálni',
          ],

          socialEnergy:
              'Sokan ilyenkor energikusabbnak érzik magukat, de a társas igény '
              'egyénenként változik. Szervezz programot akkor, amikor neked kényelmes.',

          skinState:
              'Az ösztrogénszint változásával a bőr állapota is változhat, '
              'de nincs mindenki számára érvényes, jól meghatározható '
              '„follikuláris bőrállapot”.',

          skincareTips: [
            'Tartsd egyszerűen és következetesen a bőrápolási rutint',
            'Használj a bőrtípusodnak megfelelő hidratálót',
            'Ha hámlasztót használsz, kezdd fokozatosan',
            'Napközben használj széles spektrumú, legalább SPF 30-as fényvédőt',
          ],

          energyLevel: 'Gyakran növekvő, de az egyéni energiaszint fontosabb, mint a ciklusnap.',

          vitaminsAndSupplements: [
            'Nincs szükség rutinszerűen fázisspecifikus étrend-kiegészítőre',
            'Törekedj változatos, tápanyagban gazdag étrendre',
            'Omega-3-forrásként előnyben részesíthetők a táplálékforrások',
            'Hiányállapot vagy speciális étrend esetén személyre szabott pótlás jöhet szóba',
          ],

          sleepAdvice:
              'Tartsd meg a rendszeres alvási rutint. Felnőtteknél általában '
              'legalább 7 óra alvás ajánlott, de az egyéni alvásigény eltérhet.',
        );

      case CyclePhase.ovulatory:
        return const PhaseContent(
          phase: CyclePhase.ovulatory,

          title: 'Ovuláció körüli időszak',
          description:
              'Az ovuláció körüli időszakban hormonális változások történnek, '
              'amelyek közül az LH-emelkedés kulcsszerepet játszik az ovuláció '
              'kiváltásában. A pontos időpont ciklusonként eltérhet.',

          hormoneOverview:
              'Az ovulációt megelőzően az ösztrogénszint emelkedése hozzájárul '
              'az LH-csúcshoz. Az LH-emelkedés váltja ki az ovulációt. Az '
              'ovuláció pontos időpontja nem határozható meg megbízhatóan '
              'pusztán egy általános ciklusnaptár alapján.',

          recommendedWorkouts: [
            'Erősítő edzés',
            'Futás',
            'HIIT, ha már megszoktad ezt a terhelést',
            'Intervallum edzés',
            'Kerékpározás vagy spinning',
            'Sport- és teljesítményorientált edzés',
          ],

          workoutsToAvoid: [
            'Szokatlanul nagy terhelés megfelelő felkészülés nélkül',
            'Edzés fájdalom, szédülés vagy rosszullét esetén',
          ],

          intensityGuide:
              'Ha jól regenerálódsz és jól érzed magad, a megszokott magasabb '
              'intenzitású edzés is megfelelő lehet. A ciklusfázis önmagában '
              'nem indokolja a maximális intenzitás erőltetését.',

          recommendedFoods: [
            'Zöldségek és gyümölcsök',
            'Bogyós gyümölcsök',
            'Teljes értékű gabonák',
            'Hüvelyesek',
            'Tojás, hal, hús vagy növényi fehérjeforrások',
            'Olajos magvak',
            'Omega-3-ban gazdag élelmiszerek',
          ],

          keyNutrients: [
            'Fehérje',
            'Rost',
            'Magnézium',
            'Kalcium',
            'Vas',
            'Omega-3 zsírsavak',
          ],

          hydrationAdvice:
              'Nagyobb intenzitású edzés vagy fokozott izzadás esetén figyelj '
              'a folyadékpótlásra. Ne egy fix literértéket kövess, hanem az '
              'aktivitásodhoz és környezetedhez igazítsd a bevitelt.',

          mentalWellnessTips: [
            'Időzítsd a fontos feladatokat akkorra, amikor a legjobban tudsz koncentrálni',
            'Használd ki az energikusabb időszakokat, ha valóban így érzed magad',
            'Tarts szüneteket intenzív munkavégzés közben',
            'A társas programokat a saját komfortodhoz igazítsd',
          ],

          socialEnergy:
              'Egyesek energikusabbnak és társaságkedvelőbbnek érzik magukat '
              'az ovuláció körül, de ez nem mindenkinél figyelhető meg.',

          skinState:
              'A hormonális változások a faggyútermelésre és a bőr állapotára '
              'is hatással lehetnek. Ha ilyenkor könnyebben alakul ki akné, '
              'érdemes kímélő, következetes rutint használni.',

          skincareTips: [
            'Használj gyengéd arctisztítót',
            'Akne esetén választhatsz nem komedogén hidratálót',
            'Használj széles spektrumú SPF 30+ fényvédőt',
            'Ne dörzsöld és ne nyomkodd a gyulladt pattanásokat',
          ],

          energyLevel: 'Változó – egyesek energikusabbnak érzik magukat, mások nem tapasztalnak jelentős különbséget.',

          vitaminsAndSupplements: [
            'Nincs bizonyítottan szükséges „ovulációs vitamin”',
            'A kiegyensúlyozott étrend legyen az elsődleges tápanyagforrás',
            'Étrend-kiegészítő alkalmazását egyéni szükséglet alapján érdemes megválasztani',
            'Tartós panaszok vagy hiányállapot gyanúja esetén kérj szakmai tanácsot',
          ],

          sleepAdvice:
              'Ne csökkentsd tudatosan az alvásidőt csak azért, mert energikusabbnak '
              'érzed magad. A megfelelő alvás továbbra is fontos a regenerációhoz.',
        );

      case CyclePhase.luteal:
        return const PhaseContent(
          phase: CyclePhase.luteal,

          title: 'Luteális fázis',
          description:
              'Az ovuláció után a progeszteron szerepe megnő. A ciklus végéhez '
              'közeledve egyesek PMS-tüneteket tapasztalhatnak, például '
              'hangulatingadozást, mellfeszülést, puffadást vagy fokozott étvágyat.',

          hormoneOverview:
              'Az ovuláció után kialakuló sárgatest progeszteront termel. '
              'Ha nem következik be terhesség, a ciklus végén az ösztrogén- '
              'és progeszteronszint csökken, ami hozzájárul a következő '
              'menstruáció megindulásához.',

          recommendedWorkouts: [
            'Erősítő edzés',
            'Mérsékelt intenzitású kardió',
            'Gyaloglás',
            'Pilates',
            'Jóga',
            'Úszás',
          ],

          workoutsToAvoid: [
            'Olyan terhelés, amely a megszokott regenerációdat meghaladja',
            'Edzés akkor, ha erős tünetek miatt rosszul érzed magad',
          ],

          intensityGuide:
              'A ciklus második felében is lehet magasabb intenzitású edzést '
              'végezni, ha jól érzed magad. PMS vagy fokozott fáradtság esetén '
              'nyugodtan csökkentsd a terhelést.',

          recommendedFoods: [
            'Teljes értékű gabonák',
            'Zab',
            'Barna rizs',
            'Édesburgonya és egyéb keményítőtartalmú zöldségek',
            'Hüvelyesek',
            'Olajos magvak',
            'Zöldségek és gyümölcsök',
            'Fehérjében gazdag ételek',
          ],

          keyNutrients: [
            'Magnézium',
            'Kalcium',
            'B6-vitamin',
            'Rost',
            'Fehérje',
            'Omega-3 zsírsavak',
          ],

          hydrationAdvice:
              'A puffadás vagy vízvisszatartás érzése mellett is fontos a rendszeres '
              'folyadékbevitel. Ne korlátozd a folyadékot csak azért, mert puffadtabbnak érzed magad.',

          mentalWellnessTips: [
            'Figyeld meg, hogy jelentkeznek-e nálad visszatérő PMS-tünetek',
            'Vezess tünetnaplót több cikluson keresztül',
            'Oszd kisebb részekre a nagyobb feladatokat, ha fáradtabbnak érzed magad',
            'Hagyj időt a pihenésre és regenerációra',
            'Ne tekintsd a hangulatváltozást a személyiséged állandó részének',
          ],

          socialEnergy:
              'A társas energia egyénenként változhat. Ha PMS-tüneteket tapasztalsz, '
              'tervezd úgy a programjaidat, hogy maradjon lehetőséged pihenni.',

          skinState:
              'A hormonális változások egyeseknél fokozhatják a faggyútermelést '
              'és hozzájárulhatnak az akné fellángolásához.',

          skincareTips: [
            'Használj gyengéd, nem dörzsölő arctisztítót',
            'Akne esetén szóba jöhet szalicilsavat tartalmazó termék',
            'Használj nem komedogén hidratálót',
            'Használj széles spektrumú SPF 30+ fényvédőt',
            'Ne vezess be egyszerre több új aktív hatóanyagot',
          ],

          energyLevel: 'Változó – a ciklus vége felé egyesek fáradtabbnak érzik magukat.',

          vitaminsAndSupplements: [
            'Nincs mindenkinek szükséges PMS-specifikus étrend-kiegészítő',
            'Magnéziumbevitel elsősorban változatos étrendből biztosítható',
            'B6-vitaminból ne alkalmazz nagy dózisú pótlást szakmai javaslat nélkül',
            'Tartós vagy jelentős PMS-tünetek esetén érdemes orvossal egyeztetni',
          ],

          sleepAdvice:
              'A rendszeres alvás különösen fontos lehet akkor, ha a ciklus vége '
              'felé fáradtabbnak érzed magad. Tarts következetes lefekvési és '
              'ébredési időt, és biztosíts nyugodt alvási környezetet.',
        );
    }
  }
}
