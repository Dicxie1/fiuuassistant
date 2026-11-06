import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/emergency_providers.dart';
import '../../services/emergency_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShakeSensitivitySlider extends ConsumerWidget {
  const ShakeSensitivitySlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threshold = ref.watch(shakeThresholdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Umbral: ${threshold.toStringAsFixed(1)} G',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _getSensitivityLabel(threshold),
              style: TextStyle(
                fontSize: 14,
                color: _getSensitivityColor(threshold),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: threshold,
          min: 1.5,
          max: 4.0,
          divisions: 25,
          label: threshold.toStringAsFixed(1),
          activeColor: _getSensitivityColor(threshold),
          inactiveColor: Colors.grey[300],
          thumbColor: Colors.white,
          onChanged: (value) async {
            // Actualizar provider
            ref.read(shakeThresholdProvider.notifier).state = value;
            // Actualizar servicio
            EmergencyService.updateConfiguration(threshold: value);
            // Guardar en SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setDouble('shake_threshold', value);
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1.5 G',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
              ),
            ),
            Text(
              '4.0 G',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Ajusta cuánta agitación se necesita para activar el modo emergencia',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _getSensitivityLabel(double threshold) {
    if (threshold <= 2.0) return 'ALTA';
    if (threshold <= 2.5) return 'MEDIA-ALTA';
    if (threshold <= 3.0) return 'MEDIA';
    if (threshold <= 3.5) return 'MEDIA-BAJA';
    return 'BAJA';
  }

  Color _getSensitivityColor(double threshold) {
    if (threshold <= 2.0) return Colors.green;
    if (threshold <= 2.5) return Colors.lightGreen;
    if (threshold <= 3.0) return Colors.orange;
    if (threshold <= 3.5) return Colors.orangeAccent;
    return Colors.red;
  }
}
