import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakService {
  static StreamSubscription<AccelerometerEvent>? _subscription;
  static DateTime? _lastShakeTime;

  static void startListening({
    required VoidCallback onShake,
    double shakeThreshold = 2.7,
  }) {
    _subscription?.cancel();
    try {
      _subscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          double gX = event.x / 9.806665;
          double gY = event.y / 9.806665;
          double gZ = event.z / 9.806665;

          double gForce = sqrt(gX * gX + gY * gY + gZ * gZ);
          if (gForce > shakeThreshold) {
            final now = DateTime.now();
            if (_lastShakeTime == null ||
                now.difference(_lastShakeTime!) > const Duration(seconds: 2)) {
              _lastShakeTime = now;
              onShake();
            }
          }
        },
        onError: (error) {
          debugPrint('Error en Acelerometro: $error');
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('No se pudo inicializar el sensor de agitación $e');
    }
  }

  static void stopListening() {
    _subscription?.cancel();
  }
}
