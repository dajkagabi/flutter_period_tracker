// A napi napló bejegyzés modellje az SQLite adatbázisban való tároláshoz.

class DailyLog {
  final int? id;
  final DateTime date;
  final bool isPeriodStart;
  final bool isPeriodEnd;
  final String? flowIntensity;
  final List<String> moods;
  final List<String> physicalSymptoms;
  final List<String> skinSymptoms;
  final List<String> otherSymptoms;
  final bool hadSexualActivity;
  final String? protectionType;
  final String? cervicalMucus;

  DailyLog({
    this.id,
    required this.date,
    this.isPeriodStart = false,
    this.isPeriodEnd = false,
    this.flowIntensity,
    this.moods = const [],
    this.physicalSymptoms = const [],
    this.skinSymptoms = const [],
    this.otherSymptoms = const [],
    this.hadSexualActivity = false,
    this.protectionType,
    this.cervicalMucus,
  });

  // Konvertálás Map-re az SQLite mentéshez.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // Csak a YYYY-MM-DD dátum részét mentjük el.
      'date': date.toIso8601String().split('T')[0],
      'isPeriodStart': isPeriodStart ? 1 : 0,
      'isPeriodEnd': isPeriodEnd ? 1 : 0,
      'flowIntensity': flowIntensity,
      'moods': moods.join(','),
      'physicalSymptoms': physicalSymptoms.join(','),
      'skinSymptoms': skinSymptoms.join(','),
      'otherSymptoms': otherSymptoms.join(','),
      'hadSexualActivity': hadSexualActivity ? 1 : 0,
      'protectionType': protectionType,
      'cervicalMucus': cervicalMucus,
    };
  }

  // A SQLite-ből olvasott Map alapján létrehozza a DailyLog objektumot.
  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      isPeriodStart: (map['isPeriodStart'] as int) == 1,
      isPeriodEnd: (map['isPeriodEnd'] as int) == 1,
      flowIntensity: map['flowIntensity'] as String?,
      moods: (map['moods'] as String?)?.isNotEmpty == true
          ? (map['moods'] as String).split(',')
          : [],
      physicalSymptoms: (map['physicalSymptoms'] as String?)?.isNotEmpty == true
          ? (map['physicalSymptoms'] as String).split(',')
          : [],
      skinSymptoms: (map['skinSymptoms'] as String?)?.isNotEmpty == true
          ? (map['skinSymptoms'] as String).split(',')
          : [],
      otherSymptoms: (map['otherSymptoms'] as String?)?.isNotEmpty == true
          ? (map['otherSymptoms'] as String).split(',')
          : [],
      hadSexualActivity: (map['hadSexualActivity'] as int) == 1,
      protectionType: map['protectionType'] as String?,
      cervicalMucus: map['cervicalMucus'] as String?,
    );
  }
}
