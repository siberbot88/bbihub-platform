import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FcmService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS
  static const String baseUrl = 'http://10.0.2.2:8000';
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // ✅ CREATE NOTIFICATION CHANNEL FIRST (Android 8.0+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings,
        onDidReceiveNotificationResponse: (response) {
      // Handle notification tap
      print('Notification tapped: ${response.payload}');
    });

    // ✅ Foreground handler - ALWAYS SHOW NOTIFICATION
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 FCM: Got a message in FOREGROUND!');
      print('📦 Message data: ${message.data}');

      if (message.notification != null) {
        print('✉️  Notification title: ${message.notification!.title}');
        print('✉️  Notification body: ${message.notification!.body}');
        // FORCE SHOW LOCAL NOTIFICATION
        showLocalNotification(message);
      } else {
        print('⚠️  No notification payload, only data');
      }
    });

    // Background/Terminated handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 A new onMessageOpenedApp event was published!');
      // Navigate to page based on data
    });
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    // ✅ Use the SAME channel ID created in initialize()
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // MUST match channel ID above
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'BBI Hub',
      message.notification?.body ?? 'Anda mendapat notifikasi baru',
      platformDetails,
      payload: jsonEncode(message.data),
    );

    print('✅ Local notification displayed!');
  }

  static Future<void> saveTokenToBackend(String authToken) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      print('FCM Token: $token');

      // Replace with your API URL
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/auth/fcm-token'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      if (response.statusCode == 200) {
        print('FCM Token saved successfully');
      } else {
        print('Failed to save FCM token: ${response.body}');
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }
}
