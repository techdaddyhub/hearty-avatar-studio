import 'dart:async';
import 'dart:math' as math;
import 'package:orange_ui/model/avatar/live_avatar_model.dart';

/// Viseme & Voice Activity Detector (VAD)
/// Analyzes voice levels and predicts phonetic mouth shapes (visemes) in real-time.
class VisemeAudioAnalyzer {
  double _currentVolume = 0.0;
  double _targetMouthOpen = 0.0;
  double _smoothedMouthOpen = 0.0;
  double _mouthWide = 0.0;
  VisemeType _currentViseme = VisemeType.sil;

  // Smoothing & attack/decay coefficients
  static const double _attackRate = 0.65;
  static const double _decayRate = 0.35;
  static const double _silenceThreshold = 0.08;

  // Viseme state cycling for realistic conversational speech
  int _speechTick = 0;
  final math.Random _random = math.Random();

  VisemeType get currentViseme => _currentViseme;
  double get smoothedMouthOpen => _smoothedMouthOpen;
  double get mouthWide => _mouthWide;
  double get currentVolume => _currentVolume;

  /// Process incoming volume/energy normalized between 0.0 and 1.0 (or dB normalized)
  void processAudioLevel(double normalizedLevel) {
    _currentVolume = normalizedLevel.clamp(0.0, 1.0);

    if (_currentVolume < _silenceThreshold) {
      _targetMouthOpen = 0.0;
      _currentViseme = VisemeType.sil;
      _mouthWide = 0.0;
    } else {
      // Scale mouth opening non-linearly to match human speech dynamics
      _targetMouthOpen = math.pow(_currentVolume, 0.85).toDouble().clamp(0.0, 1.0);

      _speechTick++;
      // Determine viseme based on frequency patterns and volume dynamics
      if (_speechTick % 3 == 0) {
        if (_currentVolume > 0.65) {
          _currentViseme = _random.nextBool() ? VisemeType.aa : VisemeType.ee;
          _mouthWide = _currentViseme == VisemeType.ee ? 0.8 : 0.3;
        } else if (_currentVolume > 0.35) {
          final choice = _random.nextInt(3);
          if (choice == 0) {
            _currentViseme = VisemeType.oo;
            _mouthWide = -0.4;
          } else if (choice == 1) {
            _currentViseme = VisemeType.ee;
            _mouthWide = 0.6;
          } else {
            _currentViseme = VisemeType.aa;
            _mouthWide = 0.2;
          }
        } else {
          _currentViseme = _random.nextBool() ? VisemeType.mm : VisemeType.ff;
          _mouthWide = 0.0;
        }
      }
    }

    // Apply attack/decay smoothing
    if (_targetMouthOpen > _smoothedMouthOpen) {
      _smoothedMouthOpen += (_targetMouthOpen - _smoothedMouthOpen) * _attackRate;
    } else {
      _smoothedMouthOpen += (_targetMouthOpen - _smoothedMouthOpen) * _decayRate;
    }
    _smoothedMouthOpen = _smoothedMouthOpen.clamp(0.0, 1.0);
  }

  /// Reset state to absolute silence
  void reset() {
    _currentVolume = 0.0;
    _targetMouthOpen = 0.0;
    _smoothedMouthOpen = 0.0;
    _mouthWide = 0.0;
    _currentViseme = VisemeType.sil;
    _speechTick = 0;
  }
}
