import 'dart:convert';
import 'package:client/constants.dart';
import 'package:client/models/Project.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

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

  AlertDialog alertDialog;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle", "Mine Job");
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: FutureBuilder(
        future: fetchAvailableJob(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Project> projects = snapshot.data;
            if(projects.length == 0){
              return Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Text("No available job found!"),
                ),
              );
            }else {
              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  var eachWorkerEarn = projects[index].estimatedCost/projects[index].workerNeeded;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.extension),
                          title: Text(projects[index].title),
                          subtitle: Text(
                            '${projects[index].regionName} - ${projects[index].countryName}',
                            style:
                            TextStyle(color: Colors.black.withOpacity(0.6)),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text(
                            "Todo Steps",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            ),
                          ),
                          decoration: headingDecoration(),
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                          itemCount: projects[index].todoSteps.length,
                          itemBuilder: (context, j) {
                            if(projects[index].todoSteps.length == 0){
                              return Text("No todo step found!");
                            }else {
                              return Text("${j+1}. ${projects[index].todoSteps[j]}");
                            }
                          }
                        ),
                        SizedBox(height: 10),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text(
                            "Required Proofs",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            ),
                          ),
                          decoration: headingDecoration(),
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: projects[index].requiredProofs.length,
                            itemBuilder: (context, j) {
                              if(projects[index].requiredProofs.length == 0){
                                return Text("No required proof found!");
                              }else {
                                return Text("${j+1}. ${projects[index].requiredProofs[j]}");
                              }
                            }
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20,0,20,5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "Estimated Budget: ${projects[index].estimatedCost} \$"),
                              Text(
                                  "Estimated Day: ${projects[index].estimatedDay}"),
                              Text(
                                  "Worker Needed: ${projects[index].workerNeeded}")
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20,0,20,5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "Category: ${projects[index].categoryName}"),
                              Text(
                                  "Sub Category: ${projects[index].subCategoryName}"),
                              Text(
                                  "Each Worker Earn: ${eachWorkerEarn.round()} \$")
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Visibility(
                                visible: projects[index].fileUrl != null,
                                child: FlatButton(
                                    onPressed: () => {
                                      openFile(projects[index].fileUrl,context)
                                    },
                                    color: Colors.green,
                                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                    child: Row(
                                      // Replace with a Row for horizontal icon + text
                                      children: <Widget>[
                                        Icon(Icons.file_download,
                                            size: 15,
                                            color: Colors.white),
                                        Text(" Instruction File",
                                            style: TextStyle(color: Colors.white))
                                      ],
                                    ),
                                  )
                              ),
                              FlatButton(
                                onPressed: (){
                                  eventHub.fire("redirectToProofSubmission",projects[index]);
                                },
                                color: Colors.green,
                                padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                child: Row(
                                  // Replace with a Row for horizontal icon + text
                                  children: <Widget>[
                                    Text(" Submit",
                                        style: TextStyle(color: Colors.white)),
                                    Icon(Icons.arrow_forward_ios,
                                        size: 15,
                                        color: Colors.white)
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
            }
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

  openFile(String url,BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Alert.show(alertDialog, context, Alert.ERROR, "Can't open any file!");
    }
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
              requiredScreenShots: project['requiredScreenShots'],
              estimatedDay: project['estimatedDay'],
              imageUrl: project['imageUrl'],
              fileUrl: project['fileUrl'],
              estimatedCost: project['estimatedCost']));
        });
      }
    }

    return projectList;
  }

  BoxDecoration headingDecoration() {
    return BoxDecoration(
      border: Border(
          bottom:  BorderSide(
            color: Colors.green,
            width: 3.0,
          )
      ),
    );
  }

}
