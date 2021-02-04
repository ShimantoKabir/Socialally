import 'package:client/components/job/Available.dart';
import 'package:client/components/Profile.dart';
import 'package:client/components/job/Post.dart';
import 'package:client/constants.dart';
import 'package:client/models/Project.dart';
import 'package:client/utilities/MySharedPreferences.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:client/components/job/ProofSubmissionComponent.dart';

class User extends StatefulWidget {
  User({Key key, this.userInfo}) : super(key: key);
  final userInfo;

  @override
  UserPageState createState() => UserPageState(userInfo: userInfo);
}

class UserPageState extends State<User> with SingleTickerProviderStateMixin {
  var userInfo;
  UserPageState({Key key, this.userInfo});

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

  @override
  void initState() {
    super.initState();
    nodes = userDashboardMenus;

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

    showProfilePic(userInfo);
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

  TreeViewTheme _treeViewTheme = treeViewTheme;

  var userNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 300,
            height: screenSize.height,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey,
                  width: 0.5,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 1, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      height: 100.0,
                      width: 100.0,
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TreeView(
                      controller: treeViewController,
                      allowParentSelect: true,
                      supportParentDoubleTap: false,
                      onNodeTap: (key) {
                        setState(() {
                          treeViewController = treeViewController
                              .copyWith(selectedKey: key);
                          userNavigatorKey.currentState.pushNamed(key);
                        });
                      },
                      theme: _treeViewTheme
                    )
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: screenSize.height,
              child: Column(
                children: [
                  Container(
                    height: 70,
                    width: screenSize.width - 300,
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
                                onTap: () {},
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                          child: Row(
                            children: [
                              InkWell(
                                child: Icon(Icons.notifications_active),
                                onTap: () {},
                              ),
                              SizedBox(width: 10),
                              InkWell(
                                child: Icon(Icons.account_circle_rounded),
                                onTap: () {
                                  userNavigatorKey.currentState.pushNamed('/user/profile');
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
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    height: 50,
                    width: screenSize.width - 300,
                    color: Colors.black12,
                    child: Text(
                      viewTitle,
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    height: screenSize.height - 130,
                    width: screenSize.width - 300,
                    child: Row(
                      children: [
                        Expanded(
                          child: Navigator(
                            key: userNavigatorKey,
                            onGenerateRoute: (settings){
                              if(settings.name == "/user/profile"){
                                return MaterialPageRoute(builder: (context) => Profile(eventHub: eventHub,userInfo: userInfo));
                              } else if(settings.name == "/job/post"){
                                return MaterialPageRoute(builder: (context) => Post(eventHub: eventHub,userInfo: userInfo));
                              } else if(settings.name == "/job/available"){
                                return MaterialPageRoute(builder: (context) => Available(eventHub: eventHub,userInfo: userInfo));
                              }else if(settings.name == "/job/submit"){
                                return MaterialPageRoute(builder: (context) => ProofSubmissionComponent(
                                    eventHub: eventHub,
                                    userInfo: userInfo,
                                    project: project,
                                  )
                                );
                              } else {
                                return MaterialPageRoute(builder: (context) => Available(eventHub: eventHub,userInfo: userInfo));
                              }
                            },
                          ),
                          flex: 4,
                        ),
                        Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              padding: EdgeInsets.all(20),
                              color: Colors.white60,
                              child: Column(
                                children: [
                                  Container(
                                    height: 70.0,
                                    width: 70.0,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: profileImageWidget),
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
                                      ))
                                ],
                              ),
                            ),
                            flex: 2)
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
