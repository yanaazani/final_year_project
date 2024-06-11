import 'dart:typed_data';
import 'package:florahub/view/profile/feedback.dart';
import 'package:florahub/view/user/change_password.dart';
import 'package:florahub/view/user/sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:florahub/view/Homescreen.dart';
import 'package:florahub/view/user%20plant/plants.dart';
import 'package:florahub/view/profile/privacy_page.dart';
import 'package:florahub/view/user/edit%20profile.dart';
import 'package:florahub/widgets/constants.dart';
import 'package:florahub/widgets/navigation%20bar.dart';
import 'package:flutter/material.dart';
import 'package:florahub/controller/RequestController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final int userId;
  SettingsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState(userId: userId);
}

class _SettingsPageState extends State<SettingsPage> {
  _SettingsPageState({required this.userId});
  late String username = "";
  late final int userId;
  bool isDarkModeEnabled = false;
  int _selectedIndex = 0;

  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "user/details/${widget.userId}", server: "http://$server:8080");

    await req.get();
    print(req.result());

    if (req.status() == 200) {
      var data = req.result();

      setState(() {
        username = data["username"];
        fetchProfileImage(widget.userId);
      });
      print(username);
    }
  }

  String imageUrl = "assets/images/pinktree.png";
  Uint8List? _images; // Default image URL
  Future<void> fetchProfileImage(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(Uri.parse(
        'http://$server:8080/florahub/image/getProfileImage/${widget.userId}'));

    if (response.statusCode == 200) {
      setState(() {
        _images = response.bodyBytes;
      });
    } else {
      // Handle errors, e.g., display a default image
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getUser(); // Call getUser() method when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: Container(
          padding: const EdgeInsets.only(left: 20, top: 0, right: 20),
          child: ListView(
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 33,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Account',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.transparent,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Constants.primaryColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  height: 130.0,
                  padding: const EdgeInsets.only(left: 5, top: 15),
                  margin: const EdgeInsets.only(bottom: 10, top: 5),
                  width: size.width,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            border: Border.all(width: 4, color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.1)),
                            ],
                            shape: BoxShape.circle,
                            image: _images != null
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: MemoryImage(_images!))
                                : DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(imageUrl))),
                      ),
                      Positioned(
                        bottom: 5,
                        top: 10,
                        left: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$username",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditUserProfile(
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Constants.blackColor,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.edit,
                                    color: Constants.blackColor,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text('Change Password'),
                trailing: Icon(Icons.lock),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChangePassword(userId: userId)),
                  );
                },
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'General',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
              ListTile(
                title: Text('Help and Support'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to language settings
                },
              ),
              ListTile(
                title: Text('Privacy and Policy'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrivacyPage()),
                  );
                },
              ),
              /*ListTile(
                title: Text('Language'),
                trailing: Text(
                  'English',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Constants.blackColor,
                  ),
                ),
                onTap: () {
                  // Navigate to language settings
                },
              ),*/
              ListTile(
                title: Text('Feedback'),
                trailing: Icon(Icons.feedback_outlined),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FeedbackPage(userId: userId)),
                  );
                },
              ),
              ListTile(
                title: Text('Log Out '),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
          )),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 54, 51, 51),
        unselectedItemColor: Color.fromARGB(255, 165, 173, 165),
        backgroundColor: Color.fromARGB(255, 200, 230, 201),
        selectedFontSize: 14,
        unselectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index; // Update the selected index
          });
          // Handle navigation logic based on the selected index
          switch (index) {
            case 0:
              // Navigate to HomeScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(userId: userId)),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlantsPage(
                          userId: userId,
                        )),
              );
              break;
            case 2:
              break;
          }
        },
        onTap: null,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Plants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class NewScreen extends StatefulWidget {
  const NewScreen({Key? key}) : super(key: key);

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  TextEditingController textEditingController = TextEditingController();

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('New Screen'),
      ),
      body: Center(child: Text('This is your new screen')),
    );
  }
}
