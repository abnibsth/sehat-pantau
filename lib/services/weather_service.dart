import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../models/weather.dart';

class WeatherService {
  Future<bool> _ensureLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } on MissingPluginException {
      // Plugin belum ter-registrasi (mis. belum full restart). Anggap tidak ada izin.
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Position> _getPositionOrDefault() async {
    try {
      final hasPermission = await _ensureLocationPermission();
      if (hasPermission) {
        return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      }
    } on MissingPluginException {
      // Fallback jika plugin belum siap.
    } catch (_) {}

    // Jakarta default
    return Position(
      latitude: -6.200000,
      longitude: 106.816666,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  String _buildOpenMeteoUrl(double lat, double lon) {
    final params = {
      'latitude': lat.toStringAsFixed(6),
      'longitude': lon.toStringAsFixed(6),
      'current': 'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code',
      // UV index tersedia di hourly, bukan current
      'hourly': 'uv_index',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'timezone': 'auto',
      'forecast_days': '5',
    };
    final q = params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
    return 'https://api.open-meteo.com/v1/forecast?$q';
  }

  String _reverseGeocodeName(double lat, double lon) {
    // Sederhana: tampilkan lat,lon jika tidak ada reverse geocoding
    return 'Lat ${lat.toStringAsFixed(3)}, Lon ${lon.toStringAsFixed(3)}';
  }

  Future<WeatherData> fetchWeather() async {
    final position = await _getPositionOrDefault();
    final url = _buildOpenMeteoUrl(position.latitude, position.longitude);
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('Gagal memuat cuaca (${resp.statusCode})');
    }

    final data = json.decode(resp.body) as Map<String, dynamic>;
    final current = (data['current'] as Map<String, dynamic>);
    final daily = data['daily'] as Map<String, dynamic>;
    final hourly = (data['hourly'] as Map<String, dynamic>);

    final List days = daily['time'] as List;
    final List maxs = daily['temperature_2m_max'] as List;
    final List mins = daily['temperature_2m_min'] as List;
    final List codes = daily['weather_code'] as List;

    final forecasts = <DailyForecast>[];
    for (int i = 0; i < days.length && forecasts.length < 5; i++) {
      forecasts.add(
        DailyForecast(
          date: DateFormat('yyyy-MM-dd').parse(days[i] as String),
          dayTemp: (maxs[i] as num).toDouble(),
          nightTemp: (mins[i] as num).toDouble(),
          weatherCode: (codes[i] as num).toInt(),
        ),
      );
    }

    // Ambil UV index dari hourly berdasarkan jam current
    double uv = 0.0;
    try {
      final String currentTime = (current['time'] as String);
      final List hours = (hourly['time'] as List);
      final List uvs = (hourly['uv_index'] as List);
      final idx = hours.indexOf(currentTime);
      if (idx != -1) {
        uv = (uvs[idx] as num?)?.toDouble() ?? 0.0;
      }
    } catch (_) {
      uv = 0.0;
    }

    // Konversi ke km/jam bila diperlukan (Open-Meteo default m/s)
    final double windSpeedMs = (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0;
    final double windSpeedKmh = windSpeedMs * 3.6;

    return WeatherData(
      locationName: _reverseGeocodeName(position.latitude, position.longitude),
      temperatureC: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      humidityPercent: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      windSpeedKmh: windSpeedKmh,
      uvIndex: uv,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      latitude: position.latitude,
      longitude: position.longitude,
      forecast5Days: forecasts,
    );
  }

  // Mapping sederhana WMO weather codes ke ikon dan label
  String weatherIconForCode(int code) {
    if (code == 0) return '☀️'; // Clear
    if ({1, 2}.contains(code)) return '🌤️'; // Mostly clear
    if ({3}.contains(code)) return '⛅';
    if ({45, 48}.contains(code)) return '🌫️';
    if ({51, 53, 55, 61, 63, 65}.contains(code)) return '🌧️';
    if ({66, 67}.contains(code)) return '🌧️';
    if ({71, 73, 75, 77, 85, 86}.contains(code)) return '❄️';
    if ({95, 96, 99}.contains(code)) return '⛈️';
    return '☁️';
  }

  String conditionLabelForCode(int code) {
    if (code == 0) return 'Cerah';
    if ({1, 2}.contains(code)) return 'Cerah Berawan';
    if ({3}.contains(code)) return 'Berawan';
    if ({45, 48}.contains(code)) return 'Berkabut';
    if ({51, 53, 55, 61, 63, 65, 66, 67}.contains(code)) return 'Hujan';
    if ({71, 73, 75, 77, 85, 86}.contains(code)) return 'Salju';
    if ({95, 96, 99}.contains(code)) return 'Badai Petir';
    return 'Berawan';
  }

  String activitySuggestion({required double tempC, required int code}) {
    final isRain = {51, 53, 55, 61, 63, 65, 66, 67, 95, 96, 99}.contains(code);
    final isHot = tempC >= 32;
    final isClear = code == 0 || {1, 2}.contains(code);

    if (isRain) {
      return 'Cuaca hujan, pilih olahraga indoor dan bawa payung.';
    }
    if (isHot) {
      return 'Cuaca panas, perbanyak hidrasi dan hindari olahraga siang hari.';
    }
    if (isClear) {
      return 'Cuaca cerah, bagus untuk jalan pagi atau sore.';
    }
    return 'Sesuaikan aktivitas, hindari paparan ekstrem, tetap hidrasi.';
  }

  String workoutRecommendation({required double tempC, required int code}) {
    final isRain = {51, 53, 55, 61, 63, 65, 66, 67, 95, 96, 99}.contains(code);
    final isHot = tempC >= 32;
    final isClear = code == 0 || {1, 2}.contains(code);

    if (isRain) return 'Yoga/Pilates indoor, latihan kekuatan ringan di rumah.';
    if (isHot) return 'Latihan mobilitas/streching indoor, jalan sore setelah pukul 17.00.';
    if (isClear) return 'Jogging pagi 20-30 menit atau bersepeda sore.';
    return 'Berjalan santai 20 menit atau latihan tubuh-bobot ringan.';
  }
}


