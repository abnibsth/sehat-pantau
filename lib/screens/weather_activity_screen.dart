import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherActivityScreen extends StatefulWidget {
  const WeatherActivityScreen({super.key});

  @override
  State<WeatherActivityScreen> createState() => _WeatherActivityScreenState();
}

class _WeatherActivityScreenState extends State<WeatherActivityScreen> {
  final WeatherService _service = WeatherService();
  WeatherData? _weather;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final w = await _service.fetchWeather();
      if (!mounted) return;
      setState(() {
        _weather = w;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat cuaca: ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca & Aktivitas'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildCurrentSummary(),
                      const SizedBox(height: 16),
                      _buildForecast(),
                      const SizedBox(height: 16),
                      _buildActivitySuggestion(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCurrentSummary() {
    final w = _weather!;
    final icon = _service.weatherIconForCode(w.weatherCode);
    final label = _service.conditionLabelForCode(w.weatherCode);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(w.locationName, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
                const Spacer(),
                Text(
                  '${w.temperatureC.toStringAsFixed(1)}°C',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metricTile(Icons.water_drop, 'Kelembapan', '${w.humidityPercent}%'),
                _metricTile(Icons.air, 'Angin', '${w.windSpeedKmh.toStringAsFixed(1)} km/j'),
                _metricTile(Icons.wb_sunny, 'UV', w.uvIndex.toStringAsFixed(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[600]),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        )
      ],
    );
  }

  Widget _buildForecast() {
    final w = _weather!;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prakiraan 5 Hari', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...w.forecast5Days.map((f) {
              final day = DateFormat('EEE, d MMM', 'id_ID').format(f.date);
              final icon = _service.weatherIconForCode(f.weatherCode);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(day)),
                    Text(icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text('${f.dayTemp.toStringAsFixed(0)}° / ${f.nightTemp.toStringAsFixed(0)}°'),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySuggestion() {
    final w = _weather!;
    final suggestion = _service.activitySuggestion(tempC: w.temperatureC, code: w.weatherCode);
    return Card(
      color: Colors.blue[50],
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.tips_and_updates, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saran Aktivitas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(suggestion),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


