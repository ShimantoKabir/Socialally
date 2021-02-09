import 'dart:convert';
import 'package:client/constants.dart';
import 'package:client/pages/Admin.dart';
import 'package:client/pages/User.dart';
import 'package:client/utilities/Alert.dart';
import 'package:client/utilities/HttpHandler.dart';
import 'package:client/utilities/MySharedPreferences.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  Login({Key key, this.type}) : super(key: key);

  final type;
  @override
  LoginState createState() => LoginState(type: type);
}

class LoginState extends State<Login> {

  int type;
  LoginState({Key key,this.type});

  AlertDialog alertDialog;
  TextEditingController emailCtl = new TextEditingController();
  TextEditingController passwordCtl = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Container(
          height: screenSize.height,
          width: 500,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: screenSize.height * 0.05),
                logo(screenSize),
                Divider(
                  color: Colors.lightGreenAccent,
                  thickness: 1,
                ),
                SizedBox(height: 20),
                emailPasswordWidget(),
                SizedBox(height: 20),
                submitButton(context),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.centerRight,
                  child: Text('Forgot Password ?',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [facebookButton(), googleButton()],
                ),
                SizedBox(height: screenSize.height * .005),
                createAccountLabel(),
              ],
            ),
          ),
)
      )
    );
  }

  Widget entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: isPassword ? passwordCtl : emailCtl,
              obscureText: isPassword,
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
        bool isInputVerified = verifyInput(buildContext);
        if (isInputVerified) {
          var request = {
            "userInfo": {
              "email": emailCtl.text,
              "password": passwordCtl.text,
              "type" : type
            }
          };
          Alert.show(
              alertDialog, buildContext, Alert.LOADING, Alert.LOADING_MSG);
          HttpHandler().createPost("/users/login", request).then((res) {
            Navigator.of(buildContext).pop(false);
            if (res.statusCode == 200) {
              if (res.data['code'] == 200) {
                MySharedPreferences.setStringValue(
                    'userInfo', jsonEncode(res.data['userInfo']));

                if(type ==1){
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              User(userInfo: res.data['userInfo'])),
                          (route) => false);
                }else {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Admin(userInfo: res.data['userInfo'])),
                          (route) => false);
                }
              } else {
                Alert.show(
                    alertDialog, buildContext, Alert.ERROR, res.data['msg']);
              }
            } else {
              Alert.show(
                  alertDialog, buildContext, Alert.ERROR, Alert.ERROR_MSG);
            }
          }).catchError((err) {
            Navigator.of(buildContext).pop(false);
            Alert.show(alertDialog, buildContext, Alert.ERROR, Alert.ERROR_MSG);
          });
        }
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
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or login with'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget facebookButton() {
    return Container(
      height: 30,
      margin: EdgeInsets.symmetric(vertical: 10),
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff1959a9),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: Text('f',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff2872ba),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: Text('Facebook',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    );
  }

  Widget googleButton() {
    return Container(
      height: 30,
      width: 120,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5)
                ),
              ),
              alignment: Alignment.center,
              child: Text('G',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400)),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5)
                ),
              ),
              alignment: Alignment.center,
              child: Text('Google',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, "/registration");
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget logo(Size screenSize) {
    return Center(
      child: Container(
        height: 50.0,
        width: screenSize.width,
        child: Text(type == 1 ? "Login with your account" : "Admin Login",
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

  Widget emailPasswordWidget() {
    return Column(
      children: <Widget>[
        entryField("Email id"),
        entryField("Password", isPassword: true),
      ],
    );
  }

  bool verifyInput(BuildContext buildContext) {
    bool isInputVerified = true;

    if (emailCtl.text.isEmpty) {
      Alert.show(alertDialog, buildContext, Alert.ERROR, "Email required!");
      isInputVerified = false;
    } else if (!emailRegExp.hasMatch(emailCtl.text)) {
      Alert.show(alertDialog, buildContext, Alert.ERROR,
          "Email address format not correct!");
      isInputVerified = false;
    } else if (passwordCtl.text.isEmpty) {
      Alert.show(alertDialog, buildContext, Alert.ERROR, "Password required!");
      isInputVerified = false;
    } else if (!passwordRegExp.hasMatch(passwordCtl.text)) {
      Alert.show(
          alertDialog,
          buildContext,
          Alert.ERROR,
          "Password should contain at least 8 character, "
          "one capital letter, one number and one special character!");
      isInputVerified = false;
    }
    return isInputVerified;
  }
}
