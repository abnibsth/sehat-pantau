import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/step_data.dart';

class StepService {
  static final StepService _instance = StepService._internal();
  factory StepService() => _instance;
  StepService._internal();

  StreamSubscription<StepCount>? _stepCountStream;
  int _currentSteps = 0;
  DateTime? _lastResetDate;
  final String _stepsKey = 'daily_steps';
  final String _lastResetKey = 'last_reset_date';

  int get currentSteps => _currentSteps;

  Future<void> initialize() async {
    await _loadStepsFromStorage();
    await _checkAndResetDaily();
    await _startStepCounting();
  }

  Future<void> _loadStepsFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSteps = prefs.getInt(_stepsKey) ?? 0;
    final lastResetString = prefs.getString(_lastResetKey);
    if (lastResetString != null) {
      _lastResetDate = DateTime.parse(lastResetString);
    }
  }

  Future<void> _checkAndResetDaily() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastResetDate == null || 
        _lastResetDate!.isBefore(today)) {
      await _saveStepsToHistory();
      _currentSteps = 0;
      _lastResetDate = today;
      await _saveCurrentSteps();
    }
  }

  Future<void> _startStepCounting() async {
    try {
      _stepCountStream = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
    } catch (e) {
      print('Error starting step counting: $e');
    }
  }

  void _onStepCount(StepCount event) {
    _currentSteps = event.steps;
    _saveCurrentSteps();
  }

  void _onStepCountError(error) {
    print('Step count error: $error');
  }

  Future<void> _saveCurrentSteps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_stepsKey, _currentSteps);
    await prefs.setString(_lastResetKey, _lastResetDate!.toIso8601String());
  }

  Future<void> _saveStepsToHistory() async {
    if (_currentSteps > 0) {
      final today = DateTime.now();
      final stepData = StepData(
        date: DateTime(today.year, today.month, today.day),
        steps: _currentSteps,
        distance: _currentSteps * 0.7, // Estimasi 0.7 meter per langkah
        calories: (_currentSteps * 0.04).round(), // Estimasi kalori
      );
      
      await _saveStepDataToHistory(stepData);
    }
  }

  Future<void> _saveStepDataToHistory(StepData stepData) async {
    final prefs = await SharedPreferences.getInstance();
    final historyKey = 'steps_history_${stepData.date.millisecondsSinceEpoch}';
    await prefs.setString(historyKey, jsonEncode(stepData.toJson()));
  }

  Future<List<StepData>> getStepHistory(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final List<StepData> history = [];
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final historyKey = 'steps_history_${date.millisecondsSinceEpoch}';
      final stepDataString = prefs.getString(historyKey);
      
      if (stepDataString != null) {
        final stepDataJson = jsonDecode(stepDataString);
        history.add(StepData.fromJson(stepDataJson));
      }
    }
    
    return history;
  }

  // Public method untuk menyimpan data langkah manual
  Future<void> saveManualStepData(StepData stepData) async {
    await _saveStepDataToHistory(stepData);
    _currentSteps = stepData.steps;
    await _saveCurrentSteps();
  }


  void dispose() {
    _stepCountStream?.cancel();
  }
}
