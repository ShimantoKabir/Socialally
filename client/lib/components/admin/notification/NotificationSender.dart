import 'dart:convert';

import 'package:socialally/constants.dart';
import 'package:socialally/models/UserInfo.dart';
import 'package:socialally/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';

class NotificationSender extends StatefulWidget {
  NotificationSender({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  NotificationSenderState createState() => NotificationSenderState(
      userInfo: userInfo,
      eventHub: eventHub
  );
}

class NotificationSenderState extends State<NotificationSender> {
  var userInfo;
  EventHub eventHub;

  NotificationSenderState({Key key, this.userInfo, this.eventHub});

  String selectNotificationFor;
  TextEditingController receiverNameCtl = TextEditingController();
  TextEditingController notificationCtl = TextEditingController();
  SuggestionsBoxController suggestionsBoxController  = SuggestionsBoxController();
  UserInfo receiverInfo;
  AlertDialog alertDialog;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;

  @override
  void initState() {
    super.initState();
    selectNotificationFor = "Select";
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
  }


  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: needToFreezeUi,
      child: Scaffold(
        body: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                showRequiredHeading("Send Notification To"),
                SizedBox(
                  height: 10,
                ),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                    child: DropdownButton<String>(
                        value: selectNotificationFor,
                        isExpanded: true,
                        underline: SizedBox(),
                        onChanged: (String newValue) {
                          setState(() {
                            selectNotificationFor = newValue;
                            receiverNameCtl.clear();
                            receiverInfo = null;
                          });
                        },
                        items: notificationForDropDownList
                    )
                ),
                SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: selectNotificationFor == "Individual",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      showRequiredHeading("Receiver"),
                      OutlineButton(
                        onPressed: (){
                          clearSuggestion(context);
                        },
                        child: Text("Clear Suggestion"),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Visibility(
                    visible: selectNotificationFor == "Individual",
                    child: TypeAheadField(
                      suggestionsBoxController: suggestionsBoxController,
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: receiverNameCtl,
                          decoration: InputDecoration(
                              hintText: "Search receiver ....",
                              border: OutlineInputBorder()
                          )
                      ),
                      suggestionsCallback: (pattern) async {
                        return fetchReceiver(pattern);
                      },
                      itemBuilder: (context, UserInfo u) {
                        return ListTile(
                            leading: Icon(Icons.account_tree),
                            title: Text(u.firstName)
                        );
                      },
                      onSuggestionSelected: (UserInfo u) {
                        receiverNameCtl.text = u.firstName;
                        receiverInfo = u;
                      },
                    )
                ),
                entryField("Notification",notificationCtl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlineButton(
                        onPressed: () {
                          bool isInputVerified = verifyInput(context);
                          if (isInputVerified) {
                            onSave(context);
                          }
                        },
                        child: Text("Save")
                    ),
                    OutlineButton(
                        onPressed: () {
                          onReset(context);
                        },
                        child: Text("Reset")
                    )
                  ],
                )
              ],
            )
        ),
        bottomNavigationBar: Alert.addBottomLoader(
          needToFreezeUi,
          alertIcon,
          alertText
        )
      ),
    );
  }

  Future<List<UserInfo>> fetchReceiver(String pattern) async {

    List<UserInfo> userInfoList = [];
    String url = baseUrl + "/users/query?first-name=$pattern";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['code'] == 200) {
        List<dynamic> userInfos = res['userInfos'];
        userInfos.asMap().forEach((key, project) {
          userInfoList.add(new UserInfo(
              id: project['id'],
              firstName: project['firstName']
          ));
        });
      }
    }
    return userInfoList;
  }

  Widget entryField(String title, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          showRequiredHeading(title),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: controller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  bool verifyInput(BuildContext buildContext) {

    bool isInputVerified = true;
    String errMsg;

    if (selectNotificationFor == "Select") {
      isInputVerified = false;
      errMsg = "Please select to whom you wants to send notification or all";
    }else if(selectNotificationFor == "Individual" && receiverInfo == null){
      isInputVerified = false;
      errMsg = "Please a receiver to send notification";
    }else if(notificationCtl.text.isEmpty){
      isInputVerified = false;
      errMsg = "Please writhe a notification to send!";
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, buildContext, Alert.ERROR, errMsg);
    }
    return isInputVerified;

  }

  void onReset(BuildContext context) {

    setState(() {
      notificationCtl.clear();
      selectNotificationFor = "Select";
      clearSuggestion(context);
    });

  }

  void clearSuggestion(BuildContext context) {
    receiverNameCtl.clear();
    suggestionsBoxController.close();
    receiverInfo = null;
  }

  void onSave(BuildContext context) {

    var request = {
      "notification": {
        "isForAll" : selectNotificationFor == "Individual" ? 0 : 1,
        "receiverId" : selectNotificationFor == "Individual" ? receiverInfo.id :
          0,
        "message" : notificationCtl.text
      }
    };

    String url = baseUrl + '/notifications';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    post(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        print(body['code']);
        if (body['code'] == 200) {
          setState(() {
            notificationCtl.clear();
            selectNotificationFor = "Select";
          });
          Alert.show(alertDialog, context, Alert.SUCCESS, body['msg']);
        } else {
          Alert.show(alertDialog, context, Alert.ERROR, body['msg']);
        }
      } else {

        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }).catchError((err) {
      print(err);
      setState(() {
        needToFreezeUi = false;
      });
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    });

  }

}