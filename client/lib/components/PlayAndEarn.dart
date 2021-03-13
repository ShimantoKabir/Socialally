import 'dart:convert';

import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wengine/models/Question.dart';
import 'package:wengine/constants.dart';

class PlayAndEarn extends StatefulWidget {
  PlayAndEarn({
    Key key,
    this.eventHub,
    this.userInfo
  }) : super(key: key);

  final EventHub eventHub;
  final userInfo;

  @override
  PlayAndEarnState createState() =>
  PlayAndEarnState(
      key: key,
      eventHub: eventHub,
      userInfo: userInfo
  );
}

class PlayAndEarnState extends State<PlayAndEarn> {
  EventHub eventHub;
  var userInfo;

  PlayAndEarnState({
    Key key,
    this.eventHub,
    this.userInfo
  });

  String email;
  Uri emailLaunchUri;
  AlertDialog alertDialog;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  Future futureQuestions;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle", "Play & Earn");
    List<dynamic> supportInfoList = userInfo['supportInfoList'];
    supportInfoList.forEach((element) {
      if(element['name'] == "AnswerSendMail"){
        email = element['address'];
      }
    });
    futureQuestions = fetchQuestions();
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
                "Mail Address",
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
                      email,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                          color: Colors.blueGrey
                      ),
                    )
                ),
                IconButton(icon: Icon(Icons.outgoing_mail), onPressed: (){
                  String userId = userInfo['userInfoId'];
                  emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: email,
                    queryParameters: {
                      'subject': 'Answer sending mail through play and earn',
                      'body' : "UserId: $userId"
                    }
                  );
                  launch(emailLaunchUri.toString());
                })
              ],
            ),
            SizedBox(height: 20),
            Text(
                "How it Works",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red
                )
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(5)
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText("In this section you can find 5 questions daily at ${userInfo['questionShowingTime']} Those person who can accurately response this 5 question in the 1st & 2nd place through our given email will achieve 1 GBP & 0.5 GBP reward in your earning balance from our website."),
                  SizedBox(height: 10),
                  SelectableText(
                      "NB: You have to send your User ID must and answer only with the question number.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.lightGreen
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
                "Questions",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                )
            ),
            SizedBox(height: 20),
            FutureBuilder(
                future: futureQuestions,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Question> questions = snapshot.data;
                    if(questions.length == 0){
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Text("Question showing time didn't come yet!"),
                        ),
                      );
                    }else {
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: SelectableText(
                              "${index+1}. ${questions[index].question}"
                            ),
                          );
                        },
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
                }
            )
          ],
        ),
      ),
    );
  }

  Future<List<Question>> fetchQuestions() async {

    List<Question> questionList = [];

    DateTime now = new DateTime.now();
    DateFormat dateFormat = DateFormat.jm();  //"6:00 AM"
    String timeOfDay = dateFormat.format(now).replaceAll(" ","");

    String url = baseUrl + "/questions/time/query?time-of-day=$timeOfDay";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      List<dynamic> questions = res['questions'];

      questions.asMap().forEach((key, value) {
        questionList.add(new Question(
            id: value['id'],
            question: value['question'],
            createdAt: value['createdAt']
        ));
      });
    }
    setState(() {
      needToFreezeUi = false;
    });
    return questionList;

  }

}