import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/view/user/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterForm extends StatefulWidget {
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _password = true;
  void togglePassword1() {
    setState(() {
      _password = !_password;
    });
  }

  void togglePassword2() {
    setState(() {
      _password = !_password;
    });
  }

  TextEditingController usernameCotroller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future signup() async {
    //password match
    if (passwordController.text == confirmPasswordController.text) {
      /**
       * save the data registered to database
       */
      WebRequestController req = WebRequestController(path: "user/signup");

      req.setBody({
        "email": emailController.text,
        "password": passwordController.text,
        "username": usernameCotroller.text,
      });

      await req.post();

      print(req.result());

      if (req.result() != null) {
        ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "SIGN UP SUCCESSFUL",
              text: "You may proceed to go to Login page now!",
              onConfirm: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Your email has been registered.\n Try using a different email.",
          backgroundColor: Colors.white,
          textColor: Colors.black,
          toastLength: Toast.LENGTH_LONG,
          fontSize: 16.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Password do not match",
        backgroundColor: Colors.white,
        textColor: Colors.black,
        toastLength: Toast.LENGTH_LONG,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Container(
        height: 500,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green[100],
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 80, left: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/signup.png",
                  width: 250, // Set the width of the image
                  height: 200, // Set the height of the image
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Get started and explore!',
                  style: GoogleFonts.lora(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                  ),
                ),
              ),
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
            height: 450,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(10),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, left: 20, right: 20, bottom: 5),
                  child: TextField(
                    controller: usernameCotroller,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white70,
                        hintText: "Username"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, left: 20, right: 20, bottom: 5),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: const Icon(Icons.email_sharp),
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
                            onPressed: togglePassword1,
                            icon: Icon(_password
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          hintText: "Password"),
                      // Hide text when _password is false
                      obscureText: !_password),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, left: 20, right: 20, bottom: 5),
                  child: TextField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            onPressed: togglePassword2,
                            icon: Icon(_password
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          hintText: "Confirm Password"),
                      // Hide text when _password is false
                      obscureText: !_password),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
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
                    signup();
                  },
                  child: const Text('Sign Up'),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
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
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]));
  }
}
