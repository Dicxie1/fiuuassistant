class Course {
  final String id;
  final String title;
  final String description;
  final String imgUrl;
  final double rating;
  final String instructor;
  final String duration;
  final bool isNew;
  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imgUrl,
    required this.rating,
    required this.instructor,
    required this.duration,
    required this.isNew,
  });
}
