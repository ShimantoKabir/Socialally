import 'dart:convert';
import 'package:wengine/constants.dart';
import 'package:wengine/models/FilterCriteria.dart';
import 'package:wengine/models/Project.dart';
import 'package:wengine/models/ProjectCategory.dart';
import 'package:wengine/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class JobFinder extends StatefulWidget {

  JobFinder({
    Key key,
    this.eventHub,
    this.userInfo,
    this.filterCriteria,
  }) : super(key: key);

  final EventHub eventHub;
  final FilterCriteria filterCriteria;
  final userInfo;

  @override
  JobFinderState createState() =>
      JobFinderState(
          key: key,
          eventHub: eventHub,
          userInfo: userInfo,
          filterCriteria: filterCriteria
      );
}

class JobFinderState extends State<JobFinder> {

  EventHub eventHub;
  FilterCriteria filterCriteria;
  var userInfo;

  JobFinderState({
    Key key,
    this.eventHub,
    this.userInfo,
    this.filterCriteria
  });

  AlertDialog alertDialog;
  Future futureProjects;
  Widget alertIcon;
  String alertText;
  String regionName;
  bool needToFreezeUi;
  int pageIndex = 0;
  int perPage = 15;
  int pageNumber = 0;
  String filterBy;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle","Available Job");
    futureProjects = fetchAvailableJob();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;

    filterBy = "[";

    if(filterCriteria.categoryName == null){
      filterBy = filterBy + "Category: None";
    }else {
      filterBy = filterBy+ "Category: "+filterCriteria.categoryName;
    }

    if(filterCriteria.location == null){
      filterBy = filterBy + "/Location: None";
    }else {
      filterBy = filterBy + "/Location: " + filterCriteria.location;
    }

    if(filterCriteria.sortBy == null){
      filterBy = filterBy + "/SortBy: None";
    }else {
      filterBy = filterBy + "/SortBy: " + filterCriteria.sortBy;
    }

    filterBy = filterBy + "]";

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            child: Container(
              padding: EdgeInsets.fromLTRB(0,0,5,0),
              color: Colors.green,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.filter_alt_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: (){
                            eventHub.fire("redirectToJobFilter",{
                              "type" : 1
                            });
                          }
                      ),
                      Text(
                        "Filter",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      )
                    ],
                  ),
                  Text(
                    filterBy,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white
                    ),
                  )
                ],
              ),
            ),
            preferredSize: Size.fromHeight(40.0)
        ),
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
                      child: Text("No available job found!"),
                    ),
                  );
                }else {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: (){
                            eventHub.fire("redirectToProofSubmission",projects[index]);
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      projects[index].title,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15
                                      ),
                                    ),
                                    Text("Worker Needed: ${projects[index].workerNeeded}"),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Publish By: ${projects[index].publisherName}"),
                                    Text("Budget: £${projects[index].estimatedCost}"
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
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

    String location = filterCriteria.location == null ? "none" :
    filterCriteria.location.replaceAll(" ", "").toLowerCase();

    String sortBy = filterCriteria.sortBy == null ? "none" :
    filterCriteria.sortBy.replaceAll(" ", "").toLowerCase();

    String searchText = filterCriteria.searchText == null ||
        filterCriteria.searchText.isEmpty ? "none" :
    filterCriteria.searchText.replaceAll(" ", "").toLowerCase();

    String url = baseUrl +
        "/projects/query?type=1&user-info-id=${userInfo['id']}"
            "&par-page=$perPage"
            "&page-index=$pageIndex"
            "&category-id=${filterCriteria.categoryId}"
            "&region-name=$location"
            "&sort-by=$sortBy"
            "&search-text=$searchText";

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
              givenProofs: gProofs,
              givenScreenshotUrls: gScreenshotUrls,
              estimatedCost: project['estimatedCost'],
              eachWorkerEarn: project['eachWorkerEarn'],
              type: 1,
              proofSubmissionId: project['proofSubmissionId'],
              totalApplied: project['totalApplied'],
              publisherName: project['publisherName'],
              applicantName: project['applicantName'],
              pfStatus: project['pfStatus'],
              status: project['status'],
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

  BoxDecoration headingDecoration() {
    return BoxDecoration(
      border: Border(
          bottom:  BorderSide(
            color: Colors.green,
            width: 1.0,
          )
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    filterCriteria.type = 1;
    filterCriteria.searchText = null;
    filterCriteria.sortBy = null;
    filterCriteria.location = null;
    filterCriteria.categoryId = null;
    filterCriteria.categoryName = null;
  }
}
