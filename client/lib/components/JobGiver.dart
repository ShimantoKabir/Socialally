import 'package:client/constants.dart';
import 'package:client/models/SuccessfulWork.dart';
import 'package:client/widgets/HireFreelancerCard.dart';
import 'package:client/widgets/SectionTitle.dart';
import 'package:client/widgets/SuccessfulWorkCard.dart';
import 'package:flutter/material.dart';

class JobGiver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: kDefaultPadding * 6),
      width: double.infinity,
      // just for demo
      // height: 600,
      decoration: BoxDecoration(
        color: Color(0xFFF7E8FF).withOpacity(0.3),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/images/recent_work_bg.png"),
        ),
      ),
      child: Column(
        children: [
          Transform.translate(
            offset: Offset(0, -80),
            child: HireFreelancerCard(),
          ),
          SectionTitle(
            title: "Recent Successful Projects",
            subTitle: "Freelancer Stories",
            color: Color(0xFFFFB100),
          ),
          SizedBox(height: kDefaultPadding * 1.5),
          SizedBox(
            width: 1110,
            child: Wrap(
              spacing: kDefaultPadding,
              runSpacing: kDefaultPadding * 2,
              children: List.generate(
                successfulWorks.length,
                    (index) => SuccessfulWorkCard(index: index, press: () {}),
              ),
            ),
          ),
          SizedBox(height: kDefaultPadding * 5),
        ],
      ),
    );
  }
}
