import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiuuassistant/features/emergency_mode/services/emergency_service.dart';
import 'package:fiuuassistant/features/emergency_mode/services/emergency_alert_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/emergency_providers.dart';

class EmergencyToggleWidget extends ConsumerWidget {
  const EmergencyToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(emergencyServiceEnabledProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isEnabled ? 'ACTIVADO' : 'DESACTIVADO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isEnabled ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Switch.adaptive(
          value: isEnabled,
          activeThumbColor: Colors.green,
          inactiveTrackColor: Colors.grey[400],
          onChanged: (value) async {
            if (value) {
              final hasBackgroundLocation = await EmergencyAlertService
                  .requestBackgroundLocationPermission();
              if (!context.mounted) return;
              if (!hasBackgroundLocation) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Permite el acceso a la ubicación en segundo plano para enviar la alerta.',
                    ),
                  ),
                );
                return;
              }
              await EmergencyService.start(null);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Servicio de emergencia activado'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              await EmergencyService.stop();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Servicio de emergencia desactivado'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            // Actualizar provider
            ref.read(emergencyServiceEnabledProvider.notifier).state = value;
            // Guardar en SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            if (!context.mounted) return;
            await prefs.setBool('emergency_service_enabled', value);
          },
        ),
      ],
    );
  }
}
