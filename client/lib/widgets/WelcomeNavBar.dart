import 'package:client/widgets/DefaultButton.dart';
import 'package:client/widgets/MenuItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class WelcomeNavBar extends StatefulWidget {
  WelcomeNavBar({
    Key key,
    this.data,
  }) : super(key: key);

  final data;

  @override
  WelcomeNavBarState createState() => WelcomeNavBarState(
    data: data,
  );
}

class WelcomeNavBarState extends State<WelcomeNavBar>{

  var data;

  WelcomeNavBarState({
    Key key,
    this.data,
  });

  bool isMobileNavOpen = false;

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
      Visibility(child: Image.asset(
        "assets/images/logo_without_text.png",
        height: data["logoHeight"],
        alignment: Alignment.topCenter,
      ),visible: data["needLogo"]),
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
          "title" : "Contact",
          "padding" : data['menuPadding'],
          "margin" : data['menuMargin'],
          "fontSize" : data['menuFontSize']
        },
        onClick: () {
          Navigator.pushNamed(context, "/contactus");
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
      DefaultButton(
        data: {
          "title" : "Registration",
          "padding" : data['menuPadding'],
          "fontSize" : data['menuFontSize']
        },
        onClick: () {
          Navigator.pushNamed(context, "/user/registration");
        },
      ),
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

}