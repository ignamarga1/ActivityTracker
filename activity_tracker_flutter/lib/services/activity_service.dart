import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  // Create new activity document in Firestore
  Future<void> createActivity({
    required String userId,

    required String title,
    String? description,
    required ActivityCategory category,

    required MilestoneType milestone,
    int? quantity,
    int? progressQuantity,
    String? measurementUnit,
    int? durationHours,
    int? durationMinutes,
    int? durationSeconds,
    int? remainingHours,
    int? remainingMinutes,
    int? remainingSeconds,

    required FrequencyType frequency,
    List<int>? frequencyDaysOfWeek,
    List<int>? frequencyDaysOfMonth,

    required bool reminder,
    String? reminderTime,
    required Timestamp createdAt,
  }) async {
    final docRef = FirebaseFirestore.instance.collection("Activities").doc();
    final newActivity = Activity(
      id: docRef.id,
      userId: userId,

      title: title,
      description: description,
      category: category,

      milestone: milestone,
      quantity: quantity,
      progressQuantity: progressQuantity,
      measurementUnit: measurementUnit,
      durationHours: durationHours,
      durationMinutes: durationMinutes,
      durationSeconds: durationSeconds,
      remainingHours: remainingHours,
      remainingMinutes: remainingMinutes,
      remainingSeconds: remainingSeconds,

      frequency: frequency,
      frequencyDaysOfWeek: frequencyDaysOfWeek,
      frequencyDaysOfMonth: frequencyDaysOfMonth,

      reminder: reminder,
      reminderTime: reminderTime,
      createdAt: createdAt,
    );

    await docRef.set(newActivity.toMap());
  }

  // Get activities by user (ordered by title by default)
  Stream<List<Activity>> getUserActivitiesStream(String userId) {
    return FirebaseFirestore.instance
        .collection("Activities")
        .where("userId", isEqualTo: userId)
        .orderBy("title")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Activity.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  // Delete activity
  Future<void> deleteActivityById(String id) async {
    await FirebaseFirestore.instance.collection("Activities").doc(id).delete();
  }
}
