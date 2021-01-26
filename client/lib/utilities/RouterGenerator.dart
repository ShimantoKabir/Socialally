import 'dart:convert';

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
  Route<dynamic> generate(RouteSettings settings) {
    var uri = Uri.parse(settings.name);
    if (settings.name == '/') {
      return redirect(Welcome(), settings, false);
    } else if (settings.name.contains('/email-verification')) {
      if (uri.pathSegments.length == 2 &&
          uri.pathSegments.first == 'email-verification') {
        return redirect(
            EmailVerification(emailVerificationId: uri.pathSegments[1]),
            settings,
            false);
      } else if (uri.pathSegments.length == 1 &&
          uri.pathSegments.first == 'email-verification') {
        return redirect(
            EmailVerification(emailVerificationId: "empty"), settings, false);
      } else {
        return redirect(Unknown(), settings, false);
      }
    } else if (settings.name == '/contactus') {
      return redirect(ContactUs(), settings, false);
    } else if (settings.name == '/login') {
      return redirect(Login(), settings, false);
    } else if (settings.name == '/registration') {
      return redirect(Registration(), settings, false);
    } else if (settings.name == '/user/dashboard') {
      return redirect(User(), settings, true);
    } else {
      return redirect(Unknown(), settings, false);
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
                    }else {
                      return next;
                    }
                  } else {
                    return Login();
                  }
                } else {
                  if (snapshot.hasData) {
                    return User(userInfo: jsonDecode(snapshot.data));
                  } else {
                    return next;
                  }
                }
              },
            ),
        settings: routeSettings);
  }
}
