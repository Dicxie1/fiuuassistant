import 'package:fiuuassistant/features/courses_screen/presentation/pages/course_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widget/course_card_widget.dart';
import 'package:fiuuassistant/features/courses_screen/data/models/course_model.dart';
import 'package:fiuuassistant/features/courses_screen/data/repositories/enrollment_repository.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});
  @override
  State<CourseListScreen> createState() => _CourseListScreen();
}

class _CourseListScreen extends State<CourseListScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  late EnrollmentRepositoryImp _enrollmentRepository;
  List<CourseModel> _availableCourses = [];
  List<String> _enrolledCourses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _enrollmentRepository = EnrollmentRepositoryImp(FirebaseFirestore.instance);
    _loadData();
  }

  Future<void> _loadData() async {
    if (_user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final coursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .get();
      if(mounted){
        _availableCourses = coursesSnapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc.data(), doc.id))
          .toList();
      }
      _enrolledCourses = await _enrollmentRepository.getEnrollmentCourses(
        _user.uid,
      );
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar cursos: $e')));
      }
    }
  }

  Future<void> _enrollInCourse(String courseId) async {
    if (_user == null) return;
    setState(() => _isLoading = true);
    try {
      await _enrollmentRepository.enroll(_user.uid, courseId);
      _enrollInCourse(courseId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Matriculado con Exito"),
            backgroundColor: Color(0xFF58A6A6),
          ),
        );
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al matricularse $err")));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cursos disponibles"),
        backgroundColor: const Color(0xFF1A2373),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _availableCourses.length,
                itemBuilder: (context, index) {
                  final course = _availableCourses[index];
                  final isEnrolled = _enrolledCourses.contains(course.id);
                  return CourseCardWidget(
                    course: course,
                    isEnrolled: isEnrolled,
                    onEnroll: isEnrolled
                        ? null
                        : () => _enrollInCourse(course.id),
                    onTap: isEnrolled ? () => _navigateToCourse(course) : null,
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
