import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmergencyModeScreen extends StatefulWidget {
  const EmergencyModeScreen({super.key});
  @override
  State<EmergencyModeScreen> createState() => _EmergencyModeScreenState();
}

class _EmergencyModeScreenState extends State<EmergencyModeScreen> {
  int _currentStep = 1;

  bool _color1Checked = false;
  bool _color2Checked = false;
  bool _color3Checked = false;

  void _nextStep() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentStep++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE57373)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: Color(0xFFD32F2F),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'MODO EMERGENCIA',
                          style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: Color(0xFF4A6A6A),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index < _currentStep
                            ? Colors.redAccent
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStepContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildPhysicalChallengeStep();
      case 2:
        return _buildCognitiveGroundingStep();
      case 3:
      default:
        return _buildSupportNetworkStep();
    }
  }

  Widget _buildPhysicalChallengeStep() {
    return Column(
      key: const ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE57373).withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.directions_run_rounded,
            size: 80,
            color: Color(0xFFD32F2F),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¡DESCARGA LA ADRENALINA!',
          style: TextStyle(
            color: Color(0xFFD32F2F),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFF355454),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Pon el celular boca abajo sobre la mesa y da 10 saltos potentes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '💡 Esto ayuda a quemar el exceso de cortisol y oxigenar tu cerebro de inmediato.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58A6A6),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(Icons.check_circle_outline, size: 20),
            onPressed: _nextStep,
            label: const Text(
              '¡YA LO HICE! (Continuar)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCognitiveGroundingStep() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RE-ENFOQUE SENSORIAL',
          style: TextStyle(
            color: Color(0xFF4A6A6A),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Anclándote al presente',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),

        // 1. Identificar 3 colores a tu alrededor
        const Text(
          '1. Nombra en voz alta 3 colores que ves ahora:',
          style: TextStyle(
            color: Color(0xFF4A6A6A),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildColorFilterChip(
              'Color 1',
              _color1Checked,
              (v) => setState(() => _color1Checked = v!),
            ),
            _buildColorFilterChip(
              'Color 2',
              _color2Checked,
              (v) => setState(() => _color2Checked = v!),
            ),
            _buildColorFilterChip(
              'Color 3',
              _color3Checked,
              (v) => setState(() => _color3Checked = v!),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 2. Preguntas de orientación temporal
        const Text(
          '2. Responde mentalmente o en voz alta:',
          style: TextStyle(
            color: Color(0xFF4A6A6A),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF58A6A6).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF58A6A6),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    '¿Qué hora aproximada es?',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Divider(color: Color(0xFFE8EEEE), height: 20),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Color(0xFF58A6A6),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    '¿Qué día de la semana es hoy?',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58A6A6),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: (_color1Checked && _color2Checked && _color3Checked)
                ? _nextStep
                : null,
            child: const Text(
              'Me siento más tranquilo/a',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: _nextStep,
            child: const Text(
              'Aún siento demasiada tensión',
              style: TextStyle(color: Color(0xFFD32F2F), fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorFilterChip(
    String label,
    bool isSelected,
    ValueChanged<bool?> onChanged,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF58A6A6),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF2C3E50),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF58A6A6)
              : const Color(0xFF58A6A6).withValues(alpha: 0.3),
        ),
      ),
      onSelected: onChanged,
    );
  }

  Widget _buildSupportNetworkStep() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.people_alt_rounded, color: Colors.amber, size: 48),
        const SizedBox(height: 16),
        const Text(
          'NO ESTÁS SOLO/A',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Contacta a tu red de apoyo',
          style: TextStyle(
            color: Color(0xFFF57F17),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Si la intensidad de la crisis no ha bajado, habla directamente con una persona de confianza o el equipo de acompañamiento.',
          style: TextStyle(color: Color(0xFF587070), fontSize: 14),
        ),
        const SizedBox(height: 18),

        // Opción 1: Contacto de confianza
        _buildContactCard(
          icon: Icons.person,
          title: 'Compañero / Amigo de Confianza',
          subtitle: 'Llamar o enviar mensaje rápido',
          color: const Color(0xFF58A6A6),
          onTap: () {
            // Lógica para realizar llamada o abrir WhatsApp
          },
        ),

        const SizedBox(height: 12),

        // Opción 2: Atención Psicológica / Línea Institucional
        _buildContactCard(
          icon: Icons.health_and_safety,
          title: 'Línea de Crisis Institucional / URACCAN',
          subtitle: 'Atención orientación académica y bienestar',
          color: const Color(0xFFE57373),
          onTap: () {
            // Lógica para marcar al número de la universidad / emergencia
          },
        ),

        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4A6A6A),
              side: const BorderSide(color: Color(0xFF58A6A6), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Salir de Emergencia',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF7A8E8E), fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.call, color: color, size: 18),
        ),
        onTap: onTap,
      ),
    );
  }
}
