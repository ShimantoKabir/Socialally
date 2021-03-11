import 'package:wengine/utilities/MySharedPreferences.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';

class DashboardLeftNavigation extends StatefulWidget {
  DashboardLeftNavigation({
    Key key,
    this.positionType,
    this.eventHub,
    this.treeViewController,
    this.userNavigatorKey
  }) : super(key: key);

  final int positionType;
  final EventHub eventHub;
  final TreeViewController treeViewController;
  final userNavigatorKey;

  @override
  DashboardLeftNavigationState createState() => DashboardLeftNavigationState(
    positionType: positionType,
    eventHub: eventHub,
    treeViewController: treeViewController,
    userNavigatorKey: userNavigatorKey
  );
}


class DashboardLeftNavigationState extends State<DashboardLeftNavigation>{

  int positionType;
  EventHub eventHub;
  TreeViewController treeViewController;
  var userNavigatorKey;

  DashboardLeftNavigationState({
    Key key,
    this.positionType,
    this.eventHub,
    this.treeViewController,
    this.userNavigatorKey,
  });

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if(positionType == 1){
      return SafeArea(child:getContent({
        "width" : width
      }));
    }else {
      return Expanded(
        child: getContent({
          "width" : width
        }),
        flex: 1,
      );
    }
  }

  Widget getContent(var data){
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                height: 130.0,
                width: 130.0,
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
                onNodeTap: (path) {
                  eventHub.fire("clearStaffBeforeNavigate");
                  if(data['width'] < 960){
                    eventHub.fire("openAndCloseSideNav",{
                      "screenWidth" : data['width']
                    });
                  }
                  setState(() {
                    treeViewController = treeViewController.copyWith(
                      selectedKey: path
                    );

                    if(treeViewController.selectedKey == "/logout"){
                      MySharedPreferences.clear("userInfo").then((isClear) {
                        if (isClear) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/", (r) => false
                          );
                        }
                      });
                    }else {
                      userNavigatorKey.currentState.pushNamedAndRemoveUntil(
                          path, (route) => false
                      );
                    }
                  });
                },
              )
            ),
            Center(
              child: InkWell(
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_sharp,
                        color: Colors.blueGrey,
                      ),
                      Text(
                        "Close",
                        style: TextStyle(
                            color: Colors.blueGrey
                        ),
                      )
                    ],
                  ),
                ),
                onTap: (){
                  eventHub.fire("openAndCloseSideNav",{
                    "screenWidth" : data['width']
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

}