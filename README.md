# Cikluskövető (flutter_period_tracker)

Újraírt, rétegezett Flutter-projekt: Riverpod állapotkezelés, tiszta (tesztelhető)
ciklusszámítás, repository-absztrakció a későbbi külső adatbázishoz, design-token alapú téma.

## Indítás

```bash
flutter pub get
flutter test
flutter run
```

A régi `lib/` mappa helyére másold ezt a `lib/`-et, a `test/`-et, a `pubspec.yaml`-t
és az `analysis_options.yaml`-t. A régi adatbázis (v1) első indításkor újraépül
(az app még nem éles, ezért nincs adatmigráció).

## Mappastruktúra

```
lib/
├── main.dart
├── app/                      # app.dart, router.dart, routes.dart
│   └── theme/                # app_tokens.dart (színek, térközök, CycleColors), app_theme.dart
├── core/
│   ├── database/             # app_database.dart (SQLite, séma, migráció)
│   ├── services/             # notification_service.dart
│   ├── utils/                # date_utils.dart (egységes naptári nap: UTC éjfél)
│   └── providers.dart
├── features/
│   ├── cycle_tracking/       # domain (számítás) / data (repository) / presentation
│   ├── analytics/
│   ├── lifestyle/            # phase_content.dart (csak adat) + füles képernyő
│   ├── reminders/            # orvosi emlékeztetők, higiéniai időzítő, értesítés-szinkron
│   └── settings/
└── shared/widgets/           # AppCard, SectionHeader, IconTextCard, chip-csoportok, állapotnézetek
```

Függőségi irány: `presentation → domain ← data`. A `domain` réteg nem ismeri
sem a Fluttert (a modelleken kívül), sem az adatbázist.

## Új UI / új arculat

Az összes szín, térköz és sarokrádiusz a `lib/app/theme/` alatt van:

- `AppColors.seed` – az egész `ColorScheme` ebből generálódik,
- `CycleColors` – naptár-jelölések színei (világos/sötét módban külön),
- `AppTheme` – komponens-témák.

A képernyők nem tartalmaznak fix színt (`Colors.pink…`), így az újratémázás
ebben a két fájlban elvégezhető. A közös elemek a `shared/widgets`-ben vannak.

## Külső adatbázis

A `DailyLogRepository` és a `ReminderRepository` interfész. Új megvalósítás
(pl. `RemoteDailyLogRepository`) után a `cycle_providers.dart` /
`reminders_provider.dart` megfelelő providerében kell lecserélni.
A séma már szinkronizáció-barát: UUID azonosító, `created_at`/`updated_at`,
soft delete (`deleted_at`), dátum szerinti upsert (az azonosító nem változik).

## Titkosítás (teendő)

Egészségügyi adatról van szó, ezért az éles verzió előtt kapcsold be:

1. `pubspec.yaml`: `sqflite` helyett `sqflite_sqlcipher`, plusz `flutter_secure_storage`.
2. `core/database/app_database.dart`: importcsere, az `openDatabase`-nek `password` paraméter.
3. A jelszót az első indításkor generáld (véletlen 32 bájt), és a secure storage-ban tartsd.
4. Android: `android:allowBackup="false"` az `AndroidManifest.xml`-ben.

## Android beállítás az értesítésekhez

`android/app/build.gradle(.kts)`:

```
compileOptions { coreLibraryDesugaringEnabled = true }
dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") }
```

`android/app/src/main/AndroidManifest.xml` (az `<application>` előtt és benne):

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>

<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
    <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
  </intent-filter>
</receiver>
```

Az ütemezés `inexactAllowWhileIdle` módot használ (nem kér pontos ébresztő
engedélyt; néhány perc késés lehetséges). Ha percre pontos emlékeztető kell,
cseréld `exactAllowWhileIdle`-re és kérd a `SCHEDULE_EXACT_ALARM` engedélyt.

## Ismert további teendők

- Lokalizáció (ARB) a most beégetett magyar szövegek helyett.
- `phase_content.dart` tartalmának JSON assetbe / távoli forrásba költöztetése.
- Integrációs teszt a SQLite repositoryra (`sqflite_common_ffi`).
