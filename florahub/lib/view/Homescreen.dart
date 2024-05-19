import 'dart:convert';

import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/model/plants.dart';
import 'package:florahub/view/user%20plant/search%20results%20page.dart';
import 'package:florahub/view/profile/detail_page.dart';
import 'package:florahub/view/notification.dart';
import 'package:florahub/view/user%20plant/plants.dart';
import 'package:florahub/view/profile/settings.dart';
import 'package:florahub/widgets/constants.dart';
import 'package:florahub/widgets/navigation%20bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

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
          MaterialPageRoute(
              builder: (context) => NotificationPage(
                    userId: userId,
                  )),
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

  Future<void> _searchPlants(String query) async {
    String familyName = '';
    String apiKey = 'Hl2OFlaosCC37C5TME9BwXJUwif-pIP1JrilOwlwiFU';
    String url =
        'https://trefle.io/api/v1/plants/search?token=$apiKey&q=$query';

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data['data']);
          print(_searchResults);
        });

        // Extract family name from the first result
        if (_searchResults.isNotEmpty) {
          var firstResult = _searchResults.first;
          String resultFamilyName =
              firstResult['family_common_name'] ?? firstResult['family'];
          if (resultFamilyName != null && resultFamilyName.isNotEmpty) {
            familyName = resultFamilyName;
          }
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsPage(
              searchResults: _searchResults,
              familyName: familyName,
            ),
          ),
        );
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error
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
      drawer: Drawer(
        // <-- Add this Drawer widget
        // Define your drawer contents here
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Handle the tap
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Handle the tap
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
            width: 500.0,
            height: 2820.0,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                          Expanded(
                              child: TextField(
                            controller: _searchController,
                            showCursor: true,
                            decoration: InputDecoration(
                              hintText: 'Search Plant',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            onChanged: (value) {
                              _searchPlants(value);
                            },
                          )),
                          Icon(
                            Icons.search,
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
                                        _plantList[index].isFavorated =
                                            isFavorited;
                                      });
                                    },
                                    icon: Icon(
                                      _plantList[index].isFavorated == true
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          const Color.fromARGB(255, 40, 73, 41),
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
              // _snippets1()
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _snippets1()),
                  );
                },
                child: Container(
                  width: 360,
                  height: 550,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Text(
                              '6 Awesome Health Benefits to Gain from Gardening',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                                color: Constants.primaryColor,
                              ),
                            ),
                            Text(
                              'Gardening has become a popular home activity because it '
                              'offers numerous health benefits for all ages. Beyond providing...',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Constants.blackColor,
                              ),
                            ),
                            Image.asset(
                                'assets/images/gardening-health-benefits.png'),
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
              ),
              SizedBox(
                height: 10,
              ),
              // _snippets2()
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _snippets2()),
                  );
                },
                child: Container(
                  width: 360,
                  height: 400,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Text(
                              'Things You Should Do This Month',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                                color: Constants.primaryColor,
                              ),
                            ),
                            Text(
                              "Stay ahead of important May gardening tasks before summer"
                              " makes it too uncomfortable to work outside. Read this guide to get started....",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Constants.blackColor,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Image.network(
                              'https://cdn.shopify.com/s/files/1/1090/6620/files/may-garden-chores.jpg?v=1621887415',
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
              ),
              SizedBox(
                height: 10,
              ),
              // _snippets3
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _snippets3()),
                  );
                },
                child: Container(
                  width: 360,
                  height: 370,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Text(
                              'Ready To Make A Garden Shed?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                                color: Constants.primaryColor,
                              ),
                            ),
                            Text(
                              'You can build an amazing shed in a weekend if '
                              'you have a plan, a materials list, and step-by-step instructions!...',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Constants.blackColor,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Image.network(
                              'https://cdn.shopify.com/s/files/1/1090/6620/files/plans-for-garden-sheds.png?v=1580131904',
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
              ),
              SizedBox(
                height: 10,
              ),
              // _snippets4()
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _snippets4()),
                  );
                },
                child: Container(
                  width: 360,
                  height: 430,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Text(
                              '10 TOP GARDENING TIPS FOR BEGINNERS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                                color: Constants.primaryColor,
                              ),
                            ),
                            Text(
                              'Wondering how to start a garden?\n'
                              'Never gardened before? No problem. Make your '
                              'grow-you-own dreams a reality with these 10 easy-to-follow tips.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Constants.blackColor,
                              ),
                            ),
                            Image.network(
                              'https://smg.widen.net/content/splntrbgj5/webp/10_Top_Gardening_Tips_for_Beginners_1.webp?crop=false&position=c&q=30&u=vedgwv&w=466&retina=false',
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
              ),
              SizedBox(
                height: 10,
              ),
              // _snippets5()
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => _snippets5()),
                  );
                },
                child: Container(
                  width: 360,
                  height: 490,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Text(
                              '10 Houseplants That Will Thrive in Your Kitchen',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                                color: Constants.primaryColor,
                              ),
                            ),
                            Text(
                              'Adding houseplants to the kitchen freshens the space '
                              'and also has practical applications. The right plant can '
                              'help purify the air, add a splash of color, or '
                              'even provide fresh produce year-round....',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Constants.blackColor,
                              ),
                            ),
                            Image.network(
                                'https://www.thespruce.com/thmb/fTjdsfNNLNZWxezPYt-2gzGVFus=/750x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/10-houseplants-that-will-thrive-in-your-kitchen-5079926-hero-02-90673ff3073d41c7aa495e8a4ecffc0f.JPG'),
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
              ),
              SizedBox(
                height: 10,
              )
            ])),
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
          switch (index) {
            case 0:
              // Navigate to HomeScreen
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlantsPage(
                          userId: userId,
                        )),
              );
              break; // No need to navigate, as already on PlantsPage
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationPage(
                          userId: userId,
                        )),
              );
              break;
            case 3:
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
            icon: Icon(Icons.notifications),
            label: 'Notifications',
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

class _snippets1 extends StatelessWidget {
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('6 Awesome Health Benefits to Gain from Gardening'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '6 Awesome Health Benefits to Gain from Gardening',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
                color: Constants.primaryColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Gardening has become a popular home activity because it '
              'offers numerous health benefits for all ages. Beyond providing'
              ' healthy foods, it relieves stress and keeps your mind and body active.\n',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "Here are some key health benefits of gardening:\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "1. Reduces Stress:\n Caring for plants daily helps relieve life's stresses.\n"
              "2. Boosts Immunity:\n Regular exposure to dirt strengthens the immune system.\n"
              "3. Improves Cognitive Function:\n Gardening can enhance cognitive abilities, especially in elders, and reduce the risk of dementia by 36%.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Constants.blackColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Image.asset('assets/images/gardening-health-benefits.png'),
            TextButton(
              onPressed: () {
                _launchURL(
                    'https://thehappygardeninglife.com/blogs/organic-gardening/gardening-health-benefits'); // Replace with your URL
              },
              child: Text(
                'Read more',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _snippets2 extends StatelessWidget {
  Future<void> _launchURL2(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Things You Should Do This Month'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Things You Should Do This Month',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
                color: Constants.primaryColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'May Garden Chores\n',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "Stay ahead of important May gardening tasks before summer makes "
              "it too uncomfortable to work outside. Read this guide to get started.\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "May is one of the most eventful months of the gardening season. "
              "All veggie gardens are getting busier this time of year, whether "
              "in the north or south of the country. ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Constants.blackColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Image.network(
              'https://cdn.shopify.com/s/files/1/1090/6620/files/may-garden-chores.jpg?v=1621887415',
            ),
            TextButton(
              onPressed: () {
                _launchURL2(
                    'https://thehappygardeninglife.com/blogs/things-you-should-do-this-month/may-garden-chores'); // Replace with your URL
              },
              child: Text(
                'Read more',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _snippets3 extends StatelessWidget {
  Future<void> _launchURL3(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ready To Make A Garden Shed?'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Things You Should Do This Month',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
                color: Constants.primaryColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'May Garden Chores\n',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color.fromARGB(215, 0, 0, 0),
              ),
            ),
            Text(
              "Stay ahead of important May gardening tasks before summer makes "
              "it too uncomfortable to work outside. Read this guide to get started.\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Constants.blackColor,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Image.network(
              'https://cdn.shopify.com/s/files/1/1090/6620/files/plans-for-garden-sheds.png?v=1580131904',
            ),
            Text(
              "You can build an amazing shed in a weekend, if you have a plan, a materials list, and step-by-step instructions. In this post we'll share our best suggestion for how to get the shed plan of your dreams. Bottomline, if you want to jump right to it, then just visit...\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "Ready To Make A Garden Shed?\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(215, 0, 0, 0),
              ),
            ),
            Text(
              "Are you looking to build a shed at home but don’t know what goes"
              " into it or how to do the work? In this article we'll share the"
              " Internet's largest and best source of professional shed plans... ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Constants.blackColor,
              ),
            ),
            Image.network(
              'https://cdn.shopify.com/s/files/1/1090/6620/files/plans-for-garden-sheds-1.png?v=1580413606',
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Ryan Henderson - The Professional Behind My Shed Plans!\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(215, 0, 0, 0),
              ),
            ),
            Text(
              "Ryan Henderson, a professional craftsman and educator - "
              "and he's the go-to guy for shed plans. He's put together 12,000 "
              "shed plans with different styles and designs. You don’t need to "
              "have woodworking experience to use the plans; they are detailed "
              "enough and come with “hold-you-by-the-hand” step by step instructions.... ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Constants.blackColor,
              ),
            ),
            Image.network(
              'https://cdn.shopify.com/s/files/1/1090/6620/files/plans-for-garden-sheds-2.png?v=1580413597',
            ),
            TextButton(
              onPressed: () {
                _launchURL3(
                    'https://thehappygardeninglife.com/blogs/garden-shed-plans/plans-for-garden-sheds'); // Replace with your URL
              },
              child: Text(
                'Read more',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _snippets4 extends StatelessWidget {
  Future<void> _launchURL4(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('10 TOP GARDENING TIPS FOR BEGINNERS'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '10 TOP GARDENING TIPS FOR BEGINNERS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
                color: Constants.primaryColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Never gardened before? No problem. Make your grow-you-own dreams a reality with these 10 easy-to-follow tips.\n',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "1. Site it right.\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "Starting a garden is just like real estate it's all about location. "
              "Place your garden in a part of your yard where you'll see it "
              "regularly (out of sight, out of mind definitely applies to gardening). "
              "That way, you'll be much more likely to spend time in it.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Constants.blackColor,
              ),
            ),
            Image.network(
              'https://smg.widen.net/content/5z4bry3w0v/webp/10_Top_Gardening_Tips_for_Beginners_2.webp?crop=false&position=c&q=30&u=vedgwv&w=1080&retina=false',
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "2. Follow the sun.\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "Misjudging sunlight is a common pitfall when you're first learning "
              "to garden. Pay attention to how sunlight plays through your yard "
              "before choosing a spot for your garden. Most edible plants, including"
              " many vegetables, herbs, and fruits, need at least 6 hours of sun in order to thrive.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Constants.blackColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "3. Stay close to water.\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "One of the best gardening tips you'll ever get is to plan your"
              "new garden near a water source. Make sure you can run a hose to "
              "your garden site, so you don't have to lug water to it each time "
              "your plants get thirsty. The best way to tell if plants need watering "
              "is to push a finger an inch down into the soil (that's about one knuckle deep)."
              " If it's dry, it's time to water.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Constants.blackColor,
              ),
            ),
            Image.network(
              'https://smg.widen.net/content/apx9yv1qdi/webp/10_Top_Gardening_Tips_for_Beginners_3.webp?crop=false&position=c&q=30&u=vedgwv&w=1080&retina=false',
            ),
            SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                _launchURL4(
                    'https://miraclegro.com/en-us/gardening-101/10-top-gardening-tips-for-beginners.html'); // Replace with your URL
              },
              child: Text(
                'Read more',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _snippets5 extends StatelessWidget {
  Future<void> _launchURL5(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('10 Houseplants That Will Thrive in Your Kitchen'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '10 Houseplants That Will Thrive in Your Kitchen',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28.0,
                color: Constants.primaryColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Adding houseplants to the kitchen freshens the space and also'
              ' has practical applications. The right plant can help purify the '
              'air, add a splash of color, or even provide fresh produce year-round.\n',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "1. Pothos\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "Pothos (Epipremnum aureum) are truly some of the easiest "
              "houseplants to care for. They adapt well to a variety of different "
              "light conditions and are considered to be relatively drought-tolerant. ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Constants.blackColor,
              ),
            ),
            Image.network(
              'https://www.thespruce.com/thmb/mgqO6NjHJqRHqn9dRYBQQ1u_WhE=/750x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/DSC_9109-0046249ffa2d4ba68e0962af547ddef9.jpg',
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "2. Philodendron\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Constants.blackColor,
              ),
            ),
            Text(
              "Philodendrons (Philodendron spp.) are another genus of low-maintenance"
              " houseplants that look great in hanging baskets. Similar to pothos, "
              "they are considered relatively drought-tolerant and can grow in "
              "bright to medium indirect light.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Constants.blackColor,
              ),
            ),
            Image.network(
              'https://www.thespruce.com/thmb/1vLjEHeN8y9iHh120tdXmXLLP9g=/750x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/grow-philodendron-houseplants-1902768-04-14ec67b406d742d7a5f5313edd0b622b.jpg',
            ),
            SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                _launchURL5(
                    'https://www.thespruce.com/10-houseplants-that-will-thrive-in-your-kitchen-5079926'); // Replace with your URL
              },
              child: Text(
                'Read more',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
