import 'package:activity_tracker_flutter/models/activity_progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ActivityProgressService {
  final _collection = FirebaseFirestore.instance.collection('ActivityProgress');

  // Creates a unique ID with the activity ID and the current date
  String _generateDocId(String activityId, DateTime date) {
    final formattedDate = DateFormat('dd-MM-yyyy').format(date);
    return '${activityId}_$formattedDate';
  }

  // Get activity progress
  Stream<ActivityProgress?> getActivityProgress(
    String activityId,
    DateTime date,
  ) {
    final docId = _generateDocId(activityId, date);
    return _collection.doc(docId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return ActivityProgress.fromMap(snapshot.data()!, id: snapshot.id);
    });
  }

  // Stream to get the activity progress or create it if doesn't exist
  Stream<ActivityProgress> getOrCreateProgress({
    required String activityId,
    required DateTime date,
    required Timestamp createdAt,
    int? initialQuantity,
    int? remainingHours,
    int? remainingMinutes,
    int? remainingSeconds,
  }) {
    final docId = _generateDocId(activityId, date);
    final docRef = _collection.doc(docId);

    // Stream
    return docRef.snapshots().asyncMap((snapshot) async {
      // Create progress if it doesn't exist for the selected activity and date
      if (!snapshot.exists) { 
        final newProgress = ActivityProgress(
          id: docRef.id,
          activityId: activityId,
          createdAt: createdAt,
          completed: false,
          date: DateFormat('dd-MM-yyyy').format(date),
          progressQuantity: initialQuantity ?? 0,
          remainingHours: remainingHours,
          remainingMinutes: remainingMinutes,
          remainingSeconds: remainingSeconds,
        );

        await docRef.set(newProgress.toMap());
        return newProgress;
      } else {
        // Progress already exists
        return ActivityProgress.fromMap(snapshot.data()!, id: snapshot.id);
      }
    });
  }

  // Update activity progress
  Future<void> updateActivityProgress({
    required String activityId,
    required DateTime date,
    int? progressQuantity,
    int? remainingHours,
    int? remainingMinutes,
    int? remainingSeconds,
    bool? completed,
  }) async {
    final docId = _generateDocId(activityId, date);
    final docRef = _collection.doc(docId);

    final data = <String, dynamic>{};
    if (progressQuantity != null) data['progressQuantity'] = progressQuantity;
    if (remainingHours != null) data['remainingHours'] = remainingHours;
    if (remainingMinutes != null) data['remainingMinutes'] = remainingMinutes;
    if (remainingSeconds != null) data['remainingSeconds'] = remainingSeconds;
    if (completed != null) data['completed'] = completed;

    await _collection.doc(docRef.id).set(data, SetOptions(merge: true));
  }

  // Deletes every progress of the activity
  Future<void> deleteProgressForActivity(String activityId) async {
    final query = await _collection
        .where('activityId', isEqualTo: activityId)
        .get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }
}
