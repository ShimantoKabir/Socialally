import 'dart:convert';

import 'package:client/constants.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/models/MyNotification.dart';
import 'package:http/http.dart';

class NotificationComponent extends StatefulWidget {

  NotificationComponent({
    Key key,
    this.eventHub,
    this.type,
    this.userInfo
  }) : super(key: key);

  final EventHub eventHub;
  final userInfo;
  final type;

  @override
  NotificationComponentState createState() => NotificationComponentState(
    key: key,
    eventHub: eventHub,
    type: type,
    userInfo: userInfo
  );
}

class NotificationComponentState extends State<NotificationComponent> {
  EventHub eventHub;
  var userInfo;
  int type;

  NotificationComponentState({
    Key key,
    this.eventHub,
    this.type,
    this.userInfo
  });

  AlertDialog alertDialog;
  Future futureNotifications;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  int pageIndex = 0;
  int perPage = 10;
  int pageNumber = 0;
  List<MyNotification> notifications;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle", "Notifications");
    futureNotifications = fetchNotifications();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        scrollDirection: Axis.vertical,
        child: FutureBuilder(
          future: futureNotifications,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              notifications = snapshot.data;
              if(notifications.length > 0){
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: ListTile(
                        leading: Icon(Icons.touch_app),
                        title: Text(notifications[index].message),
                        subtitle: Text(
                          "Send By ${notifications[index].senderName}/ "
                              "${notifications[index].createdAt}",
                          style: TextStyle(
                              fontStyle: FontStyle.normal
                          ),
                        ),
                        tileColor: notifications[index].isSeen == 1 ? Colors.black12 : Colors.black26,
                        onTap: (){
                          if(notifications[index].isSeen == 0){
                            onUpdate(index);
                          }
                        },
                      ),
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    );
                  },
                );
              }else {
                return Center(
                  child: Text("No notification found!"),
                );
              }
            }else {
              return Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              );
            }
          }
        ),
      ),
      bottomNavigationBar: AbsorbPointer(
        absorbing: needToFreezeUi,
        child: Container(
          color: Colors.black12,
          height: 50.0,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(icon: Icon(Icons.filter_alt_outlined), onPressed: (){

              }),
              Visibility(
                  visible: needToFreezeUi,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    strokeWidth: 2,
                  )
              ),
              Row(
                children: [
                  IconButton(
                      icon: Icon(
                          Icons.arrow_back_ios,
                          size: 15
                      ),
                      onPressed: (){
                        if(pageIndex < 1){
                          Alert.show(alertDialog, context, Alert.ERROR, "Your are already in the first page!");
                        }else {
                          pageNumber--;
                          pageIndex = pageIndex - perPage;
                          needToFreezeUi = true;
                          setState(() {
                            futureNotifications = fetchNotifications();
                          });
                        }
                      }
                  ),
                  Text("${pageNumber+1}"),
                  IconButton(
                      icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 15
                      ),
                      onPressed: (){
                        pageIndex = pageIndex + perPage;
                        needToFreezeUi = true;
                        pageNumber++;
                        setState(() {
                          futureNotifications = fetchNotifications();
                        });
                      }
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future fetchNotifications() async {

    List<MyNotification> notificationList = [];
    String url = baseUrl + "/notifications/query?user-info-id=${userInfo['id']}&type=$type&per-page=$perPage&page-index=$pageIndex";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['code'] == 200) {
        List<dynamic> notifications = res['notifications'];
        notifications.asMap().forEach((key, notification) {
          notificationList.add(new MyNotification(
            id: notification['id'],
            message: notification['message'],
            receiverId: notification['receiverId'],
            senderId: notification['senderId'],
            isSeen: notification['isSeen'],
            type: notification['type'],
            senderName: notification['senderName'],
            createdAt: notification['createdAt']
          ));
        });
      }
    }
    setState(() {
      needToFreezeUi = false;
    });
    return notificationList;
  }

  Future<void> onUpdate(int index) async {

    var request = {
      "notification": {
        "id": notifications[index].id
      }
    };

    String url = baseUrl + '/notifications';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    put(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          setState(() {
            notifications[index].isSeen = 1;
          });
          Alert.show(alertDialog, context, Alert.SUCCESS, body['msg']);
        } else {
          Alert.show(alertDialog, context, Alert.ERROR, body['msg']);
        }
      } else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }).catchError((err) {
      setState(() {
        needToFreezeUi = false;
      });
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    });

  }
}