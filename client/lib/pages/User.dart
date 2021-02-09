import 'package:client/components/job/Available.dart';
import 'package:client/components/Profile.dart';
import 'package:client/components/job/Post.dart';
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
import 'dart:html' as html;

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

  @override
  void initState() {
    super.initState();
    nodes = userDashboardMenus;

    html.window.history.pushState(null,"User Dashboard","/#/user/dashboard");

    treeViewController = TreeViewController(
      children: nodes,
      selectedKey: selectedKey,
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

    showProfilePic(userInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // side menu bar
          DashboardLeftNavigation(
              type: 1,
              isSideNavOpen: isSideNavOpen,
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
                      type: 1,
                      isSideNavOpen: isSideNavOpen,
                      userNavigatorKey: userNavigatorKey
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
                                if(settings.name == "/user/profile"){
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
                                      type: 1)
                                  );
                                }else if(settings.name == "/job/accept"){
                                  return MaterialPageRoute(builder: (context) => Available(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 2)
                                  );
                                } else if(settings.name == "/job/posted"){
                                  return MaterialPageRoute(builder: (context) => Available(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 3)
                                  );
                                }else if(settings.name == "/job/applied"){
                                  return MaterialPageRoute(builder: (context) => Available(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 4)
                                  );
                                } else if(settings.name == "/job/submit"){
                                  return MaterialPageRoute(builder: (context) => ProofSubmissionComponent(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      project: project)
                                  );
                                }else if(settings.name == "/wallet/deposit"){
                                  return MaterialPageRoute(builder: (context) => Deposit(
                                      eventHub: eventHub,
                                      userInfo: userInfo)
                                  );
                                }else if(settings.name == "/wallet/withdraw"){
                                  return MaterialPageRoute(builder: (context) => Withdraw(
                                      eventHub: eventHub,
                                      userInfo: userInfo)
                                  );
                                }else if(settings.name == "/wallet/history"){
                                  return MaterialPageRoute(builder: (context) => History(
                                      eventHub: eventHub,
                                      userInfo: userInfo)
                                  );
                                } else {
                                  return MaterialPageRoute(builder: (context) => Available(
                                      eventHub: eventHub,
                                      userInfo: userInfo,
                                      type: 1)
                                  );
                                }
                              },
                            ),
                            flex: 5
                          ),
                          Expanded(
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
                                  Visibility(
                                    visible:
                                    userInfo['profileCompleted'] != 100,
                                    child: FlatButton(
                                      onPressed: () {
                                        userNavigatorKey.currentState.pushNamed('/user/profile');
                                      },
                                      color: Colors.green,
                                      padding:
                                      EdgeInsets.fromLTRB(15, 10, 15, 10),
                                      child: Text(" Complete Now",
                                          style:
                                          TextStyle(color: Colors.white)),
                                    )
                                  )
                                ],
                              ),
                            ),
                            flex: 2
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
