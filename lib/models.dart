import '../database.dart' as db; // ✅ تأكد من استيراد ملف قاعدة البيانات

// ✅ تحديث `ClassGroup` ليحتوي على `id`
class ClassGroup {
  final int id;
  final String grade;
  final String section;
  final List<String> subjects;

  ClassGroup({
    required this.id,
    required this.grade,
    required this.section,
    required this.subjects,
  });

  // ✅ تحويل `ClassGroup` إلى JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'grade': grade,
        'section': section,
        'subjects': subjects.join(','), // ✅ تحويل القائمة إلى نص
      };

  // ✅ تحويل JSON إلى `ClassGroup`
  factory ClassGroup.fromJson(Map<String, dynamic> json) {
    return ClassGroup(
      id: json['id'],
      grade: json['grade'],
      section: json['section'],
      subjects: (json['subjects'] as String).split(','), // ✅ تحويل النص إلى قائمة
    );
  }
}

// ✅ تحديث `Student` ليشمل `id`
class Student {
  final int id;
  final String name;
  final String? parentPhone;
  final String? parentEmail;
  final String? notes;

  Student({
    required this.id,
    required this.name,
    this.parentPhone,
    this.parentEmail,
    this.notes,
  });

  // ✅ تحويل `Student` إلى JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parentPhone': parentPhone,
        'parentEmail': parentEmail,
        'notes': notes,
      };

  // ✅ تحويل JSON إلى `Student`
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      parentPhone: json['parentPhone'],
      parentEmail: json['parentEmail'],
      notes: json['notes'],
    );
  }
}

// ✅ تحديث `Evaluation`
class Evaluation {
  final int id;
  final String lessonTitle;
  final String date;
  final String session;
  final String notes;

  const Evaluation({
    required this.id,
    required this.lessonTitle,
    required this.date,
    required this.session,
    required this.notes,
  });

  // ✅ تحويل `Evaluation` إلى JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonTitle': lessonTitle,
        'date': date,
        'session': session,
        'notes': notes,
      };

  // ✅ تحويل JSON إلى `Evaluation`
  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'],
      lessonTitle: json['lessonTitle'],
      date: json['date'],
      session: json['session'],
      notes: json['notes'],
    );
  }
}

// ✅ تحديث `TestModel`
class TestModel {
  final int id;
  final String title;
  final String type;
  final String className;
  final String subject;
  final DateTime date;
  final int maxScore;
  final String notes;
  final Map<String, double> studentScores;

  TestModel({
    required this.id,
    required this.title,
    required this.type,
    required this.className,
    required this.subject,
    required this.date,
    required this.maxScore,
    this.notes = "",
    this.studentScores = const {},
  });

  // ✅ تحويل `TestModel` إلى `db.Test`
  db.Test toTest() {
    return db.Test(
      id: id,
      title: title,
      date: date,
      maxScore: maxScore,
    );
  }

  // ✅ إنشاء `TestModel` من `db.Test`
  factory TestModel.fromTest(db.Test test) {
    return TestModel(
      id: test.id,
      title: test.title ?? "بدون عنوان",
      type: "", // ❌ يجب تحديثه عند جلب البيانات
      className: "", // ❌ يجب تحديثه عند جلب البيانات
      subject: "", // ❌ يجب تحديثه عند جلب البيانات
      date: test.date,
      maxScore: test.maxScore,
      notes: "",
      studentScores: {},
    );
  }

  // ✅ تحويل `TestModel` إلى JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'className': className,
        'subject': subject,
        'date': date.toIso8601String(),
        'maxScore': maxScore,
        'notes': notes,
        'studentScores': studentScores.map((key, value) => MapEntry(key, value.toString())),
      };

  // ✅ تحويل JSON إلى `TestModel`
  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      className: json['className'],
      subject: json['subject'],
      date: DateTime.parse(json['date']),
      maxScore: json['maxScore'],
      notes: json['notes'],
      studentScores: (json['studentScores'] as Map<String, dynamic>).map((key, value) => MapEntry(key, double.parse(value))),
    );
  }
}
