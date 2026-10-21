import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Local food reminders and a rotating health quote for signed-in patients.
/// Notifications are scheduled on the device, so they also work offline.
class HealthNotificationService {
  HealthNotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static bool _permissionRequested = false;

  static const _channelId = 'food_health_reminders';
  static const _channelName = 'Food & health reminders';
  static const _channelDescription =
      'Meal reminders and encouraging health quotes';

  static const _foodReminders =
      <({int id, int hour, String title, String body})>[
    (
      id: 8100,
      hour: 8,
      title: 'Breakfast reminder',
      body: 'Good morning! Start your day with a nourishing breakfast.'
    ),
    (
      id: 8120,
      hour: 12,
      title: 'Lunch reminder',
      body: 'It is lunchtime. Choose a balanced meal and drink some water.'
    ),
    (
      id: 8200,
      hour: 20,
      title: 'Dinner reminder',
      body: 'Dinner time: enjoy a light, wholesome meal and unwind.'
    ),
  ];

  /// A numbered set of 500 positive health prompts, generated from 25 healthy
  /// habits and 20 gentle benefits so each login can choose one at random.
  static final List<String> healthQuotes = List.unmodifiable([
    for (var habit in _healthyHabits)
      for (var benefit in _benefits) '$habit $benefit',
  ]);

  static const _healthyHabits = <String>[
    'A glass of water is a small act of care.',
    'A colourful plate supports a stronger day.',
    'A short walk can refresh both body and mind.',
    'Rest is part of a healthy routine, not a reward.',
    'Slow, steady breathing can create a calmer moment.',
    'A balanced breakfast helps you begin with energy.',
    'Listening to your body is a form of wisdom.',
    'A consistent sleep routine protects tomorrow’s energy.',
    'Gentle movement is valuable movement.',
    'Fresh food and simple meals can be deeply nourishing.',
    'Taking medicine as prescribed is an act of self-respect.',
    'A quiet pause can help your mind reset.',
    'Choosing whole foods is a kind choice for your body.',
    'Sharing a healthy meal can lift your mood.',
    'Small habits become meaningful progress over time.',
    'Stretching for a few minutes can ease a busy day.',
    'Hydration supports focus, digestion, and balance.',
    'A mindful meal deserves your full attention.',
    'Kind words to yourself support emotional wellbeing.',
    'Planning meals ahead can make healthy choices easier.',
    'A little sunlight and fresh air can brighten your day.',
    'Good health grows through patient daily choices.',
    'Choosing a nourishing snack can sustain your energy.',
    'A relaxed evening routine can support restful sleep.',
    'Every healthy choice is worth celebrating.',
  ];

  static const _benefits = <String>[
    'Your wellbeing is built one caring choice at a time.',
    'You are giving your future self something valuable.',
    'Gentle consistency matters more than perfection.',
    'Today is a good day to care for yourself.',
    'Your body deserves patience and compassion.',
    'One positive step can change the rhythm of your day.',
    'You do not have to do everything at once.',
    'A healthy routine can begin with this moment.',
    'Your progress counts, even when it feels small.',
    'Make space for the habits that help you feel well.',
    'Nourishing yourself is never wasted effort.',
    'Your health journey can be calm, practical, and hopeful.',
    'Care for yourself with the same kindness you offer others.',
    'A simple routine can be a powerful foundation.',
    'Choose the next helpful step, not the perfect step.',
    'Your wellbeing deserves a place in your day.',
    'A little care today can make tomorrow feel lighter.',
    'Healthy choices are a quiet vote for your best self.',
    'You are allowed to move at a pace that feels sustainable.',
    'Your body and mind both benefit from thoughtful care.',
  ];

  static Future<void> configureForPatientLogin() async {
    try {
      await _initialize();
      await _requestPermissions();
      await _scheduleDailyFoodReminders();
      await _showLoginQuote();
    } catch (_) {
      // Notification availability must never interfere with sign-in.
    }
  }

  static Future<void> _initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone.identifier));
    } catch (_) {
      // The timezone package defaults to UTC if the device timezone is unknown.
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(),
    );
    await _notifications.initialize(settings);
    _isInitialized = true;
  }

  static Future<void> _requestPermissions() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> _scheduleDailyFoodReminders() async {
    for (final reminder in _foodReminders) {
      await _notifications.cancel(reminder.id);
      await _scheduleReminder(
          reminder, AndroidScheduleMode.exactAllowWhileIdle);
    }
  }

  static Future<void> _scheduleReminder(
    ({int id, int hour, String title, String body}) reminder,
    AndroidScheduleMode mode,
  ) async {
    try {
      await _notifications.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.body,
        _nextInstanceOf(reminder.hour),
        _details,
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Android may deny exact alarms. Keep a best-effort daily reminder.
      if (mode == AndroidScheduleMode.exactAllowWhileIdle) {
        await _scheduleReminder(
            reminder, AndroidScheduleMode.inexactAllowWhileIdle);
      }
    }
  }

  static tz.TZDateTime _nextInstanceOf(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> _showLoginQuote() async {
    final quoteNumber = Random().nextInt(healthQuotes.length);
    await _notifications.show(
      8500,
      'Health quote #${quoteNumber + 1}',
      healthQuotes[quoteNumber],
      _details,
    );
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: DarwinNotificationDetails(),
  );
}
