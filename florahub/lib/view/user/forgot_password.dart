import 'package:flutter/material.dart';
import 'package:florahub/view/Homescreen.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

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
                        'Enter your email address to receive\n a verification link.',
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
                      Align(
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
                      ),
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
                        onPressed: () {},
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
