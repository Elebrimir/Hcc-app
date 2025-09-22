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

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  // 1. Inicializa el plugin de notificaciones
  static Future<void> init() async {
    // Inicializar zona horaria para notificaciones programadas
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          'ic_notification', // Corregido el nombre del icono
        );

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
          // Manejar la carga útil de la notificación si es necesario
        }
        // Manejar la respuesta a la notificación si es necesario
      },
    );
  }

  // 2. Programa la notificación para un evento
  static Future<void> scheduleEventNotification(
    Event event, {
    Duration reminderTime = const Duration(hours: 1),
  }) async {
    // Convertir el ID del evento a un entero para el ID de la notificación
    final int notificationId = event.id.hashCode;

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
      event.startTime.subtract(reminderTime),
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'event_channel_id',
          'Event Notifications',
          channelDescription: 'Notificaciones para eventos agendados.',
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
        'Tu evento está a punto de empezar!',
        scheduledTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        payload: event.id,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        // En caso de que no se pueda programar la alarma exacta,
        // se intenta programar una menos precisa para evitar que la app falle.
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          event.title,
          'Tu evento está a punto de empezar! (Recordatorio no exacto)',
          scheduledTime,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.inexact,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
          payload: event.id,
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
