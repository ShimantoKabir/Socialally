import 'dart:convert';

import 'package:client/constants.dart';
import 'package:client/models/Project.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Available extends StatefulWidget {
  Available({Key key, this.eventHub, this.userInfo}) : super(key: key);
  final EventHub eventHub;
  final userInfo;

  @override
  AvailableState createState() =>
      AvailableState(key: key, eventHub: eventHub, userInfo: userInfo);
}

class AvailableState extends State<Available> {
  EventHub eventHub;
  var userInfo;

  AvailableState({Key key, this.eventHub, this.userInfo});

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle", "Mine Job");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: fetchAvailableJob(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Project> projects = snapshot.data;
            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.work_outline),
                        title: Text(projects[index].title),
                        subtitle: Text(
                          '${projects[index].regionName} - ${projects[index].countryName}',
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Todo Steps: ${projects[index].todoSteps.toString()} / Required Proofs: ${projects[index].requiredProofs.toString()}",
                          style:
                              TextStyle(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "Estimated Cost: ${projects[index].estimatedCost} \$"),
                            Text(
                                "Estimated Day: ${projects[index].estimatedDay}"),
                            Text(
                                "Category Name: ${projects[index].categoryName}")
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FlatButton(
                              onPressed: () => {},
                              color: Colors.green,
                              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                              child: Row(
                                // Replace with a Row for horizontal icon + text
                                children: <Widget>[
                                  Icon(Icons.file_download,
                                      color: Colors.white),
                                  Text(" Download File",
                                      style: TextStyle(color: Colors.white))
                                ],
                              ),
                            ),
                            FlatButton(
                              onPressed: () => {},
                              color: Colors.green,
                              padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                              child: Row(
                                // Replace with a Row for horizontal icon + text
                                children: <Widget>[
                                  Icon(Icons.arrow_forward_ios,
                                      color: Colors.white),
                                  Text(" Apply",
                                      style: TextStyle(color: Colors.white))
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          } else {
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

  Future<List<Project>> fetchAvailableJob() async {
    List<Project> projectList = [];

    var response = await get(baseUrl + "/projects");
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);

      if (res['code'] == 200) {
        List<dynamic> projects = res['projects'];
        projects.asMap().forEach((key, project) {
          List<String> tdSteps = [];
          List<String> rProofs = [];

          List<dynamic> todoSteps = jsonDecode(project['todoSteps']);
          todoSteps.forEach((todoStep) {
            tdSteps.add(todoStep);
          });

          List<dynamic> requiredProofs = jsonDecode(project['requiredProofs']);
          requiredProofs.forEach((requiredProof) {
            rProofs.add(requiredProof);
          });

          projectList.add(new Project(
              id: project['id'],
              title: project['title'],
              todoSteps: tdSteps,
              requiredProofs: rProofs,
              categoryId: project['categoryId'],
              categoryName: project['categoryName'],
              subCategoryId: project['subCategoryId'],
              subCategoryName: project['subCategoryName'],
              regionName: project['regionName'],
              countryName: project['countryName'],
              workerNeeded: project['workerNeeded'],
              estimatedDay: project['estimatedDay'],
              estimatedCost: project['estimatedCost']));
        });
        print("projectList = $projectList");
        // print("todoStep = $todoStep");
      }
    }

    return projectList;
  }
}
