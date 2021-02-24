import 'package:client/models/Project.dart';
import 'package:client/models/ProofSubmission.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:client/constants.dart';
import 'package:client/utilities/Alert.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_io/io.dart';

class ProofSubmissionComponent extends StatefulWidget {
  ProofSubmissionComponent(
      {Key key, this.eventHub, this.userInfo, this.project}) : super(key: key);
  final EventHub eventHub;
  final Project project;
  final userInfo;

  @override
  ProofSubmissionComponentState createState() =>
      ProofSubmissionComponentState(
          key: key, eventHub: eventHub, userInfo: userInfo, project: project);
}

class ProofSubmissionComponentState extends State<ProofSubmissionComponent> {

  EventHub eventHub;
  Project project;
  var userInfo;

  ProofSubmissionComponentState(
      {Key key, this.eventHub, this.userInfo, this.project});

  TextEditingController givenWorkProofCtl = new TextEditingController();
  List<ProofSubmission> givenScreenShots = [];
  List<TextEditingController> givenProofsControllers = [];
  AlertDialog alertDialog;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  double companyCharge = 0.1;

  @override
  void initState() {
    super.initState();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    eventHub.fire("viewTitle", project.type == 1 ? "Proof Submission" : "Proof Investigation");
    clearGivenProofs();

    if(project.type == 2){

      givenProofsControllers.clear();
      project.givenProofs.forEach((element) {
        TextEditingController t = TextEditingController();
        t.text = element;
        givenProofsControllers.add(t);
      });

      print("project ${project.id}");

      project.givenScreenshotUrls.forEach((element) {
        print("el = $element");
        givenScreenShots.add(ProofSubmission(imageUrl: element));
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return AbsorbPointer(
      absorbing: needToFreezeUi,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                width: screenSize.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      project.title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                      ),
                    ),
                    Text(
                      "${project.regionName}/${project.countryName}",
                    )
                  ],
                ),
                decoration: headingDecoration(),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 200,
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Text("${project.totalApplied}/${project.workerNeeded} Applied"),
                        SizedBox(height: 5),
                        LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.amber),
                          value: project.totalApplied / project.workerNeeded,
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
                        Text("${project.eachWorkerEarn}£"),
                        SizedBox(width: 5),
                        Icon(Icons.monetization_on, color: Colors.green, size: 25)
                      ],
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey)
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 300,
                width: screenSize.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: showProjectPic(project.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${project.categoryName}/${project.subCategoryName}"
                  ),
                  Text(
                    "${project.estimatedDay} Estimated Day"
                  ),
                  Text(
                    "Published By: ${project.publisherName}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Todo Steps",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  )
              ),
              SizedBox(height: 10),
              ListView.builder(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: project.todoSteps.length,
                  itemBuilder: (context, j) {
                    if (project.todoSteps.length == 0) {
                      return Text("No todo step found!");
                    } else {
                      return Text("${j + 1}. ${project.todoSteps[j]}");
                    }
                  }
              ),
              SizedBox(height: 20),
              Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Required Proofs",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  )
              ),
              SizedBox(height: 10),
              ListView.builder(
                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: project.requiredProofs.length,
                  itemBuilder: (context, j) {
                    if (project.requiredProofs.length == 0) {
                      return Text("No required proof found!");
                    } else {
                      return Text("${j + 1}. ${project.requiredProofs[j]}");
                    }
                  }
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomLeft,
                child: project.type == 1 ? showRequiredHeading("Given Proofs") :
                Text(
                  "Given Proofs",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                  )
                ),
              ),
              Divider(thickness: 1, color: Colors.green),
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(8),
                  itemCount: givenProofsControllers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: TextField(
                          readOnly: project.type == 1 ? false : true,
                          controller: givenProofsControllers[index],
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              fillColor: Color(0xfff3f3f4),
                              filled: true)),
                    );
                  }),
              Visibility(
                visible: project.type == 1 ? true : false,
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            givenProofsControllers
                                .add(new TextEditingController());
                          });
                        }),
                    IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (givenProofsControllers.length > 1) {
                              givenProofsControllers.removeLast();
                            }
                          });
                        })
                  ]
                )
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [
                    Text("Given Screenshots (${project.requiredScreenShots}/${givenScreenShots.length})",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Visibility(
                      visible: project.type == 1,
                      child: Text(
                        " * ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                            color: Colors.red
                        )
                      )
                    )
                  ],
                ),
              ),
              Visibility(
                visible: givenScreenShots.length == 0,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    child: Text("No screenshot selected yet!",style: TextStyle(color: Colors.red)),
                    padding: EdgeInsets.fromLTRB(20,10,0,0),
                  ),
                ),
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: EdgeInsets.all(10),
                itemCount: givenScreenShots.length,
                itemBuilder: (BuildContext context, int index) {
                  if(project.type == 1){
                    return Container(
                      padding: EdgeInsets.all(5),
                      child: Image.memory(
                        base64.decode(givenScreenShots[index].imageString),
                        width: 200,
                        height: 200,
                      )
                    );
                  }else {
                    return InkWell(
                      child: Container(
                        margin: EdgeInsets.all(20),
                        height: 300,
                        width: screenSize.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: showProjectPic(givenScreenShots[index].imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      onTap: (){
                        if(project.type == 2){
                          openFile(givenScreenShots[index].imageUrl,context);
                        }
                      },
                    );
                  }
                }
              ),
              Visibility(
                visible: project.type == 1 ? true : false,
                child: Row(
                  children: [
                    IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      if (project.requiredScreenShots <= givenScreenShots.length) {
                        Alert.show(alertDialog, context, Alert.ERROR,
                            "You can't add more then "
                                "${project.requiredScreenShots} screenshots.");
                      }else {
                        onFileSelect(context);
                      }
                    }),
                    IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (givenScreenShots.length > 0) {
                          givenScreenShots.removeLast();
                        }
                      });
                    })
                  ],
                )
              ),
              SizedBox(
                height: 20,
              ),
              Visibility(
                  visible: project.type == 1 ? true : false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlineButton(
                          onPressed: () {
                            if (userInfo['profileCompleted'] == 100) {
                              bool isInputVerified = verifyInput(context);
                              if(isInputVerified){
                                onSave(context);
                              }
                            } else {
                              Alert.show(alertDialog, context, Alert.ERROR,
                                  "To post a new job, you need to complete your profile 100%.");
                            }
                          },
                          child: Text("Save")),
                      OutlineButton(
                          onPressed: () {
                            onReset();
                          },
                          child: Text("Reset")
                      )
                    ],
                  )
              ),
              Visibility(
                visible: project.type == 2 ? project.status != null && project.status == "Pending" ? true : false : false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlineButton(
                        onPressed: () {
                          onProofSubmissionStatusChange(context,"Approved");
                        },
                        child: Text("Accept")),
                    OutlineButton(
                        onPressed: () {
                          onProofSubmissionStatusChange(context,"Declined");
                        },
                        child: Text("Declined")
                    )
                  ],
                )
              )
            ],
          ),
        ),
        bottomNavigationBar: Alert.addBottomLoader(needToFreezeUi, alertIcon, alertText)
      )
    );
  }

  ImageProvider<Object> showProjectPic(String imageUrl) {
    if (imageUrl == null) {
      return AssetImage("assets/images/bg_img_2.png");
    } else {
      return NetworkImage(imageUrl);
    }
  }

  openFile(String url,BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Alert.show(alertDialog, context, Alert.ERROR, "Can't open any file!");
    }
  }

  BoxDecoration headingDecoration() {
    return BoxDecoration(
      border: Border(
          bottom: BorderSide(
            color: Colors.green,
            width: 3.0,
          )
      ),
    );
  }

  Future<void> onFileSelect(BuildContext context) async {
    String base64String;
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedImageType,
    );

    if (result != null) {

      PlatformFile objFile = result.files.single;

      if (Platform.isAndroid || Platform.isIOS) {
        base64String = base64.encode(File(objFile.path).readAsBytesSync());
      } else {
        base64String = base64.encode(objFile.bytes);
      }


      if(objFile.size > maxImageSize){
        Alert.show(alertDialog, context, Alert.ERROR, "Image size cross the max limit, "
            "You can only upload ${maxImageSize/oneMegaByte} or less then ${maxImageSize/oneMegaByte} mb image/file.");
      } else {
        setState(() {
          givenScreenShots.add(new ProofSubmission(
            id: null,
            imageUrl: null,
            imageName: objFile.name,
            imageExt: objFile.extension,
            imageString: base64String
          ));
        });
      }
    }else {
      Alert.show(alertDialog, context, Alert.ERROR, "No image selected!");
    }
  }

  void onSave(BuildContext context) {
    List<String> givenProofs = [];

    givenProofsControllers.forEach((givenProof) {
      givenProofs.add(givenProof.text);
    });

    List<Object> gs = [];

    givenScreenShots.forEach((element) {
      gs.add({
        "imageExt" : element.imageExt,
        "imageString" : element.imageString
      });
    });

    var request = {
      "proofSubmission": {
        "projectId": project.id,
        "submittedBy": userInfo['id'],
        "publishedBy": project.publishedBy,
        "givenProofs": givenProofs,
        "applicantName": userInfo['firstName'],
        "givenScreenshots": json.encode(gs)
      }
    };

    String url = baseUrl + '/proof-submissions';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    post(url, headers: headers, body: json.encode(request)).then((response){
      setState(() {
        needToFreezeUi = false;
      });

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          onReset();
          eventHub.fire("redirectToAppliedJob");
          Alert.show(alertDialog, context, Alert.SUCCESS, body['msg']);
        }else {
          Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
        }
      } else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }).catchError((err){
      setState(() {
        needToFreezeUi = false;
      });
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    });
  }

  void onProofSubmissionStatusChange(BuildContext context, String status) {

    var request = {
      "proofSubmission": {
        "id": project.proofSubmissionId,
        "status": status,
        "projectId" : project.id,
        "submittedBy": project.submittedBy,
        "publisherName": project.publisherName,
        "publishedBy": project.publishedBy,
      }
    };

    String url = baseUrl + '/proof-submissions';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    put(url, headers: headers, body: json.encode(request)).then((response){
      setState(() {
        needToFreezeUi = false;
      });

      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          eventHub.fire("redirectToAcceptJob");
        }else {
          Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
        }
      } else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }).catchError((err){
      setState(() {
        needToFreezeUi = false;
      });
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    });

  }

  bool verifyInput(BuildContext context) {

    bool isInputVerified = true;
    String errMsg;
    bool isGivenProofsVerified = true;

    givenProofsControllers.forEach((element) {
      if(element.text.isEmpty){
        isGivenProofsVerified = false;
      }
    });

    if(!isGivenProofsVerified){
      isInputVerified = false;
      errMsg = "Given proof required!";
    }else if(project.requiredScreenShots != givenScreenShots.length){
      isInputVerified = false;
      errMsg = "Your must provide ${project.requiredScreenShots} screen shots!";
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, context, Alert.ERROR, errMsg);
    }

    return isInputVerified;

  }

  void onReset() {

    setState(() {
      clearGivenProofs();
      givenScreenShots.clear();
    });

  }

  void clearGivenProofs() {

    givenProofsControllers.clear();
    givenProofsControllers.add(TextEditingController());

  }

}
