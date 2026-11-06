import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/emergency_providers.dart';
import '../../services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget para controlar la velocidad de habla (Speech Rate)
/// 
/// Rango real: 0.3 (30%) a 0.8 (80%)
/// Rango UI: 1% a 100% (donde 1% = 0.3 y 100% = 0.8)
class SpeechRateSlider extends ConsumerWidget {
  const SpeechRateSlider({super.key});

  // Constantes para el mapeo
  static const double _minRealRate = 0.2;  // 20% real = 1% UI
  static const double _maxRealRate = 0.8;  // 80% real = 100% UI
  static const double _minUIRate = 1.0;    // 1% UI
  static const double _maxUIRate = 100.0;  // 100% UI

  /// Convierte valor real (0.2-0.8) a porcentaje UI (1-100)
  static int _realToUI(double realRate) {
    // Mapeo lineal: (realRate - minReal) / (maxReal - minReal) * (maxUI - minUI) + minUI
    return ((realRate - _minRealRate) / (_maxRealRate - _minRealRate) * (_maxUIRate - _minUIRate) + _minUIRate).round();
  }

  /// Convierte porcentaje UI (1-100) a valor real (0.2-0.8)
  static double _uiToReal(double uiPercent) {
    // Mapeo lineal inverso
    return (uiPercent - _minUIRate) / (_maxUIRate - _minUIRate) * (_maxRealRate - _minRealRate) + _minRealRate;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speechRate = ref.watch(speechRateProvider);
    final displayPercent = _realToUI(speechRate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Velocidad de habla',
              style: TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
            ),
            Text(
              '$displayPercent%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: displayPercent <= 30
                    ? const Color(0xFF58A6A6)
                    : (displayPercent <= 70
                          ? const Color(0xFFE57373)
                          : const Color(0xFFD32F2F)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: displayPercent.toDouble(),
          min: _minUIRate,
          max: _maxUIRate,
          divisions: 100,
          label: '$displayPercent%',
          activeColor: displayPercent <= 30
              ? const Color(0xFF58A6A6)
              : (displayPercent <= 70
                    ? const Color(0xFFE57373)
                    : const Color(0xFFD32F2F)),
          inactiveColor: Colors.grey[300],
          thumbColor: displayPercent <= 30
              ? const Color(0xFF58A6A6)
              : (displayPercent <= 70
                    ? const Color(0xFFE57373)
                    : const Color(0xFFD32F2F)),
          onChanged: (uiValue) async {
            // Convertir porcentaje UI a valor real
            final realRate = _uiToReal(uiValue);
            
            // Actualizar provider
            ref.read(speechRateProvider.notifier).state = realRate;
            // Actualizar servicio
            AudioService.setSpeechRate(realRate);
            // Guardar en SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setDouble('audio_speech_rate', realRate);
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Muy lento',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Normal',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: (speechRate >= 0.65 && speechRate <= 0.75)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            
            const Text(
              'Rápido',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Ajusta la velocidad para que las instrucciones sean más fáciles de seguir',
          style: TextStyle(fontSize: 12, color: Color(0xFF7A8E8E)),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            // Detener cualquier reproducción actual y limpiar cola
            await AudioService.stopAll();
            await Future.delayed(const Duration(milliseconds: 100));
            AudioService.speak(
              "Esta es una prueba de velocidad de voz. "
              "Ajusta el control deslizante para cambiar la velocidad.",
            );
          },
          icon: const Icon(Icons.volume_up),
          label: const Text("Probar velocidad"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF58A6A6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
