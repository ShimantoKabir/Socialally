import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:socialally/models/SupportInfo.dart';

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
      padding: EdgeInsets.fromLTRB(50,50,50,0),
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
        SelectableText(
          "Socialally",
          style: TextStyle(
            fontSize: data["lgFontSize"],
            fontWeight: FontWeight.w700,
            color: Colors.grey
          ),
        ),
        SizedBox(
          height: 8,
        ),
        SelectableText(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
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