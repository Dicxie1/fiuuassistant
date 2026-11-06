import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiuuassistant/features/emergency_mode/services/emergency_service.dart';
import '../providers/emergency_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyNotificationSettings extends ConsumerWidget {
  const EmergencyNotificationSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationEnabled = ref.watch(emergencyNotificationEnabledProvider);
    final soundEnabled = ref.watch(notificationSoundEnabledProvider);
    final vibrationEnabled = ref.watch(notificationVibrationEnabledProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle principal de notificaciones
        SwitchListTile.adaptive(
          title: const Text('Notificaciones de Emergencia'),
          subtitle: const Text('Recibir alertas cuando se active el modo emergencia'),
          value: notificationEnabled,
          activeColor: const Color(0xFFD32F2F),
          onChanged: (value) async {
            // Actualizar provider
            ref.read(emergencyNotificationEnabledProvider.notifier).state = value;
            // Actualizar servicio
            EmergencyService.updateConfiguration(notifications: value);
            // Guardar en SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('notifications_enabled', value);
          },
        ),

        if (notificationEnabled) ...[
          const Divider(height: 16, indent: 16, endIndent: 16),

          // Sonido
          SwitchListTile.adaptive(
            title: const Text('Sonido'),
            subtitle: const Text('Reproducir sonido al activarse'),
            value: soundEnabled,
            activeColor: const Color(0xFF58A6A6),
            onChanged: (value) async {
              // Actualizar provider
              ref.read(notificationSoundEnabledProvider.notifier).state = value;
              // Actualizar servicio
              EmergencyService.updateConfiguration(sound: value);
              // Guardar en SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('sound_enabled', value);
            },
          ),

          // Vibración
          SwitchListTile.adaptive(
            title: const Text('Vibración'),
            subtitle: const Text('Vibrar al activarse'),
            value: vibrationEnabled,
            activeColor: const Color(0xFF58A6A6),
            onChanged: (value) async {
              // Actualizar provider
              ref.read(notificationVibrationEnabledProvider.notifier).state = value;
              // Actualizar servicio
              EmergencyService.updateConfiguration(vibration: value);
              // Guardar en SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('vibration_enabled', value);
            },
          ),

          // Pantalla completa
          SwitchListTile.adaptive(
            title: const Text('Notificación en pantalla completa'),
            subtitle: const Text('Mostrar alerta de pantalla completa'),
            value: true, // Por defecto activado
            activeColor: const Color(0xFF58A6A6),
            onChanged: (value) async {
              await EmergencyService.requestFullScreenPermission();
            },
          ),
        ],
      ],
    );
  }
}
