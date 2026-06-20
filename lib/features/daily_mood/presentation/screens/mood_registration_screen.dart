import 'package:fiuuassistant/features/daily_mood/domain/usercases/record_daily_mood.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/mood_record.dart';
import '../../data/repositories/mood_recoerd_imp.dart';

class MoodRegistrationScreen extends StatefulWidget {
  const MoodRegistrationScreen({super.key});
  @override
  State<MoodRegistrationScreen> createState() => _MoodRegistrationScreen();
}

class _MoodRegistrationScreen extends State<MoodRegistrationScreen> {
  final RecordDailyMood _recordDailyMood = RecordDailyMood(MoodRecoerdImp());
  final TextEditingController _noteController = TextEditingController();

  String _selectedEmotion = "";
  double _intensity = 3.0;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _emotions = [
    {
      'label': 'Calmado',
      'emoji': '😎​',
      'color': const Color(0xFF58A6A6),
      'backgroundColor': const Color(0xFFF2F8F7),
    },
    {
      'label': 'Feliz',
      'emoji': '😀​',
      'color': const Color(0xFFF9D5C5),
      'backgroundColor': const Color(0xFFFFF7F2),
    },
    {
      'label': 'Ansioso',
      'emoji': '😰',
      'color': Colors.blueAccent,
      'backgroundColor': const Color(0xFFF0F5FA),
    },
    {
      'label': 'Estresado',
      'emoji': '🤯',
      'color': Colors.orangeAccent,
      'backgroundColor': const Color(0xFFFFF9F0),
    },
    {
      'label': 'Triste',
      'emoji': '😭​​',
      'color': Colors.purpleAccent,
      'backgroundColor': const Color(0xFFFAF2FC),
    },
  ];
  Color _currentBackgroundColor = const Color(0xFFF5F7F7);
  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitMood() async {
    if (_selectedEmotion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una emoción antes de guardar.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Instancia temporal del registro (userId estático por ahora)
      final newRecord = MoodRecord(
        id: '',
        userId: 'student_123',
        emotion: _selectedEmotion,
        intensity: _intensity.toInt(),
        note: _noteController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _recordDailyMood.execute(newRecord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Tu estado de ánimo ha sido registrado con éxito!'),
            backgroundColor: Color(0xFF58A6A6),
          ),
        );
        Navigator.pop(context); // Regresa a la pantalla anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentBackgroundColor,
      body: AnimatedContainer(
        duration: const Duration(microseconds: 400),
        curve: Curves.easeInOut,
        color: _currentBackgroundColor.withValues(alpha: 0.3),
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona tu emoción predominante:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A6A6A),
                  ),
                ),
                const SizedBox(height: 16),

                // Grid de selección de Emojis
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _emotions.length,
                  itemBuilder: (context, index) {
                    final item = _emotions[index];
                    final isSelected = _selectedEmotion == item['label'];

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedEmotion = item['label'];
                          _currentBackgroundColor = item['backgroundColor'];
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? item['color'].withOpacity(0.2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? item['color']
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['emoji'],
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['label'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: const Color(0xFF4A6A6A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 35),
                const Text(
                  '¿Qué tan intensa es esta emoción?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A6A6A),
                  ),
                ),
                const SizedBox(height: 8),

                // Slider de Intensidad personalizado
                Row(
                  children: [
                    const Text(
                      'Leve',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Expanded(
                      child: Slider(
                        value: _intensity,
                        min: 1.0,
                        max: 5.0,
                        divisions: 4,
                        activeColor: _getActiveColor(),
                        inactiveColor: _getActiveColor().withValues(alpha: 0.2),
                        thumbColor: _getActiveColor(),
                        label: _intensity.toInt().toString(),
                        onChanged: (value) {
                          setState(() => _intensity = value);
                        },
                      ),
                    ),
                    const Text(
                      'Extrema',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Text(
                  '¿Quieres añadir alguna nota o pensamiento? (Opcional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A6A6A),
                  ),
                ),
                const SizedBox(height: 12),

                // Caja de texto para notas descriptivas
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Escribe aquí lo que pasa por tu mente...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    counterText: '', // Oculta el contador básico de caracteres
                  ),
                ),

                const SizedBox(height: 40),

                // Botón de guardar con indicador de carga
                _isSaving
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF58A6A6),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _submitMood,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF58A6A6),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Guardar Registro',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  Color _getActiveColor() {
    final selected = _emotions.firstWhere(
      (item) => item['label'] == _selectedEmotion,
      orElse: () => {'color': const Color(0xFF4A6A6A)},
    );
    return selected['color'] as Color;
  }
}
