import 'package:client/utilities/Alert.dart';
import 'package:clipboard/clipboard.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReferAndEarn extends StatefulWidget {

  ReferAndEarn({Key key, this.eventHub, this.userInfo}) : super(key: key);
  final EventHub eventHub;
  final userInfo;

  @override
  ReferAndEarnState createState() =>
      ReferAndEarnState(key: key, eventHub: eventHub, userInfo: userInfo);

}

class ReferAndEarnState extends State<ReferAndEarn> {

  EventHub eventHub;
  var userInfo;

  ReferAndEarnState({Key key, this.eventHub, this.userInfo});

  AlertDialog alertDialog;
  String referrerLink;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle", "Refer & Earn");
    referrerLink = userInfo["accountNumber"] == null ?
      "Please give an account number and update you profile" :
      userInfo["referrerLink"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Your Referrer Link",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green
                )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Text(
                      referrerLink,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                          color: Colors.blueGrey
                      ),
                    )
                ),
                IconButton(icon: Icon(Icons.copy), onPressed: (){
                  FlutterClipboard.copy(referrerLink).then((value){
                    Alert.show(alertDialog, context, Alert.SUCCESS,"Copied");
                  });
                })
              ],
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(5)
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${userInfo['quantityOfJoinByYourRefer']} people join by your referral."),
                  Text("You can earn more income per deposit of your referral.")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}