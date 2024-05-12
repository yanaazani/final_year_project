import 'dart:typed_data';

import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/view/plant/plants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class EditPlantPage extends StatefulWidget {
  final int plantId, userId;
  const EditPlantPage({super.key, required this.userId, required this.plantId});

  @override
  State<EditPlantPage> createState() =>
      _EditPlantPageState(plantId: plantId, userId: userId);
}

class _EditPlantPageState extends State<EditPlantPage> {
  final int userId;
  late final int plantId;
  _EditPlantPageState({
    required this.plantId,
    required this.userId,
  });
  String? _selectedType;
  String name = "", description = "", type = "", scheduleTime = "";

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController scheduleTimeController = TextEditingController();

  List<String> predefinedImages = [
    "assets/images/plant-1.png",
    "assets/images/plant-2.png",
    "assets/images/plant-3.png",
    "assets/images/plant-4.png",
    "assets/images/plant-5.png",
    "assets/images/plant-6.png",
    "assets/images/plant-7.png",
    "assets/images/plant-8.png",
    "assets/images/plant-9.png",
    "assets/images/plant-10.png",
    "assets/images/plant-11.png",
    "assets/images/plant-12.png",
    "assets/images/plant-13.png",
    "assets/images/plant-14.png",
    "assets/images/plant-15.png",
    "assets/images/plant-16.png",
    "assets/images/plant-17.png",
    "assets/images/plant-18.png",
    "assets/images/plant-19.png",
    "assets/images/plant-20.png",
    // Add more predefined images here
  ];

  Future<void> getPlant() async {
    WebRequestController req =
        WebRequestController(path: "plant/detailPlant/${widget.plantId}");

    await req.get();
    print(req.result());

    if (req.status() == 200) {
      var data = req.result();
      setState(() {
        name = data["name"];
        type = data["type"];
        description = data["description"] ?? "";
        scheduleTime = data["scheduleTime"] ?? "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPlant(); // Call getUser() method when the widget is initialized
  }

  Future<void> updatePlant() async {
    // Create a map to hold the fields to be updated
    Map<String, dynamic> requestBody = {};

    // Add fields to the request body if they are not empty
    if (nameController.text.isNotEmpty) {
      requestBody["name"] = nameController.text;
    }

    if (typeController.text.isNotEmpty) {
      requestBody["type"] = typeController.text;
    }

    if (descriptionController.text.isNotEmpty) {
      requestBody["description"] = descriptionController.text;
    }

    if (scheduleTimeController.text.isNotEmpty) {
      requestBody["scheduleTime"] = scheduleTimeController.text;
    }

    WebRequestController req =
        WebRequestController(path: "plant/editPlant/${widget.plantId}");

    req.setBody(requestBody);
    await req.put();

    print(req.result());

    // Check the status of the response
    if (req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Update successfully',
        backgroundColor: Colors.white,
        textColor: const Color.fromARGB(255, 3, 1, 1),
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
      // Navigate to the settings page after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PlantsPage(userId: userId)),
        );
      });
    } else {
      // Display an error toast if the update fails
      Fluttertoast.showToast(
        msg: 'Update failed!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
  }

  ImagePicker picker = ImagePicker();

  Future<void> _showImagePickerDialog() async {
    String? selectedImagePath = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              children: predefinedImages
                  .map(
                    (imagePath) => GestureDetector(
                      onTap: () {
                        Navigator.pop(context, imagePath);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: AssetImage(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );

    if (selectedImagePath != null) {
      // Update the selected image path
      setState(() {
        imageUrl = selectedImagePath;
      });
    }
  }

  String imageUrl = "assets/images/kids.png";
  late Uint8List? _images = Uint8List(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Padding(padding: EdgeInsets.only(left: 20, top: 20)),
                  Text(
                    'Edit Plant Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 33,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 70),
                    child: Container(
                      width: 250,
                      height: 300,
                      decoration: BoxDecoration(
                        image: _images != null
                            ? DecorationImage(
                                fit: BoxFit.cover, image: AssetImage(imageUrl))
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(imageUrl),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.rectangle,
                  border: Border.all(width: 2, color: Colors.white),
                  color: Color.fromARGB(192, 190, 226, 193),
                ),
                child: TextButton(
                  // Changed from IconButton to TextButton
                  onPressed: _showImagePickerDialog,
                  child: Text(
                    "Change Photo", // Added text for the button
                    style: TextStyle(
                        color: Colors.black), // Adjust text style as needed
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 20, right: 20, bottom: 5),
                child: SizedBox(
                  width: double.infinity, // Match the width of the container
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.grass_outlined),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color.fromARGB(255, 111, 169, 113),
                          ),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        filled: true,
                        fillColor: Colors.white70,
                        hintText: "$name"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 20, right: 20, bottom: 5),
                child: SizedBox(
                  width: double.infinity, // Match the width of the container
                  child: TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 2,
                            color: Color.fromARGB(255, 111, 169, 113),
                          ),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        filled: true,
                        fillColor: Colors.white70,
                        hintText: "$description"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, left: 20, right: 20, bottom: 5),
                child: SizedBox(
                  width: double.infinity, // Match the width of the container
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.category),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '$type',
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
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(45),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          //color: Colors.green[600]!,
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
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel",
                          style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 2,
                              color: Colors.black)),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          side: BorderSide(
                              color: const Color.fromARGB(255, 126, 191, 128)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                    ElevatedButton(
                      onPressed: updatePlant,
                      child: const Text("Save",
                          style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 2,
                              color: Colors.black)),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
