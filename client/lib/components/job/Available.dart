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
  Available({Key key, this.eventHub, this.userInfo, this.type}) : super(key: key);
  final EventHub eventHub;
  final userInfo;
  final type;

  @override
  AvailableState createState() =>
      AvailableState(key: key, eventHub: eventHub, userInfo: userInfo, type: type);
}

class AvailableState extends State<Available> {
  EventHub eventHub;
  var userInfo;
  int type;
  AvailableState({Key key, this.eventHub, this.userInfo, this.type});

  AlertDialog alertDialog;
  Future futureProjects;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  int pageIndex = 0;
  int perPage = 2;
  int pageNumber = 0;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle", type == 1 ? "Available Job" : type == 2 ? "Accept Job" : "Posted Job");
    futureProjects = fetchAvailableJob();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize =  MediaQuery.of(context).size;
    print("screenSize = $screenSize");
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FutureBuilder(
          future: futureProjects,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Project> projects = snapshot.data;
              if(projects.length == 0){
                return Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Text(type == 1 ?"No available job found!" : "No job found to accept!"),
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
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  projects[index].title,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20
                                  ),
                                ),
                                Text(
                                  "${projects[index].regionName}/${projects[index].countryName}",
                                )
                              ],
                            ),
                            decoration: headingDecoration(),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 200,
                                  padding: EdgeInsets.all(5),
                                  child: Column(
                                    children: [
                                      Text("${projects[index].totalApplied}/${projects[index].workerNeeded} Applied"),
                                      SizedBox(height: 5),
                                      LinearProgressIndicator(
                                        backgroundColor: Colors.grey,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.amber),
                                        value: projects[index].totalApplied / projects[index].workerNeeded,
                                      )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.grey)
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text("${eachWorkerEarn.round()}"),
                                      SizedBox(width: 2),
                                      Icon(Icons.monetization_on, color: Colors.green, size: 25)
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.grey)
                                  ),
                                )
                              ],
                            )
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
                          SizedBox(height: 20),
                          Visibility(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(20, 0, 0, 10),
                              child: Text(
                                "Status: ${projects[index].status}",
                                style: TextStyle(
                                    color: projects[index].status == "Pending" ?
                                    Colors.blue :
                                    projects[index].status == "Accepted" ?
                                    Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              alignment: Alignment.bottomLeft,
                            ),
                            visible: type == 4 || type == 2,
                          ),
                          Visibility(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20,0,20,5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Budget: ${projects[index].estimatedCost}\$"),
                                  Text(
                                    "Estimated Day: ${projects[index].estimatedDay}",
                                    textAlign: TextAlign.right,
                                  ),
                                  Text(
                                      "Worker Needed: ${projects[index].workerNeeded}")
                                ],
                              ),
                            ),
                            visible: type != 5,
                          ),
                          Visibility(
                            visible: type != 5,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20,0,20,5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Category: ${projects[index].categoryName}"),
                                  Text(
                                    "Sub Category: ${projects[index].subCategoryName}",
                                    textAlign: TextAlign.right,),
                                  Text(
                                      type == 2 ? "Applied By: ${projects[index].applicantName}" : "Published By: ${projects[index].publisherName}",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold
                                      )
                                  )
                                ],
                              ),
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Visibility(
                                    visible: projects[index].fileUrl != null && type == 1 || type == 5,
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
                                Visibility(
                                  visible: type != 4,
                                  child: FlatButton(
                                    onPressed: (){
                                      if(type == 3){
                                        eventHub.fire("redirectToPost",projects[index]);
                                      }else {
                                        eventHub.fire("redirectToProofSubmission",projects[index]);
                                      }
                                    },
                                    color: Colors.green,
                                    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                    child: Row(
                                      children: <Widget>[
                                        Text(type == 1 ? " Submit " : type == 2
                                            ? " Investigate " : type == 5
                                            ? " Submit " : " Update ",
                                            style: TextStyle(color: Colors.white)),
                                        Icon(Icons.arrow_forward_ios,
                                            size: 15,
                                            color: Colors.white)
                                      ],
                                    ),
                                  )
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
                            futureProjects = fetchAvailableJob();
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
                          futureProjects = fetchAvailableJob();
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

  openFile(String url,BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Alert.show(alertDialog, context, Alert.ERROR, "Can't open any file!");
    }
  }

  Future<List<Project>> fetchAvailableJob() async {

    List<Project> projectList = [];

    String url = baseUrl + "/projects/query?type=$type&user-info-id=${userInfo['id']}&par-page=$perPage&page-index=$pageIndex";
    // if(type == 1){ // job accept published by me
    //   url = baseUrl + "/projects/query?type=$type&user-info-id=${userInfo['id']}&par-page=$perPage&page-index=$pageIndex";
    // }else if(type == 2){ // job approve request
    //   url = baseUrl + "/projects/query?type=$type&user-info-id=${userInfo['id']}&par-page=$perPage&page-index=$pageIndex";
    // }else if(type == 3){ // job only published by me
    //   url = baseUrl + "/projects/query?type=$type&user-info-id=${userInfo['id']}&par-page=$perPage&page-index=$pageIndex";
    // }else { // job applied by me
    //   url = baseUrl + "/projects/query?type=$type&user-info-id=${userInfo['id']}&par-page=$perPage&page-index=$pageIndex";
    // }

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['code'] == 200) {
        List<dynamic> projects = res['projects'];

        projects.asMap().forEach((key, project) {

          List<String> tdSteps = [];
          List<String> rProofs = [];
          List<String> gProofs = [];
          List<String> gScreenshotUrls = [];
          List<dynamic> givenScreenshotUrls = [];
          List<dynamic> givenProofs = [];

          List<dynamic> todoSteps = jsonDecode(project['todoSteps']);
          todoSteps.forEach((todoStep) {
            tdSteps.add(todoStep);
          });

          List<dynamic> requiredProofs = jsonDecode(project['requiredProofs']);
          requiredProofs.forEach((requiredProof) {
            rProofs.add(requiredProof);
          });

          if(type == 2){
            givenScreenshotUrls = jsonDecode(project['givenScreenshotUrls']);
            givenScreenshotUrls.forEach((givenScreenshotUrl) {
              gScreenshotUrls.add(givenScreenshotUrl);
            });

            givenProofs = jsonDecode(project['givenProofs']);
            givenProofs.forEach((givenProof) {
              gProofs.add(givenProof);
            });
          }

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
              givenProofs: gProofs,
              givenScreenshotUrls: gScreenshotUrls,
              estimatedCost: project['estimatedCost'],
              type: type,
              proofSubmissionId: project['proofSubmissionId'],
              totalApplied: project['totalApplied'],
              publisherName: project['publisherName'],
              applicantName: project['applicantName'],
              status: type == 2 ? project['pfStatus'] : project['status']
          ));
        });
      }
    }
    setState(() {
      needToFreezeUi = false;
    });
    return projectList;
  }

  BoxDecoration headingDecoration() {
    return BoxDecoration(
      border: Border(
          bottom:  BorderSide(
            color: Colors.green,
            width: 2.0,
          )
      ),
    );
  }

}
