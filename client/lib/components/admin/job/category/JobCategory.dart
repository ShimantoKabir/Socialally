import 'dart:convert';
import 'package:socialally/constants.dart';
import 'package:socialally/models/ProjectCategory.dart';
import 'package:socialally/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class JobCategory extends StatefulWidget {
  JobCategory({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  JobCategoryState createState() => JobCategoryState(userInfo: userInfo, eventHub: eventHub);
}

class JobCategoryState extends State<JobCategory> {
  var userInfo;
  EventHub eventHub;
  JobCategoryState({Key key, this.userInfo, this.eventHub});

  AlertDialog alertDialog;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  Future futureJobCategories;
  ProjectCategory projectCategory;
  bool isSideBoxOpen;
  TextEditingController categoryNameCtl = new TextEditingController();

  @override
  void initState() {
    super.initState();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    projectCategory = null;
    isSideBoxOpen = false;
    futureJobCategories = fetchJobCategories();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: needToFreezeUi,
      child: Scaffold(
        body: FutureBuilder(
            future: futureJobCategories,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<ProjectCategory> projectCategories = snapshot.data;
                if(projectCategories.length == 0){
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: Text("No job category found!"),
                    ),
                  );
                }else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: projectCategories.length,
                            itemBuilder: (context, index) {
                              return Container(
                                child: ListTile(
                                  leading: IconButton(
                                    icon: Icon(Icons.delete_sharp),
                                    onPressed: (){
                                      setState(() {
                                        projectCategory = projectCategories[index];
                                      });
                                      print("id ${projectCategory.categoryId}");
                                      onDelete(context);
                                    },
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(projectCategories[index].categoryName),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: (){
                                          setState(() {
                                            projectCategory = projectCategories[index];
                                            categoryNameCtl.text = projectCategories[index].categoryName;
                                            isSideBoxOpen = true;
                                          });
                                        }
                                      )
                                    ],
                                  )
                                ),
                                margin: EdgeInsets.all(5),
                              );
                            },
                          ),
                          flex: 7
                      ),
                      Visibility(
                          visible: isSideBoxOpen,
                          child: Expanded(
                              child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(
                                            color: Colors.grey
                                        )
                                    )
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    entryField(
                                        title: "Category Name",
                                        controller: categoryNameCtl
                                    ),
                                    SizedBox(height: 10),
                                    OutlineButton(
                                      onPressed: (){
                                        setState(() {
                                          if(categoryNameCtl.text.isEmpty){
                                            Alert.show(alertDialog, context, Alert.SUCCESS, "Category Name missing!");
                                          }else {
                                            if(projectCategory == null){
                                              onSave(context);
                                            }else {
                                              onUpdate(context);
                                            }
                                          }
                                        });
                                      },
                                      child: Text(
                                          projectCategory == null ? "Save" : "Update"
                                      )
                                    ),
                                    SizedBox(height: 10),
                                    OutlineButton(
                                      onPressed: (){
                                        clearProjectCategory(context);
                                      },
                                      child: Text("close")
                                    )
                                  ],
                                ),
                              ),
                              flex: 3
                          )
                      )
                    ],
                  );
                }
              }else {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                );
              }
            }
        ),
        bottomNavigationBar: Container(
          color: Colors.black12,
          height: 50.0,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.add,
                  size: 25
                ),
                onPressed: (){
                  setState(() {
                    isSideBoxOpen = true;
                  });
                }
              ),
              Visibility(
                  visible: needToFreezeUi,
                  child: Padding(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      strokeWidth: 2,
                    ),
                    padding: EdgeInsets.all(5)
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget entryField({String title,
    TextEditingController controller,
    TextInputType textInputType,
    List<TextInputFormatter> textInputFormatter,int maxLines}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          showRequiredHeading(title),
          SizedBox(
            height: 10,
          ),
          TextField(
              maxLines: maxLines == null ? 1 : maxLines,
              keyboardType: textInputType,
              controller: controller,
              inputFormatters: textInputFormatter,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true
              )
          )
        ],
      ),
    );
  }

  Future<List<ProjectCategory>> fetchJobCategories() async {

    List<ProjectCategory> projectCategoryList = [];

    String url = baseUrl + "/categories";

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    var response = await get(url);
    setState(() {
      needToFreezeUi = false;
    });
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['code'] == 200) {
        List<dynamic> projectCategories = res['projectCategories'];
        projectCategories.asMap().forEach((key, value) {
          projectCategoryList.add(new ProjectCategory(
            categoryId: value['categoryId'],
            categoryName: value['categoryName']
          ));
        });
      }else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }else {
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    }
    return projectCategoryList;
  }

  void clearProjectCategory(BuildContext context) {
    setState(() {
      categoryNameCtl.clear();
      projectCategory = null;
      isSideBoxOpen = false;
    });
  }

  void onSave(BuildContext context) {

    var request = {
      "projectCategory": {
        "categoryName": categoryNameCtl.text,
      }
    };

    String url = baseUrl + '/categories';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
    });

    post(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          setState(() {
            futureJobCategories = fetchJobCategories();
          });
          clearProjectCategory(context);
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

  void onUpdate(BuildContext context) {

    var request = {
      "projectCategory": {
        "categoryId" : projectCategory.categoryId,
        "categoryName": categoryNameCtl.text,
      }
    };

    String url = baseUrl + '/categories';
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
            futureJobCategories = fetchJobCategories();
          });
          clearProjectCategory(context);
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

  void onDelete(BuildContext context) {

    String url = baseUrl + '/categories/${projectCategory.categoryId}';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
    });

    delete(url, headers: headers).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          setState(() {
            futureJobCategories = fetchJobCategories();
          });
          clearProjectCategory(context);
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
}