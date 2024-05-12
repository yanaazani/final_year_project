import 'dart:typed_data';
import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/view/profile/settings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditUserProfile extends StatefulWidget {
  final int userId;
  const EditUserProfile({Key? key, required this.userId}) : super(key: key);

  @override
  State<EditUserProfile> createState() => _EditUserProfileState(userId: userId);
}

class _EditUserProfileState extends State<EditUserProfile> {
  _EditUserProfileState({required this.userId});
  late final int userId;
  bool showLogoutText = false;
  bool isObsecurePassword = true;
  String username = "", email = "", password = "", country = "", state = "";
  String? _selectedCountry;
  String? _selectedState;

  late TextEditingController emailController = TextEditingController();
  late TextEditingController usernameController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();

  Future<void> getUser() async {
    WebRequestController req =
        WebRequestController(path: "user/details/${widget.userId}");

    await req.get();
    print(req.result());

    if (req.status() == 200) {
      var data = req.result();
      setState(() {
        username = data["username"];
        email = data["email"];
        country = data["country"] ?? "";
        state = data["state"] ?? "";
      });
    }
  }

  Future<void> updateUser() async {
    // Create a map to hold the fields to be updated
    Map<String, dynamic> requestBody = {};

    // Add fields to the request body if they are not empty
    if (usernameController.text.isNotEmpty) {
      requestBody["username"] = usernameController.text;
    }

    if (emailController.text.isNotEmpty) {
      requestBody["email"] = emailController.text;
    }

    if (_selectedCountry != null) {
      requestBody["country"] = _selectedCountry!;
    }

    if (_selectedState != null) {
      requestBody["state"] = _selectedState!;
    }

    WebRequestController req =
        WebRequestController(path: "user/edit/${widget.userId}");

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
          MaterialPageRoute(builder: (context) => SettingsPage(userId: userId)),
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

  /// Get from gallery
  _getFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {});
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {});
    }
  }

  String imageUrl = "assets/images/pinktree.png";
  late Uint8List? _images = Uint8List(0);

  @override
  void initState() {
    super.initState();
    getUser(); // Call getUser() method when the widget is initialized
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
                  Padding(padding: EdgeInsets.only(left: 20)),
                  Text(
                    'Account',
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
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 65),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(width: 4, color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                        shape: BoxShape.circle,
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
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.rectangle,
                  border: Border.all(width: 2, color: Colors.white),
                  color: Color.fromARGB(255, 190, 226, 193),
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
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Text(
                      'Username',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color.fromARGB(255, 198, 197, 197),
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // Adjust the width as needed
                  Expanded(
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 111, 169, 113),
                          ),
                        ),
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "$username",
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color.fromARGB(255, 198, 197, 197),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  ), // Adjust the width as needed
                  Expanded(
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 111, 169, 113),
                          ),
                        ),
                        prefixIcon: Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "$email",
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCountry = newValue;
                          // Reset selected state when country changes
                          _selectedState = null;
                        });
                      },
                      items: <String>[
                        'Philippines',
                        'Vietnam',
                        'Malaysia',
                        'Indonesia',
                        'Thailand'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.white70,
                      ),
                    ),
                  ),
                  // Conditional rendering of dropdown menu for state selection
                  if (_selectedCountry == 'Malaysia') ...[
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: DropdownButtonFormField<String>(
                        value: _selectedState,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedState = newValue;
                          });
                        },
                        items: <String>[
                          'Kedah',
                          'Melaka',
                          'Johor',
                          '...',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'State',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(
                height: 20,
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
                      onPressed: () {
                        updateUser();
                      },
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
