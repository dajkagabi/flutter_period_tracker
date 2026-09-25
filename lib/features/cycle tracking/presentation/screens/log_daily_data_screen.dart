import 'package:flutter/material.dart';

import '../../data/daily_log_model.dart';
import '../../data/daily_log_repository.dart';

// Naplózás képernyő,
// ahol a felhasználó rögzítheti a napi adatokat
class LogDailyDataScreen extends StatefulWidget {
  final DateTime selectedDate;

  const LogDailyDataScreen({super.key, required this.selectedDate});

  @override
  State<LogDailyDataScreen> createState() => _LogDailyDataScreenState();
}

class _LogDailyDataScreenState extends State<LogDailyDataScreen> {
  final DailyLogRepository _repository = DailyLogRepository();

  bool _isPeriodStart = false;
  bool _isPeriodEnd = false;
  String? _flowIntensity;

  List<String> _selectedMoods = [];
  List<String> _selectedPhysicalSymptoms = [];
  List<String> _selectedSkinSymptoms = [];
  List<String> _selectedOtherSymptoms = [];

  bool _hadSexualActivity = false;
  String? _protectionType;

  String? _cervicalMucus;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  // Ha erre a napra már volt elmentve adat, betöltjük
  Future<void> _loadExistingData() async {
    final existingLog = await _repository.getLogByDate(widget.selectedDate);
    if (existingLog != null) {
      setState(() {
        _isPeriodStart = existingLog.isPeriodStart;
        _isPeriodEnd = existingLog.isPeriodEnd;
        _flowIntensity = existingLog.flowIntensity;
        _selectedMoods = List.from(existingLog.moods);
        _selectedPhysicalSymptoms = List.from(existingLog.physicalSymptoms);
        _selectedSkinSymptoms = List.from(existingLog.skinSymptoms);
        _selectedOtherSymptoms = List.from(existingLog.otherSymptoms);
        _hadSexualActivity = existingLog.hadSexualActivity;
        _protectionType = existingLog.protectionType;
        _cervicalMucus = existingLog.cervicalMucus;
      });
    }
    setState(() => _isLoading = false);
  }

  // Mentés az adatbázisba
  Future<void> _saveData() async {
    final log = DailyLog(
      date: widget.selectedDate,
      isPeriodStart: _isPeriodStart,
      isPeriodEnd: _isPeriodEnd,
      flowIntensity: _flowIntensity,
      moods: _selectedMoods,
      physicalSymptoms: _selectedPhysicalSymptoms,
      skinSymptoms: _selectedSkinSymptoms,
      otherSymptoms: _selectedOtherSymptoms,
      hadSexualActivity: _hadSexualActivity,
      protectionType: _protectionType,
      cervicalMucus: _cervicalMucus,
    );

    await _repository.saveDailyLog(log);
    if (mounted) {
      Navigator.pop(context, true); // Visszalépünk a naptárba és frissítünk
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        "${widget.selectedDate.year}.${widget.selectedDate.month}.${widget.selectedDate.day}.";

    return Scaffold(
      appBar: AppBar(
        title: Text('Naplózás - $dateStr'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 28),
            onPressed: _saveData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1.  MENSTRUÁCIÓ
                _buildSectionTitle(' Menstruáció'),
                CheckboxListTile(
                  title: const Text('Menstruáció kezdete'),
                  value: _isPeriodStart,
                  onChanged: (val) =>
                      setState(() => _isPeriodStart = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Menstruáció vége'),
                  value: _isPeriodEnd,
                  onChanged: (val) =>
                      setState(() => _isPeriodEnd = val ?? false),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vérzés erőssége:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: ['enyhe', 'közepes', 'erős'].map((intensity) {
                    return ChoiceChip(
                      label: Text(intensity),
                      selected: _flowIntensity == intensity,
                      onSelected: (selected) {
                        setState(
                          () => _flowIntensity = selected ? intensity : null,
                        );
                      },
                    );
                  }).toList(),
                ),

                const Divider(height: 32),

                // 2.  HANGULAT
                _buildSectionTitle(' Hangulat'),
                _buildMultiSelectChips(
                  options: [
                    'boldog',
                    'nyugodt',
                    'ingerlékeny',
                    'stresszes',
                    'szomorú',
                    'fáradt',
                  ],
                  selectedList: _selectedMoods,
                ),

                const Divider(height: 32),

                // 3.  TÜNETEK
                _buildSectionTitle(' Tünetek'),
                const Text(
                  'Fizikai',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildMultiSelectChips(
                  options: [
                    'hasi görcs',
                    'fejfájás',
                    'hátfájás',
                    'mellfeszülés',
                    'puffadás',
                    'fáradtság',
                  ],
                  selectedList: _selectedPhysicalSymptoms,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bőr',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildMultiSelectChips(
                  options: ['pattanások', 'zsírosodás', 'érzékenység'],
                  selectedList: _selectedSkinSymptoms,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Egyéb',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildMultiSelectChips(
                  options: ['émelygés', 'szédülés', 'alvászavar'],
                  selectedList: _selectedOtherSymptoms,
                ),

                const Divider(height: 32),

                // 4.  SZEXUÁLIS AKTIVITÁS
                _buildSectionTitle(' Szexuális aktivitás'),
                SwitchListTile(
                  title: const Text('Volt szexuális aktivitás?'),
                  value: _hadSexualActivity,
                  onChanged: (val) => setState(() => _hadSexualActivity = val),
                ),
                if (_hadSexualActivity)
                  Wrap(
                    spacing: 8,
                    children: ['védekezéssel', 'védekezés nélkül'].map((type) {
                      return ChoiceChip(
                        label: Text(type),
                        selected: _protectionType == type,
                        onSelected: (selected) {
                          setState(
                            () => _protectionType = selected ? type : null,
                          );
                        },
                      );
                    }).toList(),
                  ),

                const Divider(height: 32),

                // 5.  OVULÁCIÓ MEGFIGYELÉS
                _buildSectionTitle(' Ovuláció megfigyelés'),
                const Text(
                  'Nyák típusa:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: ['száraz', 'krémes', 'vizes', 'tojásfehérje állagú']
                      .map((type) {
                        return ChoiceChip(
                          label: Text(type),
                          selected: _cervicalMucus == type,
                          onSelected: (selected) {
                            setState(
                              () => _cervicalMucus = selected ? type : null,
                            );
                          },
                        );
                      })
                      .toList(),
                ),

                const SizedBox(height: 40),

                // MENTÉS GOMB
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveData,
                    child: const Text('Mentés', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.pink,
        ),
      ),
    );
  }

  Widget _buildMultiSelectChips({
    required List<String> options,
    required List<String> selectedList,
  }) {
    return Wrap(
      spacing: 8,
      children: options.map((option) {
        final isSelected = selectedList.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedList.add(option);
              } else {
                selectedList.remove(option);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
