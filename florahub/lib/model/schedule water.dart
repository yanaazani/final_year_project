class ScheduleWater {
  int id = 0;
  String startTime = "";
  int duration = 0;
  int plantId = 0;
  bool deleted = false;


  ScheduleWater({
    this.id = 0,
    this.startTime = "",
    this.duration = 0,
    this.plantId = 0,
    this.deleted = false,
  });

  factory ScheduleWater.fromJson(Map<String, dynamic> json) {
    // Extract the user ID from the nested user object
    int plantId = json['plantId']['id'] ?? 0;

    return ScheduleWater(
      id: json['id'] ?? 0,
      startTime: json['startTime'] ?? "",
      duration: json['duration'] ?? 0,
      deleted: json['deleted'] ?? false,
      plantId: plantId,
    );
  }

  int get _Id => id;
  set _Id(int value) => id = value;

  String get _startTime => startTime;
  set _startTime(String value) => startTime = value;

  int get _duration => duration;
  set _duration(int value) => duration = value;

  int get _plantId => plantId;
  set _plantId(int value) => plantId = value;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime,
      'duration': duration,
      'deleted': deleted,
      'plantId': plantId,
    };
  }
}
