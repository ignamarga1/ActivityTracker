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
  final String _title;
  final String? _description;
  final ActivityType _type;
  final ActivityCategory _category;
  final MilestoneType _milestone;
  final FrequencyType _frequency;
  final List<int>? _frequencyDaysOfWeek;
  final List<int>? _frequencyDaysOfMonth;
  final bool _reminder;
  final int _completionStreak;
  final int _maxCompletionStreak;
  final Timestamp _createdAt;

  // Constructor
  Activity({
    required String title,
    String? description,
    ActivityType type = ActivityType.custom,
    required ActivityCategory category,
    required MilestoneType milestone,
    required FrequencyType frequency,
    List<int>? frequencyDaysOfWeek,
    List<int>? frequencyDaysOfMonth,
    required bool reminder,
    int completionStreak = 0,
    int maxCompletionStreak = 0,
    required Timestamp createdAt,
  }) : _title = title,
       _description = description,
       _type = type,
       _category = category,
       _milestone = milestone,
       _frequency = frequency,
       _frequencyDaysOfWeek = frequencyDaysOfWeek,
       _frequencyDaysOfMonth = frequencyDaysOfMonth,
       _reminder = reminder,
       _completionStreak = completionStreak,
       _maxCompletionStreak = maxCompletionStreak,
       _createdAt = createdAt;

  // Getters
  String get title => _title;
  String? get description => _description;
  ActivityType get type => _type;
  ActivityCategory get category => _category;
  MilestoneType get milestone => _milestone;
  FrequencyType get frequency => _frequency;
  List<int>? get frequencyDaysOfWeek => _frequencyDaysOfWeek;
  List<int>? get frequencyDaysOfMonth => _frequencyDaysOfMonth;
  bool get reminder => _reminder;
  int get completionStreak => _completionStreak;
  int get maxCompletionStreak => _maxCompletionStreak;
  Timestamp get createdAt => _createdAt;

  // Enum helper
  static T _enumFromString<T>(List<T> values, String value) =>
      values.firstWhere((e) => e.toString().split('.').last == value);

  // Converts Firestore map into AppUser
  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: _enumFromString(ActivityType.values, map['type']),
      category: _enumFromString(ActivityCategory.values, map['category']),
      milestone: _enumFromString(MilestoneType.values, map['milestone']),
      frequency: _enumFromString(FrequencyType.values, map['frequency']),
      frequencyDaysOfWeek: (map['frequencyDaysOfWeek'] as List?)?.cast<int>(),
      frequencyDaysOfMonth: (map['frequencyDaysOfMonth'] as List?)?.cast<int>(),
      reminder: map['reminder'] ?? false,
      completionStreak: map['completionStreak'] ?? 0,
      maxCompletionStreak: map['maxCompletionStreak'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  // Converts AppUser into map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': _title,
      'description': _description,
      'type': _type,
      'category': _category,
      'milestone': _milestone,
      'frequency': _frequency,
      'frequencyDaysOfWeek': _frequencyDaysOfWeek,
      'frequencyDaysOfMonth': _frequencyDaysOfMonth,
      'reminder': _reminder,
      'completionStreak': _completionStreak,
      'maxCompletionStreak': _maxCompletionStreak,
      'createdAt': _createdAt,
    };
  }
}
