import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con Material Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'fiuu app',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A6A6A),
                      ),
                    ),
                  ],
                ),
                const CircleAvatar(
                  backgroundColor: Color(0xFFF9D5C5),
                  radius: 20,
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.white,
                  ), // Icono Material
                ),
              ],
            ),
            const SizedBox(height: 25),

            _buildBreathingCard(),

            const SizedBox(height: 25),

            const Text(
              'Herramienta de Relajación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A6A6A),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                // Iconos Material: music_note y place
                Expanded(
                  child: _buildToolCard(
                    'Ambient Sound',
                    'Play White Noise',
                    Icons.music_note_outlined,
                    Colors.orangeAccent,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildToolCard(
                    '5-4-3-2-1 Fix',
                    'Start Method',
                    Icons.place_outlined,
                    Colors.blueAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
            _buildTipCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
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
          Stack(
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
                child: const Center(
                  child: Text(
                    'Inhale',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF58A6A6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text('Start Session'),
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
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF355454),
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: NetworkImage(
            'https://www.transparenttextures.com/patterns/cubes.png',
          ), // Simulación de textura
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
}
