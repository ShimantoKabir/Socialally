import 'package:client/utilities/MySharedPreferences.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardTopNavigation extends StatefulWidget {
  DashboardTopNavigation({
    Key key,
    this.type,
    this.eventHub,
    this.userNavigatorKey,
    this.userInfo
  }) : super(key: key);

  final int type;
  final EventHub eventHub;
  final userNavigatorKey;
  final userInfo;

  @override
  DashboardTopNavigationState createState() => DashboardTopNavigationState(
      type: type,
      eventHub: eventHub,
      userNavigatorKey: userNavigatorKey,
      userInfo: userInfo
  );
}


class DashboardTopNavigationState extends State<DashboardTopNavigation>{

  int type;
  EventHub eventHub;
  var userNavigatorKey;
  var userInfo;

  DashboardTopNavigationState({
    Key key,
    this.type,
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
                child: Padding(
                    padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    child: InkWell(
                      child: Icon(Icons.apps),
                      onTap: () async {
                        eventHub.fire("openAndCloseSideNav");
                      },
                    )),
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
                    InkWell(
                      child: Icon(Icons.notifications_active),
                      onTap: () {

                      },
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      child: Icon(Icons.account_circle_rounded),
                      onTap: () {
                        if(type == 1){
                          userNavigatorKey.currentState.pushNamed('/user/profile');
                        }else {
                          userNavigatorKey.currentState.pushNamed('/admin/profile');
                        }
                      },
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      child: Icon(Icons.logout),
                      onTap: () {
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