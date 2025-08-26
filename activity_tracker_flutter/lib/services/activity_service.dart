import 'package:activity_tracker_flutter/models/activity.dart';
import 'package:activity_tracker_flutter/services/activity_progress_service.dart';
import 'package:activity_tracker_flutter/utils/activity_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:home_widget/home_widget.dart';

class ActivityService {
  // final _collection = FirebaseFirestore.instance.collection('Activity');
  // final ActivityProgressService _progressService = ActivityProgressService();
  final CollectionReference<Map<String, dynamic>> _collection;
  final ActivityProgressService _progressService;

  ActivityService({FirebaseFirestore? firestore, ActivityProgressService? progressService})
    : _collection = (firestore ?? FirebaseFirestore.instance).collection('Activity'),
      _progressService = progressService ?? ActivityProgressService();

  // Create a new activity
  Future<void> createActivity({
    required String userId,

    required String title,
    String? description,
    required ActivityType type,
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
      type: type,
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

  // Get all activities (custom and challenge) by user (ordered by title by default)
  Stream<List<Activity>> getUserActivitiesStream(String userId) {
    return _collection
        .where("userId", isEqualTo: userId)
        .orderBy("title")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Activity.fromMap(doc.data(), id: doc.id)).toList());
  }

  // Get custom activities by user (ordered by title by default)
  Stream<List<Activity>> getUserCustomActivitiesStream(String userId) {
    return _collection
        .where("userId", isEqualTo: userId)
        .where("type", isEqualTo: "custom")
        .orderBy("title")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Activity.fromMap(doc.data(), id: doc.id)).toList());
  }

  // Get template activities (ordered by title by default)
  Stream<List<Activity>> getTemplateActivitiesStream() {
    return _collection
        .where("type", isEqualTo: "template")
        .orderBy("title")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Activity.fromMap(doc.data(), id: doc.id)).toList());
  }

  // Get activity by id (stream)
  Stream<Activity> getActivityById(String activityId) {
    return _collection.doc(activityId).snapshots().map((snapshot) {
      return Activity.fromMap(snapshot.data()!, id: snapshot.id);
    });
  }

  // Get activity by id (future)
  Future<Activity?> getActivityByIdOnce(String activityId) async {
    final snapshot = await _collection.doc(activityId).get();

    if (!snapshot.exists || snapshot.data() == null) return null;

    return Activity.fromMap(snapshot.data()!, id: snapshot.id);
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

  // Delete all the activities for a user
  Future<void> deleteAllActivitiesForUser(String userId) async {
    final querySnapshot = await _collection.where('userId', isEqualTo: userId).get();

    for (final doc in querySnapshot.docs) {
      // Deletes the whole progress of the activity
      await _progressService.deleteProgressForActivity(doc.id);

      // Deletes the activity
      await doc.reference.delete();
    }
  }

  // Update activity streak
  Future<void> updateStreak(Activity activity) async {
    final progressRef = FirebaseFirestore.instance.collection('ActivityProgress');

    int newStreak = 1;

    final now = DateTime.now();
    final todayKey = DateFormat('dd-MM-yyyy').format(now);

    // If the activity isn't scheduled for today nothing happens
    if (!ActivityUtils().isActivityForSelectedDate(activity, now)) return;

    // Checks if the activity progress doesn't exist or it hasn't already been completed today
    final todayProgressSnap = await progressRef.doc('${activity.id}_$todayKey').get();
    final isCompletedToday = todayProgressSnap.exists && todayProgressSnap['completed'] == true;
    if (!isCompletedToday) return;

    // The activity is scheduled for today, the progress exists and it has been completed
    // Searchs for the previous day the activity was scheduled
    DateTime? lastScheduledDate;
    for (int i = 1; i <= 30; i++) {
      final previousDate = now.subtract(Duration(days: i));
      if (ActivityUtils().isActivityForSelectedDate(activity, previousDate)) {
        lastScheduledDate = previousDate;
        break;
      }
    }

    // Checks if the previous day was completed
    if (lastScheduledDate != null) {
      final lastKey = DateFormat('dd-MM-yyyy').format(lastScheduledDate);
      final lastProgressSnap = await progressRef.doc('${activity.id}_$lastKey').get();
      final completedLast = lastProgressSnap.exists && lastProgressSnap['completed'] == true;

      // Increases the streak
      if (completedLast) {
        newStreak = activity.completionStreak + 1;
      }
    }

    // Updates the streak (and the maximum streak if it has surpassed it)
    final newMaxStreak = newStreak > activity.maxCompletionStreak ? newStreak : activity.maxCompletionStreak;

    await FirebaseFirestore.instance.collection('Activity').doc(activity.id).update({
      'completionStreak': newStreak,
      'maxCompletionStreak': newMaxStreak,
    });
  }

  // Reset activity broken streak
  Future<void> checkAndResetBrokenStreak(Activity activity) async {
    final progressRef = FirebaseFirestore.instance.collection('ActivityProgress');
    final activityRef = FirebaseFirestore.instance.collection('Activity').doc(activity.id);

    final now = DateTime.now();
    final todayKey = DateFormat('dd-MM-yyyy').format(now);

    // If the activity isn't scheduled for today nothing happens
    if (!ActivityUtils().isActivityForSelectedDate(activity, now)) return;

    // Checks if the activity has already been completed today
    final todayProgressSnap = await progressRef.doc('${activity.id}_$todayKey').get();
    final isCompletedToday = todayProgressSnap.exists && todayProgressSnap['completed'] == true;
    if (isCompletedToday) return;

    // The activity hasn't been completed for today
    // Searchs the previous day the activity was scheduled
    DateTime? lastScheduledDate;
    for (int i = 1; i <= 30; i++) {
      final previousDate = now.subtract(Duration(days: i));
      if (ActivityUtils().isActivityForSelectedDate(activity, previousDate)) {
        lastScheduledDate = previousDate;
        break;
      }
    }

    // Checks if the previous day was completed
    if (lastScheduledDate != null) {
      final lastKey = DateFormat('dd-MM-yyyy').format(lastScheduledDate);
      final lastProgressSnap = await progressRef.doc('${activity.id}_$lastKey').get();
      final completedLast = lastProgressSnap.exists && lastProgressSnap['completed'] == true;

      // If it wasn't completed and it's not already 0, the streak gets set to 0
      if (!completedLast && activity.completionStreak != 0) {
        await activityRef.update({'completionStreak': 0});
      }
    }
  }

  // Saves all the activities information for the widget
  Future<void> saveActivitiesSummaryForWidget(List<Activity> activities, DateTime date) async {
    List<String> summaryLines = [];

    for (final activity in activities) {
      final progress = await ActivityProgressService().getProgressOnce(activity.id, date);
      if (progress == null) continue;

      String line = '${activity.title}: ';

      switch (activity.milestone) {
        case MilestoneType.yesNo:
          line += progress.completed ? 'Completada' : 'Pendiente';
          break;
        case MilestoneType.quantity:
          line += '${progress.progressQuantity} / ${activity.quantity}';
          break;
        case MilestoneType.timed:
          final remaining = Duration(
            hours: progress.remainingHours ?? 0,
            minutes: progress.remainingMinutes ?? 0,
            seconds: progress.remainingSeconds ?? 0,
          );
          line += ActivityUtils().formatDuration(remaining);
          break;
      }

      summaryLines.add(line);
    }

    final summaryString = summaryLines.join('\n');

    await HomeWidget.saveWidgetData<String>('activities_summary', summaryString);
    await HomeWidget.updateWidget(name: 'ScheduledActivitiesWidgetProvider');
  }
}
