import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:florahub/controller/RequestController.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPlants extends StatefulWidget {
  final int userId;
  AddPlants({super.key, required this.userId});

  @override
  State<AddPlants> createState() => _AddPlantsState(userId: userId);
}

class _AddPlantsState extends State<AddPlants> {
  _AddPlantsState({required this.userId});
  late final int userId;
  @override
  void initState() {
    super.initState();
    print('User ID add plant: $userId');
  }

  String? _selectedType;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Helper function to convert hours to the format "HH:mm:ss"
  String convertHoursToTimeFormat(String hours) {
    // Parse the number of hours

    int numberOfHours = int.tryParse(hours.split(' ')[0]) ?? 0;

    // Convert hours to a Duration
    Duration duration = Duration(hours: numberOfHours);

    // Format the Duration as "HH:mm:ss"
    String formattedTime = duration.toString().split('.').first.padLeft(8, "0");

    return formattedTime;
  }

  Future add() async {
    /**
       * save the data registered to database
       */
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "user_plant/add", server: "http://$server:8080");

    req.setBody({
      "name": nameController.text,
      "description": descriptionController.text,
      "type": _selectedType,
      "userId": userId.toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Add Plants',
            style: GoogleFonts.roboto(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Column(children: [
          Center(
            child: Lottie.asset(
              "assets/Lottie/Animation - 1714843308738.json",
              width: 330, // Set the width of the image
              height: 250, // Set the height of the image
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Text(
            'Let' 's add your new plant!',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.add_reaction_rounded),
                    // Add prefix icon here
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter your plant\'s nickname',
                    // Add hint text here
                    hintStyle: TextStyle(
                      // Style for the hint text
                      color: Colors.grey, // Adjust color if needed
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20), // Adjust padding as needed
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green[400]!,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(45),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green[600]!,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(45),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.description_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Description',
                    // Add hint text here
                    hintStyle: TextStyle(
                      // Style for the hint text
                      color: Colors.grey,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green[400]!,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(45),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green[600]!,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(45),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.category),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Select your plant\'s type',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(45),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green[400]!,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(45),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green[600]!,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(45),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(45),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(45),
                    ),
                  ),
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  },
                  items: <String>[
                    'Indoor Plants',
                    'Outdoor Plants',
                    'Garden Plants',
                    'Houseplants',
                    'Succulents',
                    'Cacti',
                    'Herbs',
                    'Vegetables',
                    'Fruits',
                    'Flowering Plants',
                    'Shrubs',
                    'Trees',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green[400],
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 10),
                      textStyle: const TextStyle(fontSize: 20),
                      side: BorderSide(color: Colors.green[300]!),
                    ),
                    onPressed: () {
                      add();
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ])));
  }
}
