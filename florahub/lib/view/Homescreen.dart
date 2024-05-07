import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/model/plants.dart';
import 'package:florahub/view/profile/detail_page.dart';
import 'package:florahub/view/notification.dart';
import 'package:florahub/view/plant/plants.dart';
import 'package:florahub/view/profile/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState(userId: userId);
}

class _HomeScreenState extends State<HomeScreen> {
  _HomeScreenState({required this.userId});
  late String username = "";
  late final int userId;
  int _selectedIndex = 0;

  Future<void> getUser() async {
    WebRequestController req =
        WebRequestController(path: "user/details/${widget.userId}");

    await req.get();
    print(req.result());

    if (req.status() == 200) {
      var data = req.result();

      setState(() {
        username = data["username"];
      });
      print(username);
    }
  }

  @override
  void initState() {
    super.initState();
    getUser(); // Call getUser() method when the widget is initialized
  }

  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning.';
    } else if (hour < 18) {
      return 'Good Afternoon.';
    } else {
      return 'Good Evening.';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Future<void> getUser() async {
      WebRequestController req =
          WebRequestController(path: "user/details/${widget.userId}");

      await req.get();
      print(req.result());
      try {
        if (req.status() == 200) {
          var data = req.result();

          setState(() {
            username = data["username"];
          });
          print(username);
        }
      } catch (e) {
        print('Error fetching user : $e');
        // Handle the exception as needed, for example, show an error message to the user
      }
    }

    @override
    void initState() {
      // TODO: implement initState
      super.initState();
      getUser();
    }

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlantsPage(
                    userId: userId,
                  )),
        ); // Navigate to PlantsScreen
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationPage()),
        ); // Navigate to NotificationScreen
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage(userId: userId)),
        ); // Navigate to ProfileScreen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    //Toggle Favorite button
    bool toggleIsFavorated(bool isFavorited) {
      return !isFavorited;
    }

    Size size = MediaQuery.of(context).size;
    List<Plant> _plantList = Plant.plantList;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FloraHub',
          style: GoogleFonts.dancingScript(
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.only(left: 25, bottom: 20, top: 20),
              child: Row(
                children: [
                  Text(
                    'Hey, $username! ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    getGreeting(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Color.fromARGB(255, 84, 128, 61),
                    ),
                  ),
                ],
              )),
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  width: size.width * .9,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.black54.withOpacity(.6),
                      ),
                      const Expanded(
                          child: TextField(
                        showCursor: false,
                        decoration: InputDecoration(
                          hintText: 'Search Plant',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      )),
                      Icon(
                        Icons.mic,
                        color: Colors.black54.withOpacity(.6),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16, bottom: 20, top: 20),
            child: const Text(
              'Popular',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          SizedBox(
            height: size.height * .3,
            child: ListView.builder(
                itemCount: _plantList.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              child: DetailPage(
                                  plantId: _plantList[index].plantId),
                              type: PageTransitionType.bottomToTop));
                    },
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10,
                            right: 20,
                            child: Container(
                              height: 50,
                              width: 50,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    bool isFavorited = toggleIsFavorated(
                                        _plantList[index].isFavorated);
                                    _plantList[index].isFavorated = isFavorited;
                                  });
                                },
                                icon: Icon(
                                  _plantList[index].isFavorated == true
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: const Color.fromARGB(255, 40, 73, 41),
                                ),
                                iconSize: 30,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 50,
                            right: 50,
                            top: 50,
                            bottom: 50,
                            child: Image.asset(_plantList[index].imageURL),
                          ),
                          Positioned(
                            bottom: 15,
                            left: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _plantList[index].category,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 83, 145, 85),
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _plantList[index].plantName,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 41, 94, 43),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }),
          ),
          Container(
            padding: const EdgeInsets.only(left: 16, bottom: 20, top: 20),
            child: const Text(
              'More',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Container(
            width: 360,
            height: 300,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [Text('HELO HELO')],
            ),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          SizedBox(
            height: 10,
          )
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compost_outlined),
            label: 'Plants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_people),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 54, 51, 51),
        unselectedItemColor: Color.fromARGB(255, 165, 173, 165),
        backgroundColor: Color.fromARGB(255, 200, 230, 201),
        onTap: _onItemTapped,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
