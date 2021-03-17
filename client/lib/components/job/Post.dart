import 'dart:convert';
import 'package:multi_select_flutter/multi_select_flutter.dart' as ms;
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:universal_html/html.dart';
import 'package:wengine/models/MyLocation.dart';
import 'package:wengine/models/Project.dart';
import 'package:http/http.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/models/ProjectCategory.dart';
import 'package:wengine/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_io/io.dart' as uio;

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
  int estimatedCost = 0;
  double jobPostingCharge = 0.0;
  var fileInfo;
  bool needToFreezeUi;
  Widget alertIcon;
  String alertText;

  List<MultiSelectItem<MyLocation>> multiSelectItems = [];
  List<MyLocation> multiSelectInitialItems = [];
  List<MyLocation> selectedItems = [];

  @override
  void initState() {
    super.initState();

    alertText = "No operation running!";
    alertIcon = Container();
    regionName = "Select";

    clearListControllers();
    resetCategories();

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
          id: 0,
          subCategoryName: null,
          categoryId: projectCategory['categoryId'],
          categoryName: projectCategory['categoryName'],
          chargeByCategory: 0.0
        );

        projectCategoriesDropDownList.add(new DropdownMenuItem<ProjectCategory>(
          value: pc,
          child: Text(pc.categoryName),
        ));
      }
    });


    workerNeededCtl.addListener(() {
      setState(() {
        calculateEstimatedCost();
        if(workerNeededCtl.text.isEmpty){
          eachWorkerEarnCtl.clear();
          estimatedCostCtl.clear();
        }
      });
    });

    eachWorkerEarnCtl.addListener(() {
      setState(() {
        calculateEstimatedCost();
        if(eachWorkerEarnCtl.text.isEmpty){
          estimatedCostCtl.clear();
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

      estimatedDayCtl.text = project.estimatedDay.toString();
      titleCtl.text = project.title;
      todoStepsControllers.clear();
      requiredProofsControllers.clear();
      project.todoSteps.forEach((element) {
        TextEditingController textEditingController = new TextEditingController();
        textEditingController.text = element;
        todoStepsControllers.add(textEditingController);
      });

      project.requiredProofs.forEach((element) {
        TextEditingController textEditingController = new TextEditingController();
        textEditingController.text = element;
        requiredProofsControllers.add(textEditingController);
      });

      requiredScreenShotsCtl.text = project.requiredScreenShots.toString();

      fetchSubCategoriesById(null,ProjectCategory(
        id: 0,
        categoryId: project.categoryId,
        categoryName: project.categoryName,
        subCategoryName: null,
        chargeByCategory: 0.0
      ))
      .whenComplete((){

        defaultProjectSubCategory = ProjectCategory(
            id: project.subCategoryId,
            categoryId: 0,
            categoryName: null,
            subCategoryName: project.subCategoryName,
            chargeByCategory: project.chargeByCategory
        );

      });

      project.countryNames.forEach((cty) {
        multiSelectInitialItems.add(MyLocation(
          countryName: cty,
          regionName: project.regionName
        ));
      });

      fetchCountriesByRegion(null,project.regionName);

      workerNeededCtl.text = project.workerNeeded.toString();
      eachWorkerEarnCtl.text = project.eachWorkerEarn.toString();
      estimatedCostCtl.text = project.estimatedCost.toString();

    }

    jobPostingCharge = userInfo['jobPostingCharge'];

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
                entryField("Title", titleCtl,50),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: showRequiredHeading("Todo Steps"),
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
                              readOnly: project == null ? false : true,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  fillColor: Color(0xfff3f3f4),
                                  filled: true)));
                    }),
                Visibility(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            todoStepsControllers.add(TextEditingController());
                          });
                        }),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (todoStepsControllers.length > 1) {
                              todoStepsControllers.removeLast();
                            }
                          });
                        }
                      )
                    ],
                  ),
                  visible: project == null
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: showRequiredHeading("Required Proofs"),
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
                Visibility(
                  child: Row(
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
                            if (requiredProofsControllers.length > 1) {
                              requiredProofsControllers.removeLast();
                            }
                          });
                        }
                      )
                    ],
                  ),
                  visible: project == null
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      showRequiredHeading("Required Screenshots"),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: requiredScreenShotsCtl,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]')
                          ),
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true
                        )
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: showRequiredHeading("Category")
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
                    onChanged: project == null ? (ProjectCategory pc) {
                      clearCalculation();
                      if (pc.categoryId != 0) {
                        fetchSubCategoriesById(context, pc);
                      } else {
                        setState(() {defaultProjectCategory = new ProjectCategory(
                          id: 0,
                          categoryId: 0,
                          categoryName: "Select",
                          subCategoryName: "Select",
                          chargeByCategory: 0.0);
                        });
                        clearSubCategoryDropdown();
                      }
                    } : null,
                    items: projectCategoriesDropDownList
                  )
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: showRequiredHeading("Sub Category")
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
                    onChanged: project == null ? (ProjectCategory pc) {
                      setState(() {
                        clearCalculation();
                        defaultProjectSubCategory = pc;
                      });
                    } : null,
                    items: projectSubCategoriesDropDownList
                  )
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: showRequiredHeading("Region")
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 50,
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
                    onChanged: project == null ? (String rn) {
                      clearMultiselectDropdown();
                      if (rn == "Select") {
                        setState(() {
                          regionName = "Select";
                        });
                      } else {
                        fetchCountriesByRegion(context, rn);
                      }
                    } : null,
                    items: regionDropDownList
                  )
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: showRequiredHeading("Country")
                ),
                SizedBox(
                  height: 10,
                ),
                AbsorbPointer(
                  child: ms.MultiSelectDialogField(
                      items: multiSelectItems,
                      title: Text("Select"),
                      searchable: true,
                      initialValue: multiSelectInitialItems,
                      selectedColor: Colors.green,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      buttonIcon: Icon(
                          Icons.arrow_drop_down_sharp,
                          color: Colors.grey
                      ),
                      onConfirm: (items) {
                        selectedItems = items;
                      }
                  ),
                  absorbing: project != null
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      showRequiredHeading("Worker Needed"),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        readOnly: project == null ? false : true,
                        controller: workerNeededCtl,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]')
                          ),
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true
                        )
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      showRequiredHeading("Each Worker Earn"),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        readOnly: project == null ? false : true,
                        controller: eachWorkerEarnCtl,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.]')
                          )
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true
                        )
                      )
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
                          fontWeight: FontWeight.bold,
                            fontSize: 15
                        ),
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
                          filled: true
                        )
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      showRequiredHeading("Estimated Approval Day"),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: estimatedDayCtl,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]')
                          ),
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true
                        )
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Visibility(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                            onPressed: () {
                              onFileSelect(context, "img");
                            },
                            icon: Icon(Icons.image)
                        ),
                        Expanded(
                            child:Text(fileInfo["imageName"],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                clearImage();
                              });
                            },
                            icon: Icon(Icons.close)
                        )
                      ]
                  ),
                  visible: project == null,
                ),
                SizedBox(
                  height: 10,
                ),
                Visibility(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                            onPressed: () {
                              onFileSelect(context, "file");
                            },
                            icon: Icon(Icons.file_copy)
                        ),
                        Expanded(
                            child:Text(fileInfo["fileName"],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                clearFile();
                              });
                            },
                            icon: Icon(Icons.close)
                        )
                      ]
                  ),
                  visible: project == null,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlineButton(
                      onPressed: () {
                        if (userInfo['profileCompleted'] == 100) {
                          bool isInputVerified = verifyInput(context);
                          if(isInputVerified){
                            if(project == null){
                              onSave(context);
                            }else {
                              onUpdate(context);
                            }
                          }
                        } else {
                          Alert.show(alertDialog, context, Alert.ERROR, "To post a new job, you need to complete your profile 100%.");
                        }
                      },
                      child: Text(project == null ? "Save" : "Update")
                    ),
                    Visibility(
                      child: OutlineButton(
                          onPressed: () {
                            onReset();
                          },
                          child: Text("Reset")
                      ),
                      visible: project == null
                    )
                  ]
                )
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

  Widget entryField(String title, TextEditingController controller,int maxLength) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          showRequiredHeading(title),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: controller,
            maxLength: maxLength,
            readOnly: project == null ? false : true,
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

  Future<void> fetchSubCategoriesById(
      BuildContext context, ProjectCategory pc) async {
    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    clearSubCategoryDropdown();

    var response = await get("$baseUrl/categories/sub/${pc.categoryId}");
    if (response.statusCode == 200) {
      setState(() {
        needToFreezeUi = false;
      });
      var res = jsonDecode(response.body);
      if (res['code'] == 200) {
        List<dynamic> projectSubCategories = res['projectCategories'];
        projectSubCategories.asMap().forEach((key, projectCategory) {
          print("sc = ${projectCategory['chargeByCategory']}");
          ProjectCategory pc = new ProjectCategory(
            id: projectCategory['id'],
            subCategoryName: projectCategory['subCategoryName'],
            categoryId: 0,
            categoryName: null,
            chargeByCategory: projectCategory['chargeByCategory']
          );
          projectSubCategoriesDropDownList.add(
            DropdownMenuItem<ProjectCategory>(
              value: pc,
              child: Text(pc.subCategoryName)
            )
          );
        });
      }
    } else {
      setState(() {
        needToFreezeUi = false;
      });
      if(context != null){
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
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
        subCategoryName: "Select",
        chargeByCategory: 0.0
      );
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

    var response = await get("https://restcountries.eu/rest/v2/region/$region");

    if (response.statusCode == 200) {

      setState(() {
        needToFreezeUi = false;
      });

      var jsonResponse = jsonDecode(response.body);
      List<dynamic> countryNames = jsonResponse;
      countryNames.asMap().forEach((key, country) {
        multiSelectItems.add(ms.MultiSelectItem(
          MyLocation(
            countryName: country['name'],
            regionName: region
          ),country['name']
        ));
      });

    } else {
      setState(() {
        needToFreezeUi = false;
      });
      if(context != null){
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }

    setState(() {
      regionName = region;
    });
  }

  void clearMultiselectDropdown() {
    multiSelectInitialItems.clear();
    multiSelectItems.clear();
    selectedItems.clear();
  }

  void onSave(BuildContext context) {
    List<String> todoSteps = [];
    List<String> requiredProofs = [];
    List<String> countryNames = [];

    todoStepsControllers.forEach((todoStep) {
      todoSteps.add(todoStep.text);
    });

    requiredProofsControllers.forEach((requiredProof) {
      requiredProofs.add(requiredProof.text);
    });

    selectedItems.forEach((element) {
      countryNames.add(element.countryName);
    });

    var request = {
      "project": {
        "title": titleCtl.text,
        "todoSteps": todoSteps,
        "requiredProofs": requiredProofs,
        "categoryId": defaultProjectCategory.categoryId,
        "subCategoryId": defaultProjectSubCategory.id,
        "regionName": regionName,
        "countryNames": countryNames,
        "workerNeeded": int.parse(workerNeededCtl.text),
        "estimatedDay": int.parse(estimatedDayCtl.text),
        "estimatedCost": double.parse(estimatedCostCtl.text),
        "eachWorkerEarn": double.parse(eachWorkerEarnCtl.text),
        "requiredScreenShots": int.parse(requiredScreenShotsCtl.text),
        "fileString": fileInfo["fileString"],
        "fileExt": fileInfo["fileExt"],
        "imageString": fileInfo["imageString"],
        "imageExt": fileInfo["imageExt"]
      },
      "userInfo": {
        "id": userInfo['id'],
        "firstName": userInfo['firstName']
      }
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
          onReset();
          eventHub.fire("redirectToPostedJob");
          eventHub.fire("reloadBalance");
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

  Future<void> onFileSelect(BuildContext context, String fileType) async {
    String base64String;
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: fileType == "img" ? allowedImageType : allowedFileType,
    );

    if (result != null) {
      PlatformFile objFile = result.files.single;

      if (uio.Platform.isAndroid || uio.Platform.isIOS) {
        base64String = base64.encode(uio.File(objFile.path).readAsBytesSync());
      } else {
        base64String = base64.encode(objFile.bytes);
      }

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
            fileInfo["imageString"] = base64String;
            fileInfo["imageExt"] = objFile.extension;
          } else {
            fileInfo["fileName"] = objFile.name;
            fileInfo["fileString"] = base64String;
            fileInfo["fileExt"] = objFile.extension;
          }
        });
      }
    } else {
      Alert.show(alertDialog, context, Alert.ERROR, "No file selected!");
    }
  }

  bool verifyInput(BuildContext context) {

    bool isInputVerified = true;
    String errMsg;
    bool isTodoStepsVerified = true;
    bool isRequiredProofsVerified = true;

    todoStepsControllers.forEach((element) {
      if(element.text.isEmpty){
        isTodoStepsVerified = false;
      }
    });

    requiredProofsControllers.forEach((element) {
      if(element.text.isEmpty){
        isRequiredProofsVerified = false;
      }
    });

    if (titleCtl.text.isEmpty) {
      errMsg = "Please give a title!";
      isInputVerified = false;
    } else if(!isTodoStepsVerified){
      errMsg = "Please fill up the todo steps!";
      isInputVerified = false;
    } else if(!isRequiredProofsVerified){
      errMsg = "Please fill up the required proofs!";
      isInputVerified = false;
    } else if(requiredScreenShotsCtl.text.isEmpty){
      errMsg = "Please give how many screen shot you need!";
      isInputVerified = false;
    } else if(defaultProjectCategory.categoryName == "Select"){
      errMsg = "Please select an category!";
      isInputVerified = false;
    } else if(defaultProjectSubCategory.categoryName == "Select"){
      errMsg = "Please select an sub category!";
      isInputVerified = false;
    } else if(selectedItems.length == 0){
      errMsg = "Please select at least one country!";
      isInputVerified = false;
    } else if(regionName == "Select"){
      errMsg = "Please select an region!";
      isInputVerified = false;
    } else if(workerNeededCtl.text.isEmpty){
      errMsg = "Please give how many worker you needed!";
      isInputVerified = false;
    }else if(eachWorkerEarnCtl.text.isEmpty){
      errMsg = "Please give how much each worker will earn!";
      isInputVerified = false;
    }else if(estimatedDayCtl.text.isEmpty){
      errMsg = "Please give an estimated day!";
      isInputVerified = false;
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, context, Alert.ERROR, errMsg);
    }
    return isInputVerified;
  }

  void calculateEstimatedCost() {
    if (workerNeededCtl.text.isNotEmpty
        && eachWorkerEarnCtl.text.isNotEmpty
        && defaultProjectSubCategory.chargeByCategory != 0.0) {
      double ewe = double.tryParse(eachWorkerEarnCtl.text);
      int wn = int.tryParse(workerNeededCtl.text);
      double withoutCharge = ewe * wn;
      double totalCharge = defaultProjectSubCategory.chargeByCategory * ewe * wn;
      double res = totalCharge + withoutCharge;
      estimatedCostCtl.text = res.toString();
    }
  }

  void clearCalculation(){
    estimatedCostCtl.clear();
    eachWorkerEarnCtl.clear();
    workerNeededCtl.clear();
  }

  void clearListControllers() {

    todoStepsControllers.clear();
    requiredProofsControllers.clear();
    todoStepsControllers.add(TextEditingController());
    requiredProofsControllers.add(TextEditingController());

  }

  void onReset() {
    setState(() {
      clearMultiselectDropdown();
      titleCtl.clear();
      clearListControllers();
      requiredScreenShotsCtl.clear();
      resetCategories();
      regionName = "Select";
      workerNeededCtl.clear();
      eachWorkerEarnCtl.clear();
      estimatedCostCtl.clear();
      estimatedDayCtl.clear();
      clearFile();
      clearImage();
    });
  }

  void resetCategories() {
    defaultProjectCategory = ProjectCategory(
      id: 0,
      categoryId: 0,
      categoryName: "Select",
      subCategoryName: "Select",
      chargeByCategory: 0.0
    );
    defaultProjectSubCategory = ProjectCategory(
      id: 0,
      categoryId: 0,
      categoryName: "Select",
      subCategoryName: "Select",
      chargeByCategory: 0.0
    );
  }

  void clearImage() {
    fileInfo["imageExt"] = null;
    fileInfo["imageName"] = "No image selected yet!";
    fileInfo["imageString"] = null;
  }

  void clearFile() {
    fileInfo["fileExt"] = null;
    fileInfo["fileName"] = "No file selected yet!";
    fileInfo["fileString"] = null;
  }

  void onUpdate(BuildContext context) {

    var request = {
      "project": {
        "id": project.id,
        "estimatedDay": int.parse(estimatedDayCtl.text),
      }
    };

    String url = baseUrl + '/projects';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    put(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          setState(() {
            estimatedDayCtl.clear();
          });
          eventHub.fire("redirectToPostedJob");
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

  @override
  void dispose() {
    super.dispose();
  }

}
