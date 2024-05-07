//import 'package:florahub/view/constants.dart';
import 'package:florahub/view/profile/help_support.dart';
import 'package:florahub/view/profile/invitefriend.dart';
import 'package:florahub/view/profile/privacy_page.dart';
import 'package:florahub/view/profile/purchase_history.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasNavigation;

  const ProfileListItem({
    required Key key,
    required this.icon,
    required this.text,
    this.hasNavigation = true,
    required void Function() onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (hasNavigation) {
          _navigateToPage(context); // Navigate to respective page
        }
      },
      child: Container(
        height: 55,
        margin: EdgeInsets.symmetric(
          horizontal: 10,
        ).copyWith(
          bottom: 20,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              this.icon,
              size: 25,
            ),
            SizedBox(width: 15),
            Text(
              this.text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            if (this.hasNavigation)
              Icon(
                LineAwesomeIcons.angle_right,
                size: 25,
              ),
          ],
        ),
      ),
    );
  }

// Function to navigate to respective page
  void _navigateToPage(BuildContext context) {
    switch (text) {
      case 'Privacy':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PrivacyPage()),
        );
        break;
      case 'Purchase History':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PurchaseHistoryPage()),
        );
        break;
      case 'Help & Support':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HelpSupportPage()),
        );
        break;
      case 'Settings':
        break;
      case 'Invite a Friend':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InviteFriendPage()),
        );
        break;
      default:
        // Handle default case
        break;
    }
  }
}
