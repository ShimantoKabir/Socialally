import 'dart:convert';

import 'package:http/http.dart';
import 'package:wengine/components/AboutUsComponent.dart';
import 'package:wengine/components/Feedback.dart';
import 'package:wengine/components/Footer.dart';
import 'package:wengine/components/JobGiver.dart';
import 'package:wengine/components/JobSeeker.dart';
import 'package:wengine/models/SupportInfo.dart';
import 'package:wengine/widgets/WelcomeBanner.dart';
import 'package:wengine/widgets/WelcomeNavBar.dart';
import 'package:flutter/material.dart';
import 'package:wengine/constants.dart';

class Welcome extends StatefulWidget {

  Welcome({
    Key key,
  }) : super(key: key);

  @override
  WelcomeState createState() => WelcomeState(
      key: key
  );
}

class WelcomeState extends State<Welcome> {

  WelcomeState({
    Key key
  });

  Future futureWelcomeDate;


  @override
  void initState() {
    super.initState();
    futureWelcomeDate = fetchWelcomeDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: futureWelcomeDate,
        builder: (context,snapshot){
          if (snapshot.hasData) {
            var welcomeData = snapshot.data;
            if(welcomeData != null){
              print("w $welcomeData");
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    WelcomeNavBar(
                      supportInfoList: welcomeData['supportInfoList'],
                    ),
                    WelcomeBanner(),
                    // JobSeeker(),
                    // JobGiver(),
                    // UserFeedback(),
                    // AboutUsComponent(),
                    // Footer()
                  ],
                ),
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
        },
      ),
    );
  }

  Future<dynamic> fetchWelcomeDate() async {

    var welcomeData;
    List<SupportInfo> supportInfoList = [];
    String url = baseUrl + "/welcome";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['code'] == 200) {
        List<dynamic> supportInfos = res['supportInfoList'];
        supportInfos.asMap().forEach((key, value) {
          supportInfoList.add(new SupportInfo(
              name : value['name'],
              address : value['address']
          ));
        });
        welcomeData = {
          "supportInfoList" : supportInfoList
        };
      }
    }

    return welcomeData;
  }

}
