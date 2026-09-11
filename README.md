# Cikluskövető

A **Cikluskövető** egy Flutterrel készült mobilalkalmazás a menstruációs ciklus
és a napi közérzet egyszerű, helyi nyilvántartására. A felhasználó naptárban
követheti a rögzített és becsült ciklusnapokat, részletes napi bejegyzéseket
vezethet, valamint grafikonokon tekintheti meg az összegyűjtött adatokat.

Az alkalmazás az adatokat helyben, a készüléken tárolja. Külső szerverhez vagy
felhasználói fiókhoz nem kapcsolódik.

## Telepítés

### Előfeltételek

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x vagy újabb
- Dart SDK 3.13.2 vagy újabb
- Android Studio vagy Visual Studio Code Flutter- és Dart-bővítményekkel
- Egy beállított Android-, iOS- vagy asztali Flutter-eszköz/emulátor
- Git a projekt klónozásához

Az aktuális környezet ellenőrzéséhez futtasd:

```bash
flutter doctor
```

### Telepítési lépések

1. Klónozd a repositoryt, majd lépj be a projekt könyvtárába:

   ```bash
   git clone https://github.com/dajkagabi/flutter_period_tracker.git
   cd flutter_period_tracker
   ```

2. Töltsd le a projekt függőségeit:

   ```bash
   flutter pub get
   ```

3. Emulatort el kell indítani

   - Android Studio Devices

4. Indítsd el az alkalmazást egy kiválasztott eszközön:

    F5

## Funkciók

- Havi naptárnézet a kiválasztott nap kezelésével.
- Rögzített menstruációs napok megjelenítése a naptárban.
- Következő menstruáció, ovuláció és termékeny időszak becslése.
- Színkódolt naptárjelölések:
  - rögzített menstruáció,
  - várható menstruáció,
  - ovuláció,
  - termékeny időszak.
- Napi menstruációs adatok rögzítése:
  - menstruáció kezdete és vége,
  - vérzés erőssége.
- Hangulatok és tünetek naplózása:
  - fizikai tünetek,
  - bőrtünetek,
  - egyéb tünetek.
- Szexuális aktivitás és a védekezés típusának rögzítése.
- Méhnyaknyák típusának megfigyelése az ovuláció követéséhez.
- Korábban mentett napi adatok betöltése és szerkesztése.
- Statisztikai áttekintő grafikonok:
  - vérzésintenzitás kördiagramon,
  - hangulatok eloszlása kördiagramon,
  - leggyakoribb fizikai tünetek oszlopdiagramon.
- Helyi adatmentés internetkapcsolat nélkül.

> **Megjegyzés:** az előrejelzés tájékoztató jellegű. A számítás a jelenlegi
> implementációban a legutóbbi rögzített menstruáció alapján, alapértelmezett
> ciklus- és menstruációhosszal történik, ezért nem helyettesít orvosi tanácsot.

## Technológia

### Főbb technológiák

- **Flutter** – többplatformos felhasználói felület és alkalmazáskeretrendszer
- **Dart** – programozási nyelv
- **Material 3** – az alkalmazás vizuális alapjai
- **SQLite** – helyi relációs adatbázis
- **Riverpod** – állapotkezelési előkészítés és alkalmazásszintű állapotkezelés

### Könyvtárak

| Könyvtár | Szerepe |
| --- | --- |
| `sqflite` | SQLite-adatbázis kezelése a készüléken |
| `path` | Platformfüggetlen adatbázis-útvonalak összeállítása |
| `flutter_riverpod` | Állapotkezelés |
| `table_calendar` | Interaktív naptármegjelenítés |
| `fl_chart` | Kör- és oszlopdiagramok rajzolása |
| `intl` | Dátum- és lokalizációs segédprogramok |
| `flutter_local_notifications` | Helyi értesítések támogatása |
| `cupertino_icons` | Cupertino ikonok |
| `flutter_lints` | Dart- és Flutter-kódminőségi ellenőrzések |
