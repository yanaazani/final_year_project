import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AutoWateringPage extends StatefulWidget {
  const AutoWateringPage({Key? key});

  @override
  State<AutoWateringPage> createState() => _AutoWateringPageState();
}

class _AutoWateringPageState extends State<AutoWateringPage> {
  Color activateButtonColor = Color.fromARGB(255, 129, 178, 130);
  Color deactivateButtonColor = Color.fromARGB(255, 209, 59, 48);

  void activateAuto() async {
    try {
      var url = 'http://172.20.10.7:6001/?action=auto';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Auto watering activate sent successfully');
        setState(() {
          activateButtonColor =
              Color.fromARGB(255, 129, 178, 130); // Change color when tapped
          deactivateButtonColor = const Color.fromARGB(
              255, 194, 216, 195); // Reset deactivate button color
        });
      } else {
        print('Failed to activate Auto watering request');
      }
    } catch (e) {
      print('Error activate Auto watering request: $e');
    }
  }

  void deactive() async {
    try {
      var url = 'http://172.20.10.7:6001/?action=stop_auto';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Auto watering deactivate sent successfully');
        setState(() {
          deactivateButtonColor =
              Color.fromARGB(255, 209, 59, 48); // Change color when tapped
          activateButtonColor = const Color.fromARGB(
              255, 194, 216, 195); // Reset activate button color
        });
      } else {
        print('Failed to deactivate auto watering request');
      }
    } catch (e) {
      print('Error deactivate auto watering request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Auto Watering',
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
          children: [
            SizedBox(height: 100),
            InkWell(
              onTap: () {
                activateAuto();
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black, // Outline border color
                  ),
                  color: activateButtonColor, // Button color
                ),
                child: Center(
                  child: Text(
                    'Activate',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                deactive();
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black, // Outline border color
                  ),
                  color: deactivateButtonColor, // Button color
                ),
                child: Center(
                  child: Text(
                    'Deactivate',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
