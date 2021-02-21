import 'package:client/components/NotificationComponent.dart';
import 'package:client/components/job/Available.dart';
import 'package:client/components/Profile.dart';
import 'package:client/components/job/Post.dart';
import 'package:client/components/user/advertisement/AdvertisedAny.dart';
import 'package:client/components/user/advertisement/AnyAdvertisementSender.dart';
import 'package:client/components/user/advertisement/JobAdvertisementSender.dart';
import 'package:client/components/wallet/Deposit.dart';
import 'package:client/components/wallet/History.dart';
import 'package:client/components/wallet/Withdraw.dart';
import 'package:client/constants.dart';
import 'package:client/models/Project.dart';
import 'package:client/widgets/DashboardLeftNavigation.dart';
import 'package:client/widgets/DashboardTopNavigation.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:client/components/job/ProofSubmissionComponent.dart';
import 'package:universal_html/html.dart' as html;

class User extends StatefulWidget {
  User({Key key, this.userInfo}) : super(key: key);
  final userInfo;

  @override
  UserState createState() => UserState(userInfo: userInfo);
}

class UserState extends State<User> with SingleTickerProviderStateMixin {
  var userInfo;
  UserState({Key key, this.userInfo});

  String selectedKey;
  List<Node> nodes;
  TreeViewController treeViewController;
  bool docsOpen = true;
  bool deepExpanded = true;
  EventHub eventHub = EventHub();
  String viewTitle;
  TextEditingController searchCtl = new TextEditingController();
  ImageProvider<Object> profileImageWidget;
  Project project;
  AlertDialog alertDialog;
  var userNavigatorKey = GlobalKey<NavigatorState>();
  bool isSideNavOpen = true;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    nodes = userDashboardMenus;
    html.window.history.pushState(null,"User Dashboard","/#/user/dashboard");
    treeViewController = TreeViewController(
      children: nodes,
      selectedKey: selectedKey
    );

    eventHub.on("userInfo", (dynamic data) {
      setState(() {
        userInfo = data;
        showProfilePic(userInfo);
      });
    });

    viewTitle = "Available Job";
    eventHub.on("viewTitle", (dynamic data) {
      setState(() {
        viewTitle = data;
      });
    });

    eventHub.on("redirectToProofSubmission", (dynamic data) {
      setState(() {
        project = data;
        userNavigatorKey.currentState.pushNamed("/job/submit");
      });
    });

    eventHub.on("redirectToAcceptJob", (dynamic data) {
      setState(() {
        userNavigatorKey.currentState.pushNamed("/job/accept");
      });
    });

    eventHub.on("redirectToPost", (dynamic data) {
      setState(() {
        project = data;
        userNavigatorKey.currentState.pushNamed("/job/post");
      });
    });

    eventHub.on("clearProject", (dynamic data) {
      setState(() {
        project = null;
      });
    });

    eventHub.on("redirectToAppliedJob", (dynamic data) {
      setState(() {
        project = data;
        userNavigatorKey.currentState.pushNamed("/job/applied");
      });
    });

    eventHub.on("redirectToPostedJob", (dynamic data) {
      setState(() {
        project = data;
        userNavigatorKey.currentState.pushNamed("/job/posted");
      });
    });

    eventHub.on("redirectToWalletHistory", (dynamic data) {
      setState(() {
        project = data;
        userNavigatorKey.currentState.pushNamed("/wallet/history");
      });
    });

    eventHub.on("redirectToJobAd", (dynamic data) {
      setState(() {
        project = data;
        userNavigatorKey.currentState.pushNamed("/advertisement/job");
      });
    });

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

    showProfilePic(userInfo);
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
      body: SafeArea(child:Row(
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
          Visibility(
            visible: true,
            child: Expanded(
              child: Container(
                child: Column(
                  children: [
                    // top menu bar
                    DashboardTopNavigation(
                      type: 1,
                      eventHub: eventHub,
                      totalUnseenNotification: userInfo["totalUnseenNotification"],
                      userNavigatorKey: userNavigatorKey,
                      userInfo: userInfo
                    ),
                    // component title
                    Container(
                      height: 25,
                      padding: EdgeInsets.all(3),
                      color: Colors.black12,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            child: Icon(Icons.arrow_back_ios,size: 15),
                            onTap: (){
                              if(userNavigatorKey.currentState.canPop()){
                                userNavigatorKey.currentState.pop();
                              }
                            }
                          ),
                          Text(
                            viewTitle.toUpperCase(),
                            style: TextStyle(fontSize: 12),
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
                                  if(settings.name == "/user/profile/update"){
                                    return MaterialPageRoute(builder: (context) => Profile(
                                      eventHub: eventHub,
                                      userInfo: userInfo
                                    ));
                                  } else if(settings.name == "/job/post"){
                                    return MaterialPageRoute(builder: (context) => Post(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      project: project
                                    ));
                                  } else if(settings.name == "/job/available"){
                                    return MaterialPageRoute(builder: (context) => Available(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 1
                                    ));
                                  }else if(settings.name == "/job/accept"){
                                    return MaterialPageRoute(builder: (context) => Available(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 2
                                    ));
                                  } else if(settings.name == "/job/posted"){
                                    return MaterialPageRoute(builder: (context) => Available(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 3
                                    ));
                                  }else if(settings.name == "/job/applied"){
                                    return MaterialPageRoute(builder: (context) => Available(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 4
                                    ));
                                  } else if(settings.name == "/job/submit"){
                                    return MaterialPageRoute(builder: (context) => ProofSubmissionComponent(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      project: project
                                    ));
                                  }else if(settings.name == "/wallet/deposit"){
                                    return MaterialPageRoute(builder: (context) => Deposit(
                                      eventHub: eventHub,
                                      userInfo: userInfo
                                    ));
                                  }else if(settings.name == "/wallet/withdraw"){
                                    return MaterialPageRoute(builder: (context) => Withdraw(
                                      eventHub: eventHub,
                                      userInfo: userInfo
                                    ));
                                  }else if(settings.name == "/wallet/history"){
                                    return MaterialPageRoute(builder: (context) => History(
                                      eventHub: eventHub,
                                      userInfo: userInfo
                                    ));
                                  }else if(settings.name == "/advertisement/job"){
                                    return MaterialPageRoute(builder: (context) => JobAdvertisementSender(
                                      eventHub: eventHub,
                                      userInfo: userInfo
                                    ));
                                  }else if(settings.name == "/advertisement/advertised/job"){
                                    return MaterialPageRoute(builder: (context) => Available(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 5
                                    ));
                                  }else if(settings.name == "/advertisement/any"){
                                    return MaterialPageRoute(builder: (context) => AnyAdvertisementSender(
                                      eventHub: eventHub,
                                      userInfo: userInfo
                                    ));
                                  }else if(settings.name == "/advertisement/advertised/any"){
                                    return MaterialPageRoute(builder: (context) => AdvertisedAny(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 2
                                    ));
                                  }else if(settings.name == "/users/notifications"){
                                    return MaterialPageRoute(builder: (context) => NotificationComponent(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 1
                                    ));
                                  }  else {
                                    return MaterialPageRoute(builder: (context) => Available(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 1
                                    ));
                                  }
                                }
                              ),
                              flex: 5
                            ),
                            Visibility(
                              child: Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          width: 1,
                                          color: Colors.black12
                                        )
                                      )
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                            child: Text(
                                              "Advertisement",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15
                                              ),
                                            ),
                                            padding: EdgeInsets.fromLTRB(0, 5, 0, 5)
                                        ),
                                        Expanded(
                                          child: AdvertisedAny(
                                            eventHub: eventHub,
                                            userInfo: userInfo,
                                            type: 1
                                          ),
                                          flex: 4,
                                        ),
                                        Visibility(
                                            visible:
                                            userInfo['profileCompleted'] != 100,
                                            child: Expanded(
                                                child: SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.all(20),
                                                    color: Colors.white70,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 70.0,
                                                          width: 70.0,
                                                          decoration: new BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            image: new DecorationImage(
                                                                fit: BoxFit.cover,
                                                                image: profileImageWidget
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 20),
                                                        Text(userInfo['email']),
                                                        SizedBox(height: 20),
                                                        LinearProgressIndicator(
                                                          backgroundColor: Colors.grey,
                                                          valueColor: AlwaysStoppedAnimation<Color>(
                                                              Colors.amber),
                                                          value: userInfo['profileCompleted'] / 100,
                                                        ),
                                                        SizedBox(height: 20),
                                                        Text(
                                                          "Profile Completed ${userInfo['profileCompleted']}%",
                                                          style:
                                                          TextStyle(fontWeight: FontWeight.bold),
                                                        ),
                                                        SizedBox(height: 20),
                                                        FlatButton(
                                                          onPressed: () {
                                                            userNavigatorKey.currentState.pushNamed('/user/profile/update');
                                                          },
                                                          color: Colors.green,
                                                          padding:
                                                          EdgeInsets.fromLTRB(15, 10, 15, 10),
                                                          child: Text(" Complete Now",
                                                              style:
                                                              TextStyle(color: Colors.white)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                flex: 3
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                  flex: 2
                              ),
                              visible: width > 950,
                            )
                          ],
                        ),
                      ),
                      flex: 13
                    )
                  ]
                )
              ),
              flex: 4
            ),
          )
        ]
      ))
    );
  }

  void showProfilePic(userInfo) {
    if (userInfo['imageUrl'] == null) {
      profileImageWidget = AssetImage("assets/images/people.png");
    } else {
      profileImageWidget = NetworkImage(userInfo['imageUrl']);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

}
