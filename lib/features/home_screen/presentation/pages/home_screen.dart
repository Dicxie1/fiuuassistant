import 'package:fiuuassistant/features/progress/domain/entities/user_progress.dart';
import 'package:fiuuassistant/features/progress/domain/usecases/get_user_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Agrega al inicio con las otras importaciones
import 'package:fiuuassistant/features/progress/data/repositories/progress_repository_imp.dart';
import 'package:fiuuassistant/features/progress/data/datasources/progress_remote_data_source.dart';
import 'package:fiuuassistant/features/progress/presentation/widgets/progress_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final FlutterTts _flutterTts = FlutterTts();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;
  String _breathText = "Inhale";
  bool _isAnimating = false;
  final User? _user = FirebaseAuth.instance.currentUser;
  late ProgressRepositoryImp _progressRepository;
  late GetUserProgress _getUserProgress;
  UserProgress? _userProgress;
  bool _isLoadingProgress = true;

  @override
  void initState() {
    super.initState();
    final dataSource = ProgressRemoteDataSourceImp(FirebaseFirestore.instance);
    _progressRepository = ProgressRepositoryImp(dataSource);
    _getUserProgress = GetUserProgress(_progressRepository);

    _loadUserProgress();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.addStatusListener((status) {
      if (!_isAnimating) return;
      if (status == AnimationStatus.completed) {
        setState(() => _breathText = "Exhale");
        _speak("Exhale");
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _breathText = "Inhale");
        _speak("Inhale");
        _controller.forward();
      }
    });
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupTts();
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAmbientSound() async {
    if (_isAudioPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isAudioPlaying = false;
      });
    } else {
      await _flutterTts.stop();
      await _audioPlayer.play(AssetSource("audio/white_noise.mp3"));
      setState(() {
        _isAudioPlaying = true;
      });
    }
  }

  void toggleBreathing() {
    setState(() {
      _isAnimating = !_isAnimating;
      if (_isAnimating) {
        _breathText = "Inhale";
        _speak("Inhale");
        _controller.forward();
      } else {
        _controller.reset();
        _flutterTts.stop();
        _breathText = "Inhale";
      }
    });
  }

  void _setupTts() async {
    await _flutterTts.setLanguage("es-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kit psicologico"),
        backgroundColor: Color(0xFF58A6A6),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Color(0xFFF5F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBreathingCard(),

              const SizedBox(height: 10),

              const Text(
                'Herramienta de Relajación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6A6A),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Iconos Material: music_note y place
                  Expanded(
                    child: InkWell(
                      onTap: _toggleAmbientSound,
                      borderRadius: BorderRadius.circular(20),
                      child: _buildToolCard(
                        'Sonido Ambientales',
                        _isAudioPlaying
                            ? "Detener Sonido"
                            : 'Reproducir ruido blanco',
                        _isAudioPlaying
                            ? Icons.stop_circle_outlined
                            : Icons.music_note_outlined,
                        _isAudioPlaying
                            ? Colors.redAccent
                            : Colors.orangeAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showGroundingExercise(context),
                      borderRadius: BorderRadius.circular(20),
                      child: _buildToolCard(
                        'Diminuye la ansiedad',
                        'Iniciar Método',
                        Icons.place_outlined,
                        Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              _buildTipCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Cerrar sesión?'),
            content: const Text(
              '¿Estás seguro de que deseas salir de fiuu app?',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58A6A6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Salir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildBreathingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'Respiración Asistida',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A6A6A),
            ),
          ),
          const Text(
            'Sincroniza tu ritmo de respiración con el boton para calmar tu mente.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _animation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildCircle(140, 0.1),
                _buildCircle(110, 0.2),
                Container(
                  width: 85,
                  height: 85,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF58A6A6),
                  ),
                  child: Center(
                    child: Text(
                      _breathText,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: toggleBreathing,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58A6A6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: Text(_isAnimating ? "Stop Session" : 'Start Session'),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF58A6A6).withValues(alpha: opacity),
      ),
    );
  }

  Widget _buildToolCard(
    String title,
    String action,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Color(0xFF4A6A6A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              action,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF58A6A6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF355454),
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: AssetImage("assets/img/cubes.png"),
          opacity: 0.05,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Psychologist\'s Tip',
            style: TextStyle(
              color: Color(0xFF8BB8B0),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '"Remember that your thoughts are just clouds passing in the sky. You are the sky, not the weather."',
            style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showGroundingExercise(BuildContext context) {
    int currentStep = 5;
    final stepsData = {
      5: {
        "title": "5 cosas que puedes ver",
        "desc": "Observa a tu alrededor y detalle 5 objetos minuciosamente.",
        "icon": Icons.visibility_outlined,
        "speak": "Busca cinco cosas que puedas ver a tu alrededor.",
      },
      4: {
        "title": "4 Cosas que puedas tocar",
        "desc": "Siente la textura de tu ropa, el suelo o un objeto cercano",
        "icon": Icons.touch_app_outlined,
        "speak": "Identifica cuatro cosas que puedas tocar o sentir.",
      },
      3: {
        "title": "3 Cosas que puedas escuchar",
        "desc": "Presta atención a los sonidos lejanos o de fondo.",
        "icon": Icons.hearing_disabled_outlined,
        "speak": "Presta atencion a tres sonidos que puedas escuchar.",
      },
      2: {
        "title": "2 Cosas que puedas probar",
        "desc": "Trata de identificar olores en el ambiente o en tu piel.",
        "icon": Icons.air,
        "speak": "Intenta percibir dos cosas que puedas oler.",
      },
      1: {
        "title": "1 Cosa que puedás, probar",
        "desc":
            "Siente el sabor actual en tu boca o imagina un sabor agradable",
        "icon": Icons.restaurant_menu_outlined,
        "speak": "Por último, nota una cosa que puedás, probar.",
      },
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _speak(stepsData[currentStep]!["speak"] as String);
        });
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentData = stepsData[currentStep]!;
            return Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 5),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0XFFF0F9F8),
                    child: Icon(
                      currentData["icon"] as IconData,
                      size: 30,
                      color: const Color(0XFF58A6A6),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currentData["title"] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF4A6A6A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentData["desc"] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (currentStep > 1) {
                        setModalState(() {
                          currentStep--;
                        });
                        _speak(stepsData[currentStep]!["speak"] as String);
                      } else {
                        Navigator.pop(context);
                        _speak("Excelente. Haz completado. el ejercicio");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Buen trabajo Has completado el ejercicio de enraizamiento",
                            ),
                            backgroundColor: Color(0XFF58A6A6),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(currentStep == 1 ? "Finalizar" : "Siguiente"),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      _flutterTts.stop();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadUserProgress() async {
    if (_user != null) {
      try {
        _userProgress = await _getUserProgress.call(_user.uid);
      } catch (e) {
        // Si hay error, crear progreso por defecto
        _userProgress = UserProgress(
          userId: _user.uid,
          totalXP: 0,
          currentLevel: 1,
          currentStreak: 0,
          longestStreak: 0,
          lastActivityDate: DateTime.now(),
          courses: [],
        );
      } finally {
        if (mounted) {
          setState(() => _isLoadingProgress = false);
        }
      }
    } else {
      setState(() => _isLoadingProgress = false);
    }
  }
}
