// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:hcc_app/models/event_model.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> requestPermissions() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  static Future<void> init() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          debugPrint('Notificación recibida con payload: ${response.payload}');
        }
      },
    );

    // Crear el canal de notificación para Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'event_channel_id',
        'Event Notifications',
        description: 'Notificaciones para eventos HCC.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      debugPrint('Canal de notificación creado: ${channel.id}');
    }
  }

  static Future<void> scheduleEventNotification(
    Event event, {
    Duration reminderTime = const Duration(hours: 1),
  }) async {
    final int notificationId = event.id.hashCode;

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
      event.startTime.subtract(reminderTime),
      tz.local,
    );

    // Validar que la notificación no sea para el pasado
    final now = tz.TZDateTime.now(tz.local);
    if (scheduledTime.isBefore(now)) {
      debugPrint(
        'No se puede programar notificación para el pasado. '
        'Evento: ${event.title}, '
        'Hora programada: $scheduledTime, '
        'Hora actual: $now',
      );
      return; // No programar notificaciones para el pasado
    }

    debugPrint(
      'Programando notificación para: ${event.title} '
      'a las $scheduledTime (${scheduledTime.timeZoneName})',
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'event_channel_id',
          'Event Notifications',
          channelDescription: 'Notificaciones para eventos HCC.',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        event.title,
        'Evento de HCC está a punto de empezar!',
        scheduledTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        payload: event.id,
      );
      debugPrint('Notificación programada exitosamente para ${event.title}');
    } on PlatformException catch (e) {
      debugPrint('Error al programar notificación: ${e.code} - ${e.message}');
      if (e.code == 'exact_alarms_not_permitted') {
        // En caso de que no se pueda programar la alarma exacta,
        // se intenta programar una menos precisa para evitar que la app falle.
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          event.title,
          'Evento de HCC está a punto de empezar! (Recordatorio no exacto)',
          scheduledTime,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
          payload: event.id,
        );
        debugPrint(
          'Notificación programada en modo inexacto para ${event.title}',
        );
      } else {
        rethrow;
      }
    }
  }

  // 3. Cancela una notificación
  static Future<void> cancelNotification(String eventId) async {
    final int notificationId = eventId.hashCode;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }
}
