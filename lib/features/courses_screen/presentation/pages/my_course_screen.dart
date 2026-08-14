import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/course_model.dart';
import 'package:fiuuassistant/features/courses_screen/data/repositories/enrollment_repository.dart';
import 'package:fiuuassistant/features/courses_screen/presentation/pages/course_details_screen.dart';
import 'package:fiuuassistant/features/courses_screen/presentation/widget/course_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyCourseScreen extends StatefulWidget {
  @Preview(
    name: 'MyCourseScreenPreview',
    textScaleFactor: 1.0,
    brightness: Brightness.light,
  )
  const MyCourseScreen({super.key});

  @override
  State<MyCourseScreen> createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  late EnrollmentRepositoryImp _enrollmentRepository;
  List<CourseModel> _myCourses = [];
  final Map<String, double> _courseProgress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _enrollmentRepository = EnrollmentRepositoryImp(FirebaseFirestore.instance);
    _loadMyCourses();
  }

  Future<void> _loadMyCourses() async {
    if (_user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    if (mounted) setState(() => _isLoading = true);
    try {
      final enrolledCoursesIds = await _enrollmentRepository
          .getEnrollmentCourses(_user.uid);
      if (enrolledCoursesIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      final List<CourseModel> allCourses = [];
      for (var i = 0; i < enrolledCoursesIds.length; i += 10) {
        final batch = enrolledCoursesIds.skip(i).take(10).toList();
        final courseSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        allCourses.addAll(
          courseSnapshot.docs.map(
            (doc) => CourseModel.fromFirestore(doc.data(), doc.id),
          ),
        );
      }
      if (mounted) {
        setState(() {
          _myCourses = allCourses;
        });
      }
      final newProgress = <String, double>{};
      for (final course in allCourses) {
        final progress = await _enrollmentRepository.getCourseProgress(
          _user.uid,
          course.id,
        );
        newProgress[course.id] = progress;
      }
      if (mounted) {
        setState(() {
          _courseProgress.clear();
          _courseProgress.addAll(newProgress);
        });
      }
    } catch (e) {
      debugPrint("Error al cargar mis cursos: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar mis cursos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cursos'),
        backgroundColor: const Color(0xFF58A6A6),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myCourses.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No estas matriculado en ningun curso',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explora cursos disponibles y matrículate',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadMyCourses,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _myCourses.length,
                itemBuilder: (context, index) {
                  final course = _myCourses[index];
                  final progress = _courseProgress[course.id] ?? 0.0;
                  return CourseCardWidget(
                    course: course,
                    isEnrolled: true,
                    progress: progress,
                    onTap: () => _navigateToCourse(course),
                  );
                },
              ),
            ),
    );
  }

  void _navigateToCourse(CourseModel course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CourseDetailsScreen(course: course, isEnrolled: true),
      ),
    );
  }
}
