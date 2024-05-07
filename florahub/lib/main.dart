//import 'package:firebase_core/firebase_core.dart';
import 'package:florahub/splashscreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void initState() {
    super.initState();

    // Remove this method to stop OneSignal Debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("9f87fbb2-2689-4a31-bd92-87b3038f433b");

    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt.
    // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.requestPermission(true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FloraHub',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
      ),
      home: const HomePage(
        userId: null,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: null,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50, width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Lottie.asset('assets/Lottie/Animation - 1713933021164.json'),
            ),
            Text(
              'Welcome to',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'FloraHub',
              textAlign: TextAlign.center,
              style: GoogleFonts.dancingScript(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 14, 149, 18)),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyWidget()),
                );
              },
              icon: Icon(
                Icons.arrow_right_alt_outlined,
                size: 30,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
