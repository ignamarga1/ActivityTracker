import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityProgress {
  final String _id;
  final String _activityId;
  final Timestamp _createdAt;

  final bool _completed;
  final String _date;

  final int? _progressQuantity;
  final int? _remainingHours;
  final int? _remainingMinutes;
  final int? _remainingSeconds;

  // Constructor
  ActivityProgress({
    required String id,
    required String activityId,
    required Timestamp createdAt,
    required bool completed,
    required String date,

    int? progressQuantity,
    int? remainingHours,
    int? remainingMinutes,
    int? remainingSeconds,
  }) : _id = id,
       _activityId = activityId,
       _createdAt = createdAt,
       _completed = completed,
       _date = date,

       _progressQuantity = progressQuantity,
       _remainingHours = remainingHours,
       _remainingMinutes = remainingMinutes,
       _remainingSeconds = remainingSeconds;

  // Getters
  String get id => _id;
  String get activityId => _activityId;
  bool get completed => _completed;
  String get date => _date;
  Timestamp get createdAt => _createdAt;

  int? get progressQuantity => _progressQuantity;
  int? get remainingHours => _remainingHours;
  int? get remainingMinutes => _remainingMinutes;
  int? get remainingSeconds => _remainingSeconds;

  factory ActivityProgress.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return ActivityProgress(
      id: id,
      activityId: map['activityId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      completed: map['completed'] ?? false,
      date: map['date'] ?? '',

      progressQuantity: map['progressQuantity'] ?? 0,
      remainingHours: map['remainingHours'] ?? 0,
      remainingMinutes: map['remainingMinutes'] ?? 0,
      remainingSeconds: map['remainingSeconds'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activityId': _activityId,
      'createdAt': _createdAt,
      'completed': completed,
      'date': date,
      
      'progressQuantity': _progressQuantity,
      'remainingHours': _remainingHours,
      'remainingMinutes': _remainingMinutes,
      'remainingSeconds': _remainingSeconds,
    };
  }
}
