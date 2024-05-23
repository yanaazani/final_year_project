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
  late final int plantId;
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
          "http://172.20.10.3:8080/florahub/scheduledWatering/plant/${widget.plantId}"));

      print('Response body: ${response.body}');
      // Check the response status
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData is List<dynamic>) {
          for (var schedule in schedules) {
            print(
                'Start Time: ${schedule.startTime}, Duration: ${schedule.duration}');
          }
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
            ElevatedButton(
              onPressed: add,
              child: Text('Add Schedule'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return Container(
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.transparent,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Constants.primaryColor.withOpacity(.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            height: 100.0,
                            padding: const EdgeInsets.only(left: 10),
                            margin: const EdgeInsets.only(bottom: 10),
                            width: size.width,
                            child: Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      top: 15,
                                      left: 140,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Display schedule details here
                                          Text(
                                            // Changes made here to display schedule startTime and duration
                                            'Time: ${schedule.startTime} - Duration: ${schedule.duration} seconds',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Constants.blackColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
