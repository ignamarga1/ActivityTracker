import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType { custom, template }

enum ActivityCategory {
  art,
  entertainment,
  health,
  home,
  nutrition,
  meditation,
  quitBadHabit,
  reading,
  social,
  sport,
  study,
  work,
  other,
}

enum MilestoneType { yesNo, quantity, timed }

enum FrequencyType { everyday, specificDayWeek, specificDayMonth }

class Activity {
  final String _id;
  final String _userId;

  final String _title;
  final String? _description;
  final ActivityType _type;
  final ActivityCategory _category;

  final MilestoneType _milestone;
  final int? _quantity;

  final String? _measurementUnit;
  final int? _durationHours;
  final int? _durationMinutes;
  final int? _durationSeconds;

  final FrequencyType _frequency;
  final List<int>? _frequencyDaysOfWeek;
  final List<int>? _frequencyDaysOfMonth;

  final bool _reminder;
  final String? _reminderTime;
  final int _completionStreak;
  final int _maxCompletionStreak;
  final Timestamp _createdAt;

  // Constructor
  Activity({
    required String id,
    required String userId,

    required String title,
    String? description,
    ActivityType type = ActivityType.custom,
    required ActivityCategory category,

    required MilestoneType milestone,
    int? quantity,
    String? measurementUnit,
    int? durationHours,
    int? durationMinutes,
    int? durationSeconds,

    required FrequencyType frequency,
    List<int>? frequencyDaysOfWeek,
    List<int>? frequencyDaysOfMonth,

    required bool reminder,
    String? reminderTime,
    int completionStreak = 0,
    int maxCompletionStreak = 0,
    required Timestamp createdAt,
  }) : _id = id,
       _userId = userId,

       _title = title,
       _description = description,
       _type = type,
       _category = category,

       _milestone = milestone,
       _quantity = quantity,
       _measurementUnit = measurementUnit,
       _durationHours = durationHours,
       _durationMinutes = durationMinutes,
       _durationSeconds = durationSeconds,

       _frequency = frequency,
       _frequencyDaysOfWeek = frequencyDaysOfWeek,
       _frequencyDaysOfMonth = frequencyDaysOfMonth,

       _reminder = reminder,
       _reminderTime = reminderTime,
       _completionStreak = completionStreak,
       _maxCompletionStreak = maxCompletionStreak,
       _createdAt = createdAt;

  // Getters
  String get id => _id;
  String get userId => _userId;

  String get title => _title;
  String? get description => _description;
  ActivityType get type => _type;
  ActivityCategory get category => _category;

  MilestoneType get milestone => _milestone;
  int? get quantity => _quantity;
  String? get measurementUnit => _measurementUnit;
  int? get durationHours => _durationHours;
  int? get durationMinutes => _durationMinutes;
  int? get durationSeconds => _durationSeconds;

  FrequencyType get frequency => _frequency;
  List<int>? get frequencyDaysOfWeek => _frequencyDaysOfWeek;
  List<int>? get frequencyDaysOfMonth => _frequencyDaysOfMonth;

  bool get reminder => _reminder;
  String? get dateTime => _reminderTime;
  int get completionStreak => _completionStreak;
  int get maxCompletionStreak => _maxCompletionStreak;
  Timestamp get createdAt => _createdAt;

  // Enum helper
  static T _enumFromString<T>(List<T> values, String value) =>
      values.firstWhere((e) => e.toString().split('.').last == value);

  // Converts Firestore map into AppUser
  factory Activity.fromMap(Map<String, dynamic> map, {required String id}) {
    return Activity(
      id: id,
      userId: map['userId'] ?? '',

      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: _enumFromString(ActivityType.values, map['type']),
      category: _enumFromString(ActivityCategory.values, map['category']),
      
      milestone: _enumFromString(MilestoneType.values, map['milestone']),
      quantity: map['quantity'] ?? 1,
      measurementUnit: map['measurementUnit'] ?? '',
      durationHours: map['durationHours'] ?? 0,
      durationMinutes: map['durationMinutes'] ?? 0,
      durationSeconds: map['durationSeconds'] ?? 1,

      frequency: _enumFromString(FrequencyType.values, map['frequency']),
      frequencyDaysOfWeek: (map['frequencyDaysOfWeek'] as List?)?.cast<int>(),
      frequencyDaysOfMonth: (map['frequencyDaysOfMonth'] as List?)?.cast<int>(),

      reminder: map['reminder'] ?? false,
      reminderTime: map['reminderTime'] ?? '',
      completionStreak: map['completionStreak'] ?? 0,
      maxCompletionStreak: map['maxCompletionStreak'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  // Converts AppUser into map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': _userId,

      'title': _title,
      'description': _description,
      'type': _type.name,
      'category': _category.name,

      'milestone': _milestone.name,
      'quantity': _quantity,
      'measurementUnit': _measurementUnit,
      'durationHours': _durationHours,
      'durationMinutes': _durationMinutes,
      'durationSeconds': _durationSeconds,

      'frequency': _frequency.name,
      'frequencyDaysOfWeek': _frequencyDaysOfWeek,
      'frequencyDaysOfMonth': _frequencyDaysOfMonth,
      
      'reminder': _reminder,
      'reminderTime': _reminderTime,
      'completionStreak': _completionStreak,
      'maxCompletionStreak': _maxCompletionStreak,
      'createdAt': _createdAt,
    };
  }
}
