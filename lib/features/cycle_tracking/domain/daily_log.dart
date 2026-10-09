import 'package:flutter/foundation.dart';

enum FlowIntensity { light, medium, heavy }

enum Mood { happy, calm, irritable, stressed, sad, tired }

enum PhysicalSymptom {
  cramps,
  headache,
  backPain,
  breastTenderness,
  bloating,
  fatigue,
}

enum SkinSymptom { acne, oily, sensitive }

enum OtherSymptom { nausea, dizziness, sleepDisturbance }

enum ProtectionType { protected, unprotected }

enum CervicalMucus { dry, creamy, watery, eggWhite }

/// Egy nap naplóbejegyzése.
///
/// A domain réteg nem ismeri az adatbázis-azonosítót és az időbélyegeket,
/// azokat az adatréteg kezeli (így a távoli adatbázisra váltás nem érinti).
@immutable
class DailyLog {
  const DailyLog({
    required this.date,
    this.isPeriodStart = false,
    this.isPeriodEnd = false,
    this.flow,
    this.moods = const {},
    this.physicalSymptoms = const {},
    this.skinSymptoms = const {},
    this.otherSymptoms = const {},
    this.hadSexualActivity = false,
    this.protection,
    this.cervicalMucus,
  });

  /// A nap UTC éjfélre normalizálva.
  final DateTime date;
  final bool isPeriodStart;
  final bool isPeriodEnd;
  final FlowIntensity? flow;
  final Set<Mood> moods;
  final Set<PhysicalSymptom> physicalSymptoms;
  final Set<SkinSymptom> skinSymptoms;
  final Set<OtherSymptom> otherSymptoms;
  final bool hadSexualActivity;
  final ProtectionType? protection;
  final CervicalMucus? cervicalMucus;

  /// Vérzéses napnak számít-e (kezdet jelölés vagy vérzéserősség megadva).
  bool get hasBleeding => isPeriodStart || flow != null;

  /// Nincs rögzített adat – az ilyen bejegyzést nem tároljuk.
  bool get isEmpty =>
      !isPeriodStart &&
      !isPeriodEnd &&
      flow == null &&
      moods.isEmpty &&
      physicalSymptoms.isEmpty &&
      skinSymptoms.isEmpty &&
      otherSymptoms.isEmpty &&
      !hadSexualActivity &&
      protection == null &&
      cervicalMucus == null;
}
