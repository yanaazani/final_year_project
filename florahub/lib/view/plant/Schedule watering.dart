import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ScheduleWateringPage extends StatefulWidget {
  const ScheduleWateringPage({Key? key});

  @override
  State<ScheduleWateringPage> createState() => _ScheduleWateringPageState();
}

class _ScheduleWateringPageState extends State<ScheduleWateringPage> {
  // Variables to store user inputs
  int selectedHour = 12; // Initialize with a non-conflicting value
  int selectedMinute = 0; // Initialize with a non-conflicting value
  String selectedPeriod = 'AM';
  int selectedDuration = 5; // Default duration

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimePicker(),
            SizedBox(height: 20),
            _buildDurationSelector(),
            SizedBox(height: 20),
            _buildSubmitButton(),
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        // Handle form submission here
        _submitSchedule();
      },
      child: Text('Submit Schedule'),
    );
  }

  void _submitSchedule() async {
    // Send HTTP request to submit schedule
    final response = await http.post(
      Uri.parse('http://172.20.10.7:5000/?action=schedule'),
      body: {
        'hour': selectedHour.toString(),
        'minute': selectedMinute.toString(),
        'period': selectedPeriod,
        'duration': selectedDuration.toString(),
      },
    );

    // Handle response
    if (response.statusCode == 200) {
      print('Schedule submitted successfully');
      // Navigate to next screen or show success message
    } else {
      print('Failed to submit schedule');
      // Show error message
    }
  }
}
