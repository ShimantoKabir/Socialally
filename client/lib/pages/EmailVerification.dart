import 'package:client/utilities/Alert.dart';
import 'package:client/utilities/HttpHandler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmailVerification extends StatefulWidget {
  EmailVerification({Key key, this.emailVerificationId}) : super(key: key);
  final String emailVerificationId;

  @override
  EmailVerificationState createState() =>
      EmailVerificationState(emailVerificationId: emailVerificationId);
}

class EmailVerificationState extends State<EmailVerification> {
  String emailVerificationId;

  EmailVerificationState({Key key, @required this.emailVerificationId});

  AlertDialog alertDialog;

  @override
  void initState() {
    super.initState();
    print("Email verification id = $emailVerificationId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: verifyEmailAddress(emailVerificationId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            int code = snapshot.data.data["code"];
            String msg = snapshot.data.data["msg"];
            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(msg,
                      style: TextStyle(fontSize: 30, color: Colors.green)),
                  SizedBox(width: 10),
                  RaisedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, "/login", (r) => false);
                      },
                      child: Text("Got to Login"))
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            );
          }
        },
      ),
    );
  }

  Future<dynamic> verifyEmailAddress(String emailVerificationId) {
    var request = {
      "userInfo": {
        "token": emailVerificationId,
      }
    };
    return HttpHandler().createPost("/users/verification/email", request);
  }
}
