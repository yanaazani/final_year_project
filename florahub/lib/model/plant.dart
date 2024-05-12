/**
 * This class is for plant that is to take data from MySQL
 */

class Plant {
  int id = 0;
  String name = "";
  String description = "";
  String type = "";
  // Assuming scheduleTime is represented as a String in Dart
  String scheduleTime = "";
  // Assuming userId is represented as an int in Dart
  int userId = 0;
  bool deleted = false;

  Plant({
    this.id = 0,
    this.name = "",
    this.description = "",
    this.type = "",
    this.scheduleTime = "",
    this.userId = 0,
    this.deleted = false,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    // Extract the user ID from the nested user object
    int userId = json['userId']['id'] ?? 0;

    return Plant(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      type: json['type'] ?? "",
      scheduleTime: json['scheduleTime'] ?? "",
      deleted: json['deleted'] ?? false,
      userId: userId,
    );
  }

  int get _Id => id;
  set _Id(int value) => id = value;

  String get _name => name;
  set _name(String value) => name = value;

  String get _description => description;
  set _description(String value) => description = value;

  String get _type => type;
  set _type(String value) => type = value;

  String get _scheduleTime => scheduleTime;
  set _scheduleTime(String value) => scheduleTime = value;

  int get _userId => userId;
  set _userId(int value) => userId = value;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'scheduleTime': scheduleTime,
      'userId': userId,
      'deleted': deleted,
    };
  }
}
