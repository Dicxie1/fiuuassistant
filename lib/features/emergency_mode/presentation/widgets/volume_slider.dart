import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/emergency_providers.dart';
import '../../services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget para controlar el volumen de audio
class VolumeSlider extends ConsumerWidget {
  const VolumeSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(audioVolumeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Volumen de audio',
              style: TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
            ),
            Row(
              children: [
                Icon(
                  volume >= 0.67
                      ? Icons.volume_up
                      : (volume >= 0.33
                            ? Icons.volume_down
                            : Icons.volume_mute),
                  color: volume >= 0.67
                      ? Colors.green
                      : (volume >= 0.33 ? Colors.orange : Colors.red),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${(volume * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A6A6A),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: volume,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: '${(volume * 100).round()}%',
          activeColor: volume >= 0.67
              ? Colors.green
              : (volume >= 0.33 ? Colors.orange : Colors.red),
          inactiveColor: Colors.grey[300],
          thumbColor: const Color(0xFF4A6A6A),
          onChanged: (value) async {
            // Actualizar provider
            ref.read(audioVolumeProvider.notifier).state = value;
            // Actualizar servicio
            AudioService.setVolume(value);
            // Guardar en SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setDouble('audio_volume', value);
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'Controla el volumen de las instrucciones de voz y sonidos de la app',
          style: TextStyle(fontSize: 12, color: Color(0xFF7A8E8E)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            // Detener cualquier reproducción actual y limpiar cola
            await AudioService.stopAll();
            await Future.delayed(const Duration(milliseconds: 100));
            AudioService.speak(
              "Esta es una prueba de volumen. "
              "Ajusta el control para encontrar el nivel adecuado.",
            );
          },
          icon: const Icon(Icons.volume_down, size: 18,),
          label: const Text("Probar volumen"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF58A6A6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)
            )
          ),
        ),
      ],
    );
  }
}
