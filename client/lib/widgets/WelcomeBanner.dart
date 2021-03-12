import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wengine/models/SupportInfo.dart';

class WelcomeBanner extends StatefulWidget {
  WelcomeBanner({
    Key key,
    this.supportInfoList
  }) : super(key: key);

  final List<SupportInfo> supportInfoList;

  @override
  WelcomeBannerState createState() => WelcomeBannerState(
    supportInfoList: supportInfoList,
  );
}

class WelcomeBannerState extends State<WelcomeBanner>{

  List<SupportInfo> supportInfoList;

  WelcomeBannerState({
    Key key,
    this.supportInfoList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(50),
      child: ScreenTypeLayout(
        desktop: getDesktopBanner({
          "lgFontSize" : 65.0,
          "smFontSize" : 15.0
        }),
        tablet: getDesktopBanner({
          "lgFontSize" : 35.0,
          "smFontSize" : 12.0
        }),
        mobile: getMobileBanner({
          "lgFontSize" : 35.0,
          "smFontSize" : 12.0
        }),
      ),
    );
  }

  Widget getDesktopBanner(var data){
    return Row(
      children: getWidgetList(data),
    );
  }

  Widget getMobileBanner(var data){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          getLeftContent(data),
          SizedBox(height: 20),
          getRightContent(data)
        ],
      )
    );
  }

  Widget getLeftContent(var data){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "WorkersEngine",
          style: TextStyle(
            fontSize: data["lgFontSize"],
            fontWeight: FontWeight.w700,
            color: Colors.green
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          "WorkersEngine is an innovative crowdsources platform that connects Employer as well as Workers globally. WorkersEngine is a UK based registered company with registration number 13162011 is registered as WorkersEngine Ltd. We offer effective solutions to companies, businesses and persons in need to outsource their jobs and projects. Solutions may include constructive ways of breaking down vast tasks to be distributed to workers, minimizing your time to finish your project and collect results on your target date. Our platform concentrates in deploying micro jobs to workers such as data collection and analysis, moderation and/or extraction of data, annotation, classification, image or video tagging, conversion and transcription, product testing, research and survey jobs and more. WorkersEngine began in 2021 and is now one of the growing and trusted crowd-based outsourcing platforms online.",
          style: TextStyle(
            fontSize: data["smFontSize"],
            fontWeight: FontWeight.w300,
            letterSpacing: 1.0,
            color: Colors.grey[800]
          ),
        ),
        SizedBox(
          height: 16,
        ),
        FlatButton.icon(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, "/user/login", (r) => false);
          },
          icon: Icon(Icons.login),
          label: Text("Login"),
          color: Colors.grey[800],
          textColor: Colors.white
        )
      ],
    );
  }

  Widget getRightContent(var data){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 500,
            height: 500,
            child: Image.asset(
              "assets/images/welcome_banner.png",
              fit: BoxFit.contain,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> getWidgetList(var data){
    return [
      Expanded(
        child: getLeftContent(data),
        flex: 1
      ),
      Expanded(
        child: getRightContent(data),
        flex: 1
      )
    ];
  }

}