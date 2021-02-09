import 'package:client/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';

class DashboardLeftNavigation extends StatefulWidget {
  DashboardLeftNavigation({
    Key key,
    this.type,
    this.isSideNavOpen,
    this.treeViewController,
    this.userNavigatorKey
  }) : super(key: key);

  final int type;
  final bool isSideNavOpen;
  final TreeViewController treeViewController;
  final userNavigatorKey;

  @override
  DashboardLeftNavigationState createState() => DashboardLeftNavigationState(
    type: type,
    isSideNavOpen: isSideNavOpen,
    treeViewController: treeViewController,
    userNavigatorKey: userNavigatorKey
  );
}


class DashboardLeftNavigationState extends State<DashboardLeftNavigation>{

  int type;
  bool isSideNavOpen;
  TreeViewController treeViewController;
  var userNavigatorKey;

  DashboardLeftNavigationState({
    Key key,
    this.type,
    this.isSideNavOpen,
    this.treeViewController,
    this.userNavigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: isSideNavOpen,
        child: Expanded(
          child: Container(
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
                          onNodeTap: (path) {
                            setState(() {
                              treeViewController = treeViewController
                                  .copyWith(selectedKey: path);
                              userNavigatorKey.currentState
                                  .pushNamedAndRemoveUntil(
                                  path, (route) => false
                              );
                            });
                          },
                          theme: tvt
                      )
                  )
                ],
              ),
            ),
          ),
          flex: 1,
        )
    );
  }
}