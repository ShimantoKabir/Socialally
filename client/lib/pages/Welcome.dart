import 'package:wengine/components/AboutUsComponent.dart';
import 'package:wengine/components/Feedback.dart';
import 'package:wengine/components/Footer.dart';
import 'package:wengine/components/JobGiver.dart';
import 'package:wengine/components/JobSeeker.dart';
import 'package:wengine/widgets/WelcomeBanner.dart';
import 'package:wengine/widgets/WelcomeNavBar.dart';
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
