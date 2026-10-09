import 'package:flutter/material.dart';

import '../domain/cycle_phase.dart';
import '../domain/daily_log.dart';

/// Megjelenítendő (magyar) feliratok. A domain csak kulcsokat (enum) ismer,
/// így a feliratok cseréje / lokalizálása nem érinti az adatokat.
extension FlowIntensityLabel on FlowIntensity {
  String get label => switch (this) {
        FlowIntensity.light => 'enyhe',
        FlowIntensity.medium => 'közepes',
        FlowIntensity.heavy => 'erős',
      };
}

extension MoodLabel on Mood {
  String get label => switch (this) {
        Mood.happy => 'boldog',
        Mood.calm => 'nyugodt',
        Mood.irritable => 'ingerlékeny',
        Mood.stressed => 'stresszes',
        Mood.sad => 'szomorú',
        Mood.tired => 'fáradt',
      };
}

extension PhysicalSymptomLabel on PhysicalSymptom {
  String get label => switch (this) {
        PhysicalSymptom.cramps => 'hasi görcs',
        PhysicalSymptom.headache => 'fejfájás',
        PhysicalSymptom.backPain => 'hátfájás',
        PhysicalSymptom.breastTenderness => 'mellfeszülés',
        PhysicalSymptom.bloating => 'puffadás',
        PhysicalSymptom.fatigue => 'fáradtság',
      };
}

extension SkinSymptomLabel on SkinSymptom {
  String get label => switch (this) {
        SkinSymptom.acne => 'pattanások',
        SkinSymptom.oily => 'zsírosodás',
        SkinSymptom.sensitive => 'érzékenység',
      };
}

extension OtherSymptomLabel on OtherSymptom {
  String get label => switch (this) {
        OtherSymptom.nausea => 'émelygés',
        OtherSymptom.dizziness => 'szédülés',
        OtherSymptom.sleepDisturbance => 'alvászavar',
      };
}

extension ProtectionTypeLabel on ProtectionType {
  String get label => switch (this) {
        ProtectionType.protected => 'védekezéssel',
        ProtectionType.unprotected => 'védekezés nélkül',
      };
}

extension CervicalMucusLabel on CervicalMucus {
  String get label => switch (this) {
        CervicalMucus.dry => 'száraz',
        CervicalMucus.creamy => 'krémes',
        CervicalMucus.watery => 'vizes',
        CervicalMucus.eggWhite => 'tojásfehérje állagú',
      };
}

extension CyclePhaseLabel on CyclePhase {
  String get label => switch (this) {
        CyclePhase.menstrual => 'Menstruációs fázis',
        CyclePhase.follicular => 'Follikuláris fázis',
        CyclePhase.ovulatory => 'Ovuláció körüli időszak',
        CyclePhase.luteal => 'Luteális fázis',
      };

  String get shortLabel => switch (this) {
        CyclePhase.menstrual => 'Menstruáció',
        CyclePhase.follicular => 'Follikuláris',
        CyclePhase.ovulatory => 'Ovuláció',
        CyclePhase.luteal => 'Luteális',
      };

  IconData get icon => switch (this) {
        CyclePhase.menstrual => Icons.water_drop_outlined,
        CyclePhase.follicular => Icons.spa_outlined,
        CyclePhase.ovulatory => Icons.wb_sunny_outlined,
        CyclePhase.luteal => Icons.nights_stay_outlined,
      };
}
