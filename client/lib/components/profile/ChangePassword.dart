import 'dart:convert';

import 'package:client/constants.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({Key key, this.eventHub, this.userInfo}) : super(key: key);
  final EventHub eventHub;
  final userInfo;

  @override
  ChangePasswordState createState() =>
      ChangePasswordState(key: key, eventHub: eventHub, userInfo: userInfo);
}

class ChangePasswordState extends State<ChangePassword>{

  EventHub eventHub;
  var userInfo;

  ChangePasswordState({Key key, this.eventHub, this.userInfo});

  TextEditingController oldPasswordCtl = new TextEditingController();
  TextEditingController newPasswordCtl = new TextEditingController();
  bool needToFreezeUi;
  Widget alertIcon;
  String alertText;
  AlertDialog alertDialog;


  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle", "Change Password");
    alertText = "No operation running!";
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
            children: [
              entryField("Old Password",oldPasswordCtl),
              entryField("New Password",newPasswordCtl),
              SizedBox(
                height: 20,
              ),
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
                      child: Text("Save")),
                  OutlineButton(
                      onPressed: () {
                        onReset(context);
                      },
                      child: Text("Reset"))
                ],
              )
            ],
          ),
        ),
        bottomNavigationBar: Alert.addBottomLoader(
          needToFreezeUi,
          alertIcon,
          alertText
        )
      ),
    );
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
            obscureText: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true
            )
          )
        ],
      ),
    );
  }

  bool verifyInput(BuildContext buildContext) {
    bool isInputVerified = true;
    String errMsg;

    if (oldPasswordCtl.text.isEmpty) {
      errMsg = "Old password required!";
      isInputVerified = false;
    } else if (!passwordRegExp.hasMatch(oldPasswordCtl.text)) {
      errMsg = "Password should contain at least 8 character, "
          "one capital letter, one number and one special character!";
      isInputVerified = false;
    } else if (newPasswordCtl.text.isEmpty) {
      errMsg = "New password required!";
      isInputVerified = false;
    } else if (!passwordRegExp.hasMatch(newPasswordCtl.text)) {
      errMsg = "Password should contain at least 8 character, "
          "one capital letter, one number and one special character!";
      isInputVerified = false;
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, buildContext, Alert.ERROR, errMsg);
    }
    return isInputVerified;

  }

  void onSave(BuildContext context) {

    var request = {
      "userInfo": {
        "id" : userInfo['id'],
        "oldPassword" : oldPasswordCtl.text,
        "newPassword" : newPasswordCtl.text
      }
    };

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    String url = baseUrl + '/users/password';
    Map<String, String> headers = {"Content-type": "application/json"};

    put(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          onReset(context);
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

  void onReset(BuildContext context) {

    oldPasswordCtl.clear();
    newPasswordCtl.clear();

  }

}