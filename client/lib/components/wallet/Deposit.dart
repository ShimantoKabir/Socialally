import 'dart:convert';
import 'package:socialally/constants.dart';
import 'package:socialally/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class Deposit extends StatefulWidget {
  Deposit({Key key, this.eventHub, this.userInfo}) : super(key: key);
  final userInfo;
  final EventHub eventHub;

  @override
  DepositState createState() =>
      DepositState(key: key, eventHub: eventHub, userInfo: userInfo);
}

class DepositState extends State<Deposit> {
  var userInfo;
  EventHub eventHub;

  DepositState({Key key, this.eventHub, this.userInfo});

  bool needToFreezeUi;
  Widget alertIcon;
  String alertText;
  String paymentGatewayName;
  String cashInNumber;
  String personalNumber;
  String agentNumber;
  List<dynamic> paymentGateways = [];
  int takePerPound;
  AlertDialog alertDialog;

  TextEditingController transactionIdCtl = new TextEditingController();
  TextEditingController senderAccountNumberCtl = new TextEditingController();
  TextEditingController amountDollarCtl = new TextEditingController();
  TextEditingController amountTakeCtl = new TextEditingController();

  @override
  void initState() {
    super.initState();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    eventHub.fire("viewTitle", "Deposit");
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
    takePerPound = userInfo['takePerPound'];
    amountDollarCtl.addListener(() {
      setState(() {
        if (amountDollarCtl.text.isNotEmpty) {
          double res = double.tryParse(amountDollarCtl.text) * takePerPound;
          amountTakeCtl.text = res.toString();
        }
        if(amountDollarCtl.text.isEmpty){
          amountTakeCtl.clear();
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
                    paymentGateways.asMap().forEach((key, value) {
                      if(paymentGatewayName == value['paymentGatewayName']){
                        setState(() {
                          cashInNumber = value['cashInNumber'] == null ? "N/A" :
                            value['cashInNumber'].toString();
                          agentNumber = value['agentNumber'] == null ? "N/A" :
                            value['agentNumber'].toString();
                          personalNumber = value['personalNumber'] == null ? "N/A" :
                            value['personalNumber'].toString();
                        });
                      }
                    });
                  },
                  items: paymentGatewayDropDownList
                )
              ),
              Visibility(
                visible: cashInNumber != null,
                child: Container(
                  padding: EdgeInsets.fromLTRB(5,10,10,10),
                  child: Text(
                    "Cash In Number: $cashInNumber/ Agent Number: $agentNumber/"
                        " Personal Number: $personalNumber",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.red
                    )
                  ),
                )
              ),
              entryField("Transaction Id",transactionIdCtl),
              entryField("Sender Account Number",senderAccountNumberCtl),
              Container(
                padding: EdgeInsets.fromLTRB(2,10,10,10),
                child: Text(
                    "1 GBP = $takePerPound Taka",
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
                    showRequiredHeading("Amount (GBP)"),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                        controller: amountDollarCtl,
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: true
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]')),
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
                          bool isInputVerified = verifyInput();
                          if(isInputVerified){
                            onSave(context);
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
        "accountNumber": senderAccountNumberCtl.text,
        "transactionId": transactionIdCtl.text,
        "creditAmount": double.tryParse(amountDollarCtl.text),
        "debitAmount": null,
        "status": "Pending",
        "accountHolderId": userInfo['id'],
        "paymentGatewayName": paymentGatewayName,
        "ledgerId": 101
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
    } else if(transactionIdCtl.text.isEmpty){
      errMsg = "Please give the transaction id!";
      isInputVerified = false;
    } else if(senderAccountNumberCtl.text.isEmpty){
      errMsg = "Please give your account number!";
      isInputVerified = false;
    } else if(amountDollarCtl.text.isEmpty){
      errMsg = "Please give your deposit amount!";
      isInputVerified = false;
    }else if(userInfo['minimumDeposit'] > double.tryParse(amountDollarCtl.text)){
      errMsg = "Minimum deposit ${userInfo['minimumDeposit'].toString()} GBP!";
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
      transactionIdCtl.clear();
      senderAccountNumberCtl.clear();
      amountDollarCtl.clear();
      amountTakeCtl.clear();
      cashInNumber = null;
    });
  }

}