import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/view/user/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:florahub/view/Homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  Future forgotpassword() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    String email = emailController.text;

    // Include the email as a query parameter in the URL
    WebRequestController req = WebRequestController(
        path: "user/findByEmail?email=$email", server: "http://$server:8080");

    await req.get(); // Use GET request for fetching data
    print(req.result());

    final userData = req.result();

    if (req.status() == 200 && userData != null) {
      // Email exists, proceed to password reset
      var userId = userData["id"];
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: "Email found!",
        desc: "You can now proceed to change your password.",
        btnOkOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                      email: email,
                    )),
          );
        },
      ).show();
    } else if (req.status() == 404) {
      // Email does not exist
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        desc: "The email address you entered does not exist.",
      ).show();
    } else {
      // General error handling
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        desc: "An error occurred. Please try again later.",
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Forgot Password'),
          backgroundColor: Colors.green[100],
        ),
        body: Stack(
          children: [
            Container(
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green[100],
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 50, left: 22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/images/forgotpassword.png",
                        width: 350, // Set the width of the image
                        height: 200, // Set the height of the image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 350.0),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                    color: Colors.white,
                  ),
                  height: 350,
                  width: double.infinity,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20),
                      ),
                      Text(
                        'Enter your email address.',
                        style: TextStyle(
                          fontSize: 20, // Adjust the font size as needed
                          fontWeight: FontWeight
                              .normal, // Use FontWeight.normal for normal weight
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 30, right: 30, bottom: 20),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  width: 2,
                                ),
                              ),
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: Colors.white70,
                              hintText: "Email"),
                        ),
                      ),
                      /*Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HomeScreen(userId: 1)),
                                );
                              },
                              child: Text(
                                ' Try another way ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),*/
                      Padding(
                        padding: EdgeInsets.only(bottom: 15.0),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green[400],
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40.0, vertical: 10),
                          textStyle: const TextStyle(fontSize: 20),
                          side: BorderSide(color: Colors.green[300]!),
                        ),
                        onPressed: () {
                          forgotpassword();
                        },
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
