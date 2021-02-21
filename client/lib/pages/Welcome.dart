import 'package:client/components/AboutUsComponent.dart';
import 'package:client/components/Feedback.dart';
import 'package:client/components/Footer.dart';
import 'package:client/components/JobGiver.dart';
import 'package:client/components/JobSeeker.dart';
import 'package:client/widgets/WelcomeBanner.dart';
import 'package:client/widgets/WelcomeNavBar.dart';
import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            WelcomeNavBar(),
            WelcomeBanner(),
            // JobSeeker(),
            // JobGiver(),
            // UserFeedback(),
            // AboutUsComponent(),
            // Footer()
          ],
        ),
      ),
    );
  }
}
