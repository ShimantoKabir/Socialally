import 'dart:convert';
import 'package:socialally/constants.dart';
import 'package:socialally/models/PaymentGateway.dart';
import 'package:socialally/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class PaymentGatewayManager extends StatefulWidget {
  PaymentGatewayManager({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  PaymentGatewayManagerState createState() => PaymentGatewayManagerState(
    userInfo: userInfo,
    eventHub: eventHub
  );
}

class PaymentGatewayManagerState extends State<PaymentGatewayManager> {
  var userInfo;
  EventHub eventHub;

  PaymentGatewayManagerState({Key key, this.userInfo, this.eventHub});

  AlertDialog alertDialog;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  Future futurePaymentGatewayList;
  bool isSideBoxOpen;

  TextEditingController paymentGatewayNameCtl = new TextEditingController();
  TextEditingController cashInNumberCtl = new TextEditingController();
  TextEditingController personalNumberCtl = new TextEditingController();
  TextEditingController agentNumberCtl = new TextEditingController();
  PaymentGateway paymentGateway;

  @override
  void initState() {
    super.initState();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    futurePaymentGatewayList = fetchPaymentGatewayList();
    isSideBoxOpen = false;
    paymentGateway = new PaymentGateway(
      cashInNumber: null,
      personalNumber: null,
      id: null,
      paymentGatewayName: null,
      agentNumber: null
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return AbsorbPointer(
      absorbing: needToFreezeUi,
      child: Scaffold(
        body: FutureBuilder(
            future: futurePaymentGatewayList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<PaymentGateway> paymentGateways = snapshot.data;
                if(paymentGateways.length == 0){
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: inputForm(context,height),
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
                          itemCount: paymentGateways.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(10),
                              color: Colors.black12,
                              child: ListTile(
                                leading: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: (){
                                    onDelete(context,paymentGateways[index].id);
                                  },
                                ),
                                title: Text("${paymentGateways[index].paymentGatewayName}"),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Personal Number: ${paymentGateways[index].personalNumber}"),
                                    Text("Cash In Number: ${paymentGateways[index].cashInNumber}"),
                                    Text("Agent Number: ${paymentGateways[index].agentNumber}")
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: (){
                                    setState(() {
                                      isSideBoxOpen = true;
                                      paymentGateway.id = paymentGateways[index].id;
                                      paymentGatewayNameCtl.text = paymentGateways[index].paymentGatewayName;
                                      personalNumberCtl.text = paymentGateways[index].personalNumber;
                                      agentNumberCtl.text = paymentGateways[index].agentNumber;
                                      cashInNumberCtl.text = paymentGateways[index].cashInNumber;
                                    });
                                  },
                                ),
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
                          child: inputForm(context,height),
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
                  onReset(context);
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget inputForm(BuildContext context,double h){
    return SingleChildScrollView(
      child: Container(
        height: h,
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
                title: "Payment Gateway",
                controller: paymentGatewayNameCtl,
                needToBeRequired: true
            ),
            SizedBox(height: 20),
            entryField(
                title: "Cash In Number",
                controller: cashInNumberCtl,
                needToBeRequired: false
            ),
            SizedBox(height: 10),
            entryField(
                title: "Agent Number",
                controller: agentNumberCtl,
                needToBeRequired: false
            ),
            SizedBox(height: 10),
            entryField(
                title: "Personal Number",
                controller: personalNumberCtl,
                needToBeRequired: false
            ),
            SizedBox(height: 10),
            OutlineButton(
                onPressed: (){
                  setState(() {
                    bool isInputVerified = verifyInput(context);
                    if(isInputVerified){
                      if(paymentGateway.id == null){
                        onSave(context);
                      }else {
                        onUpdate(context);
                      }
                    }
                  });
                },
                child: Text(paymentGateway.id == null ? "Save" : "Update")
            ),
            SizedBox(height: 10),
            OutlineButton(
                onPressed: (){
                  onReset(context);
                },
                child: Text("close")
            )
          ],
        ),
      ),
    );
  }

  Widget entryField({String title,
    TextEditingController controller,
    TextInputType textInputType,
    List<TextInputFormatter> textInputFormatter,
    int maxLines,
    bool needToBeRequired}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          needToBeRequired ? showRequiredHeading(title) :
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
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

  Future<List<PaymentGateway>> fetchPaymentGatewayList() async {

    List<PaymentGateway> paymentGatewayList = [];

    String url = baseUrl + "/payment-gateways";

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
        List<dynamic> paymentGateways = res['paymentGateways'];
        paymentGateways.asMap().forEach((key, value) {
          paymentGatewayList.add(new PaymentGateway(
            id: value['id'],
            paymentGatewayName: value['paymentGatewayName'].toString(),
            agentNumber: value['agentNumber'] == null ? "N/A" :
              value['agentNumber'].toString(),
            personalNumber: value['personalNumber'] == null ? "N/A" :
              value['personalNumber'].toString(),
            cashInNumber: value['cashInNumber'] == null ? "N/A" :
              value['cashInNumber'].toString()
          ));
        });
      }else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }else {
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    }
    return paymentGatewayList;
  }

  void onDelete(BuildContext context,int id) {

    String url = baseUrl + '/payment-gateways/$id';
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
            futurePaymentGatewayList = fetchPaymentGatewayList();
          });
          onReset(context);
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
      "paymentGateway": {
        "paymentGatewayName": paymentGatewayNameCtl.text,
        "cashInNumber": cashInNumberCtl.text,
        "personalNumber": personalNumberCtl.text,
        "agentNumber": agentNumberCtl.text
      }
    };

    String url = baseUrl + '/payment-gateways';
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
            futurePaymentGatewayList = fetchPaymentGatewayList();
          });
          onReset(context);
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
      isSideBoxOpen = false;
      paymentGateway.paymentGatewayName = null;
      paymentGateway.id = null;
      paymentGateway.agentNumber = null;
      paymentGateway.cashInNumber = null;
      paymentGateway.personalNumber = null;
      cashInNumberCtl.clear();
      agentNumberCtl.clear();
      personalNumberCtl.clear();
      paymentGatewayNameCtl.clear();
    });
  }

  bool verifyInput(BuildContext context) {

    bool isInputVerified = true;
    String errMsg;

    if (paymentGatewayNameCtl.text.isEmpty) {
      errMsg = "Please give a payment gateway name!";
      isInputVerified = false;
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, context, Alert.ERROR, errMsg);
    }
    return isInputVerified;
  }

  void onUpdate(BuildContext context) {
    var request = {
      "paymentGateway": {
        "id" : paymentGateway.id,
        "paymentGatewayName": paymentGatewayNameCtl.text,
        "cashInNumber": cashInNumberCtl.text,
        "personalNumber": personalNumberCtl.text,
        "agentNumber": agentNumberCtl.text
      }
    };

    String url = baseUrl + '/payment-gateways';
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
            futurePaymentGatewayList = fetchPaymentGatewayList();
          });
          onReset(context);
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