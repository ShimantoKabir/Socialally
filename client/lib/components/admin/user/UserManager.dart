import 'dart:convert';

import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/utilities/Alert.dart';

class UserManager extends StatefulWidget {
  UserManager({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  UserManagerState createState() => UserManagerState(userInfo: userInfo, eventHub: eventHub);
}

class UserManagerState extends State<UserManager> {
  var userInfo;
  EventHub eventHub;
  UserManagerState({Key key, this.userInfo, this.eventHub});

  AlertDialog alertDialog;
  Future futureUserInfos;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  int pageIndex = 0;
  int perPage = 10;
  int pageNumber = 0;
  var ui;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle","Manage User");
    futureUserInfos = fetchUserInfos();
    alertText = "No operation running!";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: FutureBuilder(
          future: futureUserInfos,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<dynamic> userInfos = snapshot.data;
              if(userInfos.length == 0){
                return Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Text("No user info found!"),
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
                                label: Text("Email"),
                              ),
                              DataColumn(
                                label: Text("First Name"),
                              ),
                              DataColumn(
                                label: Text("Last Name"),
                              ),
                              DataColumn(
                                label: Text("Region"),
                              ),
                              DataColumn(
                                label: Text("Country"),
                              ),
                              DataColumn(
                                label: Text("Terms & Conditions"),
                              ),
                              DataColumn(
                                label: Text("Want Newsletter Notification"),
                              )
                            ],
                            rows: List<DataRow>.generate(
                                userInfos.length, (index) => DataRow(
                                onSelectChanged: (value){
                                  if(!needToFreezeUi){
                                    setState(() {
                                      ui = userInfos[index];
                                    });
                                  }
                                },
                                cells: [
                                  DataCell(Text("${index+1}")),
                                  DataCell(userInfos[index]['isActive'] == 1 ? Text("Active") : Text("Inactive")),
                                  DataCell(Text("${userInfos[index]['email']}")),
                                  DataCell(Text("${userInfos[index]['firstName']}")),
                                  DataCell(Text("${userInfos[index]['lastName']}")),
                                  DataCell(Text("${userInfos[index]['regionName']}")),
                                  DataCell(Text("${userInfos[index]['countryName']}")),
                                  DataCell(Text("${userInfos[index]['agreedTermsAndCondition']}")),
                                  DataCell(Text("${userInfos[index]['wantNewsLetterNotification']}"))
                                ]
                            )
                            ),
                          ),
                        ),
                        flex: 7
                    ),
                    Visibility(
                        visible: ui != null,
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
                                child: ui == null ? Container() : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Email: ${ui['email']}"),
                                    SizedBox(height: 10),
                                    Text("First Name: ${ui['firstName']}"),
                                    SizedBox(height: 10),
                                    Text("Last Name: ${ui['lastName']}"),
                                    SizedBox(height: 10),
                                    Text("Region: ${ui['regionName']}"),
                                    SizedBox(height: 10),
                                    Text("Country: ${ui['countryName']}"),
                                    SizedBox(height: 10),
                                    SizedBox(height: 10),
                                    OutlineButton(
                                      onPressed: (){
                                        onStatusChange(context,ui);
                                      },
                                      child: Text(ui['isActive'] == 1 ? "Deactivate" : "Activate"),
                                    ),
                                    SizedBox(height: 10),
                                    OutlineButton(
                                      onPressed: (){
                                        onReset(context);
                                      },
                                      child: Text("Close"),
                                    ),
                                    SizedBox(height: 10),
                                    OutlineButton(
                                      onPressed: (){
                                        getUserInfoById(ui['id']);
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
                              futureUserInfos = fetchUserInfos();
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
                            futureUserInfos = fetchUserInfos();
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

  Future<void> getUserInfoById(int publishedBy) async {
    String url = baseUrl + "/users/$publishedBy";
    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      print("res ${res['userInfo']}");
      eventHub.fire("redirectToProfile",res['userInfo']);
    }
  }

  Future<List<dynamic>> fetchUserInfos() async {

    List<dynamic> userInfoList = [];
    String url = baseUrl + "/users/paginate/query?par-page=$perPage&page-index=$pageIndex&type=1";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      print("res = $res");
      List<dynamic> userInfos = res['userInfos'];

      userInfos.asMap().forEach((key, value) {
        userInfoList.add({
          "id" : value['id'],
          "email" : value['email'],
          "imageUrl" : value['imageUrl'],
          "firstName" : value['firstName'],
          "lastName" : value['lastName'],
          "regionName" : value['regionName'],
          "countryName" : value['countryName'],
          "agreedTermsAndCondition" : value['agreedTermsAndCondition'],
          "wantNewsLetterNotification" : value['wantNewsLetterNotification'],
          "isActive" : value['isActive']
        });
      });
    }
    setState(() {
      needToFreezeUi = false;
    });
    return userInfoList;

  }

  void onStatusChange(BuildContext context,var ui) {

    var request = {
      "userInfo": {
        "id": ui['id'],
        "isActive": ui['isActive'] == 1 ? 0 : 1
      }
    };

    String url = baseUrl + '/users/status';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
    });

    put(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          setState(() {
            ui = null;
            futureUserInfos = fetchUserInfos();
          });
          onReset(context);
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

  void onReset(BuildContext context) {
    setState(() {
      ui = null;
    });
  }
}