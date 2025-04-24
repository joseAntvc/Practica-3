import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
  if (_isInitialized) return; 
  
  tz.initializeTimeZones();
  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  print('Zona horaria actual: $currentTimeZone');
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings ('@mipmap/ic_launcher');
  // init ios
  const DarwinInitializationSettings initSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true, 
      requestBadgePermission: true, 
      requestSoundPermission: true,
    );
  // init settings
  const InitializationSettings initSettings = InitializationSettings(
    android: initSettingsAndroid, 
    iOS: initSettingsIOS,
  );

  await notificationsPlugin.initialize(initSettings);
  await _requestNotificationPermissions();
  _isInitialized = true;
  }

  Future<void> _requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      // Solicitar permisos en Android 13+
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      // Solicitar permisos en iOS
      await notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  // NOTI DETAILS SETUP
  NotificationDetails notificationDetails () {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily notification channel', 
        importance: Importance.max, 
        priority: Priority.high,
        ), // AndroidNotificationDetails 
        iOS: DarwinNotificationDetails(),
      );
  }
  /*
  //Notificaciones al momento
  Future<void> showNotification ({
    int id = 0,
    String? title, 
    String? body,
    String? payload,
  }) async {
    return notificationsPlugin.show(
      id, 
      title, 
      body, 
      notificationDetails(),
    );
  }*/

  /*
  Schedule a notification at a specified time (e.g. 11pm)
  - hour (0-23)
  - minute (0-59)
  */
  Future<void> scheduleNotification({
    required int id,
    required String cliente, 
    required String fechaRecordatorio,
  }) async {
    // Create a date/time for today at the specified hour/min
    final DateTime fechaNotificacion = DateFormat('dd-MM-yyyy').parse(fechaRecordatorio);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      fechaNotificacion.year,
      fechaNotificacion.month,
      fechaNotificacion.day,
      13,
      0,
    );
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      // Si la fecha ya pasó, no programar la notificación
      print('No se programará la notificación porque la fecha ya pasó: $scheduledDate');
      return;
    }
    // Schedule the notification
    await notificationsPlugin.zonedSchedule(
      id, 
      'Recordatorio de pedido', 
      'El pedido #$id del $cliente está programado en dos días.', 
      scheduledDate, 
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
    );
    print('Notificación $id: $scheduledDate');
  }

  Future<void> cancelNotification(int id) async {
    print('Notificación $id: fue eliminada');
    await notificationsPlugin.cancel(id);
  }
}