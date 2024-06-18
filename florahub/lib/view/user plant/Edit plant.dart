import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/view/user%20plant/plants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "user_plant/detailPlant/${widget.plantId}",
        server: "http://$server:8080");

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

  Future<void> updatePlant() async {
    uploadImage();
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
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "user_plant/editPlant/${widget.plantId}",
        server: "http://$server:8080");

    req.setBody(requestBody);
    await req.put();

    print(req.result());

    // Check the status of the response
    if (req.status() == 200) {
      AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          title: "Update successfully",
          desc: "Your plant information has been updated successfully",
          //btnCancelOnPress: () {},
          btnOkOnPress: () {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlantsPage(userId: userId)),
              );
            });
          }).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: "Update failed!",
        desc: "Please try again later",
      ).show();
    }
  }

  ImagePicker picker = ImagePicker();
  File? _image;

  /// Get from gallery
  _getFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  String imageUrl = "assets/images/kids.png";
  late Uint8List? _images = Uint8List(0);

  Future<void> fetchProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(Uri.parse(
        'http://$server:8080/florahub/plantImage/getProfileImage/${widget.plantId}'));

    if (response.statusCode == 200) {
      setState(() {
        _images = response.bodyBytes;
      });
    } else {
      // Handle errors, e.g., display a default image
      return null;
    }
  }

  // For edit Image
  Future<void> uploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");

    if (_images == null) {
      return;
    }

    final uri = Uri.parse(
        'http://$server:8080/florahub/plantImage/updateImage/${widget.plantId}'); // Replace with your API URL
    final request = http.MultipartRequest('PUT', uri);
    request.fields['plantId'] = '${widget.plantId}'; // Replace with the user ID
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        _image!.path,
      ),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Image is updated successfully',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Image failed to update',
          backgroundColor: Colors.white,
          textColor: Colors.red,
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getPlant();
    fetchProfileImage();
  }

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
                          image: _image == null
                              ? DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(_images!))
                              : _image != null
                                  ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(_image!))
                                  : DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(imageUrl))),
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          "Upload Image",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        content: Text(
                          "Edit your image",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              _getFromCamera();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                "Camera",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _getFromGallery();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                "Gallery",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    "Edit Photo", // Added text for the button
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
