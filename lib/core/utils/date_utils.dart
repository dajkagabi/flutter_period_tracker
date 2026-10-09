/// Naptári napok kezelése.
///
/// Az egész alkalmazásban egyetlen dátumtípust használunk: a nap UTC éjfélre
/// normalizált `DateTime`-ját. Így a nyári/téli időszámítás átállás nem
/// csúsztatja el a napok számítását, és a `Map` kulcsok is egyeznek.
DateTime dayOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// A mai nap (a készülék helyi dátuma szerint), UTC éjfélre normalizálva.
DateTime currentDay() => dayOnly(DateTime.now());

/// `d` + `n` nap (n lehet negatív).
DateTime addDays(DateTime d, int n) => DateTime.utc(d.year, d.month, d.day + n);

/// Teljes napok száma `from` és `to` között (to - from).
int daysBetween(DateTime from, DateTime to) =>
    dayOnly(to).difference(dayOnly(from)).inDays;

bool sameDay(DateTime a, DateTime b) => dayOnly(a) == dayOnly(b);

/// `2026-03-01` formátumú kulcs az adatbázishoz.
String dayKey(DateTime d) {
  final x = dayOnly(d);
  final m = x.month.toString().padLeft(2, '0');
  final day = x.day.toString().padLeft(2, '0');
  return '${x.year.toString().padLeft(4, '0')}-$m-$day';
}

DateTime parseDayKey(String key) {
  final p = key.split('-');
  return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}
