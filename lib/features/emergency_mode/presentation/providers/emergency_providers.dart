// Emergency Mode Providers
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show FutureProvider, WidgetRef;
import 'package:flutter_riverpod/legacy.dart';
import 'package:fiuuassistant/features/emergency_contact/domain/entities/emergency_contact.dart';
import 'package:fiuuassistant/features/emergency_contact/data/datasources/emergency_contact_remote_data_source.dart';
import 'package:fiuuassistant/features/emergency_mode/services/emergency_alert_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider para activar/desactivar el servicio de emergencia
final emergencyServiceEnabledProvider = StateProvider<bool>((ref) => false);
// Provider para la sensibilidad de detección de agitación (umbral en G)
final shakeThresholdProvider = StateProvider<double>((ref) => 2.7);
// Provider para el tiempo de espera antes de activar la emergencia
final cooldownDurationProvider = StateProvider<Duration>(
  (ref) => const Duration(seconds: 30),
);
// Provider para habilitar/deshabilitar notificaciones de emergencia
final emergencyNotificationEnabledProvider = StateProvider<bool>((ref) => true);
// Provider para habilitar/deshabilitar sonido en notificaciones
final notificationSoundEnabledProvider = StateProvider<bool>((ref) => true);
// Provider para habilitar/deshabilitar vibración en notificaciones
final notificationVibrationEnabledProvider = StateProvider<bool>((ref) => true);
// Provider para el contacto de confianza
final trustedContactProvider = FutureProvider<EmergencyContact?>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return null;
  }
  final remoteDataSource = EmergencyContactRemoteDataSource(
    FirebaseFirestore.instance,
  );
  return await remoteDataSource.getEmergencyContact(user.uid);
});

final isSendingLocationProvider = StateProvider<bool>((ref) => false);

// ============= PROVEEDORES DE AUDIO =============

// Provider para velocidad de habla (0.3 - 0.8)
final speechRateProvider = StateProvider<double>((ref) => 0.7);

// Provider para volumen de audio (0.0 - 1.0)
final audioVolumeProvider = StateProvider<double>((ref) => 0.8);

// Provider para habilitar/deshabilitar el habla
final speechEnabledProvider = StateProvider<bool>((ref) => true);

// Provider para habilitar/deshabilitar audio de fondo
final backgroundSoundEnabledProvider = StateProvider<bool>((ref) => false);

// Provider para saber si el audio está reproduciéndose
final audioIsPlayingProvider = StateProvider<bool>((ref) => false);

Future<void> sendEmergencySMS(WidgetRef ref) async {
  ref.read(isSendingLocationProvider.notifier).state = true;
  try {
    await EmergencyAlertService.sendCurrentLocation();
  } finally {
    ref.read(isSendingLocationProvider.notifier).state = false;
  }
}
