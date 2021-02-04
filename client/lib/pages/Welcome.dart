import 'package:client/components/AboutUsComponent.dart';
import 'package:client/components/Feedback.dart';
import 'package:client/components/Footer.dart';
import 'package:client/components/JobGiver.dart';
import 'package:client/components/JobSeeker.dart';
import 'package:client/widgets/WelcomeNavBar.dart';
import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print("welcome page");
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            WelcomeNavBar(),
            Container(
              height: screenSize.height - 150,
              width: screenSize.width,
              padding: EdgeInsets.all(0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 64),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Workers Engine",
                                  style: TextStyle(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Easy Approach makes it easy for every one to dessiminate knowledge, and making "
                                  "difficult problems easy to solve",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 1.0,
                                      color: Colors.grey[800]),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                FlatButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(context, "/login", (r) => false);
                                    },
                                    icon: Icon(Icons.login),
                                    label: Text("Login"),
                                    color: Colors.grey[800],
                                    textColor: Colors.white)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Image.asset(
                              "assets/images/web.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            JobSeeker(),
            JobGiver(),
            UserFeedback(),
            AboutUsComponent(),
            Footer()
          ],
        ),
      ),
    );
  }
}
