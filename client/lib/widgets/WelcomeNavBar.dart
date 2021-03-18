import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wengine/models/SupportInfo.dart';
import 'package:wengine/utilities/Alert.dart';
import 'package:wengine/widgets/MenuItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:wengine/widgets/SpecialButton.dart';

class WelcomeNavBar extends StatefulWidget {
  WelcomeNavBar({
    Key key,
    this.supportInfoList,
    this.type
  }) : super(key: key);

  final List<SupportInfo> supportInfoList;
  final type;

  @override
  WelcomeNavBarState createState() => WelcomeNavBarState(
    supportInfoList: supportInfoList,
    type: type
  );
}

class WelcomeNavBarState extends State<WelcomeNavBar>{

  List<SupportInfo> supportInfoList;
  int type;

  WelcomeNavBarState({
    Key key,
    this.supportInfoList,
    this.type
  });

  bool isMobileNavOpen = false;
  AlertDialog alertDialog;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Container(
        width: width,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, -2),
              blurRadius: 30,
              color: Colors.black.withOpacity(0.16),
            )
          ]
        ),
        child: ScreenTypeLayout(
          desktop: getDesktopNavBar(context,{
            "logoHeight" : 25.0,
            "menuPadding" : 15.0,
            "menuMargin" : 0.0,
            "menuFontSize" : 15.0,
            "needLogo" : true,
            "screenWidth" : width
          }),
          tablet: getDesktopNavBar(context,{
            "logoHeight" : 17.0,
            "menuPadding" : 12.0,
            "menuMargin" : 0.0,
            "menuFontSize" : 12.0,
            "needLogo" : true,
            "screenWidth" : width
          }),
          mobile: getMobileNavBar(context,{
            "logoHeight" : 17.0,
            "menuPadding" : 12.0,
            "menuMargin" : 10.0,
            "menuFontSize" : 12.0,
            "needLogo" : false,
            "screenWidth" : width
          })
        ),
      )
    );
  }

  Widget getDesktopNavBar(BuildContext context,var data){
    return Row(
      children: getMenuItems(data)
    );
  }

  List<Widget> getMenuItems(var data){
    return [
      Visibility(
        child: Image.asset(
          "assets/images/logo_main.png",
          height: data["logoHeight"],
          alignment: Alignment.topCenter,
        ),
        visible: data["needLogo"]
      ),
      SizedBox(width: 30),
      type == 1 ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.youtube,
              size: 20,
              color: Color(0xffbc4302b),
            ),
            onPressed: () {
              if(supportInfoList.length >= 1){
                openUrl(supportInfoList[0].address, context);
              }else {
                Alert.show(alertDialog, context, Alert.ERROR, "Can't open the url!");
              }
            }
          ),
          IconButton(
              icon: FaIcon(
                FontAwesomeIcons.facebookMessenger,
                size: 20,
                color: Color(0xffb3b5998),
              ),
              onPressed: () {
                if(supportInfoList.length >= 2){
                  openUrl(supportInfoList[1].address, context);
                }else {
                  Alert.show(alertDialog, context, Alert.ERROR, "Can't open the url!");
                }
              }
          ),
          IconButton(
              icon: FaIcon(
                FontAwesomeIcons.twitter,
                size: 20,
                color: Color(0xffb1DA1F2),
              ),
              onPressed: () {
                if(supportInfoList.length >= 3){
                  openUrl(supportInfoList[2].address, context);
                }else {
                  Alert.show(alertDialog, context, Alert.ERROR, "Can't open the url!");
                }
              }
          )
        ],
      ) :
      SelectableText(
        "WorkersEngine",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
          fontSize: 20
        ),
      ),
      Visibility(child: SizedBox(width: 5),visible: data["needLogo"]),
      Visibility(child: Spacer(),visible: data["needLogo"]),
      MenuItem(
        data: {
          "title" : "Home",
          "padding" : data['menuPadding'],
          "margin" : data['menuMargin'],
          "fontSize" : data['menuFontSize']
        },
        onClick: () {
          Navigator.pushNamed(context, "/");
        },
      ),
      MenuItem(
        data: {
          "title" : "About",
          "padding" : data['menuPadding'],
          "margin" : data['menuMargin'],
          "fontSize" : data['menuFontSize']
        },
        onClick: () {
          Navigator.pushNamed(context, "/about-us");
        },
      ),
      MenuItem(
        data: {
          "title" : "Login",
          "padding" : data['menuPadding'],
          "margin" : data['menuMargin'],
          "fontSize" : data['menuFontSize']
        },
        onClick: () {
          Navigator.pushNamed(context, "/user/login");
        },
      ),
      SpecialButton(
        data: {
          "title" : "Registration",
          "padding" : data['menuPadding'],
          "fontSize" : data['menuFontSize']
        },
        onClick: () {
          Navigator.pushNamed(context, "/user/registration");
        },
      )
    ];
  }

  Widget getMobileNavBar(BuildContext context,var data){

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              "assets/images/logo_without_text.png",
              height: data["logoHeight"],
              alignment: Alignment.topCenter,
            ),
            IconButton(
              icon: Icon(Icons.apps_outlined),
              onPressed: (){
                setState(() {
                  isMobileNavOpen = !isMobileNavOpen;
                });
              }
            )
          ],
        ),
        Visibility(
          visible: isMobileNavOpen,
          child: Container(
            width: data['screenWidth'],
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.transparent
                )
              )
            ),
            child: Column(
              children: getMenuItems(data),
            ),
          )
        )
      ],
    );

  }

  openUrl(String url,BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Alert.show(alertDialog, context, Alert.ERROR, "Can't open the url!");
    }
  }

}