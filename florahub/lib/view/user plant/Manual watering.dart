import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ManualWateringPage extends StatefulWidget {
  const ManualWateringPage({Key? key});

  @override
  State<ManualWateringPage> createState() => _ManualWateringPageState();
}

class _ManualWateringPageState extends State<ManualWateringPage> {
  Color activateButtonColor = Color.fromARGB(255, 129, 178, 130);
  Color deactivateButtonColor = Color.fromARGB(255, 209, 59, 48);

  void sendManualWateringOnPump() async {
    try {
      var url = 'http://172.20.10.7:5020/?action=start';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Manual watering activate sent successfully');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          title: "Activate successfully",
          desc: "Your plant is currently showering now!",
        ).show();
        setState(() {
          activateButtonColor =
              Color.fromARGB(255, 129, 178, 130); // Change color when tapped
          deactivateButtonColor = const Color.fromARGB(
              255, 194, 216, 195); // Reset deactivate button color
        });
      } else {
        print('Failed to activate manual watering request');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          title: "Activate failed",
          desc: "Failed to activate Auto watering request. \nPlease try again.",
        ).show();
      }
    } catch (e) {
      print('Error activate manual watering request: $e');
    }
  }

  void deactivateManualWateringOnPump() async {
    try {
      var url = 'http://172.20.10.7:5020/?action=stop';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Manual watering deactivate sent successfully');
         AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.topSlide,
            showCloseIcon: true,
            title: "Deactivate successfully",
            desc:
                "Your plant has stop showering now!",
            ).show();
        setState(() {
          deactivateButtonColor =
              Color.fromARGB(255, 209, 59, 48); // Change color when tapped
          activateButtonColor = const Color.fromARGB(
              255, 194, 216, 195); // Reset activate button color
        });
      } else {
        print('Failed to deactivate manual watering request');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          title: "Deactivate failed",
          desc: "Failed to deactivate manual watering request. \nPlease try again.",
        ).show();
      }
    } catch (e) {
      print('Error deactivate manual watering request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manual Watering',
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
                sendManualWateringOnPump();
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
                    'Activate Pump',
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
                deactivateManualWateringOnPump();
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
                    'Deactivate Pump',
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
