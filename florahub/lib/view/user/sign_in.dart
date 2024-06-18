import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:florahub/SystemFeedback.dart';
import 'package:florahub/controller/OneSignalController.dart';
import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/view/Homescreen.dart';
import 'package:florahub/view/user/forgot_password.dart';
import 'package:florahub/view/user/google_sign_in.dart';
import 'package:florahub/view/user/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _password = true;
  bool hasText = false;
  void togglePassword() {
    setState(() {
      _password = !_password;
    });
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /**
   * GOOGLE SIGN IN
   */
  // Step 1
  String googleEmail = "";

  Future login() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req =
        WebRequestController(path: "user/login", server: "http://$server:8080");

    req.setBody({
      'email': emailController.text,
      'password': passwordController.text,
    });

    await req.post();
    print(req.result());

    final userData = req.result();

    if (req.status() == 200) {
      var userId = userData["id"];
      AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          showCloseIcon: true,
          title: "Successful login!",
          desc:
              "Welcome back to FloraHub, we are so excited to welcome you back!",
          btnOkOnPress: () {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(userId: userId)),
              );
            });
          }).show();

      OneSignalController notify = OneSignalController();
      String targetUser = userId.toString();
      notify.sendNotification("Hello", "Welcome back to FloraHub!", targetUser);
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        desc: "Invalid email or password.",
      ).show();
    }
  }

  Future _handleSignIn() async {
    final user = await GoogleLogin.login();
    print("Login with ${user?.email}");

    setState(() {
      googleEmail = user?.email ?? '';
      emailController.text = googleEmail;
    });

    await GoogleLogin.logout();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    "assets/images/signin.png",
                    width: 250, // Set the width of the image
                    height: 250, // Set the height of the image
                    fit: BoxFit.cover,
                  ),
                ),
                Center(
                  child: Text(
                    'Hello, Welcome Back!',
                    style: GoogleFonts.lora(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 360.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
                color: Colors.white,
              ),
              height: 465,
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 30.0, left: 20, right: 20, bottom: 5),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 2,
                              color: Color.fromARGB(255, 111, 169, 113),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.white70,
                          hintText: "Email"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, left: 20, right: 20, bottom: 5),
                    child: TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              onPressed: togglePassword,
                              icon: Icon(_password
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 111, 169, 113),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.white70,
                            hintText: "Password"),
                        // Hide text when _password is false
                        obscureText: !_password),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
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
                      login();
                    },
                    child: const Text('Sign In'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Or Sign In With',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                _handleSignIn();
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.google,
                                size: 30,
                                color: Color.fromARGB(255, 214, 54, 54),
                              )),
                        ],
                      )),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterForm(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SystemFeedback(),
                        ),
                      );
                    },
                    child: Text(
                      'System Feedback',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color.fromARGB(255, 63, 63, 63),
                      ),
                      //style: TextStyle(color: Color(0xff654321), fontSize: 25),
                    ),
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
