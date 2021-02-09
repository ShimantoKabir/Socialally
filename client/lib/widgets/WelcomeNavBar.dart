import 'package:client/widgets/DefaultButton.dart';
import 'package:client/widgets/MenuItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomeNavBar extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(46),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 30,
            color: Colors.black.withOpacity(0.16),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Image.asset(
            "assets/images/logo_without_text.png",
            height: 25,
            alignment: Alignment.topCenter,
          ),
          SizedBox(width: 5),
          Spacer(),
          MenuItem(
            title: "Home",
            press: () {
              Navigator.pushNamed(context, "/");
            },
          ),
          MenuItem(
            title: "about",
            press: () {
              Navigator.pushNamed(context, "/about-us");
            },
          ),
          MenuItem(
            title: "Pricing",
            press: () {},
          ),
          MenuItem(
            title: "Contact",
            press: () {
              Navigator.pushNamed(context, "/contactus");
            },
          ),
          MenuItem(
            title: "Login",
            press: () {
              Navigator.pushNamed(context, "/user/login");
            },
          ),
          DefaultButton(
            text: "Registration",
            press: () {
              Navigator.pushNamed(context, "/registration");
            },
          ),
        ],
      ),
    );
  }
}