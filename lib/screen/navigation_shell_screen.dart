import 'package:flutter/material.dart';
import 'package:fiuuassistant/features/courses_screen/presentation/pages/courses_screen.dart';
import 'package:fiuuassistant/screen/setting_screen.dart';
import 'package:fiuuassistant/features/home_screen/presentation/pages/home_screen.dart';

class NavigationShellScreen extends StatefulWidget {
  const NavigationShellScreen({super.key});

  @override
  State<NavigationShellScreen> createState() => _NavigationShellScreenState();
}

class _NavigationShellScreenState extends State<NavigationShellScreen> {
  // Rastrear el índice seleccionado para saber qué pantalla mostrar
  int _selectedIndex = 0;

  // Lista de rutas correspondientes a los iconos.
  // Es vital que estas rutas coincidan con las de 'main.dart'.
  final List<Widget> _screens = [
    HomeScreen(),
    CoursesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack es perfecto para BottomNav: mantiene el estado de todas
      // las pantallas pero solo muestra la del índice seleccionado.
      body: IndexedStack(index: _selectedIndex, children: _screens),
      // El caparazón ahora contiene la barra de navegación inferior
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- TU CÓDIGO DE BARRA DE NAVEGACIÓN, CON LÓGICA DE RUTAS ---

  Widget _buildBottomNav() {
    return BottomAppBar(
      height: 70,
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      elevation: 5.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Pasamos el índice (0, 1, 2) y la ruta
          _buildNavItem(Icons.home_filled, 'Inicio', '/', 0),
          _buildNavItem(Icons.import_contacts_outlined, 'Cursos', '/cursos', 1),
          _buildNavItem(
            Icons.settings_outlined,
            'Configuración',
            '/configuracion',
            2,
          ),
        ],
      ),
    );
  }

  // Modificamos _buildNavItem para aceptar el índice y la ruta
  Widget _buildNavItem(
    IconData icon,
    String label,
    String routeName,
    int index,
  ) {
    // Calculamos isActive basándonos en el índice seleccionado
    bool isActive = _selectedIndex == index;

    return InkWell(
      // Añadimos interactividad de toque con un InkWell
      onTap: () {
        // Al tocar, no usamos pushNamed puro (eso abriría encima).
        // En su lugar, actualizamos el estado para cambiar de pantalla internamente.
        setState(() {
          _selectedIndex = index;
        });

        // Opcional: Si necesitas realizar una acción específica de navegación al cambiar,
        // puedes usarNavigator.of(context).pushNamed(routeName) pero
        // la estructura de IndexedStack es superior para mantener la barra visible.
        // La mejor práctica con BottomNav es usarIndexedStack o PageView en el body.
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF58A6A6) : Colors.grey,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? const Color(0xFF58A6A6) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
