import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/services/activity_progress_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  final _collection = FirebaseFirestore.instance.collection('Activity');
  final ActivityProgressService _progressService = ActivityProgressService();

  // Create a new activity
  Future<void> createActivity({
    required String userId,

    required String title,
    String? description,
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
    required Timestamp createdAt,
  }) async {
    final docRef = _collection.doc();
    final newActivity = Activity(
      id: docRef.id,
      userId: userId,

      title: title,
      description: description,
      category: category,

      milestone: milestone,
      quantity: quantity,
      measurementUnit: measurementUnit,
      durationHours: durationHours,
      durationMinutes: durationMinutes,
      durationSeconds: durationSeconds,

      frequency: frequency,
      frequencyDaysOfWeek: frequencyDaysOfWeek,
      frequencyDaysOfMonth: frequencyDaysOfMonth,

      reminder: reminder,
      reminderTime: reminderTime,
      createdAt: createdAt,
    );

    await docRef.set(newActivity.toMap());

    // Creates the activity progress
    _progressService.getOrCreateProgress(
      activityId: docRef.id,
      date: DateTime.now(),
      createdAt: Timestamp.now(),
      initialQuantity: quantity,
      remainingHours: durationHours,
      remainingMinutes: durationMinutes,
      remainingSeconds: durationSeconds,
    );
  }

  // Get activities by user (ordered by title by default)
  Stream<List<Activity>> getUserActivitiesStream(String userId) {
    return _collection
        .where("userId", isEqualTo: userId)
        .orderBy("title")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Activity.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  // Get activity by id
  Stream<Activity> getActivityById(String activityId) {
    return _collection.doc(activityId).snapshots().map((snapshot) {
      return Activity.fromMap(snapshot.data()!, id: snapshot.id);
    });
  }

  // Get template activities (ordered by title by default)
  Stream<List<Activity>> getTemplateActivitiesStream() {
    return _collection
        .where("type", isEqualTo: "template")
        .orderBy("title")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Activity.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  // Update activity
  Future<void> updateActivity({
    required String id,
    String? title,
    String? description,
    ActivityCategory? category,
    bool? reminder,
    String? reminderTime,
  }) async {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (category != null) data['category'] = category.name;
    if (reminder != null) data['reminder'] = reminder;
    if (reminderTime != null) data['reminderTime'] = reminderTime;

    await _collection.doc(id).update(data);
  }

  // Delete activity
  Future<void> deleteActivityById(String id) async {
    // Deletes the whole progress of the activity
    await _progressService.deleteProgressForActivity(id);

    // Deletes the activity
    await _collection.doc(id).delete();
  }
}
