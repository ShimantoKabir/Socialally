import 'dart:convert';

import 'package:client/models/AdCostPlan.dart';
import 'package:client/models/Project.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:client/constants.dart';
import 'package:http/http.dart';

class JobAdvertisementSender extends StatefulWidget {
  JobAdvertisementSender({Key key, this.eventHub, this.userInfo}) : super(key: key);
  final userInfo;
  final EventHub eventHub;

  @override
  JobAdvertisementSenderState createState() =>
      JobAdvertisementSenderState(key: key, eventHub: eventHub, userInfo: userInfo);
}

class JobAdvertisementSenderState extends State<JobAdvertisementSender> {
  var userInfo;
  EventHub eventHub;

  JobAdvertisementSenderState({Key key, this.eventHub, this.userInfo});

  TextEditingController projectTitleCtl = TextEditingController();
  SuggestionsBoxController suggestionsBoxController  = SuggestionsBoxController();
  var defaultAdCost;
  bool needToFreezeUi = false;
  Widget alertIcon;
  String alertText;
  AlertDialog alertDialog;
  Project p;
  AdCostPlan adCostPlan;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle","Job Advertisement");
    alertText = "No operation running.";
    alertIcon = Container();

    adCostPlan = AdCostPlan(
        cost: 0,
        day: 0,
        txt: "Select"
    );

    List<dynamic> adCostPlanList = userInfo['adCostPlanList'];
    adCostPlanList.asMap().forEach((key, plan) {
      bool isValueExist = false;
      adCostPlanDropDownList.forEach((element) {
        if (element.value.day == plan['day']) {
          isValueExist = true;
        }
      });
      if (!isValueExist) {
        AdCostPlan acp = new AdCostPlan(
            day: plan["day"],
            cost: plan["cost"],
            txt: "Day = ${plan['day']}, Cost = ${plan['cost']}\$"
        );
        adCostPlanDropDownList.add(DropdownMenuItem(
            value: acp,
            child: Text(acp.txt)
        ));
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                showRequiredHeading("Posted Job"),
                OutlineButton(
                  onPressed: (){
                    clearSuggestion(context);
                  },
                  child: Text("Clear Suggestion"),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TypeAheadField(
              suggestionsBoxController: suggestionsBoxController,
              textFieldConfiguration: TextFieldConfiguration(
                controller: projectTitleCtl,
                decoration: InputDecoration(
                  hintText: "Search your posted job ....",
                  border: OutlineInputBorder()
                )
              ),
              suggestionsCallback: (pattern) async {
                return fetchProject(pattern);
              },
              itemBuilder: (context, Project project) {
                return ListTile(
                  leading: Icon(Icons.account_tree),
                  title: Text(project.title)
                );
              },
              onSuggestionSelected: (Project project) {
                projectTitleCtl.text = project.title;
                p = project;
              },
            ),
            SizedBox(
              height: 10,
            ),
            showRequiredHeading("Plan"),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
              child: DropdownButton<AdCostPlan>(
                value: adCostPlan,
                isExpanded: true,
                underline: SizedBox(),
                onChanged: (AdCostPlan acp) {
                  setState(() {
                    adCostPlan = new AdCostPlan(
                        day: acp.day,
                        cost: acp.cost,
                        txt: acp.txt
                    );
                  });
                },
                items: adCostPlanDropDownList
              )
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlineButton(
                  onPressed: (){
                    if (userInfo['profileCompleted'] == 100) {
                      bool isInputVerified = verifyInput(context);
                      if(isInputVerified){
                        onSave(context);
                      }
                    }else {
                      Alert.show(alertDialog, context, Alert.ERROR, "To post a new job, you need to complete your profile 100%.");
                    }
                  },
                  child: Text("Save"),
                ),
                OutlineButton(
                  onPressed: (){
                    onReset(context);
                  },
                  child: Text("Reset"),
                )
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Alert.addBottomLoader(
        needToFreezeUi,
        alertIcon,
        alertText
      ),
    );
  }

  void onSave(BuildContext context) {

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    var request = {
      "project": {
        "id" : p.id,
        "adCost": adCostPlan.cost,
        "adDuration": adCostPlan.day,
        "publishedBy" : userInfo['id']
      }
    };

    String url = baseUrl + '/projects/advertisements';
    Map<String, String> headers = {"Content-type": "application/json"};

    put(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          onReset(context);
          eventHub.fire("reloadBalance");
          // eventHub.fire("redirectToJobAd");
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

  Future<List<Project>> fetchProject(String title) async {

    List<Project> projectList = [];
    String url = baseUrl + "/projects/title-query?title=$title&user-info-id=${userInfo['id']}";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['code'] == 200) {
        List<dynamic> projects = res['projects'];
        projects.asMap().forEach((key, project) {
          projectList.add(new Project(
              id: project['id'],
              title: project['title']
          ));
        });
      }
    }
    return projectList;
  }

  bool verifyInput(BuildContext context) {

    bool isInputVerified = true;
    String errMsg;

    if (projectTitleCtl.text.isEmpty) {
      errMsg = "Please select a job to advertise!";
      isInputVerified = false;
    }else if(adCostPlan.txt == "Select"){
      errMsg = "Please select plan to advertise!";
      isInputVerified = false;
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, context, Alert.ERROR, errMsg);
    }
    return isInputVerified;

  }

  void onReset(BuildContext context) {

    setState(() {
      clearSuggestion(context);
      adCostPlan = AdCostPlan(day: 0,cost: 0,txt: "Select");
    });

  }

  void clearSuggestion(BuildContext context) {
    projectTitleCtl.clear();
    suggestionsBoxController.close();
    p = null;
  }

}