import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettings extends ChangeNotifier {
  static final GameSettings _instance = GameSettings._internal();
  factory GameSettings() => _instance;
  GameSettings._internal();

  double _masterVolume = 0.8;
  double _bgmVolume = 0.6;
  double _sfxVolume = 0.7;
  bool _vibration = true;
  bool _rightHanded = true;

  double get masterVolume => _masterVolume;
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  bool get vibration => _vibration;
  bool get rightHanded => _rightHanded;

  set masterVolume(double v) { _masterVolume = v; notifyListeners(); _save(); }
  set bgmVolume(double v) { _bgmVolume = v; notifyListeners(); _save(); }
  set sfxVolume(double v) { _sfxVolume = v; notifyListeners(); _save(); }
  set vibration(bool v) { _vibration = v; notifyListeners(); _save(); }
  set rightHanded(bool v) { _rightHanded = v; notifyListeners(); _save(); }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _masterVolume = prefs.getDouble('masterVolume') ?? 0.8;
    _bgmVolume = prefs.getDouble('bgmVolume') ?? 0.6;
    _sfxVolume = prefs.getDouble('sfxVolume') ?? 0.7;
    _vibration = prefs.getBool('vibration') ?? true;
    _rightHanded = prefs.getBool('rightHanded') ?? true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('masterVolume', _masterVolume);
    await prefs.setDouble('bgmVolume', _bgmVolume);
    await prefs.setDouble('sfxVolume', _sfxVolume);
    await prefs.setBool('vibration', _vibration);
    await prefs.setBool('rightHanded', _rightHanded);
  }

  void resetToDefault() {
    _masterVolume = 0.8;
    _bgmVolume = 0.6;
    _sfxVolume = 0.7;
    _vibration = true;
    _rightHanded = true;
    notifyListeners();
    _save();
  }
}
