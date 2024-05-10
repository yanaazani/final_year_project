import 'dart:convert';
import 'package:florahub/view/plant/Manual%20watering.dart';
import 'package:http/http.dart' as http;
import 'package:florahub/model/plant.dart';
import 'package:florahub/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        'http://172.20.10.3:8080/florahub/plant/detail/$userId/$plantId'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return Plant.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load plant detail');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futurePlant = fetchPlantDetail(widget.userId, widget.plantId);
    print('User ID: $userId');
    print('Plant ID: $plantId');
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
                              // Handle edit action
                              debugPrint('Edit');
                            } else if (value == 'Delete') {
                              // Handle delete action
                              debugPrint('Delete');
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
                                130, // Center horizontally
                            child: SizedBox(
                              height: 200,
                              child: Image.asset("assets/images/kids.png"),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 0,
                            child: SizedBox(
                              height: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  //Text('Size'),
                                  /*PlantFeature(
                            title: 'Humidity',
                            plantFeature:
                                _plantList[widget.plantId].humidity.toString(),
                          ),
                          PlantFeature(
                            title: 'Temperature',
                            plantFeature:
                                _plantList[widget.plantId].temperature,
                          ),*/
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
                          const EdgeInsets.only(top: 40, left: 30, right: 30),
                      height: size.height * .6,
                      width: size.width,
                      decoration: BoxDecoration(
                        color: //Constants.primaryColor.withOpacity(.4),
                            const Color.fromARGB(255, 201, 228, 202),
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
                              Row(
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
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to the web page for manual watering
                                    // Replace 'WebViewPage' with your actual web page view page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ManualWateringPage()),
                                    );
                                  },
                                  child: Text('Manual Watering'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Add functionality for auto watering
                                    // This could involve activating the soil moisture sensor
                                    // or triggering an API call to start auto watering
                                  },
                                  child: Text('Auto Watering'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Implement functionality for manual schedule watering
                                    // This might involve showing a dialog for the user to input their schedule
                                    // and then storing this schedule in the database or triggering an action based on it
                                  },
                                  child: Text('Schedule Watering'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 320, // Set the desired width
                            child: OutlinedButton(
                              onPressed: () {
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
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                      color: const Color
                                                          .fromARGB(
                                                          255,
                                                          68,
                                                          104,
                                                          69) // Change color to green
                                                      ),
                                                ),
                                                onPressed: () {},
                                                child: Text(
                                                  "Explore Trends",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 40),
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
                                            onPressed: () {},
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
              debugPrint('Edit');
              // Add code to handle edit action
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
