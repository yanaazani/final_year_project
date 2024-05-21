import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:florahub/controller/RequestController.dart';
import 'package:florahub/view/profile/constants.dart';
import 'package:florahub/view/profile/privacy_page.dart';
import 'package:florahub/view/profile/purchase_history.dart';
import 'package:florahub/widgets/profile_list_item.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState(userId: userId);
}

class _ProfilePageState extends State<ProfilePage> {
  _ProfilePageState({required this.userId});
  late String username = "";
  late final int userId;

  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    WebRequestController req = WebRequestController(
        path: "user/details/${widget.userId}", server: "http://$server:8080");

    await req.get();
    print(req.result());

    if (req.status() == 200) {
      var data = req.result();

      setState(() {
        username = data["username"];
        fetchProfileImage(widget.userId);
      });
      print(username);
    }
  }

  String imageUrl = "assets/images/pinktree.png";
  Uint8List? _images; // Default image URL
  Future<void> fetchProfileImage(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    String? server = prefs.getString("localhost");
    final response = await http.get(Uri.parse(
        'http://$server:8080/florahub/image/getProfileImage/${widget.userId}'));

    if (response.statusCode == 200) {
      setState(() {
        _images = response.bodyBytes;
      });
    } else {
      // Handle errors, e.g., display a default image
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getUser(); // Call getUser() method when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
                Container(
      width: 150,
      height: 150,
      padding: EdgeInsets.all(8),
      decoration: avatarDecoration,
      child: Container(
        decoration: avatarDecoration,
        padding: EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: _images != null
                  ? DecorationImage(
                      fit: BoxFit.cover, image: MemoryImage(_images!))
                  : DecorationImage(
                      fit: BoxFit.cover, image: AssetImage(imageUrl))),
        ),
      ),
    ),
                SizedBox(
                  height: 30,
                ),
                ProfileListItems(userId: userId),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AppBarButton extends StatelessWidget {
  final IconData icon;

  const AppBarButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kAppPrimaryColor,
          boxShadow: [
            BoxShadow(
              color: kLightBlack,
              offset: Offset(1, 1),
              blurRadius: 10,
            ),
            BoxShadow(
              color: kWhite,
              offset: Offset(-1, -1),
              blurRadius: 10,
            ),
          ]),
      child: Icon(
        icon,
        color: fCL,
      ),
    );
  }
}


class SocialIcon extends StatelessWidget {
  final Color color;
  final IconData iconData;
  final Function onPressed;

  SocialIcon(
      {super.key,
      required this.color,
      required this.iconData,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.only(left: 20.0),
      child: Container(
        width: 45.0,
        height: 45.0,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: RawMaterialButton(shape: CircleBorder(), onPressed: () {}),
        //Icon(iconData, color: Colors.white),
      ),
    );
  }
}

class ProfileListItems extends StatelessWidget {
  const ProfileListItems({super.key, required int userId});

  void navigateToPrivacyPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrivacyPage()),
    );
  }

  void navigateToPurchaseHistoryPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PurchaseHistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: <Widget>[
          ProfileListItem(
            key: ValueKey('settings'),
            icon: LineAwesomeIcons.cog,
            text: 'Settings',
            onPressed: () => navigateToPrivacyPage(context),
          ),
          ProfileListItem(
            key: ValueKey('help_and_support'),
            icon: LineAwesomeIcons.question_circle,
            text: 'Help & Support',
            onPressed: () => navigateToPrivacyPage(context),
          ),
          ProfileListItem(
            key: ValueKey('invite_friend'),
            icon: LineAwesomeIcons.user_plus,
            text: 'Invite a Friend',
            onPressed: () => navigateToPrivacyPage(context),
          ),
          ProfileListItem(
            key: ValueKey(
                'privacy'), // Provide a unique key for each ProfileListItem
            icon: LineAwesomeIcons.user_shield,
            text: 'Privacy',
            onPressed: () => navigateToPrivacyPage(context),
          ),
          ProfileListItem(
            key: ValueKey('logout'),
            icon: LineAwesomeIcons.alternate_sign_out,
            text: 'Logout',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
