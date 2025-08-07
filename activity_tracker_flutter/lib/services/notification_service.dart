import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart' as tz;

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  final bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize notifications
  Future<void> initNotifications() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    final String currentTimezone = await tz.FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimezone));

    // Initialize Android settings
    const initAndroidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize settings
    const initSettings = InitializationSettings(android: initAndroidSettings);
    await notificationsPlugin.initialize(initSettings);
  }

  // Notification details
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'activity_reminders',
        'Activity Reminders',
        channelDescription: 'Activity Reminders channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  // Shows the content of the notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  // Schedules an activity reminder notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, year, month, day, hour, minute);

    // If it's a previous date, no notifications will be scheduled
    if (scheduledDate.isBefore(now)) return;

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // Cancels all notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  // Generates a custom id for each activity and date
  int generateNotificationId(String activityId, DateTime date) {
    final dateStr = DateFormat('dd-MM-yyyy').format(date);
    final uniqueString = '$activityId-$dateStr';
    return uniqueString.hashCode;
  }

  // Request user permission for notifications
  Future<void> requestPermissions() async {
    final androidImplementation = notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }
}
