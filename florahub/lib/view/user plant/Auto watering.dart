import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:florahub/widgets/constants.dart';
import 'package:lottie/lottie.dart';

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
      var url = 'http://172.20.10.7:5027/?action=auto';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Auto watering activate sent successfully');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          title: "Activate successfully",
          desc: "Auto watering activate sent successfully",
        ).show();
        setState(() {
          activateButtonColor =
              Color.fromARGB(255, 129, 178, 130); // Change color when tapped
          deactivateButtonColor = const Color.fromARGB(
              255, 194, 216, 195); // Reset deactivate button color
        });
      } else {
        print('Failed to activate Auto watering request');
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
      print('Error activate Auto watering request: $e');
    }
  }

  void deactive() async {
    try {
      var url = 'http://172.20.10.7:5027/?action=stop_auto';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Auto watering deactivate sent successfully');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          title: "Deactivate successfully",
          desc: "Auto watering deactivate successfully",
        ).show();
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
      body: SingleChildScrollView(
        // Wrap Column with SingleChildScrollView
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "The automatic watering system is enabled by default, meaning it "
                  "will automatically turn on without any additional setup required.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Constants.blackColor,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Lottie.asset(
                    'assets/Lottie/Animation - 1722311177385.json'),
              ),
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
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "To deactivate the automatic features, click the button below.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Constants.blackColor,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  deactive();
                },
                child: Container(
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
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
      ),
    );
  }
}
