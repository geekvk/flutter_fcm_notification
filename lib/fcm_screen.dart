import 'package:fcm_push_notification/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FCMScreen extends StatelessWidget {
  const FCMScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FCM Notifications')),
      body: Center(
        child: ValueListenableBuilder<RemoteMessage?>(
          valueListenable: NotificationService.latestMessage,
          builder: (context, message, _) {
            if (message == null) {
              return const Text('No notification yet');
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.notification?.title ?? 'No title',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.notification?.body ?? 'No body',
                    textAlign: TextAlign.center,
                  ),
                  if (message.data.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Data: ${message.data}', textAlign: TextAlign.center),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}