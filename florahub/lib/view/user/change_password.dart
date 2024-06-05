import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/view/profile/settings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  final int userId;
  const ChangePassword({super.key, required this.userId});

  @override
  State<ChangePassword> createState() => _ChangePasswordState(userId: userId);
}

class _ChangePasswordState extends State<ChangePassword> {
  _ChangePasswordState({required this.userId});
  late final int userId;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

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

  Future<void> changePassword() async {
    // Create a map to hold the fields to be updated
    Map<String, dynamic> requestBody = {};

    if (passwordController.text.isNotEmpty) {
      requestBody["password"] = passwordController.text;
    }

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "user/updatePassword/${widget.userId}",
        server: "http://$server:8080");

    req.setBody(requestBody);
    await req.put();

    print(req.result());

    // Check the status of the response
    if (req.status() == 200) {
      Fluttertoast.showToast(
        msg: 'Update successfully',
        backgroundColor: Colors.white,
        textColor: const Color.fromARGB(255, 3, 1, 1),
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
      // Navigate to the settings page after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage(userId: userId)),
        );
      });
    } else {
      // Display an error toast if the update fails
      Fluttertoast.showToast(
        msg: 'Update failed!',
        backgroundColor: Colors.white,
        textColor: Colors.red,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Container(
          padding: const EdgeInsets.only(left: 20, top: 0, right: 20),
          child: Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 33,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/change password.png",
                        width: 700,
                        height: 250,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "New Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, left: 10, right: 10, bottom: 20),
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
                              color: Color.fromARGB(255, 111, 169, 113),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          hintText: "Enter confirm password"),
                      // Hide text when _password is false
                      obscureText: !_password),
                ),
                Row(
                  children: [
                    Text(
                      "Confirm Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10.0, left: 10, right: 10, bottom: 20),
                  child: TextField(
                      controller: confirmPassController,
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
                              color: Color.fromARGB(255, 111, 169, 113),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          hintText: "Enter confirm password"),
                      // Hide text when _password is false
                      obscureText: !_password),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green[400],
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 110.0, vertical: 10),
                    textStyle: const TextStyle(fontSize: 20),
                    side: BorderSide(color: Colors.green[300]!),
                  ),
                  onPressed: () {
                    changePassword();
                  },
                  child: const Text('Update Now'),
                ),
              ],
            ),
          ),
        )));
  }
}
