import 'package:flutter/material.dart';
import 'courses_manager_screen.dart';
import 'setting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const CoursesManagerScreen(),
    const SettingScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xFF1A237E),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            selectedLabelTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            leading: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(height: 50),
              ],
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.book),
                label: Text('Cursos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.group),
                label: Text('Alumnos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Ajustes'),
              ),
              // Agrega más destinos aquí si es necesario
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    tooltip: "Cerrar sesión",
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _views[_selectedIndex]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedIndex == 0 ? "Gestión de Cursos" : "Panel Administrativo",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  /* Acción para refrescar datos */
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Actualizar"),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddCourseDialog(context),
                icon: const Icon(Icons.add),
                label: const Text("NUEVO CURSO"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[900],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Crear Nuevo Curso"),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(labelText: "Nombre del Curso"),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(labelText: "Descripción"),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Categoría"),
                items: const [
                  DropdownMenuItem(value: "IS", child: Text("Ingeniería")),
                  DropdownMenuItem(value: "ADM", child: Text("Administración")),
                ],
                onChanged: (val) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(onPressed: () {}, child: const Text("GUARDAR")),
        ],
      ),
    );
  }
}
