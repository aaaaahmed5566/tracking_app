class ClassGroup {
  final String grade;
  final String section;
  final List<String> subjects;

  ClassGroup({
    required this.grade,
    required this.section,
    List<String>? subjects,
  }) : subjects = subjects ?? [];
}

class Student {
  String name;
  String? parentPhone;
  String? parentEmail;
  String? notes;

  Student({
    required this.name,
    this.parentPhone,
    this.parentEmail,
    this.notes,
  });
}

