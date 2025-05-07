import 'dart:convert';
import 'dart:async';
import 'package:adventura/config.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static late WebSocketChannel _channel;
  static Timer? _pollingTimer;

  static Future<void> init(String userId) async {
    // 1. Init local notification
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);

    // 2. Connect to WebSocket
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://$wsUrl'),
    );

    // 3. Send auth
    _channel.sink.add(jsonEncode({
      "type": "auth",
      "userId": userId,
    }));

    // 4. Listen for push messages
    _channel.stream.listen(
      (message) {
        final data = jsonDecode(message);
        if (data["type"] == "push") {
          _showNotification(data["title"], data["body"]);
        }
      },
      onDone: () {
        print("🔌 WebSocket disconnected. Starting polling...");
        _startPolling(userId);
      },
      onError: (e) {
        print("❌ WebSocket error: $e. Falling back to polling.");
        _startPolling(userId);
      },
    );
  }

  static Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'push_channel_id',
      'Push Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  static void _startPolling(String userId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(Duration(seconds: 30), (_) async {
      try {
        final response =
            await http.get(Uri.parse('$baseUrl/api/offline-messages/$userId'));
        if (response.statusCode == 200) {
          final messages = jsonDecode(response.body);
          for (var msg in messages) {
            _showNotification(msg['title'], msg['body']);
          }
        }
      } catch (e) {
        print("❌ Polling error: $e");
      }
    });
  }
}
