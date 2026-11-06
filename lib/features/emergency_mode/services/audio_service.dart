import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// Servicio centralizado para manejo de audio
/// Permite reproducción secuencial (bloqueo de sonidos simultáneos)
/// Control de volumen y velocidad de habla
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();

  // Configuración - Variables estáticas
  static double _speechRate = 0.7;
  static double _volume = 0.5;
  static bool _speechEnabled = true;
  static bool _backgroundSoundEnabled = false;

  // Estado - Variables de instancia
  bool _isPlaying = false;
  bool _isSpeaking = false;
  bool _isPaused = false;
  final List<Completer<void>> _pendingTasks = [];
  bool _isInitialized = false;

  // Inicialización
  static Future<void> initialize() async {
    if (!_instance._isInitialized) {
      await _instance._initializeTts();
      _instance._isInitialized = true;
    }
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('es-ES');

      final voices = await _flutterTts.getVoices;
      final spanishVoice = voices.firstWhere(
        (voice) => voice.name?.toLowerCase().contains('es') ?? false,
        orElse: () => voices.first,
      );

      if (spanishVoice.name != null) {
        await _flutterTts.setVoice(spanishVoice);
      }

      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        _onSpeechComplete();
      });

      _flutterTts.setErrorHandler((message) {
        debugPrint('❌ Error en TTS: $message');
        _onSpeechComplete();
      });

      // Switch EXHAUSTIVO: cubre TODOS los PlayerState posibles
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        switch (state) {
          case PlayerState.completed:
            debugPrint('✅ AudioPlayer: Reproducción completada');
            _onAudioComplete();
            break;
          case PlayerState.stopped:
            debugPrint('⏹️ AudioPlayer: Detenido');
            _onAudioComplete();
            break;
          case PlayerState.paused:
            debugPrint('⏸️ AudioPlayer: Pausado');
            break;
          case PlayerState.playing:
            debugPrint('▶️ AudioPlayer: Reproduciendo');
            break;
          case PlayerState.disposed:
            debugPrint('🗑️ AudioPlayer: Dispuesto (liberado)');
            _onAudioComplete();
            break;
        }
      });

      debugPrint('✅ TTS inicializado - Rate: $_speechRate, Volume: $_volume');
    } catch (e) {
      debugPrint('❌ Error inicializando TTS: $e');
    }
  }

  // ============= CONTROL DE REPRODUCCIÓN =============

  static Future<void> playAudio(String assetPath) async {
    if (!_speechEnabled) return;

    await _instance._waitForPlaybackCompletion();

    try {
      _instance._isPlaying = true;
      _instance._isPaused = false;
      await _instance._audioPlayer.setVolume(_volume);
      await _instance._audioPlayer.play(AssetSource(assetPath));
      debugPrint('▶️ Reproduciendo audio: $assetPath');
    } catch (e) {
      debugPrint('❌ Error reproduciendo audio: $e');
      _instance._onAudioComplete();
    }
  }

  static Future<void> speak(String text) async {
    if (!_speechEnabled) return;

    await _instance._waitForPlaybackCompletion();

    try {
      _instance._isSpeaking = true;
      _instance._isPaused = false;

      await _instance._flutterTts.setSpeechRate(_speechRate);
      await _instance._flutterTts.setVolume(_volume);
      await _instance._flutterTts.speak(text);
      debugPrint('🗣️ Hablando: "$text" (Duración estimada: ${_instance._estimateSpeechDuration(text).inSeconds}s)');
      
      // Esperar un tiempo estimado + margen para asegurar que el callback se dispare
      // Esto es un fallback por si el callback no funciona
      final estimatedDuration = _instance._estimateSpeechDuration(text);
      final safetyMargin = Duration(seconds: 2);
      final totalWait = estimatedDuration + safetyMargin;
      
      await Future.delayed(totalWait);
      
      // Si después del tiempo estimado + margen, todavía está speaking,
      // es probable que el callback no se haya disparado
      if (_instance._isSpeaking) {
        debugPrint('⚠️ TTS parece no haber completado. Verificando...');
        // No forzamos stop, solo marcamos como completado para evitar bloqueo
        // El TTS puede seguir hablando, pero liberamos el lock
        _instance._onSpeechComplete();
      }
      
    } catch (e) {
      debugPrint('❌ Error en speak: $e');
      _instance._onSpeechComplete();
    }
  }

  static Future<void> playBackgroundAudio(
    String assetPath, {
    bool loop = true,
  }) async {
    if (!_backgroundSoundEnabled || !_speechEnabled) return;

    try {
      final backgroundPlayer = AudioPlayer();
      await backgroundPlayer.setVolume(_volume * 0.5);
      await backgroundPlayer.play(AssetSource(assetPath));
      if (loop) {
        await backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      }
      debugPrint('🎵 Reproduciendo audio de fondo: $assetPath');
    } catch (e) {
      debugPrint('❌ Error reproduciendo audio de fondo: $e');
    }
  }

  static Future<void> stopAll() async {
    try {
      await _instance._audioPlayer.stop();
      await _instance._flutterTts.stop();
      _instance._isPlaying = false;
      _instance._isSpeaking = false;
      _instance._isPaused = false;

      for (final task in _instance._pendingTasks) {
        if (!task.isCompleted) {
          task.complete();
        }
      }
      _instance._pendingTasks.clear();

      debugPrint('⏹️ Todas las reproducciones detenidas');
    } catch (e) {
      debugPrint('❌ Error deteniendo audio: $e');
    }
  }

  static Future<void> pause() async {
    try {
      if (_instance._isPlaying) {
        await _instance._audioPlayer.pause();
      }
      if (_instance._isSpeaking) {
        await _instance._flutterTts.stop();
      }
      _instance._isPaused = true;
      debugPrint('⏸️ Pausado');
    } catch (e) {
      debugPrint('❌ Error pausando audio: $e');
    }
  }

  static Future<void> resume() async {
    try {
      if (_instance._isPlaying) {
        await _instance._audioPlayer.resume();
      }
      _instance._isPaused = false;
      debugPrint('▶️ Reanudado');
    } catch (e) {
      debugPrint('❌ Error reanudando audio: $e');
    }
  }

  // ============= CONFIGURACIÓN =============

  static Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.5, 2.0);
    try {
      await _instance._flutterTts.setSpeechRate(_speechRate);
      debugPrint('✅ Speech rate actualizado a $_speechRate');
    } catch (e) {
      debugPrint('❌ Error configurando speech rate: $e');
    }
  }

  static Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    try {
      await _instance._audioPlayer.setVolume(_volume);
      await _instance._flutterTts.setVolume(_volume);
      debugPrint('✅ Volumen actualizado a: ${(_volume * 100).round()}%');
    } catch (e) {
      debugPrint('❌ Error configurando volumen: $e');
    }
  }

  static Future<void> setSpeechEnabled(bool enabled) async {
    _speechEnabled = enabled;
    if (!enabled) {
      await stopAll();
    }
    debugPrint('✅ Speech enabled: $_speechEnabled');
  }

  static Future<void> setBackgroundSoundEnabled(bool enabled) async {
    _backgroundSoundEnabled = enabled;
    debugPrint('✅ Background sound enabled: $_backgroundSoundEnabled');
  }

  static Map<String, dynamic> getConfiguration() {
    return {
      'speechRate': _speechRate,
      'volume': _volume,
      'speechEnabled': _speechEnabled,
      'backgroundSoundEnabled': _backgroundSoundEnabled,
    };
  }

  static Future<void> updateConfiguration({
    double? speechRate,
    double? volume,
    bool? speechEnabled,
    bool? backgroundSoundEnabled,
  }) async {
    if (speechRate != null) {
      await setSpeechRate(speechRate);
    }
    if (volume != null) {
      await setVolume(volume);
    }
    if (speechEnabled != null) {
      await setSpeechEnabled(speechEnabled);
    }
    if (backgroundSoundEnabled != null) {
      await setBackgroundSoundEnabled(backgroundSoundEnabled);
    }
  }

  // ============= CALLBACKS INTERNOS =============

  void _onAudioComplete() {
    _isPlaying = false;
    _completeNextTask();
    debugPrint('✅ Audio completado');
  }

  void _onSpeechComplete() {
    _isSpeaking = false;
    _completeNextTask();
    debugPrint('✅ Speech completado');
  }

  void _completeNextTask() {
    if (_pendingTasks.isNotEmpty) {
      final nextTask = _pendingTasks.removeAt(0);
      if (!nextTask.isCompleted) {
        nextTask.complete();
      }
    }
  }

  void _completeAllPending() {
    for (final task in _pendingTasks) {
      if (!task.isCompleted) {
        task.complete();
      }
    }
    _pendingTasks.clear();
  }

  /// Limpia tareas pendientes que puedan estar obsoleto
  void _cleanupStaleTasks() {
    _pendingTasks.removeWhere((task) => task.isCompleted);
  }

  /// Tiempo máximo de espera por tarea de audio (evitar bloqueo infinito)
  /// A velocidad mínima (0.3), un texto de ~100 caracteres puede tardar ~30-40 segundos
  static const Duration _maxPlaybackWaitTime = Duration(seconds: 45);

  /// Tiempo estimado de habla por carácter (en milisegundos) a velocidad normal (1.0)
  static const int _msPerCharAtNormalRate = 100;

  /// Calcula el tiempo estimado para hablar un texto basado en su longitud y la velocidad actual
  Duration _estimateSpeechDuration(String text) {
    final charCount = text.length;
    // A mayor velocidad, menos tiempo por carácter (inversamente proporcional)
    final adjustedMsPerChar = _msPerCharAtNormalRate / _speechRate;
    final estimatedMs = charCount * adjustedMsPerChar;
    // Añadir un margen de seguridad
    return Duration(milliseconds: (estimatedMs * 1.5).round());
  }

  Future<void> _waitForPlaybackCompletion() async {
    // Limpiar tareas obsoleto primero
    _cleanupStaleTasks();
    
    if (_isPlaying || _isSpeaking) {
      final completer = Completer<void>();
      _pendingTasks.add(completer);
      debugPrint('⏳ Esperando a que termine reproducción actual...');
      
      // Esperar a que la tarea se complete con timeout
      try {
        await completer.future.timeout(_maxPlaybackWaitTime);
      } on TimeoutException {
        debugPrint('⚠️ Timeout: Forzando finalización de reproducción anterior');
        // Forzar finalización si hay un timeout
        _isPlaying = false;
        _isSpeaking = false;
        _completeAllPending();
      } catch (e) {
        debugPrint('⚠️ Error esperando reproducción: $e');
        _completeAllPending();
      }
    }
  }

  // ============= UTILIDADES =============

  static Future<void> playInstruction(String text) async {
    await speak(text);
  }

  static Future<void> playInstructionWithAudio(
    String text,
    String audioPath,
  ) async {
    await speak(text);
    await playAudio(audioPath);
  }

  static Future<void> playInstructionSequence(List<String> instructions) async {
    for (final instruction in instructions) {
      await speak(instruction);
    }
  }

  static Future<void> stopSpeech() async {
    try {
      await _instance._flutterTts.stop();
      _instance._isSpeaking = false;
      _instance._completeAllPending();
      debugPrint('⏹️ TTS detenido');
    } catch (e) {
      debugPrint('❌ Error deteniendo TTS: $e');
    }
  }

  // ============= GETTERS =============

  static bool get isSpeaking => _instance._isSpeaking;
  static bool get isPlaying => _instance._isPlaying || _instance._isSpeaking;
  static bool get isPaused => _instance._isPaused;
  static double get speechRate => _speechRate;
  static double get volume => _volume;
  static bool get speechEnabled => _speechEnabled;
  static bool get backgroundSoundEnabled => _backgroundSoundEnabled;

  // ============= LIMPIEZA =============

  static Future<void> dispose() async {
    try {
      await _instance._audioPlayer.dispose();
      await _instance._flutterTts.stop();
      _instance._pendingTasks.clear();
      _instance._isInitialized = false;
      _instance._isPlaying = false;
      _instance._isSpeaking = false;
      _instance._isPaused = false;
      debugPrint('🗑️ AudioService disposed');
    } catch (e) {
      debugPrint('❌ Error en dispose: $e');
    }
  }
}
