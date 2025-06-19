import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  // Create new activity document in Firestore
  Future<void> createActivityDocument({
    required String title,
    String? description,
    required ActivityCategory category,
    required MilestoneType milestone,
    required FrequencyType frequency,
    List<int>? frequencyDaysOfWeek,
    List<int>? frequencyDaysOfMonth,
    required bool reminder,
    required Timestamp createdAt,
  }) async {
    final newActivity = Activity(
      title: title,
      description: description,
      category: category,
      milestone: milestone,
      frequency: frequency,
      frequencyDaysOfWeek: frequencyDaysOfWeek,
      frequencyDaysOfMonth: frequencyDaysOfMonth,
      reminder: reminder,
      completionStreak: 0,
      maxCompletionStreak: 0,
      createdAt: createdAt,
    );

    await FirebaseFirestore.instance
        .collection("Activities")
        .doc()
        .set(newActivity.toMap());
  }

  // Delete activity
  Future<void> deleteActivityById(String id) async {
    await FirebaseFirestore.instance.collection("Activities").doc(id).delete();
  }
}
