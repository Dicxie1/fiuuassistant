import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/cognitive_battle_model.dart';
import 'package:vibration/vibration.dart';

class ThoughtBattleScreen extends StatefulWidget {
  const ThoughtBattleScreen({super.key});

  @override
  State<ThoughtBattleScreen> createState() => _ThoughtBattleScreenState();
}

class _ThoughtBattleScreenState extends State<ThoughtBattleScreen>
    with SingleTickerProviderStateMixin {
  late CognitiveEnemy _currentEnemy;
  late double _enemyHealth;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final TextEditingController _customAttackController = TextEditingController();
  final List<_DamageText> _damageTexts = [];
  final List<CognitiveEnemy> _enemyPool = [
    CognitiveEnemy(
      id: 'e1',
      category: 'Catastrofismo',
      distortedThought: '¡Voy a reprobar este examen y arruinaré mi futuro!',
      presetCounterAttacks: [
        'He aprobado exámenes difíciles antes.',
        'Reprobar un examen no define mi valor profesional.',
        'Puedo estudiar y repasar los temas donde tengo dudas.',
        'Un tropiezo es una oportunidad de aprendizaje, no el fin.',
      ],
    ),
    CognitiveEnemy(
      id: 'e2',
      category: 'Pensamiento Todo o Nada',
      distortedThought: 'Si el proyecto no sale perfecto, no sirve para nada.',
      presetCounterAttacks: [
        'Hecho es mejor que perfecto.',
        'El valor del proyecto está en lo que resuelve, no en la perfección.',
        'Puedo iterar y mejorar la versión en el camino.',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadNewEnemy();

    // Configurar animación de impacto (sacudida)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  void _loadNewEnemy() {
    final random = Random();
    _currentEnemy = _enemyPool[random.nextInt(_enemyPool.length)];
    _enemyHealth = _currentEnemy.maxHealth;
    _damageTexts.clear();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _customAttackController.dispose();
    super.dispose();
  }

  void _executeAttack(String counterThought, {double damage = 25.0}) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100);
    }

    // Activar animación de sacudida
    _shakeController.forward(from: 0);

    setState(() {
      _enemyHealth = max(0, _enemyHealth - damage);

      // Agregar texto flotante de impacto
      _damageTexts.add(
        _DamageText(
          id: DateTime.now().toString(),
          text: '-${damage.toInt()} ANSIA',
          position: Offset(
            Random().nextDouble() * 100 - 50,
            Random().nextDouble() * -50,
          ),
        ),
      );
    });

    // Si el enemigo fue derrotado
    if (_enemyHealth <= 0) {
      _showVictoryDialog();
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.emoji_events, size: 60, color: Colors.amber),
            SizedBox(height: 8),
            Text('¡Pensamiento Derrotado!', textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          'Has reestructurado con éxito este pensamiento negativo. ¡Tu nivel de ansiedad ha bajado!',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _loadNewEnemy();
              });
            },
            child: const Text('Siguiente Batalla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthPercentage = _enemyHealth / _currentEnemy.maxHealth;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7), // Fondo oscuro estilo Arcade
      appBar: AppBar(
        title: const Text('Duelo de Pensamientos'),
        backgroundColor: const Color(0xFF58A6A6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 1. Barra de Ansiedad / Vida Enemiga
              _buildEnemyHealthBar(healthPercentage),

              const SizedBox(height: 30),

              // 2. Avatar del Pensamiento Enemigo (Sujeto a impactos)
              Expanded(
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(sin(_shakeAnimation.value * pi) * 10, 0),
                      child: child,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Tarjeta del Enemigo
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.red.shade700,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentEnemy.category.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '"${_currentEnemy.distortedThought}"',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Textos flotantes de daño
                      ..._damageTexts.map((dt) => _buildDamageTextWidget(dt)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. Panel de Contraataque (Racionalizaciones/Respuestas)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SELECCIONA TU UN CONTRAATAQUE:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Lista de Golpes Rápidos Sugeridos
              Expanded(
                child: ListView.builder(
                  itemCount: _currentEnemy.presetCounterAttacks.length,
                  itemBuilder: (context, index) {
                    final counterAttack =
                        _currentEnemy.presetCounterAttacks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00ACC1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _executeAttack(counterAttack),
                        child: Row(
                          children: [
                            const Icon(Icons.flash_on, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                counterAttack,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Option: Golpe Personalizado (Escribir tu propia respuesta)
              _buildCustomAttackInput(),
            ],
          ),
        ),
      ),
    );
  }

  // Componente para la barra de vida
  Widget _buildEnemyHealthBar(double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'NIVEL DE ANSIEDAD',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 14,
            backgroundColor: Colors.grey.shade900,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAttackInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF58A6A6).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customAttackController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Escribe tu propio contraataque...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF00ACC1)),
            onPressed: () {
              if (_customAttackController.text.trim().isNotEmpty) {
                _executeAttack(
                  _customAttackController.text.trim(),
                  damage: 35.0, // Un golpe personalizado hace más daño
                );
                _customAttackController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDamageTextWidget(_DamageText damageText) {
    return Transform.translate(
      offset: damageText.position,
      child: Text(
        damageText.text,
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2)),
          ],
        ),
      ),
    );
  }
}

class _DamageText {
  final String id;
  final String text;
  final Offset position;
  _DamageText({required this.id, required this.text, required this.position});
}
