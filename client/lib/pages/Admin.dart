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
import 'package:universal_html/html.dart' as html;

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
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

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
      if(data['screenWidth'] > 960){
        setState(() {
          isSideNavOpen = !isSideNavOpen;
        });
      }else {
        if (scaffoldKey.currentState.isDrawerOpen) {
          scaffoldKey.currentState.openEndDrawer();
        } else {
          scaffoldKey.currentState.openDrawer();
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if(width<960){
      var logoutKey = nodes.where((element) => element.key == "/logout");
      if(logoutKey.isEmpty){
        nodes.add(Node(
            label: 'Logout',
            key: '/logout',
            icon: NodeIcon.fromIconData(Icons.logout)
        ));
      }
    }else {
      var logoutKey = nodes.where((element) => element.key == "/logout");
      if(logoutKey.isNotEmpty){
        nodes.removeWhere((element) => element.key == "/logout");
      }
    }
    return Scaffold(
      key: scaffoldKey,
      drawer: Visibility(
        child: DashboardLeftNavigation(
            positionType: 1,
            eventHub: eventHub,
            treeViewController: treeViewController,
            userNavigatorKey: userNavigatorKey
        ),
        visible: width < 960,
      ),
      body: SafeArea(
        child: Row(
          children: [
            // side menu bar
            Visibility(
              child: DashboardLeftNavigation(
                  positionType: 2,
                eventHub: eventHub,
                treeViewController: treeViewController,
                userNavigatorKey: userNavigatorKey
              ),
              visible: width > 960 && isSideNavOpen
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
                    Container(
                        height: 50,
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
        )
      ),
    );
  }
}
