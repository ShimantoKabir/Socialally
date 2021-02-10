import 'dart:convert';

import 'package:client/models/Project.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:client/constants.dart';
import 'package:http/http.dart';

class AdvertisementSender extends StatefulWidget {
  AdvertisementSender({Key key, this.eventHub, this.userInfo}) : super(key: key);
  final userInfo;
  final EventHub eventHub;

  @override
  AdvertisementSenderState createState() =>
      AdvertisementSenderState(key: key, eventHub: eventHub, userInfo: userInfo);
}

class AdvertisementSenderState extends State<AdvertisementSender> {
  var userInfo;
  EventHub eventHub;

  AdvertisementSenderState({Key key, this.eventHub, this.userInfo});

  TextEditingController projectTitleCtl = TextEditingController();
  var defaultAdCost;
  bool needToFreezeUi = false;
  Widget alertIcon;
  String alertText;
  AlertDialog alertDialog;
  Project p;

  @override
  void initState() {
    super.initState();
    alertText = "No operation running.";
    alertIcon = Container();
    defaultAdCost = {
      "day" : 0,
      "cost" : 0
    };
    adCostPlanDropDownList.clear();
    adCostPlanDropDownList.add(DropdownMenuItem<dynamic>(
        value: defaultAdCost,
        child: Text("Select")
      )
    );
    List<dynamic> adCostPlanList = userInfo['adCostPlanList'];
    adCostPlanList.asMap().forEach((key, value) {
      adCostPlanDropDownList.add(
        DropdownMenuItem(
          value: value,
          child: Text("${value['day']} day = ${value['cost']} \$")
        )
      );
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
            Text(
              "Posted Job",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15
              )
            ),
            SizedBox(
              height: 10,
            ),
            TypeAheadField(
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
            Text(
                "Plan",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                )
            ),
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
              child: DropdownButton<dynamic>(
                value: defaultAdCost,
                isExpanded: true,
                underline: SizedBox(),
                onChanged: (var ac) {
                  setState(() {
                    defaultAdCost = ac;
                  });
                },
                items: adCostPlanDropDownList
              )
            ),
            SizedBox(
              height: 10,
            ),
            OutlineButton(
              onPressed: (){
                onSave(context);
              },
              child: Text("Save"),
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

    var request = {
      "project": {
        "id" : p.id,
        "adCost": defaultAdCost['cost'],
        "adDuration": defaultAdCost['day'],
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

}