import 'package:flutter/material.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/course_model.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/module_model.dart';
class EditCourseDialog extends StatefulWidget {
  final CourseModel course;
  const EditCourseDialog({super.key, required this.course});

  @override
  State<EditCourseDialog> createState() => _EditCourseDialogState();
}

class _EditCourseDialogState extends State<EditCourseDialog> {
  late TextEditingController _titleController;
  late TextEditingController _instructorController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course.title);
    _instructorController = TextEditingController(
      text: widget.course.instructor,
    );
    _durationController = TextEditingController(text: widget.course.duration);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructorController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Editar Curso"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Título del curso"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instructorController,
              decoration: const InputDecoration(labelText: "Instructor"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: "Duración"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final updateCourse = CourseModel(
                id: widget.course.id,
                title: _titleController.text.trim(),
                description: widget.course.description,
                imgUrl: widget.course.imgUrl,
                rating: widget.course.rating,
                instructor: _instructorController.text.trim(),
                duration: _durationController.text.trim(),
                isNew: widget.course.isNew,
                module: widget.course.module.cast<ModuleModel>());
            Navigator.of(context).pop(updateCourse);
          },
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}
