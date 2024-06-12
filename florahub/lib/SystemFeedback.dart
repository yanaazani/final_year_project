import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SystemFeedback extends StatefulWidget {
  SystemFeedback({Key? key}) : super(key: key);

  @override
  State<SystemFeedback> createState() => _SystemFeedbackState();
}

class _SystemFeedbackState extends State<SystemFeedback> {
  List<Feedback> feedbackList = [];
  bool isDarkModeEnabled = false;
  String imageUrl = "assets/images/pinktree.png";
  Uint8List? _images; // Default image URL

  Future<void> fetchFeedback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? server = prefs.getString("localhost");
      final response =
          await http.get(Uri.parse("http://$server:8080/florahub/feedback"));

      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData is List<dynamic>) {
          setState(() {
            feedbackList = responseData
                .where((item) => item != null) // Filter out null items
                .map((json) => Feedback.fromJson(json as Map<String, dynamic>))
                .toList();
          });
        } else {
          print('Unexpected response format: $responseData');
        }
      } else {
        print('Failed to fetch feedback: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching feedback: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('System Feedback'),
      ),
      backgroundColor: Colors.white,
      body: feedbackList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: feedbackList.length,
              itemBuilder: (context, index) {
                Feedback feedback = feedbackList[index];
                return FeedbackCard(feedback: feedback);
              },
            ),
    );
  }
}

class Feedback {
  final User user;
  final int rate;
  final String message;
  final String dateTime;

  Feedback({
    required this.user,
    required this.rate,
    required this.message,
    required this.dateTime,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      user: User.fromJson(json['user']),
      rate: json['rate'],
      message: json['message'],
      dateTime: json['dateTime'],
    );
  }
}

class User {
  final String username;

  User({required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
    );
  }
}

class FeedbackCard extends StatelessWidget {
  final Feedback feedback;

  FeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feedback.user.username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8.0),
            Text("Rate: ${feedback.rate}"),
            SizedBox(height: 8.0),
            Text("Message: ${feedback.message}"),
            SizedBox(height: 8.0),
            Text("Date: ${feedback.dateTime}"),
          ],
        ),
      ),
    );
  }
}
