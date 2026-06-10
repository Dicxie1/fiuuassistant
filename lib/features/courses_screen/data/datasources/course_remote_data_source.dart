import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';

abstract class CourseRemoteDataSource {
  Stream<List<CourseModel>> getCourses();
  Future<void> updateCourse(CourseModel course);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final FirebaseFirestore firestore;

  CourseRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<CourseModel>> getCourses() {
    return firestore.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Aquí usamos el factory que definimos en el modelo
        return CourseModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }
  @override
  Future<void> updateCourse(CourseModel course) async{
    await firestore
        .collection('courses')
        .doc(course.id)
        .update(course.toFirebastore());
  }
  Future<CourseModel> getCourseDetails(String courseId) async {
    final doc = await firestore.collection('courses').doc(courseId).get();
    return CourseModel.fromFirestore(doc.data()!, doc.id);
  }
}
