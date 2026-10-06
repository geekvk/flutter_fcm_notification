import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.notification?.title}: ${message.notification?.body}');
}

class NotificationService {
  static final ValueNotifier<RemoteMessage?> latestMessage = ValueNotifier(null);

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initFCM() async{
      await _firebaseMessaging.requestPermission();
      final fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $fcmToken');

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Message opened: ${message.notification?.title}: ${message.notification?.body}');
        latestMessage.value = message;
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Message received: ${message.notification?.title}: ${message.notification?.body}');
        latestMessage.value = message;
      });
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // App launched from a terminated state by tapping a notification.
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        latestMessage.value = initialMessage;
      }

  }
}
