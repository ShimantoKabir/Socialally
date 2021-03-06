import 'package:wengine/constants.dart';
import 'package:wengine/widgets/AboutSectionText.dart';
import 'package:wengine/widgets/AboutUsBtn.dart';
import 'package:wengine/widgets/OutlineButton.dart';
import 'package:wengine/widgets/SectionTitle.dart';
import 'package:flutter/material.dart';

class AboutUsComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 1110),
      margin: EdgeInsets.only(top: kDefaultPadding * 2),
      padding: EdgeInsets.all(kDefaultPadding * 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          SectionTitle(
            title: "About Us",
            subTitle: "To know us more",
            color: Colors.red,
          ),
          AboutSectionText(
            text:
            "WorkersEngine is an innovative crowdsources platform that connects Employer as well as Workers globally. WorkersEngine is a UK based registered company with registration number 13162011 is registered as WorkersEngine Ltd. We offer effective solutions to companies, businesses and persons in need to outsource their jobs and projects. Solutions may include constructive ways of breaking down vast tasks to be distributed to workers, minimizing your time to finish your project and collect results on your target date. Our platform concentrates in deploying micro jobs to workers such as data collection and analysis, moderation and/or extraction of data, annotation, classification, image or video tagging, conversion and transcription, product testing, research and survey jobs and more. WorkersEngine began in 2021 and is now one of the growing and trusted crowd-based outsourcing platforms online.",
          ),
          SizedBox(height: kDefaultPadding * 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AboutUsBtn(
                imageSrc: "assets/images/download.png",
                text: "See Our Team",
                press: () {
                  Navigator.pushNamed(context, "/about-us");
                },
              ),
              SizedBox(width: kDefaultPadding * 1.5),
              MyOutlineButton(
                imageSrc: "assets/images/hand.png",
                text: "See How It Works",
                press: () {
                  Navigator.pushNamed(context, "/about-us");
                },
              ),
              SizedBox(width: kDefaultPadding * 1.5),
              AboutUsBtn(
                imageSrc: "assets/images/download.png",
                text: "See Our Workers",
                press: () {
                  Navigator.pushNamed(context, "/about-us");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

