import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:socialally/constants.dart';
import 'package:socialally/pages/Admin.dart';
import 'package:socialally/pages/User.dart' as u;
import 'package:socialally/utilities/Alert.dart';
import 'package:socialally/utilities/HttpHandler.dart';
import 'package:socialally/utilities/MySharedPreferences.dart';
import 'package:socialally/widgets/WelcomeNavBar.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
                  emailPasswordWidget(context),
                  SizedBox(height: 20),
                  submitButton(context),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      child: Text('Forgot Password ?',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500
                          )
                      ),
                      onTap: (){
                        Navigator.pushNamed(context, "/forgot-password");
                      },
                    ),
                  ),
                  divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      facebookButton(context),
                      googleButton(context)
                    ],
                  ),
                  SizedBox(height: screenSize.height * .005),
                  createAccountLabel(),
                ],
              ),
            )
          ],
        ),
      )
    );
  }

  Widget entryField(BuildContext context, String title, {bool isPassword = false}) {
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
            textInputAction: TextInputAction.newline,
            controller: isPassword ? passwordCtl : emailCtl,
            obscureText: isPassword,
            onSubmitted: (value){
              onLogin(
                context: context,
                socialUser: null
              );
            },
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
        bool isInputVerified = verifyInput(context);
        if (isInputVerified) {
          onLogin(
            context: buildContext,
            socialUser: null
          );
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

  void onLogin({BuildContext context,User socialUser}){

    var request;

    if(socialUser == null){
      request = {
        "userInfo": {
          "email": emailCtl.text,
          "password": passwordCtl.text,
          "socialLoginId": null,
          "type" : type
        }
      };
    }else{
      request = {
        "userInfo": {
          "socialLoginId": socialUser.uid,
          "password": socialUser.uid,
          "email": null,
          "type" : type
        }
      };
    }

    Alert.show(
        alertDialog, context, Alert.LOADING, Alert.LOADING_MSG);
    HttpHandler().createPost("/users/login", request).then((res) {
      Navigator.of(context).pop(false);
      if (res.statusCode == 200) {
        if (res.data['code'] == 200) {
          MySharedPreferences.setStringValue(
              'userInfo', jsonEncode(res.data['userInfo'])
          );
          var ui = res.data['userInfo'];
          if(ui['type'] == 1){
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => u.User(userInfo: ui)
                ),(route) => false
            );
          }else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => Admin(userInfo: ui)
                ),(route) => false
            );
          }
        } else {
          Alert.show(
              alertDialog, context, Alert.ERROR, res.data['msg']);
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

  Widget facebookButton(BuildContext buildContext) {
    return InkWell(
      child: Container(
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
      ),
      onTap: () async {
        try {
          AccessToken accessToken = await FacebookAuth.instance.login();
          OAuthCredential credential = FacebookAuthProvider.credential(
            accessToken.token,
          );
          FirebaseAuth.instance.signInWithCredential(credential).then((value){
            onLogin(
              context: buildContext,
              socialUser: value.user
            );
          });
        } catch (error) {

          print("Facebook login error $error");
        }
      },
    );
  }

  Widget googleButton(BuildContext buildContext) {
    return InkWell(
      onTap: () async {
        try {
          GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
          GoogleSignInAuthentication googleSignInAuthentication = await
          googleSignInAccount.authentication;
          AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );
          FirebaseAuth.instance.signInWithCredential(credential).then((value){
            onLogin(
              context: buildContext,
              socialUser: value.user
            );
          });
        } catch (error) {
          print("Google login error $error");
        }
      },
      child: Container(
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
                        fontWeight: FontWeight.w400
                    )
                ),
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
      )
    );
  }

  Widget createAccountLabel() {
    return InkWell(
      onTap: () {
        if(type == 1){
          Navigator.pushNamed(context, "/user/registration");
        }else {
          Navigator.pushNamed(context, "/admin/registration");
        }
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

  Widget emailPasswordWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        entryField(context,"Email id"),
        entryField(context,"Password", isPassword: true),
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
