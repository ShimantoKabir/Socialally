import 'dart:convert';

import 'package:universal_html/html.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/models/Project.dart';
import 'package:wengine/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class JobManager extends StatefulWidget {
  JobManager({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  JobManagerState createState() => JobManagerState(userInfo: userInfo, eventHub: eventHub);
}

class JobManagerState extends State<JobManager> {
  var userInfo;
  EventHub eventHub;
  JobManagerState({Key key, this.userInfo, this.eventHub});

  AlertDialog alertDialog;
  Future futureProjects;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  int pageIndex = 0;
  int perPage = 10;
  int pageNumber = 0;
  int listPosition;
  Project project;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle","Requisition");
    futureProjects = fetchProjects();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;
    project = null;
    listPosition = null;
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
                    child: Text("No project found!"),
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
                              label: Text("Published By"),
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
                              label: Text("Status"),
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
                                    listPosition = index;
                                  });
                                }
                              },
                              cells: [
                                DataCell(Text("${index+1}")),
                                DataCell(Text("${projects[index].publisherName}")),
                                DataCell(Text("${projects[index].title}")),
                                DataCell(Text("${projects[index].regionName}")),
                                DataCell(Text("${projects[index].countryNames.toString()}")),
                                DataCell(Text("${projects[index].workerNeeded}")),
                                DataCell(Text("${projects[index].eachWorkerEarn}")),
                                DataCell(Text("${projects[index].estimatedCost}")),
                                DataCell(Text("${projects[index].status}")),
                                DataCell(Text("${projects[index].createdAt}"))
                              ]
                          )
                          ),
                        ),
                      ),
                      flex: 7
                    ),
                    Visibility(
                      visible: project != null && project.status == "Pending",
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
                                  ),
                                  SizedBox(height: 10),
                                  OutlineButton(
                                    onPressed: (){
                                      getUserInfoById(projects[listPosition].publishedBy);
                                    },
                                    child: Text("See Publisher Profile"),
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
    String url = baseUrl + "/projects/approve-query?par-page=$perPage&page-index=$pageIndex&status=pending";


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
          id: value["id"],
          title: value['title'],
          regionName: value['regionName'],
          countryNames: countryNames,
          workerNeeded: value['workerNeeded'],
          estimatedCost: value['estimatedCost'],
          eachWorkerEarn: value['eachWorkerEarn'],
          status: value['status'],
          createdAt: value['createdAt'],
          publishedBy: value['publishedBy'],
          publisherName: value['firstName']
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
      "project": {
        "id": projects[listPosition].id,
        "status": status,
        "publishedBy" : projects[listPosition].publishedBy
      }
    };

    String url = baseUrl + '/projects/status';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
      project = null;
    });

    put(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          setState(() {
            projects[listPosition].status = status;
          });
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

  Future<void> getUserInfoById(int publishedBy) async {
    String url = baseUrl + "/users/$publishedBy";
    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      eventHub.fire("redirectToProfile",res['userInfo']);
    }
  }

}