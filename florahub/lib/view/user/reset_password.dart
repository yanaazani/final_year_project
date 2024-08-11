import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:florahub/controller/RequestController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email; // You can pass the email to this page
  ResetPasswordPage({super.key, required this.email});
  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
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

  Future<void> resetPassword() async {
    print("Email used in resetPassword: ${widget.email}");

    if (passwordController.text != confirmPasswordController.text) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: "Error",
        desc: "Passwords do not match.",
        btnOkOnPress: () {},
      ).show();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");

    // Ensure the URL is correctly formatted
    String url =
        "user/updatePasswordByEmail?email=${widget.email}&newPassword=${passwordController.text}";

    WebRequestController req = WebRequestController(
        path: url, // Use the path without the server
        server: "http://$server:8080" // The server should be correct
        );

    await req.put();

    if (req.status() == 200) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: "Success",
        desc: "Password updated successfully.",
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        showCloseIcon: true,
        title: "Error",
        desc: "Failed to update password. Please try again.",
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
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
                      width: 350,
                      height: 200,
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
                      'Set new password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
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
                            borderSide: const BorderSide(width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          hintText: "Password",
                        ),
                        obscureText: !_password,
                      ),
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
                            borderSide: const BorderSide(width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          hintText: "Confirm Password",
                        ),
                        obscureText: !_password,
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
                      onPressed: () {
                        resetPassword(); // Call the function on press
                      },
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
