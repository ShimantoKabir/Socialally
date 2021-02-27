import 'dart:convert';

import 'package:client/constants.dart';
import 'package:client/models/Project.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Applicants extends StatefulWidget{

  Applicants({
    Key key,
    this.eventHub,
    this.userInfo,
    this.project
  }) : super(key: key);

  final userInfo;
  final EventHub eventHub;
  final Project project;

  @override
  ApplicantsState createState() => ApplicantsState(
    key: key,
    userInfo: userInfo,
    eventHub: eventHub,
    project: project
  );

}

class ApplicantsState extends State<Applicants> {

  var userInfo;
  EventHub eventHub;
  Project project;

  ApplicantsState({
    Key key,
    this.userInfo,
    this.eventHub,
    this.project
  });

  Future futureApplicants;
  int pageIndex = 0;
  int perPage = 5;
  int pageNumber = 0;
  AlertDialog alertDialog;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle", "${project.title}");
    futureApplicants = fetchApplicants();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.fromLTRB(20,5,10,5),
        child: FutureBuilder(
          future: futureApplicants,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Project> projects = snapshot.data;
              if(projects.length == 0){
                return Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Text("No applicants found!"
                    ),
                  ),
                );
              }else {
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: ListTile(
                        leading: Icon(Icons.touch_app_outlined),
                        title: Text(projects[index].applicantName),
                        subtitle: Text(
                          "${projects[index].status}",
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            color: projects[index].status == "Approved" ?
                              Colors.green :
                              projects[index].status == "Pending" ?
                              Colors.blue : Colors.red
                          ),
                        ),
                        tileColor: Colors.black12,
                        onTap: (){
                          eventHub.fire("redirectToProofSubmission",projects[index]);
                        },
                      ),
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                            futureApplicants = fetchApplicants();
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
                        futureApplicants = fetchApplicants();
                      });
                    }
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future fetchApplicants() async {

    List<Project> projectList = [];

    String url = baseUrl +
      "/projects/query?type=6&user-info-id=${userInfo['id']}"
      "&par-page=$perPage"
      "&page-index=$pageIndex"
      "&project-id=${project.id}"
      "&category-id=null"
      "&region-name=none"
      "&sort-by=none"
      "&search-text=none";

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

          givenScreenshotUrls = jsonDecode(project['givenScreenshotUrls']);
          givenScreenshotUrls.forEach((givenScreenshotUrl) {
            gScreenshotUrls.add(givenScreenshotUrl);
          });

          givenProofs = jsonDecode(project['givenProofs']);
          givenProofs.forEach((givenProof) {
            gProofs.add(givenProof);
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
              givenProofs: gProofs,
              givenScreenshotUrls: gScreenshotUrls,
              estimatedCost: project['estimatedCost'],
              eachWorkerEarn: project['eachWorkerEarn'],
              type: 2,
              proofSubmissionId: project['proofSubmissionId'],
              totalApplied: project['totalApplied'],
              publisherName: project['publisherName'],
              applicantName: project['applicantName'],
              status: project['pfStatus'],
              publishedBy: project['publishedBy'],
              submittedBy: project['submittedBy']
          ));
        });
      }
    }
    setState(() {
      needToFreezeUi = false;
    });
    return projectList;

  }

}