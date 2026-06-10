import 'package:flutter/material.dart';

class TopicEditWidget extends StatefulWidget {
  final String title;
  final String content;
  final int order;
  final void Function(String, String) onSave;
  const TopicEditWidget({
    super.key,
    required this.title,
    required this.content,
    required this.order,
    required this.onSave,
  });

  @override
  State<TopicEditWidget> createState() => _TopicEditWidgetState();
}

class _TopicEditWidgetState extends State<TopicEditWidget> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los datos actuales del tema
    _titleController = TextEditingController(text: widget.title);
    _contentController = TextEditingController(text: widget.content);
  }

  @override
  void didUpdateWidget(covariant TopicEditWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // CRUCIAL: Si el usuario selecciona un tema diferente en el panel izquierdo,
    // actualizamos los controladores con los nuevos datos sin perder el foco.
    if (oldWidget.order != widget.order) {
      _titleController.text = widget.title;
      _contentController.text = widget.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        Row(
          children: [
            const Icon(Icons.edit_note, color: Colors.indigo, size: 28),
            const SizedBox(width: 10),
            Text(
              "Editando Tema ${widget.order}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Input para el Título
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: "Título del Tema",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 20),

        // Input para el Contenido/Lectura
        TextField(
          controller: _contentController,
          maxLines: 15, // Te da un área de texto amplia para las lecturas
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            labelText: "Contenido de la Lección / Lectura",
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            hintText:
                "Escribe aquí la teoría, instrucciones o guías para los estudiantes...",
          ),
        ),
        const SizedBox(height: 24),

        // Botón de Guardado
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.cancel),
              label: const Text("Cancelar", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Aquí puedes capturar el texto modificado usando:
                // _titleController.text y _contentController.text
                print("Guardando: ${_titleController.text}");
                widget.onSave(_titleController.text, _contentController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 5),
              ),
              icon: const Icon(Icons.save),
              label: const Text("Guardar", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ],
    );
  }
}
