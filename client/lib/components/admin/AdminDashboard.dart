import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  AdminDashboardState createState() => AdminDashboardState(userInfo: userInfo, eventHub: eventHub);
}

class AdminDashboardState extends State<AdminDashboard> {
  var userInfo;
  EventHub eventHub;
  AdminDashboardState({Key key, this.userInfo, this.eventHub});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Welcome to Dashboard",
          style: TextStyle(
            fontSize: 30,
            color: Colors.red
          ),
        ),
      ),
    );
  }
}