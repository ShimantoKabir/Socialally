import 'package:client/models/Project.dart';
import 'package:client/models/ProofSubmission.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:client/constants.dart';
import 'package:client/utilities/Alert.dart';

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

  TextEditingController requiredWorkProofCtl = new TextEditingController();
  List<ProofSubmission> requiredScreenShots = [];
  AlertDialog alertDialog;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle", "Proof Submission");
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    return SingleChildScrollView(
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
                    Text("32/20 Submitted"),
                    SizedBox(height: 5),
                    LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.amber),
                      value: 50 / 100,
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey)
                ),
              ),
              Container(
                width: 200,
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("0.05"),
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
                "${project.categoryName}/${project.subCategoryName}",
              ),
              Text(
                "${project.estimatedDay} days left",
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
                  return Text("No required proof found!");
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
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Required Work Proof",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                    maxLines: 5,
                    controller: requiredWorkProofCtl,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: Color(0xfff3f3f4),
                        filled: true))
              ],
            ),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text("Required ScreenShots",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          Visibility(
            visible: requiredScreenShots.length == 0,
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
              itemCount: requiredScreenShots.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    padding: EdgeInsets.all(5),
                    child: Image.memory(
                      base64.decode(requiredScreenShots[index].imageString),
                      width: 200,
                      height: 200,
                    )
                );
              }),
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    onFileSelect(context);
                  }),
              IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (requiredScreenShots.length > 0) {
                        requiredScreenShots.removeLast();
                      }
                    });
                  })
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlineButton(
                  onPressed: () {

                  },
                  child: Text("Save")),
              OutlineButton(
                  onPressed: () {

                  },
                  child: Text("Reset")
              )
            ],
          )
        ],
      ),
    );
  }

  ImageProvider<Object> showProjectPic(String imageUrl) {
    if (imageUrl == null) {
      return AssetImage("assets/images/bg_img_2.png");
    } else {
      return NetworkImage(imageUrl);
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

    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedImageType,
    );

    if (result != null) {
      PlatformFile objFile = result.files.single;
      if(objFile.size > maxImageSize){
        Alert.show(alertDialog, context, Alert.ERROR, "Image size cross the max limit, "
            "You can only upload ${maxImageSize/oneMegaByte} or less then ${maxImageSize/oneMegaByte} mb image/file.");
      }else {
        setState(() {
          requiredScreenShots.add(new ProofSubmission(
            id: null,
            imageUrl: null,
            imageName: objFile.name,
            imageExt: objFile.extension,
            imageString: base64.encode(objFile.bytes)
          ));
        });
      }
    }else {
      Alert.show(alertDialog, context, Alert.ERROR, "No image selected!");
    }
  }

}
