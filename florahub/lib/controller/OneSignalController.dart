import 'dart:convert';
import 'package:http/http.dart' as http;

class OneSignalController {
  static final String _appId = 'dcb557a8-6999-47e7-a23b-228b4a28e3bd';
  static final String _apiKey =
      'MTRlNWNmNjYtZDE1Ny00NGI1LTlmMDktMTkwM2UwYzMyZjIw';

  Future<void> sendNotification(
      String title, String message, String userId) async {
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
      'include_external_user_ids': [userId],
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
