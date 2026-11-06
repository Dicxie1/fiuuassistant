import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiuuassistant/features/emergency_mode/services/emergency_service.dart';
import 'package:fiuuassistant/features/emergency_mode/services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/emergency_providers.dart';
import '../widgets/emergency_toggle_widget.dart';
import '../widgets/shake_sensitivity_slider.dart';
import '../widgets/cooldown_timer_setting.dart';
import '../widgets/emergency_notification_settings.dart';
import '../widgets/speech_rate_slider.dart';
import '../widgets/volume_slider.dart';

class EmergencySettingsScreen extends ConsumerStatefulWidget {
  const EmergencySettingsScreen({super.key});

  @override
  ConsumerState<EmergencySettingsScreen> createState() =>
      _EmergencySettingsScreenState();
}

class _EmergencySettingsScreenState
    extends ConsumerState<EmergencySettingsScreen> {
  
  // Claves para SharedPreferences
  static const String _speechRateKey = 'audio_speech_rate';
  static const String _volumeKey = 'audio_volume';
  static const String _speechEnabledKey = 'audio_speech_enabled';
  static const String _backgroundSoundEnabledKey = 'audio_background_enabled';
  
  // Estado para evitar múltiples inicializaciones
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Usar ScheduleMicrotask para evitar bloquear initState
    // y permitir que el widget se construya primero
    scheduleMicrotask(() {
      _loadAndSetupConfiguration();
    });
  }

  /// Carga la configuración inicial y configura los valores UNA SOLA VEZ
  /// Con manejo robusto de errores de SharedPreferences
  Future<void> _loadAndSetupConfiguration() async {
    if (_isInitialized) return;
    
    // Intentar hasta 3 veces con delay entre intentos
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 200);
    
    SharedPreferences? prefs;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        prefs = await SharedPreferences.getInstance();
        break; // Éxito, salir del loop
      } catch (e) {
        debugPrint('⚠️ Intento $attempt fallido para obtener SharedPreferences: $e');
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }
    
    // Si no se pudo obtener prefs, usar valores por defecto
    if (prefs == null) {
      debugPrint('❌ No se pudo inicializar SharedPreferences, usando valores por defecto');
      _setupWithDefaults();
      return;
    }

    _isInitialized = true;

    try {
      // Cargar configuración de emergencia
      final threshold = prefs.getDouble('shake_threshold') ?? 2.7;
      final cooldownSeconds = prefs.getInt('cooldown_seconds') ?? 30;
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      final soundEnabled = prefs.getBool('sound_enabled') ?? true;
      final vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      final serviceEnabled = prefs.getBool('emergency_service_enabled') ?? false;

      // Cargar configuración de audio
      // Asegurar que el speechRate esté en el rango 0.2-0.8
      var speechRate = prefs.getDouble(_speechRateKey) ?? 0.7;
      if (speechRate < 0.2) speechRate = 0.2;
      if (speechRate > 0.8) speechRate = 0.8;
      final volume = prefs.getDouble(_volumeKey) ?? 0.5;
      final speechEnabled = prefs.getBool(_speechEnabledKey) ?? true;
      final backgroundSoundEnabled = prefs.getBool(_backgroundSoundEnabledKey) ?? false;

      // Actualizar providers en un solo frame usando ScheduleMicrotask
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Actualizar providers de emergencia
        ref.read(shakeThresholdProvider.notifier).state = threshold;
        ref.read(cooldownDurationProvider.notifier).state = Duration(seconds: cooldownSeconds);
        ref.read(emergencyNotificationEnabledProvider.notifier).state = notificationsEnabled;
        ref.read(notificationSoundEnabledProvider.notifier).state = soundEnabled;
        ref.read(notificationVibrationEnabledProvider.notifier).state = vibrationEnabled;
        ref.read(emergencyServiceEnabledProvider.notifier).state = serviceEnabled;

        // Actualizar providers de audio
        ref.read(speechRateProvider.notifier).state = speechRate;
        ref.read(audioVolumeProvider.notifier).state = volume;
        ref.read(speechEnabledProvider.notifier).state = speechEnabled;
        ref.read(backgroundSoundEnabledProvider.notifier).state = backgroundSoundEnabled;

        // Actualizar servicios
        EmergencyService.updateConfiguration(
          threshold: threshold,
          cooldown: Duration(seconds: cooldownSeconds),
          notifications: notificationsEnabled,
          sound: soundEnabled,
          vibration: vibrationEnabled,
        );

        AudioService.updateConfiguration(
          speechRate: speechRate,
          volume: volume,
          speechEnabled: speechEnabled,
          backgroundSoundEnabled: backgroundSoundEnabled,
        );

        // Iniciar servicio de emergencia si estaba activado
        if (serviceEnabled) {
          EmergencyService.start(null);
        }
        
        // Marcamos como finalizado el Loading
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      debugPrint('❌ Error cargando configuración: $e');
      // Si falla la carga, usar valores por defecto
      _setupWithDefaults();
    }
  }

  /// Configura valores por defecto cuando SharedPreferences no está disponible
  void _setupWithDefaults() {
    _isInitialized = true;
    debugPrint('⚠️ Usando configuración por defecto');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Valores por defecto
      const threshold = 2.7;
      const cooldownSeconds = 30;
      const notificationsEnabled = true;
      const soundEnabled = true;
      const vibrationEnabled = true;
      const serviceEnabled = false;
      const speechRate = 0.7;
      const volume = 0.5;
      const speechEnabled = true;
      const backgroundSoundEnabled = false;

      // Actualizar providers con valores por defecto
      ref.read(shakeThresholdProvider.notifier).state = threshold;
      ref.read(cooldownDurationProvider.notifier).state = const Duration(seconds: cooldownSeconds);
      ref.read(emergencyNotificationEnabledProvider.notifier).state = notificationsEnabled;
      ref.read(notificationSoundEnabledProvider.notifier).state = soundEnabled;
      ref.read(notificationVibrationEnabledProvider.notifier).state = vibrationEnabled;
      ref.read(emergencyServiceEnabledProvider.notifier).state = serviceEnabled;
      ref.read(speechRateProvider.notifier).state = speechRate;
      ref.read(audioVolumeProvider.notifier).state = volume;
      ref.read(speechEnabledProvider.notifier).state = speechEnabled;
      ref.read(backgroundSoundEnabledProvider.notifier).state = backgroundSoundEnabled;

      // Actualizar servicios con valores por defecto
      EmergencyService.updateConfiguration(
        threshold: threshold,
        cooldown: const Duration(seconds: cooldownSeconds),
        notifications: notificationsEnabled,
        sound: soundEnabled,
        vibration: vibrationEnabled,
      );

      AudioService.updateConfiguration(
        speechRate: speechRate,
        volume: volume,
        speechEnabled: speechEnabled,
        backgroundSoundEnabled: backgroundSoundEnabled,
      );

      // Marcar como finalizado
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si está cargando, mostrar un indicador
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando configuración...'),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración Modo Emergencia'),
        backgroundColor: const Color(0xFF58A6A6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Mejorar rendimiento del scroll
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tarjeta: Activación del servicio
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const EmergencyToggleWidget(),
                        const SizedBox(height: 12),
                        Text(
                          'Activa el monitoreo de agitación en segundo plano',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tarjeta: Sensibilidad de detección
                _SettingCard(
                  title: 'Sensibilidad de Detección',
                  icon: Icons.vibration,
                  iconColor: Colors.orange,
                  child: ShakeSensitivitySlider(),
                ),

                const SizedBox(height: 20),

                // Tarjeta: Tiempo de espera
                _SettingCard(
                  title: 'Tiempo de Espera',
                  icon: Icons.timer,
                  iconColor: Colors.blue,
                  child: CooldownTimerSetting(),
                ),

                const SizedBox(height: 20),

                // Tarjeta: Notificaciones
                _SettingCard(
                  title: 'Notificaciones de Emergencia',
                  icon: Icons.notifications_active,
                  iconColor: Colors.red,
                  child: EmergencyNotificationSettings(),
                ),

                const SizedBox(height: 20),

                // Tarjeta: Configuración de Audio
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.record_voice_over, color: Colors.purple, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Configuración de Voz',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Personaliza cómo se reproducen las instrucciones de voz durante una emergencia',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Widget de velocidad de voz
                        SpeechRateSlider(),
                        const SizedBox(height: 20),
                        
                        // Widget de volumen
                        VolumeSlider(),
                        const SizedBox(height: 20),
                        
                        // Switch para habilitar voz
                        _buildSpeechEnabledSwitch(),
                        
                        // Switch para audio de fondo
                        _buildBackgroundSoundSwitch(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón para probar la detección
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Agita el dispositivo para probar la detección',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  icon: const Icon(Icons.science),
                  label: const Text('Probar Detección'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón para probar voz
                ElevatedButton.icon(
                  onPressed: () async {
                    await AudioService.stopAll();
                    await Future.delayed(const Duration(milliseconds: 100));
                    AudioService.speak(
                      'Esta es una prueba de la configuración de voz. '
                      'Ajusta la velocidad y el volumen según tus preferencias.',
                    );
                  },
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Probar Voz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58A6A6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para el switch de habilitar voz
  Widget _buildSpeechEnabledSwitch() {
    return Consumer(
      builder: (context, ref, child) {
        final enabled = ref.watch(speechEnabledProvider);
        return SwitchListTile(
          title: Text(
            'Habilitar voz en instrucciones',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            enabled
                ? 'Las instrucciones se leerán en voz alta'
                : 'Las instrucciones solo se mostrarán como texto',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          value: enabled,
          onChanged: (value) async {
            // Actualizar provider
            ref.read(speechEnabledProvider.notifier).state = value;
            // Actualizar servicio
            AudioService.setSpeechEnabled(value);
            // Guardar en SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_speechEnabledKey, value);
          },
          activeThumbColor: Color(0xFF58A6A6),
          activeTrackColor: Color(0xFF58A6A6).withValues(alpha: 0.3),
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  // Widget para el switch de audio de fondo
  Widget _buildBackgroundSoundSwitch() {
    return Consumer(
      builder: (context, ref, child) {
        final enabled = ref.watch(backgroundSoundEnabledProvider);
        return SwitchListTile(
          title: Text(
            'Audio de fondo relajante',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            enabled
                ? 'Se reproducirá sonido ambiente durante la emergencia'
                : 'Solo se reproducirán las instrucciones de voz',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          value: enabled,
          onChanged: (value) async {
            // Actualizar provider
            ref.read(backgroundSoundEnabledProvider.notifier).state = value;
            // Actualizar servicio
            AudioService.setBackgroundSoundEnabled(value);
            // Guardar en SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool(_backgroundSoundEnabledKey, value);
          },
          activeThumbColor: Color(0xFF58A6A6),
          activeTrackColor: Color(0xFF58A6A6).withValues(alpha: 0.3),
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SettingCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
