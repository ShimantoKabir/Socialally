import 'dart:convert';
import 'package:client/models/Project.dart';
import 'package:http/http.dart';
import 'package:client/constants.dart';
import 'package:client/models/ProjectCategory.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Post extends StatefulWidget {
  Post({Key key, this.eventHub, this.userInfo, this.project}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  final Project project;

  @override
  PostState createState() =>
      PostState(key: key, eventHub: eventHub, userInfo: userInfo, project: project);
}

class PostState extends State<Post> {
  var userInfo;
  EventHub eventHub;
  Project project;

  PostState({Key key, this.eventHub, this.userInfo, this.project});

  TextEditingController titleCtl = new TextEditingController();
  TextEditingController workerNeededCtl = new TextEditingController();
  TextEditingController eachWorkerEarnCtl = new TextEditingController();
  TextEditingController estimatedCostCtl = new TextEditingController();
  TextEditingController estimatedDayCtl = new TextEditingController();
  TextEditingController requiredScreenShotsCtl = new TextEditingController();
  List<TextEditingController> todoStepsControllers = [];
  List<TextEditingController> requiredProofsControllers = [];
  ProjectCategory defaultProjectCategory;
  ProjectCategory defaultProjectSubCategory;
  AlertDialog alertDialog;
  String regionName;
  String countryName;
  int estimatedCost = 0;
  int companyCharge = 20;
  var fileInfo;
  bool needToFreezeUi;
  Widget alertIcon;
  String alertText;

  @override
  void initState() {
    super.initState();

    alertText = "No operation running.";
    alertIcon = Container();

    todoStepsControllers.add(new TextEditingController());
    requiredProofsControllers.add(new TextEditingController());

    defaultProjectCategory = new ProjectCategory(
        id: 0,
        categoryId: 0,
        categoryName: "Select",
        subCategoryName: "Select");

    defaultProjectSubCategory = new ProjectCategory(
        id: 0,
        categoryId: 0,
        categoryName: "Select",
        subCategoryName: "Select");

    List<dynamic> projectCategories = userInfo['projectCategories'];
    projectCategories.asMap().forEach((key, projectCategory) {
      bool isValueExist = false;
      projectCategoriesDropDownList.forEach((element) {
        if (element.value.categoryName == projectCategory['categoryName']) {
          isValueExist = true;
        }
      });

      if (!isValueExist) {
        ProjectCategory pc = new ProjectCategory(
          id: null,
          subCategoryName: null,
          categoryId: projectCategory['categoryId'],
          categoryName: projectCategory['categoryName'],
        );

        projectCategoriesDropDownList.add(new DropdownMenuItem<ProjectCategory>(
          value: pc,
          child: Text(pc.categoryName),
        ));
      }
    });

    if (userInfo['regionName'] == null) {
      regionName = "Select";
    } else {
      regionName = userInfo['regionName'];
    }

    if (userInfo['countryName'] == null) {
      countryName = "Select";
    } else {
      bool isValueExist = false;
      countryDropDownList.forEach((element) {
        if (element.value == userInfo['countryName']) {
          isValueExist = true;
        }
      });

      countryName = userInfo['countryName'];
      if (!isValueExist) {
        countryDropDownList.add(new DropdownMenuItem<String>(
          value: userInfo['countryName'],
          child: Text(userInfo['countryName']),
        ));
      }
    }

    estimatedCostCtl.text = estimatedCost.toString();
    eachWorkerEarnCtl.addListener(() {
      setState(() {
        if (eachWorkerEarnCtl.text.isNotEmpty &&
            workerNeededCtl.text.isNotEmpty) {
          int res = int.tryParse(eachWorkerEarnCtl.text) *
                  int.tryParse(workerNeededCtl.text) +
              companyCharge;
          estimatedCostCtl.text = res.toString();
        }
      });
    });

    fileInfo = {
      "fileName": "No file selected yet",
      "fileExt": null,
      "fileString": null,
      "imageName": "No image selected yet",
      "imageExt": null,
      "imageString": null
    };

    needToFreezeUi = false;

    if(project == null){
      eventHub.fire("viewTitle", "Post Job");
    }else {
      eventHub.fire("viewTitle", "Update Job");
    }

  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: needToFreezeUi,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                entryField("Title", titleCtl),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text("Todo Steps",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Divider(thickness: 1, color: Colors.green),
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(8),
                    itemCount: todoStepsControllers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                              controller: todoStepsControllers[index],
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true)));
                    }),
                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            todoStepsControllers
                                .add(new TextEditingController());
                          });
                        }),
                    IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (todoStepsControllers.length > 0) {
                              todoStepsControllers.removeLast();
                            }
                          });
                        })
                  ],
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text("Required Proofs",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Divider(thickness: 1, color: Colors.green),
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(8),
                    itemCount: requiredProofsControllers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: TextField(
                            controller: requiredProofsControllers[index],
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                fillColor: Color(0xfff3f3f4),
                                filled: true)),
                      );
                    }),
                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            requiredProofsControllers
                                .add(new TextEditingController());
                          });
                        }),
                    IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (requiredProofsControllers.length > 0) {
                              requiredProofsControllers.removeLast();
                            }
                          });
                        })
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Required Screenshots",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                          controller: requiredScreenShotsCtl,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]')),
                          ],
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              fillColor: Color(0xfff3f3f4),
                              filled: true))
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text("Category",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                    child: DropdownButton<ProjectCategory>(
                        value: defaultProjectCategory,
                        isExpanded: true,
                        underline: SizedBox(),
                        onChanged: (ProjectCategory pc) {
                          print("pc id ${pc.categoryId}");
                          if (pc.categoryId != 0) {
                            fetchSubCategoriesById(context, pc);
                          } else {
                            setState(() {
                              defaultProjectCategory = new ProjectCategory(
                                  id: 0,
                                  categoryId: 0,
                                  categoryName: "Select",
                                  subCategoryName: "Select");
                            });
                            clearSubCategoryDropdown();
                          }
                        },
                        items: projectCategoriesDropDownList)),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text("Sub Category",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                    child: DropdownButton<ProjectCategory>(
                        value: defaultProjectSubCategory,
                        isExpanded: true,
                        underline: SizedBox(),
                        onChanged: (ProjectCategory pc) {
                          setState(() {
                            defaultProjectSubCategory = pc;
                          });
                        },
                        items: projectSubCategoriesDropDownList)),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text("Region",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                    child: DropdownButton<String>(
                        value: regionName,
                        isExpanded: true,
                        underline: SizedBox(),
                        onChanged: (String rn) {
                          if (rn == "Select") {
                            setState(() {
                              regionName = "Select";
                            });
                            clearCountryDropdown();
                          } else {
                            fetchCountriesByRegion(context, rn);
                          }
                        },
                        items: regionDropDownList)),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text("Country",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                    child: DropdownButton<String>(
                        value: countryName,
                        isExpanded: true,
                        underline: SizedBox(),
                        onChanged: (String newValue) {
                          setState(() {
                            countryName = newValue;
                          });
                        },
                        items: countryDropDownList)),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Worker Needed",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                          controller: workerNeededCtl,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]')),
                          ],
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              fillColor: Color(0xfff3f3f4),
                              filled: true))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Each Worker Earn",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                          controller: eachWorkerEarnCtl,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]')),
                          ],
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              fillColor: Color(0xfff3f3f4),
                              filled: true))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Estimated Cost",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                          controller: estimatedCostCtl,
                          readOnly: true,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              fillColor: Color(0xfff3f3f4),
                              filled: true))
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Estimated Day",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                          controller: estimatedDayCtl,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]')),
                          ],
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              fillColor: Color(0xfff3f3f4),
                              filled: true))
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlineButton(
                          onPressed: () {
                            onFileSelect(context, "img");
                          },
                          child: Text("Select Image")),
                      Text(fileInfo["imageName"]),
                      OutlineButton(
                          onPressed: () {
                            setState(() {
                              fileInfo["imageExt"] = null;
                              fileInfo["imageName"] = "No file selected yet!";
                              fileInfo["imageString"] = null;
                            });
                          },
                          child: Text("Clear"))
                    ]),
                SizedBox(
                  height: 10,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlineButton(
                          onPressed: () {
                            onFileSelect(context, "file");
                          },
                          child: Text("Select File")),
                      Text(fileInfo["fileName"]),
                      OutlineButton(
                          onPressed: () {
                            setState(() {
                              fileInfo["fileExt"] = null;
                              fileInfo["fileName"] = "No file selected yet!";
                              fileInfo["fileString"] = null;
                            });
                          },
                          child: Text("Clear"))
                    ]),
                SizedBox(
                  height: 20,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlineButton(
                          onPressed: () {
                            if (userInfo['profileCompleted'] == 100) {
                              onSave(context);
                            } else {
                              Alert.show(alertDialog, context, Alert.ERROR,
                                  "To post a new job, you need to complete your profile 100%.");
                            }
                          },
                          child: Text(project == null ? "Save" : "Update")),
                      OutlineButton(
                          onPressed: () {
                            onReset(context);
                          },
                          child: Text("Reset"))
                    ])
              ]
            )
          )
        ),
        bottomNavigationBar: Alert.addBottomLoader(
          needToFreezeUi,
          alertIcon,
          alertText
        )
      )
    );
  }

  Widget entryField(String title, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: controller,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Future<void> fetchSubCategoriesById(
      BuildContext context, ProjectCategory pc) async {
    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    clearSubCategoryDropdown();

    var response = await get("$baseUrl/categories/sub/${pc.categoryId}");
    print("response = $response");
    if (response.statusCode == 200) {
      setState(() {
        needToFreezeUi = false;
      });
      var res = jsonDecode(response.body);
      if (res['code'] == 200) {
        List<dynamic> projectSubCategories = res['projectCategories'];
        projectSubCategories.asMap().forEach((key, projectCategory) {
          ProjectCategory pc = new ProjectCategory(
            id: projectCategory['id'],
            subCategoryName: projectCategory['subCategoryName'],
            categoryId: null,
            categoryName: null,
          );
          projectSubCategoriesDropDownList.add(
              new DropdownMenuItem<ProjectCategory>(
                value: pc,
                child: Text(pc.subCategoryName),
            )
          );
        });
      }
    } else {
      setState(() {
        needToFreezeUi = false;
      });
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    }

    setState(() {
      defaultProjectCategory = pc;
    });
  }

  void clearSubCategoryDropdown() {
    setState(() {
      projectSubCategoriesDropDownList.clear();
      defaultProjectSubCategory = new ProjectCategory(
          id: 0,
          categoryId: 0,
          categoryName: "Select",
          subCategoryName: "Select");
      projectSubCategoriesDropDownList.add(
          new DropdownMenuItem<ProjectCategory>(
            value: defaultProjectSubCategory,
            child: Text("Select"),
      ));
    });
  }

  Future<void> fetchCountriesByRegion(
      BuildContext context, String region) async {
    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    clearCountryDropdown();

    var response = await get("https://restcountries.eu/rest/v2/region/$region");
    if (response.statusCode == 200) {
      setState(() {
        needToFreezeUi = false;
      });
      var jsonResponse = jsonDecode(response.body);
      List<dynamic> countryNames = jsonResponse;
      countryNames.asMap().forEach((key, country) {
        countryDropDownList.add(new DropdownMenuItem<String>(
          value: country['name'],
          child: Text(country['name']),
        ));
      });
    } else {
      setState(() {
        needToFreezeUi = false;
      });
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    }

    setState(() {
      regionName = region;
    });
  }

  void clearCountryDropdown() {
    setState(() {
      countryDropDownList.clear();
      countryName = "Select";
      countryDropDownList.add(new DropdownMenuItem<String>(
        value: "Select",
        child: Text("Select"),
      ));
    });
  }

  void onSave(BuildContext context) {
    List<String> todoSteps = [];
    List<String> requiredProofs = [];

    todoStepsControllers.forEach((todoStep) {
      todoSteps.add(todoStep.text);
    });

    requiredProofsControllers.forEach((requiredProof) {
      requiredProofs.add(requiredProof.text);
    });

    var request = {
      "project": {
        "title": titleCtl.text,
        "todoSteps": todoSteps,
        "requiredProofs": requiredProofs,
        "categoryId": defaultProjectCategory.categoryId,
        "subCategoryId": defaultProjectSubCategory.id,
        "regionName": regionName,
        "countryName": countryName,
        "workerNeeded": int.parse(workerNeededCtl.text),
        "estimatedDay": int.parse(estimatedDayCtl.text),
        "estimatedCost": int.parse(estimatedCostCtl.text),
        "requiredScreenShots": int.parse(requiredScreenShotsCtl.text),
        "fileString": fileInfo["fileString"],
        "fileExt": fileInfo["fileExt"],
        "imageString": fileInfo["imageString"],
        "imageExt": fileInfo["imageExt"]
      },
      "userInfo": {"id": userInfo['id']}
    };

    String url = baseUrl + '/projects';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    post(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
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

  void onReset(BuildContext context) {}

  Future<void> onFileSelect(BuildContext context, String fileType) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: fileType == "img" ? allowedImageType : allowedFileType,
    );

    if (result != null) {
      PlatformFile objFile = result.files.single;
      if (objFile.size > maxImageSize) {
        Alert.show(
            alertDialog,
            context,
            Alert.ERROR,
            "Image size cross the max limit, "
            "You can only upload ${maxImageSize / oneMegaByte} or less then ${maxImageSize / oneMegaByte} mb image/file.");
      } else {
        setState(() {
          if (fileType == "img") {
            fileInfo["imageName"] = objFile.name;
            fileInfo["imageString"] = base64.encode(objFile.bytes);
            fileInfo["imageExt"] = objFile.extension;
          } else {
            fileInfo["fileName"] = objFile.name;
            fileInfo["fileString"] = base64.encode(objFile.bytes);
            fileInfo["fileExt"] = objFile.extension;
          }
        });
      }
    } else {
      Alert.show(alertDialog, context, Alert.ERROR, "No file selected!");
    }
  }



  @override
  void dispose() {
    super.dispose();
    eventHub.fire("clearProject");
  }
}
