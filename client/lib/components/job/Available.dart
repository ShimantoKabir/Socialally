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

class Available extends StatefulWidget {

  Available({
    Key key,
    this.eventHub,
    this.userInfo,
    this.filterCriteria,
    this.type
  }) : super(key: key);

  final EventHub eventHub;
  final FilterCriteria filterCriteria;
  final userInfo;
  final type;

  @override
  AvailableState createState() =>
  AvailableState(
    key: key,
    eventHub: eventHub,
    userInfo: userInfo,
    filterCriteria: filterCriteria,
    type: type
  );
}

class AvailableState extends State<Available> {

  EventHub eventHub;
  FilterCriteria filterCriteria;
  var userInfo;
  int type;

  AvailableState({
    Key key,
    this.eventHub,
    this.userInfo,
    this.filterCriteria,
    this.type
  });

  AlertDialog alertDialog;
  Future futureProjects;
  Widget alertIcon;
  String alertText;
  String regionName;
  bool needToFreezeUi;
  int pageIndex = 0;
  int perPage = 5;
  int pageNumber = 0;
  String filterBy;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle",
      type == 1 ? "Available Job" :
      type == 2 ? "Accept Job" :
      type == 3 ? "Posted Job" :
      type == 4 ? "Applied Job" : "Advertisement Job"
    );
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
                    child: Text(type == 1 ?"No available job found!" :
                      type == 2 ? "No job found to accept!" :
                      type == 3 ? "You didn't post any job yet!" :
                      type == 4 ? "You didn't applied any job yet!" :
                      "No advertisement job found!"
                    ),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(10,5,10,5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  projects[index].title,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15
                                  ),
                                ),
                                Text(
                                  "${projects[index].regionName}/${projects[index].countryNames.toString()}",
                                )
                              ],
                            ),
                            decoration: headingDecoration(),
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: EdgeInsets.fromLTRB(15,0,15,0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 200,
                                      padding: EdgeInsets.all(3),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 3),
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
                                    SizedBox(width: 5),
                                    Text(
                                      "${projects[index].totalApplied}/${projects[index].workerNeeded} Applied",
                                      style: TextStyle(
                                        fontSize: 12
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  child: Text(
                                    "£${projects[index].eachWorkerEarn}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightGreen
                                    ),
                                  )
                                )
                              ],
                            )
                          ),
                          SizedBox(height: 5),
                          ListView.builder(
                            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: 1,
                            itemBuilder: (context, j) {
                              if(projects[index].todoSteps.length == 0){
                                return Text("No todo step found!");
                              }else {
                                return RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: TextStyle(
                                        letterSpacing: 0.5,
                                        height: 1.5,
                                        color: Colors.black
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: "Todo Steps: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey
                                        )
                                      ),
                                      TextSpan(text: "${projects[index].todoSteps[j]}")
                                    ],
                                  ),
                                );
                              }
                            }
                          ),
                          ListView.builder(
                            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: 1,
                            itemBuilder: (context, j) {
                              if(projects[index].requiredProofs.length == 0){
                                return Text("No required proof found!");
                              }else {
                                return RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: TextStyle(
                                        letterSpacing: 0.5,
                                        height: 1.5,
                                        color: Colors.black
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: "Required Proofs: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey
                                        )
                                      ),
                                      TextSpan(
                                        text: "${projects[index].requiredProofs[j]}"
                                      )
                                    ],
                                  ),
                                );
                              }
                            }
                          ),
                          SizedBox(height: 5),
                          Visibility(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(15, 0, 15,0),
                              child: Text(
                                "Status: ${projects[index].pfStatus}",
                                style: TextStyle(
                                  color: projects[index].pfStatus == "Pending" ?
                                  Colors.blue :
                                  projects[index].pfStatus == "Approved" ?
                                  Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              alignment: Alignment.bottomLeft,
                            ),
                            visible: type == 4 || type == 2,
                          ),
                          Visibility(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(15, 0, 15,0),
                              child: Text(
                                "Status: ${projects[index].status}",
                                style: TextStyle(
                                    color: projects[index].status == "Pending" ?
                                    Colors.blue :
                                    projects[index].status == "Approved" ?
                                    Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              alignment: Alignment.bottomLeft,
                            ),
                            visible: type == 3,
                          ),
                          Visibility(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(15,0,15,0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Estimated Day: ${projects[index].estimatedDay}",
                                    textAlign: TextAlign.right,
                                  ),
                                  Text(
                                      "${projects[index].categoryName}/${projects[index].subCategoryName}"
                                  ),
                                  Text(
                                    type == 2 ?
                                    "Applied By: ${projects[index].applicantName}" :
                                    type == 3 ? "Published By: Me" :
                                    "Published By: ${projects[index].publisherName}",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold
                                    )
                                  )
                                ],
                              ),
                            ),
                            visible: type != 5,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(15,5,15,10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Visibility(
                                  visible: projects[index].fileUrl != null &&
                                    type == 1 ||
                                    type == 5 ||
                                    type == 3,
                                  child: FlatButton(
                                    onPressed: (){
                                      if(type == 3){
                                        eventHub.fire("redirectToJobApplicants",projects[index]);
                                      }else {
                                        openFile(projects[index].fileUrl,context);
                                      }
                                    },
                                    color: Colors.green,
                                    child: Row(
                                      // Replace with a Row for horizontal icon + text
                                      children: <Widget>[
                                        Icon(
                                            type == 3 ? Icons.people_outline :
                                            Icons.file_download,
                                          size: 10,
                                          color: Colors.white
                                        ),
                                        Text(type == 3 ? " Applicants" :
                                            " Instruction File",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10
                                          )
                                        )
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
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          type == 1 ? " Apply " : type == 2
                                          ? " Investigate " : type == 5
                                          ? " Submit " : " Update ",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10
                                          )
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 10,
                                          color: Colors.white
                                        )
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
      "/projects/query?type=$type&user-info-id=${userInfo['id']}"
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
          List<String> cNames = [];
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

          List<dynamic> countryNames = jsonDecode(project['countryNames']);
          countryNames.forEach((countryName) {
            cNames.add(countryName);
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
              countryNames: cNames,
              workerNeeded: project['workerNeeded'],
              requiredScreenShots: project['requiredScreenShots'],
              estimatedDay: project['estimatedDay'],
              imageUrl: project['imageUrl'],
              fileUrl: project['fileUrl'],
              givenProofs: gProofs,
              givenScreenshotUrls: gScreenshotUrls,
              estimatedCost: project['estimatedCost'],
              eachWorkerEarn: project['eachWorkerEarn'],
              type: type,
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
    filterCriteria.type = type;
    filterCriteria.searchText = null;
    filterCriteria.sortBy = null;
    filterCriteria.location = null;
    filterCriteria.categoryId = null;
    filterCriteria.categoryName = null;
  }
}
