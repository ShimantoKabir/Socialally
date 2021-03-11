import 'package:wengine/components/NotificationComponent.dart';
import 'package:wengine/components/Profile.dart';
import 'package:wengine/components/admin/AdminDashboard.dart';
import 'package:wengine/components/admin/job/JobManager.dart';
import 'package:wengine/components/admin/job/category/JobCategory.dart';
import 'package:wengine/components/admin/job/category/JobSubCategory.dart';
import 'package:wengine/components/admin/notification/NotificationSender.dart';
import 'package:wengine/components/admin/setting/AdvertisementCost.dart';
import 'package:wengine/components/admin/setting/General.dart';
import 'package:wengine/components/admin/setting/PaymentGatewayManager.dart';
import 'package:wengine/components/admin/setting/SupportInfoManager.dart';
import 'package:wengine/components/admin/transaction/Requisition.dart';
import 'package:wengine/components/admin/user/UserManager.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/models/Transaction.dart';
import 'package:wengine/widgets/DashboardLeftNavigation.dart';
import 'package:wengine/widgets/DashboardTopNavigation.dart';
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
  Transaction transaction;

  @override
  void initState() {
    super.initState();
    nodes = adminDashboardMenus;
    transaction = null;
    treeViewController = TreeViewController(
      children: nodes,
      selectedKey: selectedKey,
    );
    html.window.history
        .pushState(null, "Admin Dashboard", "/#/admin/dashboard");
    viewTitle = "Dashboard";
    eventHub.on("openAndCloseSideNav", (dynamic data) {
      if (data['screenWidth'] > 960) {
        setState(() {
          isSideNavOpen = !isSideNavOpen;
        });
      } else {
        if (scaffoldKey.currentState.isDrawerOpen) {
          scaffoldKey.currentState.openEndDrawer();
        } else {
          scaffoldKey.currentState.openDrawer();
        }
      }
    });

    eventHub.on("redirectToProfile", (dynamic data) {
      setState(() {
        userInfo = data;
        userNavigatorKey.currentState.pushNamed("/user/profile");
      });
    });

    eventHub.on("redirectToTransaction", (dynamic data) {
      setState(() {
        transaction = data;
        userNavigatorKey.currentState.pushNamed("/transactions/requisition");
      });
    });

    eventHub.on("clearStaffBeforeNavigate", (dynamic data) {
      setState(() {
        transaction = null;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 960) {
      var logoutKey = nodes.where((element) => element.key == "/logout");
      if (logoutKey.isEmpty) {
        nodes.add(Node(
            label: 'Logout',
            key: '/logout',
            icon: NodeIcon.fromIconData(Icons.logout)));
      }
    } else {
      var logoutKey = nodes.where((element) => element.key == "/logout");
      if (logoutKey.isNotEmpty) {
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
            userNavigatorKey: userNavigatorKey),
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
                    userNavigatorKey: userNavigatorKey),
                visible: width > 960 && isSideNavOpen),
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
                        totalUnseenNotification:
                            userInfo["totalUnseenNotification"],
                        userInfo: userInfo),
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
                                onPressed: () {
                                  if (userNavigatorKey.currentState.canPop()) {
                                    userNavigatorKey.currentState.pop();
                                  }
                                }),
                            Text(
                              viewTitle,
                              style: TextStyle(fontSize: 20),
                            )
                          ],
                        )),
                    // component body
                    Expanded(
                      child: Container(
                        child: Row(
                          children: [
                            Expanded(
                              child: Navigator(
                                key: userNavigatorKey,
                                onGenerateRoute: (settings) {
                                  if (settings.name ==
                                      "/transactions/requisition") {
                                    return MaterialPageRoute(
                                        builder: (context) => Requisition(
                                          eventHub: eventHub,
                                          userInfo: userInfo,
                                          transactionQuery: transaction,
                                        ));
                                  } else if (settings.name ==
                                      "/admins/notifications") {
                                    return MaterialPageRoute(
                                        builder: (context) => NotificationComponent(
                                              eventHub: eventHub,
                                              userInfo: userInfo,
                                              type: 2,
                                            ));
                                  } else if (settings.name ==
                                      "/notifications/send") {
                                    return MaterialPageRoute(
                                        builder: (context) => NotificationSender(
                                            eventHub: eventHub,
                                            userInfo: userInfo));
                                  } else if (settings.name == "/job/approve") {
                                    return MaterialPageRoute(
                                        builder: (context) => JobManager(
                                            eventHub: eventHub,
                                            userInfo: userInfo));
                                  } else if (settings.name == "/settings/general") {
                                    return MaterialPageRoute(
                                        builder: (context) => General(
                                            eventHub: eventHub,
                                            userInfo: userInfo));
                                  } else if (settings.name ==
                                      "/categories/create") {
                                    return MaterialPageRoute(
                                        builder: (context) => JobCategory(
                                            eventHub: eventHub,
                                            userInfo: userInfo));
                                  } else if (settings.name ==
                                      "/categories/create-sub-category") {
                                    return MaterialPageRoute(
                                        builder: (context) => JobSubCategory(
                                            eventHub: eventHub,
                                            userInfo: userInfo));
                                  } else if (settings.name ==
                                      "/settings/advertisement-cost") {
                                    return MaterialPageRoute(
                                        builder: (context) => AdvertisementCost(
                                            eventHub: eventHub,
                                            userInfo: userInfo));
                                  } else if (settings.name ==
                                      "/settings/support-info") {
                                    return MaterialPageRoute(
                                        builder: (context) => SupportInfoManager(
                                            eventHub: eventHub,
                                            userInfo: userInfo));
                                  } else if (settings.name ==
                                      "/settings/payment-gateway") {
                                    return MaterialPageRoute(
                                        builder: (context) => PaymentGatewayManager(
                                            eventHub: eventHub,
                                            userInfo: userInfo));
                                  }else if (settings.name ==
                                      "/user/profile") {
                                    return MaterialPageRoute( builder: (context) => Profile(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 2
                                    ));
                                  }else if (settings.name ==
                                      "/user/manage") {
                                    return MaterialPageRoute( builder: (context) => UserManager(
                                        eventHub: eventHub,
                                        userInfo: userInfo
                                    ));
                                  } else {
                                    return MaterialPageRoute(builder: (context) => AdminDashboard(
                                      eventHub: eventHub,
                                      userInfo: userInfo
                                    ));
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
