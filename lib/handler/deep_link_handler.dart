import 'package:app_links/app_links.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:starter_flutter/handler/dogwalk_task_handler.dart';

class DeepLinkHandler {
  late AppLinks _appLinks;

  void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'dogwalk_service',
        channelName: 'Hunde-Runde Tracking',
        channelDescription: 'Zeigt die aktuelle Distanz und Dauer an.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000), 
        allowWakeLock: true, 
        allowWifiLock: true,
        ),
    );
  }
  void initDeepLinks() {
    _appLinks = AppLinks();

    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) async {
    if (uri.scheme == 'hunderunde' && uri.host == 'start-walk') {
      
      if (await FlutterForegroundTask.isRunningService) return;

      await FlutterForegroundTask.startService(
        notificationTitle: 'Hunde-Runde gestartet',
        notificationText: 'GPS wird initialisiert...',
        callback: startCallback,
      );
    }
  }
  void requestPermissions() async {
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }
}