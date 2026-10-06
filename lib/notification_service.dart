import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.notification?.title}: ${message.notification?.body}');
}

class NotificationService {
  static final ValueNotifier<RemoteMessage?> latestMessage = ValueNotifier(null);

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize a Dio instance
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8000', // Replace with your FastAPI host
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future<void> initFCM(String userId) async {
    // 1. Request Permission
    await _firebaseMessaging.requestPermission();

    // 2. Get FCM Token & Send to FastAPI
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $fcmToken');

    if (fcmToken != null) {
      await _syncFCMTokenWithBackend(userId: userId, fcmToken: fcmToken);
    }

    // Refresh token listener
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _syncFCMTokenWithBackend(userId: userId, fcmToken: newToken);
    });

    // 3. Set up notification listeners
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened: ${message.notification?.title}: ${message.notification?.body}');
      latestMessage.value = message;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Message received: ${message.notification?.title}: ${message.notification?.body}');
      latestMessage.value = message;
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // App launched from a terminated state by tapping a notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      latestMessage.value = initialMessage;
    }
  }

  // Method to push FCM Token using Dio
  Future<void> _syncFCMTokenWithBackend({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      final response = await _dio.post(
        '/users/register-token',
        data: {
          'user_id': userId,
          'fcm_token': fcmToken,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('FCM token successfully registered to backend');
      }
    } on DioException catch (e) {
      debugPrint('Dio error syncing FCM token: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      debugPrint('Error syncing FCM token: $e');
    }
  }
}