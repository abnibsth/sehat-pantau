import '../models/step_data.dart';
import '../models/sleep_data.dart';
import '../models/food_data.dart';
import '../services/weather_service.dart';
import '../services/mood_service.dart';
import '../models/mood.dart';

class HealthInsight {
  final String title;
  final String message;
  final String suggestion;
  final String icon;
  final String color;
  final int priority; // 1-5, 5 = most important

  HealthInsight({
    required this.title,
    required this.message,
    required this.suggestion,
    required this.icon,
    required this.color,
    required this.priority,
  });
}

class InsightService {
  static final InsightService _instance = InsightService._internal();
  factory InsightService() => _instance;
  InsightService._internal();

  // Rule-based AI untuk memberikan insight kesehatan (tanpa cuaca)
  List<HealthInsight> generateInsights({
    required List<StepData> stepHistory,
    required List<SleepData> sleepHistory,
    required List<FoodData> foodHistory,
  }) {
    List<HealthInsight> insights = [];

    // 1. Analisis Langkah
    if (stepHistory.isNotEmpty) {
      final todaySteps = stepHistory.first.steps;
      final targetSteps = 10000;
      
      if (todaySteps < targetSteps * 0.3) {
        insights.add(HealthInsight(
          title: 'Aktivitas Rendah',
          message: 'Langkah hari ini masih sangat sedikit',
          suggestion: 'Coba berjalan kaki 10-15 menit atau naik tangga untuk meningkatkan aktivitas!',
          icon: '🚶‍♂️',
          color: 'orange',
          priority: 4,
        ));
      } else if (todaySteps < targetSteps * 0.7) {
        insights.add(HealthInsight(
          title: 'Aktivitas Sedang',
          message: 'Langkah sudah cukup baik, tapi bisa lebih optimal',
          suggestion: 'Tambahkan 20-30 menit berjalan kaki untuk mencapai target harian!',
          icon: '👟',
          color: 'blue',
          priority: 3,
        ));
      } else if (todaySteps >= targetSteps) {
        insights.add(HealthInsight(
          title: 'Aktivitas Excellent!',
          message: 'Target langkah harian sudah tercapai!',
          suggestion: 'Pertahankan kebiasaan baik ini untuk kesehatan optimal!',
          icon: '🏆',
          color: 'green',
          priority: 2,
        ));
      }
    }

    // 2. Analisis Tidur
    if (sleepHistory.isNotEmpty) {
      final recentSleep = sleepHistory.first;
      final sleepHours = recentSleep.totalSleep.inHours;
      
      if (sleepHours < 6) {
        insights.add(HealthInsight(
          title: 'Tidur Kurang',
          message: 'Durasi tidur masih kurang dari rekomendasi',
          suggestion: 'Coba tidur 7-9 jam untuk kesehatan optimal. Hindari gadget 1 jam sebelum tidur!',
          icon: '😴',
          color: 'red',
          priority: 5,
        ));
      } else if (sleepHours >= 6 && sleepHours < 7) {
        insights.add(HealthInsight(
          title: 'Tidur Cukup',
          message: 'Durasi tidur sudah cukup, tapi bisa lebih optimal',
          suggestion: 'Coba tambahkan 1-2 jam tidur untuk performa yang lebih baik!',
          icon: '😊',
          color: 'orange',
          priority: 3,
        ));
      } else if (sleepHours >= 7 && sleepHours <= 9) {
        insights.add(HealthInsight(
          title: 'Tidur Optimal!',
          message: 'Durasi tidur sudah sangat baik',
          suggestion: 'Pertahankan pola tidur yang konsisten untuk kesehatan jangka panjang!',
          icon: '😌',
          color: 'green',
          priority: 1,
        ));
      } else if (sleepHours > 9) {
        insights.add(HealthInsight(
          title: 'Tidur Berlebihan',
          message: 'Durasi tidur mungkin terlalu lama',
          suggestion: 'Coba kurangi 1-2 jam tidur untuk keseimbangan yang lebih baik!',
          icon: '😵',
          color: 'blue',
          priority: 2,
        ));
      }
    }

    // 3. Analisis Nutrisi
    if (foodHistory.isNotEmpty) {
      final todayFood = foodHistory.where((food) => 
        food.dateTime.year == DateTime.now().year &&
        food.dateTime.month == DateTime.now().month &&
        food.dateTime.day == DateTime.now().day
      ).toList();

      if (todayFood.isNotEmpty) {
        // Hitung total nutrisi hari ini
        double totalCalories = 0;
        double totalProtein = 0;
        
        for (var food in todayFood) {
          totalCalories += food.calories;
          totalProtein += food.protein;
        }

        // Analisis kalori
        final targetCalories = 2000; // Target kalori harian
        if (totalCalories < targetCalories * 0.5) {
          insights.add(HealthInsight(
            title: 'Asupan Rendah',
            message: 'Konsumsi kalori hari ini masih sangat rendah',
            suggestion: 'Tambahkan makanan bergizi seperti nasi, sayuran, dan protein untuk energi optimal!',
            icon: '🍽️',
            color: 'red',
            priority: 5,
          ));
        } else if (totalCalories < targetCalories * 0.8) {
          insights.add(HealthInsight(
            title: 'Asupan Sedang',
            message: 'Konsumsi kalori sudah cukup, tapi bisa lebih optimal',
            suggestion: 'Tambahkan 1-2 porsi makanan sehat untuk memenuhi kebutuhan harian!',
            icon: '🥗',
            color: 'orange',
            priority: 3,
          ));
        }

        // Analisis protein
        final targetProtein = 50; // Target protein harian (gram)
        if (totalProtein < targetProtein * 0.3) {
          insights.add(HealthInsight(
            title: 'Protein Rendah',
            message: 'Konsumsi protein hari ini masih sangat rendah',
            suggestion: 'Tambahkan telur, tahu, tempe, atau daging untuk memenuhi kebutuhan protein!',
            icon: '🥚',
            color: 'red',
            priority: 4,
          ));
        } else if (totalProtein < targetProtein * 0.7) {
          insights.add(HealthInsight(
            title: 'Protein Sedang',
            message: 'Konsumsi protein sudah cukup, tapi bisa lebih optimal',
            suggestion: 'Tambahkan 1 porsi protein seperti ikan atau kacang-kacangan!',
            icon: '🐟',
            color: 'orange',
            priority: 3,
          ));
        }

        // Analisis variasi makanan
        final uniqueFoods = todayFood.map((f) => f.name).toSet().length;
        if (uniqueFoods < 3) {
          insights.add(HealthInsight(
            title: 'Variasi Makanan',
            message: 'Variasi makanan hari ini masih terbatas',
            suggestion: 'Coba tambahkan sayuran hijau, buah-buahan, dan biji-bijian untuk nutrisi lengkap!',
            icon: '🥬',
            color: 'blue',
            priority: 2,
          ));
        }
      } else {
        // Tidak ada data makanan hari ini
        insights.add(HealthInsight(
          title: 'Belum Ada Data Makanan',
          message: 'Belum ada data asupan makanan hari ini',
          suggestion: 'Mulai catat makanan yang dikonsumsi untuk analisis nutrisi yang lebih baik!',
          icon: '📝',
          color: 'blue',
          priority: 3,
        ));
      }
    }

    // 4. Analisis Keseimbangan
    if (stepHistory.isNotEmpty && sleepHistory.isNotEmpty && foodHistory.isNotEmpty) {
      final todaySteps = stepHistory.first.steps;
      final sleepHours = sleepHistory.first.totalSleep.inHours;
      final todayFood = foodHistory.where((food) => 
        food.dateTime.year == DateTime.now().year &&
        food.dateTime.month == DateTime.now().month &&
        food.dateTime.day == DateTime.now().day
      ).toList();

      if (todaySteps >= 8000 && sleepHours >= 7 && todayFood.length >= 3) {
        insights.add(HealthInsight(
          title: 'Hari yang Sehat!',
          message: 'Semua aspek kesehatan hari ini sudah sangat baik!',
          suggestion: 'Pertahankan pola hidup sehat ini untuk kesehatan jangka panjang!',
          icon: '🌟',
          color: 'green',
          priority: 1,
        ));
      }
    }

    // Urutkan berdasarkan priority (yang paling penting di atas)
    insights.sort((a, b) => b.priority.compareTo(a.priority));
    
    // Ambil maksimal 3 insight teratas
    return insights.take(3).toList();
  }

  // Versi gabungan dengan cuaca
  Future<List<HealthInsight>> generateInsightsWithWeather({
    required List<StepData> stepHistory,
    required List<SleepData> sleepHistory,
    required List<FoodData> foodHistory,
  }) async {
    final base = generateInsights(
      stepHistory: stepHistory,
      sleepHistory: sleepHistory,
      foodHistory: foodHistory,
    );

    try {
      final weather = await WeatherService().fetchWeather();
      final double temp = weather.temperatureC;
      final int code = weather.weatherCode;
      final int todaySteps = stepHistory.isNotEmpty ? stepHistory.first.steps : 0;

      // Aturan: panas + langkah sedikit
      if (temp > 32 && todaySteps < 4000) {
        base.add(HealthInsight(
          title: 'Aktivitas Turun di Hari Panas',
          message: 'Aktivitas menurun saat suhu > 32°C.',
          suggestion: 'Coba jalan di pagi/sore dan perbanyak hidrasi.',
          icon: '🌞',
          color: 'orange',
          priority: 4,
        ));
      }

      // Aturan: cerah + langkah meningkat
      final bool isClear = code == 0 || {1, 2}.contains(code);
      if (isClear && todaySteps >= 8000) {
        base.add(HealthInsight(
          title: 'Cuaca Cerah Mendorong Aktivitas',
          message: 'Cuaca cerah mendukung aktivitasmu!',
          suggestion: 'Pertahankan ritme ini, bagus untuk kebugaran.',
          icon: '🌤️',
          color: 'green',
          priority: 2,
        ));
      }

      // Cuaca dan Tidur: bandingkan tidur terakhir dengan suhu malam (pakai min temp hari ini)
      if (sleepHistory.isNotEmpty && weather.forecast5Days.isNotEmpty) {
        final sleepHours = sleepHistory.first.totalSleep.inHours;
        final nightTemp = weather.forecast5Days.first.nightTemp; // asumsi malam sebelumnya
        if (sleepHours < 6 && nightTemp > 28) {
          base.add(HealthInsight(
            title: 'Tidur Terganggu Panas',
            message: 'Kualitas tidur menurun saat suhu malam > 28°C.',
            suggestion: 'Gunakan kipas/AC, kurangi kafein malam hari, mandi air hangat.',
            icon: '🥵',
            color: 'red',
            priority: 4,
          ));
        }
      }

      // Mood & Cuaca: korelasi sederhana 7 hari
      final moods = await MoodService().getAll();
      if (moods.isNotEmpty) {
        final last7 = moods.where((m) => m.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))).toList();
        if (last7.length >= 3) {
          final hot = last7.where((m) => (m.temperatureC ?? 0) > 32).toList();
          final cool = last7.where((m) => (m.temperatureC ?? 0) <= 32).toList();
          double avg(List<MoodEntry> l) => l.isEmpty ? 0 : l.map((e) => e.mood).reduce((a, b) => a + b) / l.length;
          final avgHot = avg(hot);
          final avgCool = avg(cool);
          if (hot.length >= 2 && avgHot < avgCool - 0.5) {
            base.add(HealthInsight(
              title: 'Mood Turun di Hari Panas',
              message: 'Rata-rata mood lebih rendah saat suhu > 32°C.',
              suggestion: 'Kurangi aktivitas terik siang, pilih ruang sejuk, hidrasi cukup.',
              icon: '🌞',
              color: 'orange',
              priority: 3,
            ));
          }
        }
      }
    } catch (_) {
      // Abaikan error cuaca, tetap kembalikan insight dasar
    }

    // Urutkan dan batasi 3 teratas
    base.sort((a, b) => b.priority.compareTo(a.priority));
    return base.take(3).toList();
  }

  // Method untuk mendapatkan insight berdasarkan data spesifik
  HealthInsight? getTopInsight({
    required List<StepData> stepHistory,
    required List<SleepData> sleepHistory,
    required List<FoodData> foodHistory,
  }) {
    final insights = generateInsights(
      stepHistory: stepHistory,
      sleepHistory: sleepHistory,
      foodHistory: foodHistory,
    );
    
    return insights.isNotEmpty ? insights.first : null;
  }
}
