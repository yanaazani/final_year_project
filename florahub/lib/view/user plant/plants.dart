import 'dart:convert';
import 'dart:typed_data';
import 'package:florahub/model/plant.dart';
import 'package:florahub/view/Homescreen.dart';
import 'package:florahub/view/user%20plant/add.dart';
import 'package:florahub/view/user%20plant/plant_item.dart';
import 'package:florahub/view/profile/settings.dart';
import 'package:florahub/widgets/constants.dart';
import 'package:florahub/widgets/navigation%20bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PlantsPage extends StatelessWidget {
  final int userId;
  PlantsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlantsTabBar(userId: userId);
  }
}

class PlantsTabBar extends StatefulWidget {
  final int userId;
  PlantsTabBar({Key? key, required this.userId}) : super(key: key);

  @override
  _PlantsTabBarState createState() => _PlantsTabBarState(userId: userId);
}

class _PlantsTabBarState extends State<PlantsTabBar> {
  _PlantsTabBarState({
    required this.userId,
  });
  late final int userId;
  bool isScheduleTimeEnabled = false;
  late List<Plant> plants = []; // List to store the user's plants
  late int plantId;
  int _selectedIndex = 0;

  Future<void> _refreshData() async {
    //await getChildrenData();
    await fetchPlants();
  }

  Future<void> fetchPlants() async {
    try {
      // Make an HTTP GET request to fetch the user's plants from the backend
      http.Response response = await http.get(Uri.parse(
          "http://172.20.10.3:8080/florahub/user_plant/plantsByUserId/${widget.userId}"));

      print('Response body: ${response.body}');
      // Check the response status
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        if (responseData is List<dynamic>) {
          // If the response data is a list, update the plants list
          setState(() {
            plants = responseData
                .map((json) => Plant.fromJson(json))
                .where((plant) => !plant.deleted) // Filter out deleted plants
                .toList();
          });
        } else {
          // Handle unexpected response format
          print('Unexpected response format: $responseData');
        }
      } else {
        // Handle errors or display an error message
        print('Failed to fetch plants: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error fetching plants: $e');
    }
  }

  String imageUrl = "assets/images/kids.png";
  Uint8List? _images; // Default image URL
  Future<void> fetchProfileImage(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(Uri.parse(
        'http://$server:8080/florahub/plantImage/getProfileImage/${plantId}'));

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
    // TODO: implement initState
    super.initState();
    fetchPlants();
    print('User ID: $userId');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                ),
                Row(
                  children: [
                    Text(
                      'My Plants',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 33,
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 160)),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Constants.primaryColor.withOpacity(.15),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddPlants(
                                      userId: userId,
                                    )), // Navigate to AddPage
                          );
                        },
                        icon: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: plants.length,
                        itemBuilder: (context, index) {
                          final plant = plants[index];
                          return GestureDetector(
                              onTap: () {
                                // Navigate to the PlantItem screen when a plant is tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlantItem(
                                        userId: userId, plantId: plant.id),
                                  ),
                                );
                              },
                              child: Container(
                                child: Column(children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PlantItem(
                                                userId: userId,
                                                plantId: plant.id)),
                                      );
                                    },
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: Colors
                                            .transparent, // Set the background color to green
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Constants.primaryColor
                                              .withOpacity(.1),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        height: 150.0,
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        width: size.width,
                                        child: Row(
                                          children: [
                                            Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Container(
                                                  width: 100.0,
                                                  height: 120.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[100],
                                                    shape: BoxShape.rectangle,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 10,
                                                  left: 10,
                                                  child: SizedBox(
                                                    height: 110.0,
                                                    child: Image.asset(
                                                        "assets/images/kids.png"),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 15,
                                                  left: 140,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        plant.name,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          color: Constants
                                                              .blackColor,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Text(
                                                          "Type: ${plant.type}"),
                                                      const SizedBox(
                                                          height: 10),
                                                      SizedBox(
                                                        width:
                                                            150, // Set your desired width here
                                                        child: OutlinedButton(
                                                          onPressed: () {},
                                                          child: Text(
                                                            "More",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          style: OutlinedButton
                                                              .styleFrom(
                                                            side: BorderSide(
                                                              color: const Color(
                                                                  0xff296e48),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                /*Positioned(
                              left: 280,
                              child: IconButton(
                                icon:
                                    Icon(Icons.more_vert), // Use the menu icon
                                onPressed: () {
                                  // Handle tap on the menu icon
                                },
                              ),
                            )*/
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                              ));
                        })),
              ],
            )),
      ),
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
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage(userId: userId)),
              );
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
