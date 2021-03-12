import 'dart:convert';

import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/models/Question.dart';
import 'package:wengine/utilities/Alert.dart';

class QuestionManager extends StatefulWidget {
  QuestionManager({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  QuestionManagerState createState() => QuestionManagerState(userInfo: userInfo, eventHub: eventHub);
}

class QuestionManagerState extends State<QuestionManager> {
  var userInfo;
  EventHub eventHub;
  QuestionManagerState({Key key, this.userInfo, this.eventHub});

  AlertDialog alertDialog;
  Future futureQuestions;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  int pageIndex = 0;
  int perPage = 10;
  int pageNumber = 0;
  Question question;
  bool isSideBoxOpen;

  TextEditingController questionCtl = new TextEditingController();

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle","Manage Questions");
    futureQuestions = fetchQuestions();
    alertText = "No operation running!";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;
    isSideBoxOpen = false;
    question = new Question(
      id: null,
      createdAt: null,
      question: null
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return AbsorbPointer(
      absorbing: needToFreezeUi,
      child: Scaffold(
        body: FutureBuilder(
            future: futureQuestions,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Question> questions = snapshot.data;
                if(questions.length == 0){
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: inputForm(context,height),
                    ),
                  );
                }else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.all(10),
                                color: Colors.black12,
                                child: ListTile(
                                  leading: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: (){
                                      onDelete(context,questions[index].id);
                                    },
                                  ),
                                  title: Text("${questions[index].question}"),
                                  subtitle: Text("Created at: ${questions[index].createdAt}"),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: (){
                                      setState(() {
                                        isSideBoxOpen = true;
                                        question.id = questions[index].id;
                                        question.question = questions[index].question;
                                        questionCtl.text = questions[index].question;
                                        question.createdAt = questions[index].createdAt;
                                      });
                                    },
                                  ),
                                ),
                                margin: EdgeInsets.all(5),
                              );
                            },
                          ),
                          flex: 7
                      ),
                      Visibility(
                          visible: isSideBoxOpen,
                          child: Expanded(
                              child: inputForm(context,height),
                              flex: 3
                          )
                      )
                    ],
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
        ),
        bottomNavigationBar: Container(
          color: Colors.black12,
          height: 50.0,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                  icon: Icon(
                      Icons.add,
                      size: 25
                  ),
                  onPressed: (){
                    onReset(context);
                    setState(() {
                      isSideBoxOpen = true;
                    });
                  }
              ),
              Visibility(
                  visible: needToFreezeUi,
                  child: Padding(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        strokeWidth: 2,
                      ),
                      padding: EdgeInsets.all(5)
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget inputForm(BuildContext context,double h){
    return SingleChildScrollView(
      child: Container(
        height: h,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
                    color: Colors.grey
                )
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            entryField(
              title: "Question",
              controller: questionCtl,
              needToBeRequired: true,
              maxLines: 4
            ),
            SizedBox(height: 10),
            OutlineButton(
                onPressed: (){
                  setState(() {
                    bool isInputVerified = verifyInput(context);
                    if(isInputVerified){
                      if(question.id == null){
                        onSave(context);
                      }else {
                        onUpdate(context);
                      }
                    }
                  });
                },
                child: Text(question.id == null ? "Save" : "Update")
            ),
            SizedBox(height: 10),
            OutlineButton(
                onPressed: (){
                  onReset(context);
                },
                child: Text("close")
            )
          ],
        ),
      ),
    );
  }

  Widget entryField({String title,
    TextEditingController controller,
    TextInputType textInputType,
    List<TextInputFormatter> textInputFormatter,
    int maxLines,
    bool needToBeRequired}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          needToBeRequired ? showRequiredHeading(title) :
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              maxLines: maxLines == null ? 1 : maxLines,
              keyboardType: textInputType,
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

  Future fetchQuestions() async {
    List<Question> questionList = [];
    String url = baseUrl + "/questions/query?par-page=$perPage&page-index=$pageIndex";

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

  bool verifyInput(BuildContext context) {
    bool isInputVerified = true;
    String errMsg;

    if (questionCtl.text.isEmpty) {
      errMsg = "Please give question!";
      isInputVerified = false;
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, context, Alert.ERROR, errMsg);
    }
    return isInputVerified;

  }

  void onSave(BuildContext context) {
    var request = {
      "question": {
        "question": questionCtl.text,
      }
    };

    String url = baseUrl + '/questions';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
    });

    post(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          setState(() {
            futureQuestions = fetchQuestions();
          });
          onReset(context);
          Alert.show(alertDialog, context, Alert.SUCCESS, body['msg']);
        } else {
          Alert.show(alertDialog, context, Alert.ERROR, body['msg']);
        }
      } else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }).catchError((err) {
      setState(() {
        needToFreezeUi = false;
      });
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    });
  }

  void onReset(BuildContext context) {
    setState(() {
      isSideBoxOpen = false;
      question.id = null;
      question.question = null;
      question.createdAt = null;
      questionCtl.clear();
    });
  }

  void onUpdate(BuildContext context) {
    var request = {
      "question": {
        "id" : question.id,
        "question": questionCtl.text,
      }
    };

    String url = baseUrl + '/questions';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
    });

    put(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          setState(() {
            futureQuestions = fetchQuestions();
          });
          onReset(context);
          Alert.show(alertDialog, context, Alert.SUCCESS, body['msg']);
        } else {
          Alert.show(alertDialog, context, Alert.ERROR, body['msg']);
        }
      } else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }).catchError((err) {
      setState(() {
        needToFreezeUi = false;
      });
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    });
  }

  void onDelete(BuildContext context, int id) {
    String url = baseUrl + '/questions/$id';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
    });

    delete(url, headers: headers).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          setState(() {
            futureQuestions = fetchQuestions();
          });
          onReset(context);
          Alert.show(alertDialog, context, Alert.SUCCESS, body['msg']);
        } else {
          Alert.show(alertDialog, context, Alert.ERROR, body['msg']);
        }
      } else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }).catchError((err) {
      setState(() {
        needToFreezeUi = false;
      });
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    });
  }
}