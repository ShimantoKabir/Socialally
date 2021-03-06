import 'package:wengine/constants.dart';
import 'package:wengine/models/Feedback.dart';
import 'package:wengine/widgets/FeedbackCard.dart';
import 'package:wengine/widgets/SectionTitle.dart';
import 'package:flutter/material.dart';

class UserFeedback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: kDefaultPadding * 2.5),
      constraints: BoxConstraints(maxWidth: 1110),
      child: Column(
        children: [
          SectionTitle(
            title: "Feedback Received",
            subTitle: "Client’s testimonials that inspired me a lot",
            color: Color(0xFF00B1FF),
          ),
          SizedBox(height: kDefaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              feedbacks.length,
                  (index) => FeedbackCard(index: index),
            ),
          ),
        ],
      ),
    );
  }
}
