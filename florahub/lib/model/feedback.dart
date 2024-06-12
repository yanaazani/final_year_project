import 'package:florahub/model/user.dart';

/**
 * This class is for feedback that is to take data from MySQL
 */

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

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime,
      'rate': rate,
      'message': message,
      'userId': user,
    };
  }
}
