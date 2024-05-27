import 'dart:convert';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/model/schedule%20water.dart';
import 'package:florahub/widgets/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleWateringPage extends StatefulWidget {
  final int plantId;
  const ScheduleWateringPage({super.key, required this.plantId});

  @override
  State<ScheduleWateringPage> createState() =>
      _ScheduleWateringPageState(plantId: plantId);
}

class _ScheduleWateringPageState extends State<ScheduleWateringPage> {
  late final int plantId, scheduleId;
  _ScheduleWateringPageState({required this.plantId});
  // Variables to store user inputs
  int selectedHour = 12; // Initialize with a non-conflicting value
  int selectedMinute = 0; // Initialize with a non-conflicting value
  String selectedPeriod = 'AM';
  int selectedDuration = 5; // Default duration
  bool isOn = false;
  late List<ScheduleWater> schedules = [];

  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  Future add() async {
    // Convert selected hour to 24-hour format
    int hour =
        selectedPeriod == 'AM' ? selectedHour % 12 : (selectedHour % 12) + 12;
    // Format time as "HH:mm:ss"
    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}:00';

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "scheduledWatering/add", server: "http://$server:8080");

    req.setBody({
      'startTime': formattedTime,
      'duration': selectedDuration.toString(),
      "plantId": plantId.toString(),
    });

    await req.post();

    print(req.result());
    if (req.result() != null) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            text: "Congrats, you have add new plant!",
            onConfirm: () {
              Navigator.pop(context);
            }),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to add your plant. \nPlease try again.",
        backgroundColor: Colors.white,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
        fontSize: 16.0,
      );
    }
  }

  Future<void> fetchSchedules() async {
    try {
      // Make an HTTP GET request to fetch the schedules from the backend
      http.Response response = await http.get(Uri.parse(
          "http://172.20.10.3:8080/florahub/scheduledWatering/plant/${widget.plantId}?deleted=0"));

      print('Response body: ${response.body}');
      // Check the response status
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print('Response Data: $responseData');
        if (responseData is List<dynamic>) {
          print('\n\nResponse Data2: $responseData');
          setState(() {
            schedules = responseData
                .map((data) => ScheduleWater.fromJson(data))
                .where((schedule) => schedule.deleted == false)
                .toList();

            // Convert schedule times to formatted strings
            schedules.forEach((schedule) {
              schedule.startTime = formatScheduleTime(schedule.startTime);
            });
          });
        } else {
          // Handle unexpected response format
          print('Unexpected response format: $responseData');
        }
      } else {
        // Handle errors or display an error message
        print('Failed to fetch schedules: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error fetching schedules: $e');
    }
  }

  String formatScheduleTime(String time) {
    // Split the time string into components
    List<String> components = time.split(':');
    int hour = int.parse(components[0]);
    int minute = int.parse(components[1]);

    // Convert hour to 12-hour format
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    // Format the time string
    String formattedTime = '$hour:${minute.toString().padLeft(2, '0')} $period';
    return formattedTime;
  }

  // Function to soft delete the schedule
  void softDeleteSchedule(int scheduleId, Function(bool) callback) async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
      path: "scheduledWatering/deleteSchedule/$scheduleId",
      server: "http://$server:8080",
    );
    // Send the request to the server
    await req.put();

    if (req.status() == 200) {
      // Schedule soft deleted successfully
      print('Schedule soft deleted successfully');
      callback(true); // Invoke the callback with true
    } else {
      // Failed to soft delete schedule
      print('Failed to soft delete schedule');
      callback(false); // Invoke the callback with false
    }
  }

  // Function to on the schedule
  void isOnToggle(int scheduleId, Function(bool) callback) async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
      path: "scheduledWatering/toggleOn/$scheduleId",
      server: "http://$server:8080",
    );
    // Send the request to the server
    await req.put();

    if (req.status() == 200) {
      // Schedule toggled successfully
      print('Schedule toggled successfully');
      callback(true); // Invoke the callback with true
    } else {
      // Failed to toggle schedule
      print('Failed to toggle schedule');
      callback(false); // Invoke the callback with false
    }
  }

  // Function to on the schedule
  void isOffToggle(int scheduleId, Function(bool) callback) async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
      path: "scheduledWatering/toggleOff/$scheduleId",
      server: "http://$server:8080",
    );
    // Send the request to the server
    await req.put();

    if (req.status() == 200) {
      // Schedule toggled successfully
      print('Schedule toggled successfully');
      callback(true); // Invoke the callback with true
    } else {
      // Failed to toggle schedule
      print('Failed to toggle schedule');
      callback(false); // Invoke the callback with false
    }
  }

  Future<void> _refreshData() async {
    await fetchSchedules();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Schedule Watering',
          style: GoogleFonts.dancingScript(
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            SizedBox(height: 15),
            _buildTimePicker(),
            SizedBox(height: 20),
            _buildDurationSelector(),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                add();
              },
              child: Text(
                "Add Schedule",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: const Color(0xff296e48),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return Dismissible(
                    key: Key(
                        schedule.id.toString()), // Unique key for each schedule
                    onDismissed: (direction) {
                      // Remove the schedule from the list
                      setState(() {
                        schedules.removeAt(index);
                        setState(() {
                          softDeleteSchedule(schedule.id, (bool success) {
                            if (success) {
                              // Handle success
                              print('Schedule soft deleted successfully');
                            } else {
                              // Handle failure
                              print('Failed to soft delete Scheduless');
                            }
                          });
                        });
                      });
                      // Optionally, you can add code to delete the schedule from the backend
                    },
                    background: Container(
                      color: Colors.red, // Background color when swiping
                      child: Icon(Icons.delete), // Delete icon
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                    ),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors
                                      .transparent, // Set the background color to green
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Constants.primaryColor.withOpacity(.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  height: 100.0,
                                  padding: const EdgeInsets.only(left: 20),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  width: size.width,
                                  child: Row(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: 90.0,
                                            height: 80.0,
                                            decoration: BoxDecoration(
                                              color: Colors.green[100],
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          Positioned(
                                            left: 5,
                                            child: SizedBox(
                                              height: 90.0,
                                              child: Image.asset(
                                                  "assets/images/Schedule.png"),
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            left: 110,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  schedule.startTime,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 30,
                                                    color: Constants.blackColor,
                                                  ),
                                                ),
                                                Text(
                                                  "${schedule.duration} seconds pump on",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Constants.blackColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width - 40,
                                            child: ListTile(
                                              trailing: Switch(
                                                value: schedule.isOn,
                                                onChanged: (bool value) {
                                                  if (value) {
                                                    // Toggle on
                                                    isOnToggle(schedule.id,
                                                        (bool success) {
                                                      if (success) {
                                                        setState(() {
                                                          schedule.isOn = value;
                                                        });
                                                      } else {
                                                        // Handle failure case
                                                        Fluttertoast.showToast(
                                                          msg:
                                                              "Failed to update schedule state. Please try again.",
                                                          backgroundColor:
                                                              Colors.red,
                                                          textColor:
                                                              Colors.white,
                                                          toastLength:
                                                              Toast.LENGTH_LONG,
                                                          fontSize: 16.0,
                                                        );
                                                      }
                                                    });
                                                  } else {
                                                    // Toggle off
                                                    isOffToggle(schedule.id,
                                                        (bool success) {
                                                      if (success) {
                                                        setState(() {
                                                          schedule.isOn = value;
                                                        });
                                                      } else {
                                                        // Handle failure case
                                                        Fluttertoast.showToast(
                                                          msg:
                                                              "Failed to update schedule state. Please try again.",
                                                          backgroundColor:
                                                              Colors.red,
                                                          textColor:
                                                              Colors.white,
                                                          toastLength:
                                                              Toast.LENGTH_LONG,
                                                          fontSize: 16.0,
                                                        );
                                                      }
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hour Selector
        DropdownButton<int>(
          value: selectedHour,
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                selectedHour = newValue;
              });
            }
          },
          items: List.generate(12, (index) => index + 1)
              .map((int value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  ))
              .toList(),
        ),
        Text(
          ' : ',
          style: TextStyle(fontSize: 20),
        ),
        // Minute Selector
        DropdownButton<int>(
          value: selectedMinute,
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                selectedMinute = newValue;
              });
            }
          },
          items: List.generate(60, (index) => index)
              .map((int value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString().padLeft(2, '0')),
                  ))
              .toList(),
        ),
        SizedBox(width: 5),
        // Period Selector (AM/PM)
        DropdownButton<String>(
          value: selectedPeriod,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedPeriod = newValue;
              });
            }
          },
          items: <String>['AM', 'PM']
              .map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Duration: ',
          style: TextStyle(fontSize: 20),
        ),
        DropdownButton<int>(
          value: selectedDuration,
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                selectedDuration = newValue;
              });
            }
          },
          items: List.generate(13, (index) => index * 5)
              .map((int value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(
                      value == 0 ? '5 seconds' : '$value seconds',
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
