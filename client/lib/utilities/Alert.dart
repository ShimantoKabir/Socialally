import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Alert {
  static const LOADING = 100;
  static const SUCCESS = 200;
  static const ERROR = 404;
  static const ERROR_MSG = "Something went wrong, please try again!";
  static const LOADING_MSG = "Please wait....!";

  static show(AlertDialog alertDialog, BuildContext context, int status, String msg) {
    alertDialog = AlertDialog(
      content: ListTile(
        leading: showLeading(status),
        title: showTitle(status),
        subtitle: Text(msg,textAlign: TextAlign.start),
      ),
    );

    showDialog(
        context: context,
        barrierDismissible: status == LOADING ? false : true,
        builder: (BuildContext ctx) {
          return alertDialog;
        });
  }

  static showLeading(int status) {
    if (status == LOADING) {
      return CircularProgressIndicator();
    } else if (status == SUCCESS) {
      return Icon(Icons.check_circle_rounded,size: 50,color: Colors.green);
    } else {
      return Icon(Icons.error,size: 50,color: Colors.red);
    }
  }

  static showTitle(int status) {
    if (status == LOADING) {
      return Text("Loading");
    } else if (status == SUCCESS) {
      return Text("Success");
    } else {
      return Text("Error");
    }
  }

  static showIcon(int status) {
    if (status == LOADING) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        strokeWidth: 1,
      );
    } else if (status == SUCCESS) {
      return Icon(Icons.check_circle_rounded, color: Colors.red);
    } else {
      return Icon(Icons.error,color: Colors.red);
    }
  }

  static Widget addBottomLoader(bool needToFreezeUi,Widget alertIcon,String alertText){
    return Visibility(
      visible: needToFreezeUi,
      child: Container(
        color: Colors.black12,
        height: 50.0,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(width: 30, height: 30, child: alertIcon),
            SizedBox(width: 10),
            Text(alertText,
              style: TextStyle(
                color: Colors.black
              )
            )
          ],
        ),
      )
    );
  }

}
