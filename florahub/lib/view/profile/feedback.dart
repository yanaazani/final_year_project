import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:florahub/controller/RequestController.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_emoji_feedback/flutter_emoji_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackPage extends StatefulWidget {
  final int userId;
  FeedbackPage({super.key, required this.userId});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState(userId: userId);
}

class _FeedbackPageState extends State<FeedbackPage> {
  _FeedbackPageState({required this.userId});
  late final int userId;
  TextEditingController _commentController = TextEditingController();
  int rating = 0;

  Future add() async {
    /**
       * save the data registered to database
       */
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "feedback/add", server: "http://$server:8080");

    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    req.setBody({
      "rate": rating.toString(),
      "dateTime": formattedDateTime,
      "message": _commentController.text,
      "userId": userId.toString(),
    });

    await req.post();

    print(req.result());
    if (req.result() != null) {
      ArtSweetAlert.show(
        context: context,
        artDialogArgs: ArtDialogArgs(
            type: ArtSweetAlertType.success,
            text: "Thankyou for your feedback.",
            onConfirm: () {
              Navigator.pop(context);
            }),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Something is wrong. \nPlease try again later.",
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
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        elevation: 2.0,
        centerTitle: true,
        title: const Text(
          'Feedback',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Lottie.network(
                      "https://lottie.host/1bf323c9-4be4-4d8c-8654-53753e2cb550/rVAIOlx2HY.json"),
                ),
                const Text(
                  'Give Feedback',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.black),
                ),
                SizedBox(height: 10),
                const Text(
                  'What do you think of the app?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const SizedBox(width: 15.0),
                EmojiFeedback(
                  animDuration: const Duration(milliseconds: 300),
                  curve: Curves.bounceIn,
                  inactiveElementScale: .5,
                  onChanged: (value) {
                    setState(() {
                      rating = value;
                    });
                    print(value);
                  },
                ),
                const SizedBox(
                  height: 25.0,
                ),
                const Text(
                  "Do you have any thoughts that you'd like to share?",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black),
                ),
                Container(
                  height: 200.0,
                  child: Stack(
                    children: [
                      TextField(
                        controller: _commentController,
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText: "Tell us on how can we improve...",
                          hintStyle: TextStyle(
                            fontSize: 13.0,
                            color: Colors.green[100],
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(
                              width: 1.0,
                              color: Colors.white70,
                            )),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text(
                                            "Upload Image",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {},
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(14),
                                                child: Text(
                                                  "Gallery",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add)),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              const Text(
                                "Upload Screenshot \n(Optional)",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          add();
                        },
                        child: const Text("Submit",
                            style: TextStyle(
                                fontSize: 15,
                                letterSpacing: 2,
                                color: Colors.black)),
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
