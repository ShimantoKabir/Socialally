import 'dart:convert';

import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/constants.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class General extends StatefulWidget {
  General({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  GeneralState createState() => GeneralState(
      userInfo: userInfo,
      eventHub: eventHub
  );
}

class GeneralState extends State<General> {
  var userInfo;
  EventHub eventHub;

  GeneralState({Key key, this.userInfo, this.eventHub});

  AlertDialog alertDialog;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  String jobApprovalType;
  String referCommissionType;

  TextEditingController minimumDepositCtl = new TextEditingController();
  TextEditingController minimumWithdrawCtl = new TextEditingController();
  TextEditingController takePerPoundCtl = new TextEditingController();
  TextEditingController jobPostingChargeCtl = new TextEditingController();
  TextEditingController referCommissionCtl = new TextEditingController();
  TextEditingController clientDashboardHeadlineCtl = new TextEditingController();
  TextEditingController quantityOfReferCommissionCtl = new TextEditingController();
  Future futureGeneralSettingData;

  @override
  void initState() {
    super.initState();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    jobApprovalType = "Manual";
    referCommissionType = "Lifetime";
    futureGeneralSettingData = fetchGeneralSettingData();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: needToFreezeUi,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Job Approve Type",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
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
                  value: jobApprovalType,
                  isExpanded: true,
                  underline: SizedBox(),
                  onChanged: (String newValue) {
                    setState(() {
                      jobApprovalType = newValue;
                    });
                  },
                  items: jobApproveTypeDropDownList
                )
              ),
              SizedBox(
                height: 10,
              ),
              entryField(
                title: "Minimum Deposit",
                controller: minimumDepositCtl,
                textInputType: TextInputType.numberWithOptions(
                    decimal: true
                ),
                textInputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.]')
                  )
                ]
              ),
              entryField(
                title: "Minimum Withdraw",
                controller: minimumWithdrawCtl,
                textInputType: TextInputType.numberWithOptions(
                    decimal: true
                ),
                textInputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.]')
                  )
                ]
              ),
              entryField(
                title: "Take Per Pound",
                controller: takePerPoundCtl,
                textInputType: TextInputType.numberWithOptions(
                    decimal: true
                ),
                textInputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.]')
                  )
                ]
              ),
              entryField(
                title: "Job Posting Charge",
                controller: jobPostingChargeCtl,
                textInputType: TextInputType.numberWithOptions(
                    decimal: true
                ),
                textInputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.]')
                  )
                ]
              ),
              entryField(
                title: "Refer Commission",
                controller: referCommissionCtl,
                textInputType: TextInputType.numberWithOptions(
                    decimal: true
                ),
                textInputFormatter: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.]')
                  )
                ]
              ),
              entryField(
                title: "User Dashboard headline",
                controller: clientDashboardHeadlineCtl,
                textInputType: null,
                textInputFormatter: null,
                maxLines: 3
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                  "Refer Commission Type",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                  )
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
                      value: referCommissionType,
                      isExpanded: true,
                      underline: SizedBox(),
                      onChanged: (String newValue) {
                        setState(() {
                          quantityOfReferCommissionCtl.clear();
                          referCommissionType = newValue;
                        });
                      },
                      items: referCommissionTypeDropDownList
                  )
              ),
              Visibility(
                child: entryField(
                  title: "Refer Commission Will Get",
                  controller: quantityOfReferCommissionCtl,
                  textInputType: TextInputType.numberWithOptions(
                      decimal: true
                  ),
                  textInputFormatter: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.]')
                    )
                  ]
                ),
                visible: referCommissionType == "Limited",
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlineButton(
                      onPressed: () {
                        bool isInputVerified = verifyInput(context);
                        if(isInputVerified){
                          onUpdate(context);
                        }
                      },
                      child: Text("Update")
                  )
                ]
              )
            ],
          ),
        ),
        bottomNavigationBar: Alert.addBottomLoader(
          needToFreezeUi,
          alertIcon,
          alertText
        )
      ),
    );
  }

  Widget entryField({String title,
    TextEditingController controller,
    TextInputType textInputType,
    List<TextInputFormatter> textInputFormatter,int maxLines}) {
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

  Future<dynamic> fetchGeneralSettingData() async {

    String url = baseUrl + "/app-constants/settings/general";

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
        setState(() {
          clientDashboardHeadlineCtl.text = res['clientDashboardHeadline'];
          referCommissionCtl.text = res['referCommission'].toString();
          jobPostingChargeCtl.text = res['jobPostingCharge'].toString();
          takePerPoundCtl.text = res['takePerPound'].toString();
          referCommissionCtl.text = res['referCommission'].toString();
          referCommissionCtl.text = res['referCommission'].toString();
          minimumWithdrawCtl.text = res['minimumWithdraw'].toString();
          minimumDepositCtl.text = res['minimumDeposit'].toString();
          jobApprovalType = res['jobApprovalType'] == 1 ? "Automatic" : "Manual";
          referCommissionType = res['quantityOfEarnByRefer'] == -1 ? "Lifetime" : "Limited";
          if(res['quantityOfEarnByRefer'] != -1){
            quantityOfReferCommissionCtl.text = res['quantityOfEarnByRefer'].toString();
          }
        });
      }else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }else {
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    }
  }

  bool verifyInput(BuildContext context) {

    bool isInputVerified = true;
    String errMsg;

    if (minimumDepositCtl.text.isEmpty) {
      errMsg = "Please give a minimum deposit!";
      isInputVerified = false;
    } else if(minimumWithdrawCtl.text.isEmpty){
      errMsg = "Please give a minimum withdraw!";
      isInputVerified = false;
    }else if(takePerPoundCtl.text.isEmpty){
      errMsg = "Please give take per pound!";
      isInputVerified = false;
    }else if(jobPostingChargeCtl.text.isEmpty){
      errMsg = "Please give a job posting charge!";
      isInputVerified = false;
    }else if(referCommissionCtl.text.isEmpty){
      errMsg = "Please give refer commission!";
      isInputVerified = false;
    }else if(clientDashboardHeadlineCtl.text.isEmpty){
      errMsg = "Please give user dashboard headline!";
      isInputVerified = false;
    }else if(referCommissionType == "Limited" && quantityOfReferCommissionCtl.text.isEmpty){
      errMsg = "Please give how many time refer commission will get!";
      isInputVerified = false;
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, context, Alert.ERROR, errMsg);
    }
    return isInputVerified;

  }

  void onUpdate(BuildContext context) {

    var request = {
      "generalSetting": {
        "minimumDeposit": double.tryParse(minimumDepositCtl.text),
        "minimumWithdraw": double.tryParse(minimumWithdrawCtl.text),
        "takePerPound": double.tryParse(takePerPoundCtl.text),
        "jobPostingCharge": double.tryParse(jobPostingChargeCtl.text),
        "referCommission": double.tryParse(referCommissionCtl.text),
        "clientDashboardHeadline": clientDashboardHeadlineCtl.text,
        "jobApprovalType": jobApprovalType == "Manual" ? 0 : 1,
        "quantityOfEarnByRefer": referCommissionType == "Lifetime" ? -1 :
            int.tryParse(quantityOfReferCommissionCtl.text)
      }
    };

    String url = baseUrl + '/app-constants/settings/general';
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
