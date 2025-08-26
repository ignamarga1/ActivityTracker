import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:activity_tracker_flutter/services/activity_service.dart';
import 'package:activity_tracker_flutter/services/activity_progress_service.dart';
import 'package:activity_tracker_flutter/models/activity.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ActivityService service;
  late ActivityProgressService progressService;

  // Before all the tests
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  // Before every test
  setUp(() {
    firestore = FakeFirebaseFirestore();
    progressService = ActivityProgressService(firestore: firestore);
    service = ActivityService(firestore: firestore, progressService: progressService);
  });

  group('ActivityService', () {
    test('Create a new custom activity', () async {
      await service.createActivity(
        userId: '1234567890AbCdEfGhIjKlMnOpQr',
        title: 'Actividad de prueba',
        description: 'Descripción de prueba',
        type: ActivityType.custom,
        category: ActivityCategory.other,
        milestone: MilestoneType.yesNo,
        frequency: FrequencyType.everyday,
        reminder: false,
        createdAt: Timestamp.now(),
      );

      final snapshot = await firestore.collection('Activity').get();
      final expectedLenght = 1;
      final expectedUserId = '1234567890AbCdEfGhIjKlMnOpQr';
      final expectedTitle = 'Actividad de prueba';

      expect(snapshot.docs.length, expectedLenght);
      expect(snapshot.docs.first['userId'], expectedUserId);
      expect(snapshot.docs.first['title'], expectedTitle);
    });

    test('Get all the activities of the user', () async {
      await service.createActivity(
        userId: '1234567890AbCdEfGhIjKlMnOpQr',
        title: 'Actividad de prueba 1',
        description: 'Descripción de prueba 1',
        type: ActivityType.custom,
        category: ActivityCategory.other,
        milestone: MilestoneType.yesNo,
        frequency: FrequencyType.everyday,
        reminder: false,
        createdAt: Timestamp.now(),
      );

      await service.createActivity(
        userId: '1234567890AbCdEfGhIjKlMnOpQr',
        title: 'Actividad de prueba 2 (desafío)',
        type: ActivityType.challenge,
        category: ActivityCategory.entertainment,
        milestone: MilestoneType.quantity,
        quantity: 10,
        measurementUnit: 'unidades',
        frequency: FrequencyType.specificDayWeek,
        frequencyDaysOfWeek: [0, 2, 4],
        reminder: true,
        reminderTime: '12:00',
        createdAt: Timestamp.now(),
      );

      await service.createActivity(
        userId: '1234567890AbCdEfGhIjKlMnOpQr',
        title: 'Actividad de prueba 3',
        type: ActivityType.custom,
        category: ActivityCategory.social,
        milestone: MilestoneType.timed,
        durationHours: 1,
        durationMinutes: 2,
        durationSeconds: 3,
        frequency: FrequencyType.specificDayMonth,
        frequencyDaysOfMonth: [1, 3, 5, 7, 9],
        reminder: true,
        reminderTime: '18:30',
        createdAt: Timestamp.now(),
      );

      final activities = await service.getUserActivitiesStream('1234567890AbCdEfGhIjKlMnOpQr').first;
      final expectedLenght = 3;
      final actualLenght = activities.length;

      final activity1 = activities[0];
      final expectedActivity1Title = 'Actividad de prueba 1';
      final actualActivity1Title = activity1.title;
      final expectedActivity1Description = 'Descripción de prueba 1';
      final actualActivity1Description = activity1.description;

      final activity2 = activities[1];
      final expectedActivity2Milestone = MilestoneType.quantity;
      final actualActivity2Milestone = activity2.milestone;
      final expectedActivity2Quantity = 10;
      final actualActivity2Quantity = activity2.quantity;
      
      final activity3 = activities[2];
      final expectedActivity3Milestone = MilestoneType.timed;
      final actualActivity3Milestone = activity3.milestone;
      final expectedActivity3DurationMinutes = 2;
      final actualActivity3DurationMinutes = activity3.durationMinutes;
      final expectedActivity3Frequency = FrequencyType.specificDayMonth;
      final actualActivity3Frequency = activity3.frequency;
      final expectedActivity3FrequencyDaysOfMonth = [1, 3, 5, 7, 9];
      final actualActivity3FrequencyDaysOfMonth = activity3.frequencyDaysOfMonth;

      expect(actualLenght, expectedLenght);

      expect(actualActivity1Title, expectedActivity1Title);
      expect(actualActivity1Description, expectedActivity1Description);

      expect(actualActivity2Milestone, expectedActivity2Milestone);
      expect(actualActivity2Quantity, expectedActivity2Quantity);    

      expect(actualActivity3Milestone, expectedActivity3Milestone);
      expect(actualActivity3DurationMinutes, expectedActivity3DurationMinutes);
      expect(actualActivity3Frequency, expectedActivity3Frequency);
      expect(actualActivity3FrequencyDaysOfMonth, expectedActivity3FrequencyDaysOfMonth);
    });

    test('Get all the activities created by the user', () async {
      await service.createActivity(
        userId: '1234567890AbCdEfGhIjKlMnOpQr',
        title: 'Actividad de prueba',
        description: 'Descripción de prueba 1',
        type: ActivityType.custom,
        category: ActivityCategory.other,
        milestone: MilestoneType.yesNo,
        frequency: FrequencyType.everyday,
        reminder: false,
        createdAt: Timestamp.now(),
      );

      await service.createActivity(
        userId: '1234567890AbCdEfGhIjKlMnOpQr',
        title: 'Actividad de desafío de prueba',
        type: ActivityType.challenge,
        category: ActivityCategory.entertainment,
        milestone: MilestoneType.quantity,
        quantity: 10,
        measurementUnit: 'unidades',
        frequency: FrequencyType.specificDayWeek,
        frequencyDaysOfWeek: [0, 2, 4],
        reminder: true,
        reminderTime: '12:00',
        createdAt: Timestamp.now(),
      );

      final activities = await service.getUserCustomActivitiesStream('1234567890AbCdEfGhIjKlMnOpQr').first;
      final expectedLenght = 1;
      final actualLenght = activities.length;

      final activity1 = activities[0];
      final expectedActivity1Type = ActivityType.custom;
      final actualActivity1Type = activity1.type;

      expect(actualLenght, expectedLenght);
      expect(actualActivity1Type, expectedActivity1Type);
    });

    test('Get all the template activities', () async {
      await service.createActivity(
        userId: '1234567890AbCdEfGhIjKlMnOpQr',
        title: 'Actividad de prueba',
        description: 'Descripción de prueba 1',
        type: ActivityType.custom,
        category: ActivityCategory.other,
        milestone: MilestoneType.yesNo,
        frequency: FrequencyType.everyday,
        reminder: false,
        createdAt: Timestamp.now(),
      );

      await service.createActivity(
        userId: '1234567890AbCdEfGhIjKlMnOpQr',
        title: 'Plantilla de prueba 1',
        type: ActivityType.template,
        category: ActivityCategory.entertainment,
        milestone: MilestoneType.quantity,
        quantity: 5,
        measurementUnit: 'unidades',
        frequency: FrequencyType.specificDayWeek,
        frequencyDaysOfWeek: [1, 5],
        reminder: true,
        reminderTime: '22:00',
        createdAt: Timestamp.now(),
      );

      await service.createActivity(
        userId: '1234567890AbCdEfGhIjKlMnOpQr',
        title: 'Plantilla de prueba 2',
        type: ActivityType.template,
        category: ActivityCategory.nutrition,
        milestone: MilestoneType.quantity,
        quantity: 10,
        measurementUnit: 'unidades',
        frequency: FrequencyType.specificDayWeek,
        frequencyDaysOfWeek: [0, 2, 4],
        reminder: false,
        createdAt: Timestamp.now(),
      );

      final activities = await service.getTemplateActivitiesStream().first;
      final expectedLenght = 2;
      final actualLenght = activities.length;

      final activity1 = activities[0];
      final expectedActivity1Type = ActivityType.template;
      final actualActivity1Type = activity1.type;
      final expectedActivity1Title = 'Plantilla de prueba 1';
      final actualActivity1Title = activity1.title;

      final activity2 = activities[1];
      final expectedActivity2Type = ActivityType.template;
      final actualActivity2Type = activity1.type;
      final expectedActivity2Category = ActivityCategory.nutrition;
      final actualActivity2Category = activity2.category;

      expect(actualLenght, expectedLenght);
      expect(actualActivity1Type, expectedActivity1Type);
      expect(actualActivity1Title, expectedActivity1Title);

      expect(actualActivity2Type, expectedActivity2Type);
      expect(actualActivity2Category, expectedActivity2Category);
    });

    test('Get an activity by its ID', () async {
      final doc = await firestore.collection('Activity').add({
        'userId': '1234567890AbCdEfGhIjKlMnOpQr',
        'title': 'Actividad de prueba 1',
        'type': 'custom',
        'category': 'health',
        'milestone': 'yesNo',
        'frequency': 'everyday',
        'reminder': false,
        'createdAt': Timestamp.now(),
        'quantity': null,
        'durationHours': null,
        'durationMinutes': null,
        'durationSeconds': null,
        'completionStreak' : 2,
        'maxCompletionStreak': 4,
      });

      final stream = service.getActivityById(doc.id);
      final activity = await stream.first;
      final expectedActivityId = doc.id;
      final actualActivityId = activity.id;
      final expectedActivityTitle = 'Actividad de prueba 1';
      final actualActivityTitle = activity.title;

      expect(actualActivityId, expectedActivityId);
      expect(actualActivityTitle, expectedActivityTitle);
    });

    test('Get an activity by its ID for an activity that does not exist', () async {
      final activity  = await service.getActivityByIdOnce('987654321AbCdEfGhIjKlMnOpQr');
      expect(activity, isNull);
    });

    test('Update an activity', () async {
      final doc = await firestore.collection('Activity').add({
        'userId': '1234567890AbCdEfGhIjKlMnOpQr',
        'title': 'Actividad de prueba 1',
        'type': 'custom',
        'category': 'health',
        'milestone': 'yesNo',
        'frequency': 'everyday',
        'reminder': false,
        'createdAt': Timestamp.now(),
        'quantity': null,
        'durationHours': null,
        'durationMinutes': null,
        'durationSeconds': null,
        'completionStreak' : 2,
        'maxCompletionStreak': 4,
      });

      await service.updateActivity(
        id: doc.id,
        title: 'Título editado',
        description: 'Nueva descripción',
        category: ActivityCategory.home,
        reminder: true,
        reminderTime: "12:00"
      );

      final updatedActivity = await firestore.collection('Activity').doc(doc.id).get();
      final expectedUpdatedActivityTitle = 'Título editado';
      final actualUpdatedActivityTitle = updatedActivity['title'];
      final expectedUpdatedActivityDescription = 'Nueva descripción';
      final actualUpdatedActivityDescription = updatedActivity['description'];
      final expectedUpdatedActivityCategory = 'home';
      final actualUpdatedActivityCategory = updatedActivity['category'];

      expect(actualUpdatedActivityTitle, expectedUpdatedActivityTitle);
      expect(actualUpdatedActivityDescription, expectedUpdatedActivityDescription);
      expect(actualUpdatedActivityCategory, expectedUpdatedActivityCategory);
    });

    test('Delete an activity by its ID', () async {
      final doc = await firestore.collection('Activity').add({
        'userId': '1234567890AbCdEfGhIjKlMnOpQr',
        'title': 'Actividad para borrar',
        'type': 'custom',
        'category': 'other',
        'milestone': 'yesNo',
        'frequency': 'everyday',
        'reminder': false,
        'createdAt': Timestamp.now(),
        'quantity': null,
        'durationHours': null,
        'durationMinutes': null,
        'durationSeconds': null,
        'completionStreak' : 2,
        'maxCompletionStreak': 4,
      });

      await service.deleteActivityById(doc.id);

      final activity = await firestore.collection('Activity').doc(doc.id).get();
      expect(activity.exists, false);
    });

    test('Deletes all the activities of the user', () async {
      await firestore.collection('Activity').add({
        'userId': '1234567890AbCdEfGhIjKlMnOpQr',
        'title': 'Actividad para borrar 1',
        'type': 'custom',
        'category': 'other',
        'milestone': 'yesNo',
        'frequency': 'everyday',
        'reminder': false,
        'createdAt': Timestamp.now(),
        'quantity': null,
        'durationHours': null,
        'durationMinutes': null,
        'durationSeconds': null,
        'completionStreak' : 2,
        'maxCompletionStreak': 4,
      });
      
      await firestore.collection('Activity').add({
        'userId': '1234567890AbCdEfGhIjKlMnOpQr',
        'title': 'Actividad para borrar 2',
        'type': 'challenge',
        'category': 'home',
        'milestone': 'quantity',
        'frequency': 'everyday',
        'reminder': false,
        'createdAt': Timestamp.now(),
        'quantity': 10,
        'durationHours': null,
        'durationMinutes': null,
        'durationSeconds': null,
        'completionStreak' : 0,
        'maxCompletionStreak': 12,
      });

      await service.deleteAllActivitiesForUser('1234567890AbCdEfGhIjKlMnOpQr');

      final activities = await firestore.collection('Activity').get();
      final expectedSize = 0;
      final actualSize = activities.size;

      expect(actualSize, expectedSize);
      expect(activities.docs, isEmpty);
    });
  });
}
