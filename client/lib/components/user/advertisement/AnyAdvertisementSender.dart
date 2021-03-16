import 'dart:convert';
import 'package:universal_io/io.dart';
import 'package:wengine/models/AdCostPlan.dart';
import 'package:wengine/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wengine/constants.dart';
import 'package:http/http.dart';

class AnyAdvertisementSender extends StatefulWidget {
  AnyAdvertisementSender({Key key, this.eventHub, this.userInfo}) : super(key: key);
  final userInfo;
  final EventHub eventHub;

  @override
  AnyAdvertisementSenderState createState() =>
      AnyAdvertisementSenderState(key: key, eventHub: eventHub, userInfo: userInfo);
}

class AnyAdvertisementSenderState extends State<AnyAdvertisementSender> {
  var userInfo;
  EventHub eventHub;

  AnyAdvertisementSenderState({Key key, this.eventHub, this.userInfo});

  TextEditingController titleCtl = TextEditingController();
  TextEditingController targetedDestinationUrlCtl = TextEditingController();
  bool needToFreezeUi = false;
  Widget alertIcon;
  String alertText;
  AlertDialog alertDialog;
  var bannerImageInfo;
  AdCostPlan adCostPlan;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle","Any Advertisement");
    alertText = "No operation running.";
    alertIcon = Container();

    adCostPlan = AdCostPlan(
        cost: 0,
        day: 0,
        txt: "Select"
    );

    List<dynamic> adCostPlanList = userInfo['adCostPlanList'];
    adCostPlanList.asMap().forEach((key, plan) {
      bool isValueExist = false;
      adCostPlanDropDownList.forEach((element) {
        if (element.value.day == plan['day']) {
          isValueExist = true;
        }
      });
      if (!isValueExist) {
        AdCostPlan acp = new AdCostPlan(
            day: plan["day"],
            cost: plan["cost"],
            txt: "Day = ${plan['day']}, Cost = £${plan['cost']}"
        );
        adCostPlanDropDownList.add(DropdownMenuItem(
            value: acp,
            child: Text(acp.txt)
        ));
      }
    });

    bannerImageInfo = {
      "imageName": "e",
      "imageExt": "e",
      "imageString": "e"
    };

  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: needToFreezeUi,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              entryField("Ads Title", titleCtl),
              SizedBox(
                height: 10,
              ),
              entryField("Target Destination(URL)", targetedDestinationUrlCtl),
              SizedBox(
                height: 10,
              ),
              showRequiredHeading("Plan"),
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
                child: DropdownButton<AdCostPlan>(
                  value: adCostPlan,
                  isExpanded: true,
                  underline: SizedBox(),
                  onChanged: (AdCostPlan acp) {
                    setState(() {
                      adCostPlan = new AdCostPlan(
                          day: acp.day,
                          cost: acp.cost,
                          txt: acp.txt
                      );
                    });
                  },
                  items: adCostPlanDropDownList,

                )
              ),
              SizedBox(
                height: 10,
              ),
              OutlineButton(
                padding: EdgeInsets.all(15),
                onPressed: (){
                  onFileSelect(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 10),
                    Text("Select Banner Image")
                  ],
                ),
              ),
              Visibility(
                  visible: bannerImageInfo['imageString'] != 'e',
                  child: Container(
                      margin: EdgeInsets.fromLTRB(0,10,0,10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                      padding: EdgeInsets.all(5),
                      child: bannerImageInfo['imageString'] != "e" ? Image.memory(
                        base64.decode(bannerImageInfo['imageString']),
                        width: 200,
                        height: 200,
                      ) : Container()
                  )
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlineButton(
                    onPressed: (){
                      bool isInputVerified = verifyInput(context);
                      if(isInputVerified){
                        onSave(context);
                      }
                    },
                    child: Text("Save"),
                  ),
                  OutlineButton(
                    onPressed: (){
                      onReset(context);
                    },
                    child: Text("Reset"),
                  )
                ],
              )
            ],
          ),
        ),
        bottomNavigationBar: Alert.addBottomLoader(
          needToFreezeUi,
          alertIcon,
          alertText
        ),
      )
    );
  }

  Widget entryField(String title, TextEditingController controller) {
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
          bannerImageInfo['imageName'] = objFile.name;
          bannerImageInfo['imageExt'] = objFile.extension;
          bannerImageInfo['imageString'] = base64String;
        });
      }
    }else {
      Alert.show(alertDialog, context, Alert.ERROR, "No image selected!");
    }
  }

  void onSave(BuildContext context) {

    setState(() {
      needToFreezeUi = true;
      alertIcon = Alert.showIcon(Alert.LOADING);
      alertText = Alert.LOADING_MSG;
    });

    var request = {
      "advertisement": {
          "givenBy" : userInfo["id"],
        "adCost": adCostPlan.cost,
        "adDuration": adCostPlan.day,
        "title" : titleCtl.text,
        "targetedDestinationUrl" : targetedDestinationUrlCtl.text,
        "bannerImageString" : bannerImageInfo["imageString"],
        "bannerImageExt" : bannerImageInfo["imageExt"],
        "bannerImageName" : bannerImageInfo["imageName"]
      }
    };

    String url = baseUrl + '/advertisements';
    Map<String, String> headers = {"Content-type": "application/json"};

    post(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          onReset(context);
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

  void onReset(BuildContext context) {
    setState(() {
      titleCtl.clear();
      targetedDestinationUrlCtl.clear();
      bannerImageInfo['imageName'] = "e";
      bannerImageInfo['imageExt'] = "e";
      bannerImageInfo['imageString'] = "e";
      adCostPlan = AdCostPlan(day: 0,cost: 0,txt: "Select");
    });
  }

  bool verifyInput(BuildContext context) {

    bool isInputVerified = true;
    String msg;

    if(titleCtl.text.isEmpty){
      isInputVerified = false;
      msg = "Advertisement title required!";
    }else if(targetedDestinationUrlCtl.text.isEmpty){
      isInputVerified = false;
      msg = "Targeted destination url required!";
    }else if(adCostPlan.txt == "Select"){
      isInputVerified = false;
      msg = "Please select an plan!";
    }else if(bannerImageInfo["imageName"] == "e") {
      isInputVerified = false;
      msg = "Please select an banner image!";
    }

    if(!isInputVerified){
      Alert.show(alertDialog, context, Alert.ERROR, msg);
    }
    return isInputVerified;

  }

}