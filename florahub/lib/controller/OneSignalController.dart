import 'dart:convert';
import 'package:http/http.dart' as http;

class OneSignalController {
  static final String _appId = '9f87fbb2-2689-4a31-bd92-87b3038f433b';
  static final String _apiKey = 'NjNkZjczZDUtMTgzNC00ZWM4LTkxNjktN2YxNzJjNWUxODEy';

  Future<void> sendNotification(String title, String message, List<String> playerIds) async {
    //final apiUrl = 'https://onesignal.com/api/v1/notifications';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $_apiKey',
    };

    final request = {
      'app_id': _appId,
      'headings': {'en': title},
      'contents': {'en': message},
     // 'include_player_ids': playerIds,
      'include_external_user_ids': playerIds,
    };

    var response = await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: headers,
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully.");
    } else {
      print("Failed to send notification. Status code: ${response.statusCode}");
    }
  }
}