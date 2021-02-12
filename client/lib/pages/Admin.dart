import 'package:client/components/NotificationComponent.dart';
import 'package:client/components/admin/AdminDashboard.dart';
import 'package:client/components/admin/transaction/Requisition.dart';
import 'package:client/constants.dart';
import 'package:client/widgets/DashboardLeftNavigation.dart';
import 'package:client/widgets/DashboardTopNavigation.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class Admin extends StatefulWidget {
  Admin({Key key, this.userInfo}) : super(key: key);
  final userInfo;

  @override
  AdminState createState() => AdminState(userInfo: userInfo);
}

class AdminState extends State<Admin> with SingleTickerProviderStateMixin {
  var userInfo;
  AdminState({Key key, this.userInfo});

  String selectedKey;
  List<Node> nodes;
  TreeViewController treeViewController;
  bool docsOpen = true;
  bool deepExpanded = true;
  EventHub eventHub = EventHub();
  String viewTitle;
  TextEditingController searchCtl = new TextEditingController();
  AlertDialog alertDialog;
  var userNavigatorKey = GlobalKey<NavigatorState>();
  bool isSideNavOpen = true;

  @override
  void initState() {
    super.initState();
    nodes = adminDashboardMenus;
    treeViewController = TreeViewController(
      children: nodes,
      selectedKey: selectedKey,
    );
    html.window.history.pushState(null,"Admin Dashboard","/#/admin/dashboard");
    viewTitle = "Dashboard";
    eventHub.on("openAndCloseSideNav", (dynamic data) {
      setState(() {
        isSideNavOpen = !isSideNavOpen;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // side menu bar
          DashboardLeftNavigation(
            type: 2,
            eventHub: eventHub,
            treeViewController: treeViewController,
            userNavigatorKey: userNavigatorKey
          ),
          // body with top menu bar, title and body
          Expanded(
            child: Container(
              child: Column(
                children: [
                  // top menu bar
                  DashboardTopNavigation(
                    type: 2,
                    eventHub: eventHub,
                    userNavigatorKey: userNavigatorKey,
                    totalUnseenNotification: userInfo["totalUnseenNotification"],
                    userInfo: userInfo
                  ),
                  // component tile
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(5),
                      color: Colors.black12,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: (){
                              if(userNavigatorKey.currentState.canPop()){
                                userNavigatorKey.currentState.pop();
                              }
                            }
                          ),
                          Text(
                            viewTitle,
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      )
                    ),
                    flex: 1,
                  ),
                  // component body
                  Expanded(
                    child: Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Navigator(
                              key: userNavigatorKey,
                              onGenerateRoute: (settings){
                                if(settings.name == "/transactions/requisition"){
                                  return MaterialPageRoute(builder: (context) => Requisition(
                                      eventHub: eventHub,
                                      userInfo: userInfo
                                    )
                                  );
                                }else if(settings.name == "/admins/notifications"){
                                  return MaterialPageRoute(builder: (context) => NotificationComponent(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 2,
                                    )
                                  );
                                } else {
                                  return MaterialPageRoute(builder: (context) => AdminDashboard(
                                      eventHub: eventHub,
                                      userInfo: userInfo
                                    )
                                  );
                                }
                              },
                            )
                          )
                        ],
                      ),
                    ),
                    flex: 13,
                  )
                ],
              ),
            ),
            flex: 4,
          )
        ],
      ),
    );
  }
}
