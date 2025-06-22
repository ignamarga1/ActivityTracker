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
    String? measurementUnit,
    int? durationSeconds,

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
      measurementUnit: measurementUnit,
      durationSeconds: durationSeconds,

      frequency: frequency,
      frequencyDaysOfWeek: frequencyDaysOfWeek,
      frequencyDaysOfMonth: frequencyDaysOfMonth,
      
      reminder: reminder,
      reminderTime: reminderTime,
      createdAt: createdAt,
    );

    await docRef.set(newActivity.toMap());
  }

  // Delete activity
  Future<void> deleteActivityById(String id) async {
    await FirebaseFirestore.instance.collection("Activities").doc(id).delete();
  }
}
