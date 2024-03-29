import 'dart:convert';

import 'package:http/http.dart';
import 'package:socialally/models/SupportInfo.dart';
import 'package:socialally/widgets/WelcomeBanner.dart';
import 'package:socialally/widgets/WelcomeNavBar.dart';
import 'package:socialally/constants.dart';
import 'package:flutter/material.dart';

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
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    WelcomeNavBar(
                      supportInfoList: welcomeData['supportInfoList'],
                      type: 1,
                    ),
                    WelcomeBanner(),
                    // JobSeeker(),
                    // JobGiver(),
                    // UserFeedback(),
                    // AboutUsComponent(),
                    // Footer()
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "Our Payment Partners",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Container(
                          height: 50,
                          child: Image.asset(
                            "assets/images/all_payment_partners.png",
                            fit: BoxFit.contain,
                          ),
                        )
                      ],
                    )
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
