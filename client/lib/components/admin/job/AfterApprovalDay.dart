import 'dart:convert';

import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:socialally/constants.dart';
import 'package:socialally/models/Project.dart';
import 'package:socialally/utilities/Alert.dart';

class AfterApprovalDay extends StatefulWidget {

  AfterApprovalDay({
    Key key,
    this.userInfo,
    this.eventHub
  }) : super(key: key);

  final userInfo;
  final EventHub eventHub;
  @override

  AfterApprovalDayState createState() => AfterApprovalDayState(
      userInfo: userInfo,
      eventHub: eventHub
  );
}

class AfterApprovalDayState extends State<AfterApprovalDay> {

  var userInfo;
  EventHub eventHub;

  AfterApprovalDayState({
    Key key,
    this.userInfo,
    this.eventHub
  });

  AlertDialog alertDialog;
  Future futureProjects;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  int pageIndex = 0;
  int perPage = 10;
  int pageNumber = 0;
  Project project;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle","Requisition");
    futureProjects = fetchProjects();
    alertText = "No operation running!";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;
    project = null;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: FutureBuilder(
          future: futureProjects,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Project> projects = snapshot.data;
              if(projects.length == 0){
                return Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Text("No Job Found To Approve!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red
                      )
                    ),
                  ),
                );
              }else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            sortAscending: true,
                            columns: <DataColumn>[
                              DataColumn(
                                label: Text('SL'),
                              ),
                              DataColumn(
                                label: Text("Status"),
                              ),
                              DataColumn(
                                label: Text("Published By"),
                              ),
                              DataColumn(
                                label: Text("Applied By"),
                              ),
                              DataColumn(
                                label: Text("Title"),
                              ),
                              DataColumn(
                                label: Text("Region"),
                              ),
                              DataColumn(
                                label: Text("Country"),
                              ),
                              DataColumn(
                                label: Text("Worker Needed"),
                              ),
                              DataColumn(
                                label: Text("Estimated Cost"),
                              ),
                              DataColumn(
                                label: Text("Each Worker Earn"),
                              ),
                              DataColumn(
                                label: Text("Date"),
                              )
                            ],
                            rows: List<DataRow>.generate(
                                projects.length, (index) => DataRow(
                                onSelectChanged: (value){
                                  if(!needToFreezeUi){
                                    setState(() {
                                      project = projects[index];
                                    });
                                  }
                                },
                                cells: [
                                  DataCell(Text("${index+1}")),
                                  DataCell(Text("${projects[index].status}")),
                                  DataCell(Text("${projects[index].publisherName}")),
                                  DataCell(Text("${projects[index].applicantName}")),
                                  DataCell(Text("${projects[index].title}")),
                                  DataCell(Text("${projects[index].regionName}")),
                                  DataCell(Text("${projects[index].countryNames.toString()}")),
                                  DataCell(Text("${projects[index].workerNeeded}")),
                                  DataCell(Text("${projects[index].eachWorkerEarn}")),
                                  DataCell(Text("${projects[index].estimatedCost}")),
                                  DataCell(Text("${projects[index].createdAt}"))
                                ]
                            )
                            ),
                          ),
                        ),
                        flex: 7
                    ),
                    Visibility(
                        visible: project != null,
                        child: Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              height: height,
                              child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                          color: Colors.grey
                                      ),
                                    )
                                ),
                                child: project == null ? Container() : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Published By: ${project.publisherName}"),
                                    SizedBox(height: 10),
                                    Text("Applied By: ${project.applicantName}"),
                                    SizedBox(height: 10),
                                    Text("Title: ${project.title}"),
                                    SizedBox(height: 10),
                                    Text("Region: ${project.regionName}"),
                                    SizedBox(height: 10),
                                    Text("Country: ${project.countryNames.toString()}"),
                                    SizedBox(height: 10),
                                    Text("Worker Needed: ${project.workerNeeded}"),
                                    SizedBox(height: 10),
                                    Text("Each Worker Earn: ${project.eachWorkerEarn}"),
                                    SizedBox(height: 10),
                                    SizedBox(height: 10),
                                    Visibility(
                                      child: OutlineButton(
                                        onPressed: (){
                                          onUpdate(context,"Approved",projects);
                                        },
                                        child: Text("Approved"),
                                      ),
                                      visible: project.status == "Pending",
                                    ),
                                    SizedBox(height: 10),
                                    Visibility(
                                      child: OutlineButton(
                                        onPressed: (){
                                          onUpdate(context,"Declined",projects);
                                        },
                                        child: Text("Declined"),
                                      ),
                                      visible: project.status == "Pending",
                                    ),
                                    SizedBox(height: 10),
                                    OutlineButton(
                                      onPressed: (){
                                        setState(() {
                                          project = null;
                                        });
                                      },
                                      child: Text("Close"),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          flex: 3,
                        )
                    )
                  ],
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
        bottomNavigationBar: AbsorbPointer(
          absorbing: needToFreezeUi,
          child: Container(
            color: Colors.black12,
            height: 50.0,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(icon: Icon(Icons.filter_alt_outlined), onPressed: (){

                }),
                Visibility(
                    visible: needToFreezeUi,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      strokeWidth: 2,
                    )
                ),
                Row(
                  children: [
                    IconButton(
                        icon: Icon(
                            Icons.arrow_back_ios,
                            size: 15
                        ),
                        onPressed: (){
                          if(pageIndex < 1){
                            Alert.show(alertDialog, context, Alert.ERROR, "Your are already in the first page!");
                          }else {
                            pageNumber--;
                            pageIndex = pageIndex - perPage;
                            needToFreezeUi = true;
                            setState(() {
                              futureProjects = fetchProjects();
                            });
                          }
                        }
                    ),
                    Text("${pageNumber+1}"),
                    IconButton(
                        icon: Icon(
                            Icons.arrow_forward_ios,
                            size: 15
                        ),
                        onPressed: (){
                          pageIndex = pageIndex + perPage;
                          needToFreezeUi = true;
                          pageNumber++;
                          setState(() {
                            futureProjects = fetchProjects();
                          });
                        }
                    )
                  ],
                )
              ],
            ),
          ),
        )
    );
  }

  Future fetchProjects() async {

    List<Project> projectList = [];
    String url = baseUrl + "/proof-submissions/pending?par-page=$perPage&page-index=$pageIndex";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);

      List<dynamic> projects = res['projects'];
      projects.asMap().forEach((key, value) {

        List<String> countryNames = [];
        List<dynamic> countryNameList = jsonDecode(value['countryNames']);
        countryNameList.forEach((element) {
          countryNames.add(element);
        });

        projectList.add(new Project(
          id: value["pId"],
          proofSubmissionId: value["pfId"],
          title: value['title'],
          regionName: value['regionName'],
          countryNames: countryNames,
          workerNeeded: value['workerNeeded'],
          estimatedCost: value['estimatedCost'],
          eachWorkerEarn: value['eachWorkerEarn'],
          status: value['pfStatus'],
          createdAt: value['approvedOrDeclinedDate'],
          submittedBy: value['submittedBy'],
          publishedBy: value['publishedBy'],
          publisherName: value['publisherName'],
          applicantName: value['applicantName']
        ));
      });
    }

    setState(() {
      needToFreezeUi = false;
    });

    return projectList;

  }

  void onUpdate(BuildContext context, String status, List<Project> projects) {

    var request = {
      "proofSubmission": {
        "id": project.proofSubmissionId,
        "status": status,
        "projectId" : project.id,
        "submittedBy": project.submittedBy,
        "publisherName": project.publisherName,
        "publishedBy": project.publishedBy
      }
    };

    String url = baseUrl + '/proof-submissions';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    put(url, headers: headers, body: json.encode(request)).then((response){
      setState(() {
        needToFreezeUi = false;
      });

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          futureProjects = fetchProjects();
          project = null;
        }else {
          Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
        }
      } else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }).catchError((err){
      setState(() {
        needToFreezeUi = false;
      });
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    });

  }
}