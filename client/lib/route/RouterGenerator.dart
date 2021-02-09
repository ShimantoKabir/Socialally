import 'dart:convert';
import 'package:client/pages/AboutUs.dart';
import 'package:client/pages/Admin.dart';
import 'package:client/pages/EmailVerification.dart';
import 'package:flutter/material.dart';
import 'package:client/pages/ContactUs.dart';
import 'package:client/pages/Login.dart';
import 'package:client/pages/Registration.dart';
import 'package:client/pages/User.dart';
import 'package:client/pages/Unknown.dart';
import 'package:client/pages/Welcome.dart';
import 'package:client/utilities/MySharedPreferences.dart';

class RouterGenerator {
  Route<dynamic> generate(RouteSettings routeSettings) {

    var uri = Uri.parse(routeSettings.name);
    if (routeSettings.name == '/') {
      return redirect(Welcome(), routeSettings, false);
    } else if (routeSettings.name.contains('/email-verification')) {
      if (uri.pathSegments.length == 2 &&
          uri.pathSegments.first == 'email-verification') {
        return redirect(
          EmailVerification(emailVerificationId: uri.pathSegments[1]),
            routeSettings,
          false
        );
      } else if (uri.pathSegments.length == 1 &&
          uri.pathSegments.first == 'email-verification') {
        return redirect(EmailVerification(emailVerificationId: "empty"), routeSettings, false);
      } else {
        return redirect(Unknown(), routeSettings, false);
      }
    } else if (routeSettings.name == '/contactus') {
      return redirect(ContactUs(), routeSettings, false);
    }else if (routeSettings.name == '/about-us') {
      return redirect(AboutUs(), routeSettings, false);
    } else if (routeSettings.name == '/user/login') {
      return redirect(Login(type: 1), routeSettings, false);
    }else if (routeSettings.name == '/admin/login') {
      return redirect(Login(type: 2), routeSettings, false);
    } else if (routeSettings.name == '/registration') {
      return redirect(Registration(), routeSettings, false);
    } else if (routeSettings.name == '/user/dashboard') {
      return redirect(User(), routeSettings, true);
    }else if (routeSettings.name == '/admin/dashboard') {
      return redirect(Admin(), routeSettings, true);
    } else {
      return redirect(Unknown(), routeSettings, false);
    }
  }

  MaterialPageRoute redirect(
      Object next, RouteSettings routeSettings, bool needAuthentication) {
    return MaterialPageRoute(
      builder: (context) => FutureBuilder(
        future: MySharedPreferences.getStringValue("userInfo"),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {

          if (needAuthentication) {

            if (snapshot.hasData) {

              if(routeSettings.name == '/user/dashboard'){

                return User(userInfo: jsonDecode(snapshot.data));

              } else if(routeSettings.name == '/admin/dashboard'){

                return Admin(userInfo: jsonDecode(snapshot.data));

              } else {

                return next;

              }
            } else {

              if(routeSettings.name == '/user/dashboard'){

                return Login(type: 1);

              } else if(routeSettings.name == '/admin/dashboard'){

                return Login(type: 2);

              } else{

                return Unknown();

              }
            }
          } else {

            if (snapshot.hasData) {

              if(routeSettings.name == '/user/dashboard'){

                return User(userInfo: jsonDecode(snapshot.data));

              }else if(routeSettings.name == '/admin/dashboard'){

                return Admin(userInfo: jsonDecode(snapshot.data));

              }else {

                return Unknown();

              }

            } else {

              return next;

            }
          }
        }
      ),
      settings: routeSettings
    );
  }
}
