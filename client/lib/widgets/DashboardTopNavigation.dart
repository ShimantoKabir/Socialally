import 'package:badges/badges.dart';
import 'package:client/utilities/MySharedPreferences.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: IconButton(
                  icon: Icon(
                    Icons.apps,
                    size: 20,
                    color: Colors.black
                  ),
                  onPressed: () async {
                    eventHub.fire("openAndCloseSideNav");
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: Row(
                  children: [
                    Visibility(
                      child: IconButton(
                        icon: Icon(
                          Icons.refresh,
                          size: 20,
                          color: Colors.black
                        ),
                        onPressed: (){

                        },
                      ),
                      visible: type == 1,
                    ),
                    Visibility(
                      child: FlatButton(
                        onPressed: () => {

                        },
                        color: Colors.blue,
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: Row(
                          children: <Widget>[
                            Text("Deposit  ${userInfo['totalDeposit']} \$ ",
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                      visible: type == 1,
                    ),
                    SizedBox(width: 10),
                    Visibility(
                      child: FlatButton(
                        onPressed: () => {

                        },
                        color: Colors.red,
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: Row(
                          children: <Widget>[
                            Text("Withdraw  ${userInfo['totalWithdraw']} \$ ",
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                      visible: type == 1,
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
                            Text("Balance  ${userInfo['totalDeposit'] - userInfo['totalWithdraw']} \$ ",
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
                    IconButton(
                      icon: Icon(
                        Icons.account_circle_rounded,
                        size: 20,
                        color: Colors.black
                      ),
                      onPressed: () {
                        if(type == 1){
                          userNavigatorKey.currentState.pushNamed('/user/profile');
                        }else {
                          userNavigatorKey.currentState.pushNamed('/admin/profile');
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.logout,
                        size: 20,
                        color: Colors.black
                      ),
                      onPressed: () {
                        MySharedPreferences.clear("userInfo")
                            .then((isClear) {
                          if (isClear) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, "/", (r) => false);
                          }
                        });
                      },
                    )
                  ],
                ),
              )
            ],
          )
      ),
      flex: 1,
    );
  }
}