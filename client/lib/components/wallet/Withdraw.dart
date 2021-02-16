import 'dart:convert';
import 'package:client/constants.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class Withdraw extends StatefulWidget {
  Withdraw({Key key, this.eventHub, this.userInfo}) : super(key: key);
  final userInfo;
  final EventHub eventHub;

  @override
  WithdrawState createState() =>
      WithdrawState(key: key, eventHub: eventHub, userInfo: userInfo);
}

class WithdrawState extends State<Withdraw> {
  var userInfo;
  EventHub eventHub;

  WithdrawState({Key key, this.eventHub, this.userInfo});

  bool needToFreezeUi;
  Widget alertIcon;
  String alertText;
  AlertDialog alertDialog;
  String paymentGatewayName;
  List<dynamic> paymentGateways = [];
  int takaPerDollar;

  TextEditingController receiverAccountNumberCtl = new TextEditingController();
  TextEditingController amountDollarCtl = new TextEditingController();
  TextEditingController amountTakeCtl = new TextEditingController();

  @override
  void initState() {
    super.initState();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    eventHub.fire("viewTitle", "Withdraw");
    paymentGatewayDropDownList.clear();
    paymentGatewayDropDownList.add(
        new DropdownMenuItem<String>(
            value: "Select",
            child: Text("Select")
        )
    );
    paymentGatewayName = "Select";
    paymentGateways = userInfo['paymentGateways'];
    paymentGateways.asMap().forEach((key, paymentGateways) {
      paymentGatewayDropDownList.add(
          new DropdownMenuItem<String>(
              value: paymentGateways['paymentGatewayName'],
              child: Text(paymentGateways['paymentGatewayName'])
          )
      );
    });
    takaPerDollar = userInfo['takePerDollar']['appConstantIntegerValue'];
    amountDollarCtl.addListener(() {
      setState(() {
        if (amountDollarCtl.text.isNotEmpty) {
          int res = int.tryParse(amountDollarCtl.text) * takaPerDollar;
          amountTakeCtl.text = res.toString();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showRequiredHeading("Payment Gateway"),
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
                      value: paymentGatewayName,
                      isExpanded: true,
                      underline: SizedBox(),
                      onChanged: (String newValue) {
                        setState(() {
                          paymentGatewayName = newValue;
                        });
                      },
                      items: paymentGatewayDropDownList
                  )
              ),
              entryField("Account Number",receiverAccountNumberCtl),
              Container(
                padding: EdgeInsets.fromLTRB(2,10,10,10),
                child: Text(
                    "1 Dollar = $takaPerDollar Taka",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.red
                    )
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    showRequiredHeading("Amount (Dollar)"),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                        controller: amountDollarCtl,
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
                      "Amount (Taka)",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                        readOnly: true,
                        controller: amountTakeCtl,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]')),
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
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlineButton(
                        onPressed: () {
                          if (userInfo['profileCompleted'] == 100) {
                            bool isInputVerified = verifyInput();
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
                        child: Text("Reset"))
                  ])
            ],
          ),
        ),
      ),
      bottomNavigationBar: Alert.addBottomLoader(needToFreezeUi, alertIcon, alertText),
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
                  filled: true))
        ],
      ),
    );
  }

  void onSave(BuildContext context) {
    var request = {
      "transaction": {
        "accountNumber": receiverAccountNumberCtl.text,
        "debitAmount": double.tryParse(amountDollarCtl.text),
        "creditAmount": null,
        "status": "Pending",
        "accountHolderId": userInfo['id'],
        "transactionId": null,
        "paymentGatewayName": paymentGatewayName,
        "ledgerId": 102
      }
    };

    String url = baseUrl + '/transactions';
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
          eventHub.fire("reloadBalance");
          eventHub.fire("redirectToWalletHistory");
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

  bool verifyInput() {
    bool isInputVerified = true;
    String errMsg;
    if (paymentGatewayName == "Select") {
      errMsg = "Please select a payment gateway!";
      isInputVerified = false;
    } else if(receiverAccountNumberCtl.text.isEmpty){
      errMsg = "Please give an account number to withdraw!";
      isInputVerified = false;
    }  else if(amountDollarCtl.text.isEmpty){
      errMsg = "Please give your deposit amount!";
      isInputVerified = false;
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, context, Alert.ERROR, errMsg);
    }
    return isInputVerified;
  }

  void onReset(){
    setState(() {
      paymentGatewayName = "Select";
      receiverAccountNumberCtl.clear();
      amountDollarCtl.clear();
      amountTakeCtl.clear();
    });
  }

}