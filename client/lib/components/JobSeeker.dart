import 'package:client/constants.dart';
import 'package:client/models/Service.dart';
import 'package:client/widgets/SectionTitle.dart';
import 'package:client/widgets/ServiceCard.dart';
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
