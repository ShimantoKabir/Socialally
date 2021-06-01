import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socialally/pages/AboutUs.dart';
import 'package:socialally/pages/Admin.dart';
import 'package:socialally/pages/EmailVerification.dart';
import 'package:socialally/pages/ForgotPassword.dart';
import 'package:socialally/pages/Login.dart';
import 'package:socialally/pages/Registration.dart';
import 'package:socialally/pages/User.dart';
import 'package:socialally/pages/Unknown.dart';
import 'package:socialally/pages/Welcome.dart';
import 'package:socialally/utilities/MySharedPreferences.dart';

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
    }else if (routeSettings.name.contains('/forgot-password')) {
      if (uri.pathSegments.length == 2 &&
          uri.pathSegments.first == 'forgot-password') {
        return redirect(
            ForgotPassword(forgotPasswordId: uri.pathSegments[1]),
            routeSettings,
            false
        );
      } else if (uri.pathSegments.length == 1 &&
          uri.pathSegments.first == 'forgot-password') {
        return redirect(ForgotPassword(forgotPasswordId: "empty"), routeSettings, false);
      } else {
        return redirect(Unknown(), routeSettings, false);
      }
    } else if (routeSettings.name == '/about-us') {
      return redirect(AboutUs(), routeSettings, false);
    } else if (routeSettings.name == '/user/login') {
      return redirect(Login(type: 1), routeSettings, false);
    }else if (routeSettings.name == '/admin/login') {
      return redirect(Login(type: 2), routeSettings, false);
    } else if (routeSettings.name.contains("/user/registration")) {
      if(uri.pathSegments.length == 3){
        return redirect(Registration(type: 1, referrerId: uri.pathSegments[2]), routeSettings, false);
      }else if(uri.pathSegments.length == 2){
        return redirect(Registration(type: 1, referrerId: "empty"), routeSettings, false);
      }else {
        return redirect(Unknown(), routeSettings, false);
      }
    }else if (routeSettings.name == '/admin/registration') {
      return redirect(Registration(type: 2), routeSettings, false);
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

              var userInfo = jsonDecode(snapshot.data);

              if(userInfo['type']==1){

                return User(userInfo: userInfo);

              }else {

                return Admin(userInfo: userInfo);

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
