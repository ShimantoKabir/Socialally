import 'package:client/utilities/MySharedPreferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardTopNavigation extends StatefulWidget {
  DashboardTopNavigation({
    Key key,
    this.type,
    this.isSideNavOpen,
    this.userNavigatorKey
  }) : super(key: key);

  final int type;
  final bool isSideNavOpen;
  final userNavigatorKey;

  @override
  DashboardTopNavigationState createState() => DashboardTopNavigationState(
      type: type,
      isSideNavOpen: isSideNavOpen,
      userNavigatorKey: userNavigatorKey
  );
}


class DashboardTopNavigationState extends State<DashboardTopNavigation>{

  int type;
  bool isSideNavOpen;
  var userNavigatorKey;

  DashboardTopNavigationState({
    Key key,
    this.type,
    this.isSideNavOpen,
    this.userNavigatorKey,
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
                        setState(() {
                          isSideNavOpen = !isSideNavOpen;
                        });
                      },
                    )),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: Row(
                  children: [
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