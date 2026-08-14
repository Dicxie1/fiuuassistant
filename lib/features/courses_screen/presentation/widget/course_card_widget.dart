import 'package:flutter/material.dart';
import '../../data/models/course_model.dart';

class CourseCardWidget extends StatelessWidget {
  final CourseModel course;
  final bool isEnrolled;
  final double? progress;
  final VoidCallback? onEnroll;
  final VoidCallback? onTap;
  const CourseCardWidget({
    super.key,
    required this.course,
    this.isEnrolled = false,
    this.progress,
    this.onEnroll,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Imagen con Badge de "Nuevo"
            Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Row(
                children: [
                  if (course.imgUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        course.imgUrl,
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                        // Manejo de error por si la URL de Firebase falla o está vacía
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 80,
                            width: 80,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school_outlined, size: 40),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          course.instructor,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                course.description,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isEnrolled && progress != null)
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      minHeight: 7.0,
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress! >= 0.8
                            ? Colors.green
                            : progress! >= 0.5
                            ? Colors.orange
                            : Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Progress: ${(progress! * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsetsGeometry.only(left: 10, bottom: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isEnrolled && onEnroll != null)
                    ElevatedButton.icon(
                      onPressed: onEnroll,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Matricularme'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58A6A6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(12),
                        ),
                      ),
                    ),
                  if (isEnrolled && onTap != null)
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Continuar curso'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
