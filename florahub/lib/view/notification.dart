import 'package:florahub/view/Homescreen.dart';
import 'package:florahub/view/plant/plants.dart';
import 'package:florahub/view/profile/settings.dart';
import 'package:florahub/widgets/navigation%20bar.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  final int userId;
  const NotificationPage({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationPageState createState() =>
      _NotificationPageState(userId: userId);
}

class _NotificationPageState extends State<NotificationPage> {
  _NotificationPageState({required this.userId});
  late final int userId;
  int _selectedIndex = 2; // Set the initial index for NotificationPage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            backgroundColor:
                Colors.green[100], // Make scaffold background transparent
            appBar: AppBar(
              title: Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor:
                  Colors.transparent, // Make app bar background transparent
              elevation: 0, // Remove app bar elevation
              automaticallyImplyLeading: false, // Remove back button
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_sharp),
                      title: Text('Notification 1'),
                      subtitle: Text('This is a notification'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_sharp),
                      title: Text('Notification 2'),
                      subtitle: Text('This is a notification'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlantsPage(
                          userId: userId,
                        )),
              );
              break;
            case 2:
              // Navigate to NotificationPage
              break;
            case 3:
              Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage(userId: userId)),
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
