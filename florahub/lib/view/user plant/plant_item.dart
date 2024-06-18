import 'dart:convert';
import 'dart:typed_data';
import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/view/dashboard/water%20data%20volume.dart';
import 'package:florahub/view/user%20plant/Auto%20watering.dart';
import 'package:florahub/view/user%20plant/Edit%20plant.dart';
import 'package:florahub/view/user%20plant/Manual%20watering.dart';
import 'package:florahub/view/user%20plant/Schedule%20watering.dart';
import 'package:http/http.dart' as http;
import 'package:florahub/model/plant.dart';
import 'package:florahub/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PlantItem extends StatefulWidget {
  final int userId, plantId;
  PlantItem({super.key, required this.userId, required this.plantId});

  @override
  State<PlantItem> createState() =>
      _PlantItemState(userId: userId, plantId: plantId);
}

class _PlantItemState extends State<PlantItem> {
  _PlantItemState({required this.userId, required this.plantId});
  bool isScheduleTimeEnabled = false;
  late Future<Plant> futurePlant;
  late final int userId, plantId;
  late String name, description, type, scheduleTime;
  late Plant plant;

  Future<Plant> fetchPlantDetail(int userId, int plantId) async {
    final response = await http.get(Uri.parse(
        'http://10.131.79.60:8080/florahub/user_plant/detail/$userId/$plantId'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      setState(() {
        fetchProfileImage(widget.plantId);
      });
      return Plant.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load plant detail');
    }
  }

  String imageUrl = "assets/images/kids.png";
  Uint8List? _images; // Default image URL
  Future<void> fetchProfileImage(int userId) async {
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

  // Function to soft delete the plant
  void softDeletePlant(int plantId, Function(bool) callback) async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "user_plant/deletePlant/$plantId", server: "http://$server:8080");
    // Send the request to the server
    await req.put();

    if (req.status() == 200) {
      // Plant soft deleted successfully
      print('Plant soft deleted successfully');
      callback(true); // Invoke the callback with true
    } else {
      // Failed to soft delete plant
      print('Failed to soft delete plant');
      callback(false); // Invoke the callback with false
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futurePlant = fetchPlantDetail(widget.userId, widget.plantId);
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: FutureBuilder(
            future: futurePlant,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData) {
                return Center(
                  child: Text('No data available'),
                );
              } else {
                // Plant details fetched successfully, display them
                plant = snapshot.data as Plant;
              }
              return Stack(
                children: [
                  Positioned(
                    top: 50,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Constants.primaryColor.withOpacity(.15),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Constants.primaryColor,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (String value) {
                            // Handle the selected option
                            if (value == 'Edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditPlantPage(
                                          plantId: plantId,
                                          userId: userId,
                                        )),
                              );
                            } else if (value == 'Delete') {
                              showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                      backgroundColor: Colors.green[50],
                                      contentPadding: EdgeInsets.zero,
                                      content: SizedBox(
                                          width: double.infinity,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Center(
                                                  child: Text(
                                                    'Are you sure you want to\n delete this plant?',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 150,
                                                  child: OutlinedButton(
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      side: BorderSide(
                                                          color: const Color
                                                              .fromARGB(
                                                              255,
                                                              68,
                                                              104,
                                                              69) // Change color to green
                                                          ),
                                                    ),
                                                    onPressed: () {
                                                      softDeletePlant(plantId,
                                                          (bool success) {
                                                        if (success) {
                                                          // Handle success
                                                          print(
                                                              'Plant soft deleted successfully');
                                                        } else {
                                                          // Handle failure
                                                          print(
                                                              'Failed to soft delete plant');
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      "Yes",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                              ]))));
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'Edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'Delete',
                              child: Text('Delete'),
                            ),
                          ],
                          icon: Icon(Icons.more_vert),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 70,
                    left: 20,
                    right: 20,
                    child: Container(
                      width: size.width * .8,
                      height: size.height * .8,
                      padding: const EdgeInsets.all(20),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 5,
                            left: MediaQuery.of(context).size.width / 2 -
                                200, // Center horizontally
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 0, color: Colors.white),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        color: const Color.fromARGB(
                                                255, 123, 193, 126)
                                            .withOpacity(0.1)),
                                  ],
                                  shape: BoxShape.rectangle,
                                  image: _images != null
                                      ? DecorationImage(
                                          fit: BoxFit.cover,
                                          image: MemoryImage(_images!))
                                      : DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(imageUrl))),
                            ),
                          ),
                          Positioned(
                            top: 270,
                            child: SizedBox(
                              width: 240, // Set the desired width
                              child: OutlinedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: const Color.fromRGBO(
                                          232, 245, 233, 1),
                                      contentPadding: EdgeInsets.zero,
                                      content: SizedBox(
                                        width: double.infinity,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Center(
                                              child: Text(
                                                "Data Overview",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 25,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            /**Image.asset(
                                              "assets/images/report.png",
                                              width:
                                                  150, // Adjust the width as needed
                                              height:
                                                  150, // Adjust the height as needed
                                              // You can adjust other properties like width and height according to your requirements
                                            ),
                                             Center(
                                              child: Text(
                                                "See how your plants are\n doing and improve care.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: SizedBox(
                                                width: 250,
                                                child: OutlinedButton(
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    side: BorderSide(
                                                        color: const Color
                                                            .fromARGB(
                                                            255,
                                                            68,
                                                            104,
                                                            69) // Change color to green
                                                        ),
                                                  ),
                                                  onPressed: () {
                                                    _launchURL(
                                                        'http://172.20.10.3:3000/public-dashboards/b9ce6054116e4d92a3b497a35bb8bea3'); // Replace with your URL
                                                  },
                                                  child: Text(
                                                    "Explore Trends",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ), */
                                            //SizedBox(height: 20),
                                            Image.asset(
                                              "assets/images/analysis.png",
                                              width:
                                                  200, // Adjust the width as needed
                                              height:
                                                  150, // Adjust the height as needed
                                              // You can adjust other properties like width and height according to your requirements
                                            ),
                                            Center(
                                              child: Text(
                                                "Check water reports \nto care for plants better.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        Center(
                                          child: SizedBox(
                                            width: 250,
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: const Color.fromARGB(
                                                      255,
                                                      68,
                                                      104,
                                                      69), // Change color to green
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          WaterDataVolume()),
                                                );
                                              },
                                              child: Text(
                                                "View Reports",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: const Color(0xff296e48),
                                  ),
                                ),
                                child: Text(
                                  "Data Overview",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 0,
                            child: SizedBox(
                              height: 300,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Manual'),
                                  Text('Watering'),
                                  FloatingActionButton(
                                    backgroundColor:
                                        Color.fromARGB(187, 201, 228, 202),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ManualWateringPage()),
                                      );
                                    },
                                    mini: true,
                                    child: const Icon(Icons.water_drop,
                                        color: Colors.white, size: 25),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text('Auto'),
                                  Text('Watering'),
                                  FloatingActionButton(
                                    backgroundColor:
                                        Color.fromARGB(187, 201, 228, 202),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AutoWateringPage()),
                                      );
                                    },
                                    mini: true,
                                    child: const Icon(Icons.auto_awesome,
                                        color: Colors.white, size: 25),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text('Schedule'),
                                  Text('Watering'),
                                  FloatingActionButton(
                                    backgroundColor:
                                        Color.fromARGB(187, 201, 228, 202),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ScheduleWateringPage(
                                                    plantId: plantId)),
                                      );
                                    },
                                    mini: true,
                                    child: const Icon(Icons.schedule,
                                        color: Colors.white, size: 30),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding:
                          const EdgeInsets.only(top: 30, left: 30, right: 30),
                      height: size.height * .48,
                      width: size.width,
                      decoration: BoxDecoration(
                        color: //Constants.primaryColor.withOpacity(.4),
                            Color.fromARGB(187, 201, 228, 202),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(30),
                          topLeft: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${plant.name}',
                                    style: TextStyle(
                                      color: Constants.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30.0,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Type: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color:
                                          Constants.blackColor.withOpacity(.7),
                                    ),
                                  ),
                                  Text(
                                    '${plant.type}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          Constants.blackColor.withOpacity(.7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color:
                                          Constants.blackColor.withOpacity(.7),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${plant.description}',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Constants.blackColor
                                            .withOpacity(.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              /*Row(
                                children: [
                                  Text(
                                    'Schedule Time',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color:
                                          Constants.blackColor.withOpacity(.7),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 135)),
                                  Switch(
                                    value: isScheduleTimeEnabled,
                                    onChanged: (bool value) {
                                      setState(() {
                                        isScheduleTimeEnabled = value;
                                      });
                                    },
                                  ),
                                ],
                              ),*/
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }));
  }

  // Function to show the popup menu
  void _showPopupMenu(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          overlay.localToGlobal(Offset.zero),
          overlay.localToGlobal(overlay.size.bottomRight(Offset.zero)),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditPlantPage(
                          plantId: plantId,
                          userId: userId,
                        )),
              );
            },
            child: Text('Edit'),
          ),
        ),
        PopupMenuItem(
          child: GestureDetector(
            onTap: () {
              debugPrint('Delete');
              // Add code to handle delete action
            },
            child: Text('Delete'),
          ),
        ),
      ],
    );
  }
}
