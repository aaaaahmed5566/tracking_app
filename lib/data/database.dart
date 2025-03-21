// ✅ بدون استخدام alias
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';


// جدول المجموعات (الصف + الفصل)
@DataClassName("Group")
class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get grade => text().withLength(min: 1, max: 10)();
  TextColumn get section => text().withLength(min: 1, max: 10)();
}

// جدول الطلاب
@DataClassName("Student")
class Students extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)(); // ✅ اسم الطالب (إجباري)
  IntColumn get groupId => integer().references(Groups, #id)(); // ✅ ربط الطالب بالمجموعة
  TextColumn get parentPhone => text().nullable()(); // ✅ رقم ولي الأمر (اختياري)
  TextColumn get notes => text().nullable()(); // ✅ ملاحظات (اختياري)
  BoolColumn get isPresent => boolean().withDefault(const Constant(true))(); // ✅ الحضور الافتراضي
}



@DataClassName("Subject")
class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(Groups, #id)(); // ✅ ربط المادة بالمجموعة
  TextColumn get name => text().withLength(min: 1, max: 50)();
}

// جدول التقييمات
@DataClassName("Evaluation")
class Evaluations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  TextColumn get subject => text()();
  TextColumn get type => text()(); // حفظ - مشاركة - واجب
  IntColumn get score => integer().withDefault(const Constant(2))();
}

// جدول الاختبارات
@DataClassName("Test")
class Tests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get date => dateTime()();
  IntColumn get maxScore => integer()();
}

// جدول درجات الاختبارات
@DataClassName("TestScore")
class TestScores extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  IntColumn get testId => integer().references(Tests, #id)();
  IntColumn get score => integer()();
}

@DriftDatabase(tables: [Students, Evaluations, Tests, TestScores, Groups, Subjects])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ✅ إضافة طالب جديد
  Future<int> addStudent(StudentsCompanion student) => into(students).insert(student);

  // ✅ جلب جميع الطلاب
  // ✅ جلب جميع الطلاب المرتبطين بمجموعة معينة
Future<List<Student>> getStudentsForGroup(int groupId) {
  return (select(students)..where((s) => s.groupId.equals(groupId))).get();
}

  // ✅ تحديث بيانات طالب معين
  Future<bool> updateStudent(Student student) async {
    int updatedRows = await (update(students)..where((s) => s.id.equals(student.id)))
        .write(StudentsCompanion(
          name: Value(student.name),
          isPresent: Value(student.isPresent),
          notes: student.notes != null ? Value(student.notes) : const Value.absent(),
        ));
    return updatedRows > 0;
  }

  
  // ✅ حذف طالب معين
  Future<bool> deleteStudent(int id) async {
    int deletedRows = await (delete(students)..where((tbl) => tbl.id.equals(id))).go();
    return deletedRows > 0;
  }

  // ✅ إضافة تقييم جديد
  Future<int> addEvaluation(EvaluationsCompanion evaluation) => into(evaluations).insert(evaluation);

  // ✅ جلب جميع التقييمات
  Future<List<Evaluation>> getEvaluations() => select(evaluations).get();

  // ✅ إضافة اختبار جديد
  Future<int> addTest(TestsCompanion test) => into(tests).insert(test);

  // ✅ جلب جميع الاختبارات
  Future<List<Test>> getTests() => select(tests).get();

  // ✅ حذف اختبار معين
  Future<int> deleteTest(int testId) => (delete(tests)..where((t) => t.id.equals(testId))).go();

  // ✅ إضافة درجة اختبار لطالب
  Future<int> addTestScore(TestScoresCompanion score) => into(testScores).insert(score);

  // ✅ جلب جميع درجات الاختبارات
  Future<List<TestScore>> getTestScores() => select(testScores).get();


  // ✅ إضافة مجموعة جديدة
// ✅ إضافة مجموعة جديدة
Future<int> addGroup(GroupsCompanion group) => into(groups).insert(group);

// ✅ جلب جميع المجموعات
Future<List<Group>> getGroups() => select(groups).get();

// ✅ التحقق من وجود مجموعة قبل إضافتها
Future<bool> isGroupExists(String grade, String section) async {
  final query = await (select(groups)
        ..where((g) => g.grade.equals(grade) & g.section.equals(section)))
      .get();
  return query.isNotEmpty;
}

// ✅ حذف مجموعة معينة مع المواد المرتبطة بها
Future<int> deleteGroup(int id) async {
  await (delete(subjects)..where((s) => s.groupId.equals(id))).go(); // حذف المواد المرتبطة
  return (delete(groups)..where((g) => g.id.equals(id))).go();
}

// ✅ إضافة مادة جديدة لمجموعة
Future<int> addSubject(SubjectsCompanion subject) => into(subjects).insert(subject);

// ✅ جلب جميع المواد الخاصة بمجموعة معينة
Future<List<Subject>> getSubjectsForGroup(int groupId) {
  return (select(subjects)..where((s) => s.groupId.equals(groupId))).get();
}

// ✅ حذف مادة معينة
Future<int> deleteSubject(int subjectId) => (delete(subjects)..where((s) => s.id.equals(subjectId))).go();


}

// ✅ إعداد اتصال قاعدة البيانات
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase(file, logStatements: true);
  });
}
