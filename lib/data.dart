// lib/data.dart
import 'models.dart';

// قائمة المجموعات (يتم تعبئتها من صفحة تسجيل البيانات)
List<ClassGroup> groups = [];

// تخزين بيانات الطلاب لكل مجموعة (المفتاح: "grade-section")
Map<String, List<Student>> studentGroupsGlobal = {};
