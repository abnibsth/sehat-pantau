class DailyForecast {
  final DateTime date;
  final double dayTemp;
  final double nightTemp;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.dayTemp,
    required this.nightTemp,
    required this.weatherCode,
  });
}

class WeatherData {
  final String locationName;
  final double temperatureC;
  final int humidityPercent;
  final double windSpeedKmh;
  final double uvIndex;
  final int weatherCode;
  final double latitude;
  final double longitude;
  final List<DailyForecast> forecast5Days;

  WeatherData({
    required this.locationName,
    required this.temperatureC,
    required this.humidityPercent,
    required this.windSpeedKmh,
    required this.uvIndex,
    required this.weatherCode,
    required this.latitude,
    required this.longitude,
    required this.forecast5Days,
  });
}


