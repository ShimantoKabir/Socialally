import 'package:client/utilities/Alert.dart';
import 'package:clipboard/clipboard.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SupportInfo extends StatefulWidget{
  SupportInfo({Key key, this.eventHub, this.userInfo}) : super(key: key);
  final EventHub eventHub;
  final userInfo;

  @override
  SupportInfoState createState() =>
      SupportInfoState(key: key, eventHub: eventHub, userInfo: userInfo);
}

class SupportInfoState extends State<SupportInfo> {
  EventHub eventHub;
  var userInfo;

  SupportInfoState({Key key, this.eventHub, this.userInfo});

  List<dynamic> supportInfo;
  AlertDialog alertDialog;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle", "Support");
    supportInfo = userInfo['supportInfo'];
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
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: EdgeInsets.all(8),
              itemCount: supportInfo.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        supportInfo[index]["key"],
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green
                        )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text(
                              supportInfo[index]["value"],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                  color: Colors.blueGrey
                              ),
                            )
                        ),
                        IconButton(icon: Icon(Icons.copy), onPressed: (){
                          FlutterClipboard.copy(supportInfo[index]["value"]).then((value){
                            Alert.show(alertDialog, context, Alert.SUCCESS,"Copied");
                          });
                        })
                      ],
                    ),
                    SizedBox(height: 20)
                  ],
                );
            })
          ],
        ),
      ),
    );
  }
}