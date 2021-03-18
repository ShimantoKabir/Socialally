import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/utilities/Alert.dart';
import 'package:wengine/widgets/WelcomeNavBar.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({Key key, this.forgotPasswordId}) : super(key: key);
  final String forgotPasswordId;
  @override
  ForgotPasswordState createState() => ForgotPasswordState(
      forgotPasswordId: forgotPasswordId
  );
}

class ForgotPasswordState extends State<ForgotPassword> {

  String forgotPasswordId;
  ForgotPasswordState({Key key,this.forgotPasswordId});

  AlertDialog alertDialog;
  TextEditingController emailCtl = new TextEditingController();
  TextEditingController passwordCtl = new TextEditingController();
  TextEditingController confirmPasswordCtl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              WelcomeNavBar(type: 2),
              Container(
                width: 500,
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(height: screenSize.height * 0.05),
                    logo(screenSize),
                    Divider(
                      color: Colors.lightGreenAccent,
                      thickness: 1,
                    ),
                    SizedBox(height: 20),
                    entryField(
                      title: "Email",
                      controller: emailCtl,
                    ),
                    SizedBox(height: 20),
                    submitButton(context),
                    SizedBox(height: screenSize.height * .005),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }

  Widget entryField({String title,
    TextEditingController controller,
    TextInputType textInputType,
    List<TextInputFormatter> textInputFormatter,
    int maxLines,
    bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          showRequiredHeading(title),
          SizedBox(
            height: 10,
          ),
          TextField(
              maxLines: maxLines == null ? 1 : maxLines,
              keyboardType: textInputType,
              obscureText: isPassword,
              controller: controller,
              inputFormatters: textInputFormatter,
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

  Widget submitButton(BuildContext buildContext) {
    return InkWell(
      onTap: () {
        onSubmit(buildContext);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.green, Colors.greenAccent])),
        child: Text(
          forgotPasswordId == "empty" ? 'Get Password Reset Link' : "Change Password",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  onSubmit(BuildContext context){
    bool isInputVerified = verifyInput(context);
    if (isInputVerified) {
      var request = {
        "userInfo": {
          "email": emailCtl.text
        }
      };

      String url = baseUrl + '/users/login';
      Map<String, String> headers = {"Content-type": "application/json"};

      Alert.show(
          alertDialog, context, Alert.LOADING, Alert.LOADING_MSG);
      post(url, headers: headers, body: json.encode(request)).then((res) {
        Navigator.of(context).pop(false);
        if (res.statusCode == 200) {
          var body = json.decode(res.body);
          if (body['code'] == 200) {


          } else {
            Alert.show(
                alertDialog, context, Alert.ERROR, body['msg']);
          }
        } else {
          Alert.show(
              alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
        }
      }).catchError((err) {
        Navigator.of(context).pop(false);
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      });
    }
  }

  Widget logo(Size screenSize) {
    return Center(
      child: Container(
        height: 50.0,
        width: screenSize.width,
        child: Text("Forgot Password",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold
            )
        ),
      ),
    );
  }

  bool verifyInput(BuildContext context) {
    return true;
  }

}