import 'package:wengine/constants.dart';
import 'package:wengine/models/Service.dart';
import 'package:wengine/widgets/SectionTitle.dart';
import 'package:wengine/widgets/ServiceCard.dart';
import 'package:flutter/material.dart';

class JobSeeker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: kDefaultPadding * 2),
      constraints: BoxConstraints(maxWidth: 1110),
      child: Column(
        children: [
          SectionTitle(
            color: Color(0xFFFF0000),
            title: "Make Smart Choice",
            subTitle: "Popular Jobs Sector",
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
                services.length, (index) => ServiceCard(index: index)),
          )
        ],
      ),
    );
  }
}
