import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/utilities/MySharedPreferences.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:responsive_builder/responsive_builder.dart';

class DashboardTopNavigation extends StatefulWidget {
  DashboardTopNavigation({
    Key key,
    this.type,
    this.totalUnseenNotification,
    this.eventHub,
    this.userNavigatorKey,
    this.userInfo
  }) : super(key: key);

  final int type;
  final int totalUnseenNotification;
  final EventHub eventHub;
  final userNavigatorKey;
  final userInfo;

  @override
  DashboardTopNavigationState createState() => DashboardTopNavigationState(
    type: type,
    totalUnseenNotification: totalUnseenNotification,
    eventHub: eventHub,
    userNavigatorKey: userNavigatorKey,
    userInfo: userInfo
  );
}


class DashboardTopNavigationState extends State<DashboardTopNavigation>{

  int type;
  int totalUnseenNotification;
  EventHub eventHub;
  var userNavigatorKey;
  var userInfo;

  DashboardTopNavigationState({
    Key key,
    this.type,
    this.totalUnseenNotification,
    this.eventHub,
    this.userNavigatorKey,
    this.userInfo,
  });

  Future futureBalanceSummary;
  String balance;
  String withdrawAmount;
  bool isSideNavOpen;

  @override
  void initState() {
    super.initState();
    balance = "0.0";
    withdrawAmount = "0.0";
    isSideNavOpen = true;
    futureBalanceSummary = fetchBalanceSummary();
    eventHub.on("reloadBalance", (dynamic data) {
      fetchBalanceSummary();
    });
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: ScreenTypeLayout(
        desktop: getContent(context,{
          "needToShowDesktopStaff" : true,
          "screenWidth" : width
        }),
        mobile: getContent(context,{
          "needToShowDesktopStaff" : false,
          "screenWidth" : width
        }),
      )
    );
  }

  Widget getContent(BuildContext context,var data){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Center(
          child: IconButton(
            icon: Icon(
              Icons.apps,
              size: 20,
              color: Colors.black,
            ),
            onPressed: () async {
              isSideNavOpen = !isSideNavOpen;
              eventHub.fire("openAndCloseSideNav",{
                "screenWidth" : data['screenWidth']
              });
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
          child: Row(
            children: [
              // Visibility(
              //   child: IconButton(
              //     icon: Icon(
              //       Icons.refresh,
              //       size: 20,
              //       color: Colors.black
              //     ),
              //     onPressed: (){
              //
              //     },
              //   ),
              //   visible: type == 1,
              // ),
              SizedBox(width: 10),
              Visibility(
                child: FlatButton(
                  onPressed: () => {

                  },
                  color: Colors.red,
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Earning £$withdrawAmount",
                        style: TextStyle(color: Colors.white)
                      )
                    ],
                  ),
                ),
                visible: type == 1 && data['needToShowDesktopStaff'],
              ),
              SizedBox(width: 10),
              Visibility(
                child: FlatButton(
                  onPressed: () => {

                  },
                  color: Colors.green,
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: Row(
                    // Replace with a Row for horizontal icon + text
                    children: <Widget>[
                      Text("Balance £$balance",
                          style: TextStyle(color: Colors.white))
                    ],
                  ),
                ),
                visible: type == 1,
              ),
              SizedBox(width: 10),
              Badge(
                position: BadgePosition.topEnd(top: 0, end: -5),
                showBadge: totalUnseenNotification != null
                    && totalUnseenNotification > 0,
                badgeContent: Text(
                  totalUnseenNotification == null ? "" :
                  totalUnseenNotification.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                      Icons.notifications_active,
                      size: 20,
                      color: Colors.black
                  ),
                  onPressed: () {
                    setState(() {
                      totalUnseenNotification = 0;
                    });
                    if(type == 1){
                      userNavigatorKey.currentState.pushNamed('/users/notifications');
                    }else {
                      userNavigatorKey.currentState.pushNamed('/admins/notifications');
                    }
                  },
                ),
              ),
              Visibility(
                child: IconButton(
                  icon: Icon(
                      Icons.account_circle_rounded,
                      size: 20,
                      color: Colors.black
                  ),
                  onPressed: () {
                    if(type == 1){
                      userNavigatorKey.currentState.pushNamed('/user/profile/update');
                    }else {
                      userNavigatorKey.currentState.pushNamed('/admin/profile');
                    }
                  },
                ),
                visible: data['needToShowDesktopStaff'],
              ),
              Visibility(
                child: IconButton(
                    icon: Icon(
                        Icons.logout,
                        size: 20,
                        color: Colors.black
                    ),
                    onPressed: () {
                      logout(context);
                    },
                  ),
                visible: data['needToShowDesktopStaff'],
              )
            ],
          ),
        )
      ],
    );
  }

  Future<dynamic> fetchBalanceSummary() async {

    String url = baseUrl + "/transactions/balance-summary-query?account-holder-id=${userInfo['id']}";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['code'] == 200) {
        setState(() {
          balance = res['balance'].toString();
          withdrawAmount = res['withdrawTransaction']['debitAmount'].toString();
        });
      }
    }

    return response;

  }

  Future<void> logout(BuildContext context) async {

    bool isSignInWithGoogle = await googleSignIn.isSignedIn();

    if(isSignInWithGoogle){
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }

    await FirebaseAuth.instance.signOut();
    await MySharedPreferences.clear("userInfo");

    Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);

  }
}