import 'package:flutter/material.dart';

import '../models/mood.dart';
import '../services/mood_service.dart';
import '../services/weather_service.dart';

class MoodWeatherScreen extends StatefulWidget {
  const MoodWeatherScreen({super.key});

  @override
  State<MoodWeatherScreen> createState() => _MoodWeatherScreenState();
}

class _MoodWeatherScreenState extends State<MoodWeatherScreen> {
  final MoodService _moodService = MoodService();
  final WeatherService _weatherService = WeatherService();

  List<MoodEntry> _entries = [];
  int _selectedMood = 0;
  final TextEditingController _noteCtrl = TextEditingController();
  String? _weatherSummary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _moodService.getAll();
    try {
      final w = await _weatherService.fetchWeather();
      _weatherSummary = '${_weatherService.weatherIconForCode(w.weatherCode)} ${w.temperatureC.toStringAsFixed(1)}°C • ${_weatherService.conditionLabelForCode(w.weatherCode)}';
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _entries = entries.reversed.toList();
    });
  }

  Future<void> _save() async {
    await _moodService.addMood(mood: _selectedMood, note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text);
    _noteCtrl.clear();
    _selectedMood = 0;
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mood tersimpan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood & Cuaca'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_weatherSummary != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_weatherSummary!)),
                  ],
                ),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Catat Mood Hari Ini', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _moodChip('😞', -2),
                      _moodChip('🙁', -1),
                      _moodChip('😐', 0),
                      _moodChip('🙂', 1),
                      _moodChip('😄', 2),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Simpan'),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Riwayat', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ..._entries.map((e) => ListTile(
                leading: Text(_emojiForMood(e.mood), style: const TextStyle(fontSize: 20)),
                title: Text('${e.date.toLocal()}'.split('.').first),
                subtitle: Text(e.note ?? '-'),
                trailing: Text(e.temperatureC != null ? '${e.temperatureC!.toStringAsFixed(0)}°C' : ''),
              )),
        ],
      ),
    );
  }

  Widget _moodChip(String emoji, int value) {
    final selected = _selectedMood == value;
    return ChoiceChip(
      label: Text(emoji, style: const TextStyle(fontSize: 18)),
      selected: selected,
      onSelected: (_) => setState(() => _selectedMood = value),
    );
  }

  String _emojiForMood(int m) {
    switch (m) {
      case -2:
        return '😞';
      case -1:
        return '🙁';
      case 0:
        return '😐';
      case 1:
        return '🙂';
      case 2:
        return '😄';
      default:
        return '😐';
    }
  }
}


