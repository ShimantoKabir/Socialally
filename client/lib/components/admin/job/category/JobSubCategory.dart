import 'dart:convert';

import 'package:wengine/constants.dart';
import 'package:wengine/models/ProjectCategory.dart';
import 'package:wengine/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:universal_html/html.dart';

class JobSubCategory extends StatefulWidget {
  JobSubCategory({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  JobSubCategoryState createState() => JobSubCategoryState(
    userInfo: userInfo,
    eventHub: eventHub
  );
}

class JobSubCategoryState extends State<JobSubCategory> {

  var userInfo;
  EventHub eventHub;

  JobSubCategoryState({
    Key key,
    this.userInfo,
    this.eventHub
  });

  AlertDialog alertDialog;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  Future futureJobCategories;
  ProjectCategory projectCategory;
  bool isSideBoxOpen;
  TextEditingController subCategoryNameCtl = new TextEditingController();
  TextEditingController chargeByCategoryCtl = new TextEditingController();
  bool isInSaveMood;
  int subCategoryId;


  @override
  void initState() {
    super.initState();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    isSideBoxOpen = false;
    isInSaveMood = true;
    futureJobCategories = fetchJobCategories();
    subCategoryId = null;
    projectCategory = ProjectCategory(
      id: 0,
      categoryId: 0,
      categoryName: "Select",
      subCategoryName: "Select",
      chargeByCategory: 0.0
    );
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
                return SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: inputFields(),
                    ),
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
                                    subCategoryId = projectCategories[index].id;
                                  });
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
                                          subCategoryId = projectCategories[index].id;
                                          projectCategory.id = 0;
                                          projectCategory.subCategoryName = "Select";
                                          projectCategory.categoryName = projectCategories[index].categoryName;
                                          projectCategory.categoryId = projectCategories[index].categoryId;
                                          subCategoryNameCtl.text = projectCategories[index].subCategoryName;
                                          chargeByCategoryCtl.text = projectCategories[index].chargeByCategory.toString();
                                          isSideBoxOpen = true;
                                          isInSaveMood = false;
                                        });
                                      }
                                  )
                                ],
                              ),
                              subtitle: Text(
                                "${projectCategories[index].subCategoryName}/"
                                "Charge: ${projectCategories[index].chargeByCategory}"
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
                              children: inputFields(),
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
                  clearProjectCategory(true);
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

  List<Widget> inputFields(){
    return [
      showRequiredHeading("Category"),
      SizedBox(height: 10),
      Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
          child: DropdownButton<ProjectCategory>(
              value: projectCategory,
              isExpanded: true,
              underline: SizedBox(),
              onChanged: (ProjectCategory pc) {
                setState(() {
                  projectCategory.id = 0;
                  projectCategory.categoryId = pc.categoryId;
                  projectCategory.categoryName = pc.categoryName;
                  projectCategory.chargeByCategory = 0.0;
                  projectCategory.subCategoryName = "Select";
                });
              },
              items: projectCategoriesDropDownList
          )
      ),
      SizedBox(height: 10),
      entryField(
          title: "Sub Category Name",
          controller: subCategoryNameCtl
      ),
      entryField(
        title: "Charge By Category",
        controller: chargeByCategoryCtl,
        textInputFormatter: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(
              RegExp(r'[0-9.]')
          ),
        ],
        textInputType: TextInputType.number
      ),
      SizedBox(height: 10),
      OutlineButton(
          onPressed: (){
            bool isInputVerified = verifyInput(context);
            if(isInputVerified){
              if(isInSaveMood){
                onSave(context);
              }else {
                onUpdate(context);
              }
            }
          },
          child: Text(
              isInSaveMood ? "Save" : "Update"
          )
      ),
      SizedBox(height: 10),
      OutlineButton(
          onPressed: (){
            clearProjectCategory(false);
          },
          child: Text("Close")
      )
    ];

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

    List<ProjectCategory> projectSubCategoryList = [];
    String url = baseUrl + "/sub-categories";
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
        List<dynamic> projectSubCategories = res['projectSubCategories'];
        projectSubCategories.asMap().forEach((key, value) {
          projectSubCategoryList.add(new ProjectCategory(
            id: value['id'],
            categoryId: value['categoryId'],
            categoryName: value['categoryName'],
            subCategoryName: value['subCategoryName'],
            chargeByCategory: value['chargeByCategory']
          ));
        });

        List<dynamic> projectCategories = res['projectCategories'];
        projectCategories.asMap().forEach((key, projectCategory) {
          bool isValueExist = false;
          projectCategoriesDropDownList.forEach((element) {
            if (element.value.categoryName == projectCategory['categoryName']) {
              isValueExist = true;
            }
          });
          if (!isValueExist) {
            ProjectCategory pc = new ProjectCategory(
              id: 0,
              categoryId: projectCategory['categoryId'],
              categoryName: projectCategory['categoryName'],
              subCategoryName: "Select",
              chargeByCategory: 0.0
            );
            projectCategoriesDropDownList.add(new DropdownMenuItem<ProjectCategory>(
              value: pc,
              child: Text(pc.categoryName),
            ));
          }
        });

      }else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }else {
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    }
    return projectSubCategoryList;
  }

  void onDelete(BuildContext context) {

    String url = baseUrl + '/sub-categories/$subCategoryId';
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
          clearProjectCategory(false);
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

  void onSave(BuildContext context) {

    var request = {
      "projectCategory": {
        "categoryId": projectCategory.categoryId,
        "categoryName" : projectCategory.categoryName,
        "subCategoryName" : subCategoryNameCtl.text,
        "chargeByCategory" : double.tryParse(chargeByCategoryCtl.text)
      }
    };

    String url = baseUrl + '/sub-categories';
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
          clearProjectCategory(true);
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
        "id" : subCategoryId,
        "categoryId" : projectCategory.categoryId,
        "categoryName": projectCategory.categoryName,
        "subCategoryName": subCategoryNameCtl.text,
        "chargeByCategory" : double.tryParse(chargeByCategoryCtl.text)
      }
    };

    String url = baseUrl + '/sub-categories';
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
          clearProjectCategory(false);
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

  void clearProjectCategory(bool needToOpenSideBox) {
    setState(() {
      subCategoryNameCtl.clear();
      chargeByCategoryCtl.clear();
      subCategoryId = null;
      projectCategory.id = 0;
      projectCategory.categoryId = 0;
      projectCategory.categoryName = "Select";
      projectCategory.subCategoryName = "Select";
      projectCategory.chargeByCategory = 0.0;
      isSideBoxOpen = needToOpenSideBox;
      isInSaveMood = true;
    });
  }

  bool verifyInput(BuildContext context) {

    bool isInputVerified = true;
    String errMsg;

    if (subCategoryNameCtl.text.isEmpty) {
      errMsg = "Sub Category Name missing!";
      isInputVerified = false;
    }else if(chargeByCategoryCtl.text.isEmpty){
      errMsg = "Charge by category is missing!!";
      isInputVerified = false;
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, context, Alert.ERROR, errMsg);
    }
    return isInputVerified;

  }

}