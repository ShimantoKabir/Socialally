import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class WelcomeBanner extends StatefulWidget {
  WelcomeBanner({
    Key key,
    this.data,
  }) : super(key: key);

  final data;

  @override
  WelcomeBannerState createState() => WelcomeBannerState(
    data: data,
  );
}

class WelcomeBannerState extends State<WelcomeBanner>{

  var data;

  WelcomeBannerState({
    Key key,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(50,20,20,20),
      child: ScreenTypeLayout(
        desktop: getDesktopBanner({
          "lgFontSize" : 65,
          "smFontSize" : 15,
        }),
        tablet: getDesktopBanner({
          "lgFontSize" : 35,
          "smFontSize" : 12,
        }),
        mobile: getMobileBanner({
          "lgFontSize" : 35,
          "smFontSize" : 12,
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
          "Workers Engine",
          style: TextStyle(
              fontSize: data["lgFontSize"],
              fontWeight: FontWeight.w700,
              color: Colors.green),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          "Easy Approach makes it easy for every one to disseminate knowledge, and making "
              "difficult problems easy to solve",
          style: TextStyle(
              fontSize: data["smFontSize"],
              fontWeight: FontWeight.w300,
              letterSpacing: 1.0,
              color: Colors.grey[800]),
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
            textColor: Colors.white)
      ],
    );
  }

  Widget getRightContent(var data){
    return Column(
      children: [
        Image.asset(
          "assets/images/web.png",
          fit: BoxFit.contain,
        )
      ],
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