import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/emergency_providers.dart';
import '../../services/emergency_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CooldownTimerSetting extends ConsumerWidget {
  const CooldownTimerSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(cooldownDurationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiempo de espera antes de activar: ${duration.inSeconds} segundos',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(5, (index) {
              final seconds = (index + 1) * 10; // 10, 20, 30, 40, 50 segundos
              final isSelected = duration.inSeconds == seconds;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text('${seconds}s'),
                  selected: isSelected,
                  selectedColor: const Color(0xFF58A6A6),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF58A6A6)
                          : Colors.grey[400]!,
                    ),
                  ),
                  onSelected: (selected) async {
                    if (selected) {
                      final duration = Duration(seconds: seconds);
                      // Actualizar provider
                      ref.read(cooldownDurationProvider.notifier).state = duration;
                      // Actualizar servicio
                      EmergencyService.updateConfiguration(cooldown: duration);
                      // Guardar en SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('cooldown_seconds', seconds);
                    }
                  },
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Evita activaciones accidentales por movimientos normales',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }
}
