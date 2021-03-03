import 'dart:convert';

import 'package:client/constants.dart';
import 'package:client/models/AdCostPlan.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class AdvertisementCost extends StatefulWidget {
  AdvertisementCost({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  AdvertisementCostState createState() => AdvertisementCostState(
    userInfo: userInfo,
    eventHub: eventHub
  );
}

class AdvertisementCostState extends State<AdvertisementCost> {
  var userInfo;
  EventHub eventHub;

  AdvertisementCostState({Key key, this.userInfo, this.eventHub});

  AlertDialog alertDialog;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  Future futureAdCostPlanList;
  bool isSideBoxOpen;

  TextEditingController dayCtl = new TextEditingController();
  TextEditingController costCtl = new TextEditingController();
  AdCostPlan adCostPlan;

  @override
  void initState() {
    super.initState();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    futureAdCostPlanList = fetchAdCostPlanList();
    isSideBoxOpen = false;
    adCostPlan = new AdCostPlan(
      day: null,
      cost: null,
      txt: null
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: needToFreezeUi,
      child: Scaffold(
        body: FutureBuilder(
            future: futureAdCostPlanList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<AdCostPlan> adCostPlans = snapshot.data;
                if(adCostPlans.length == 0){
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: Text("No job category found!"),
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
                            itemCount: adCostPlans.length,
                            itemBuilder: (context, index) {
                              return Container(
                                color: Colors.black12,
                                child: ListTile(
                                    title: Text("Day = ${adCostPlans[index].day}, Cost = ${adCostPlans[index].cost}")
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
                                  children: [
                                    entryField(
                                        title: "Day",
                                        controller: dayCtl
                                    ),
                                    entryField(
                                        title: "Cost",
                                        controller: costCtl
                                    ),
                                    SizedBox(height: 10),
                                    OutlineButton(
                                        onPressed: (){
                                          setState(() {
                                            if(dayCtl.text.isEmpty){
                                              Alert.show(
                                                  alertDialog,
                                                  context,
                                                  Alert.ERROR,
                                                  "Please give day!"
                                              );
                                            } else if(costCtl.text.isEmpty){
                                              Alert.show(
                                                  alertDialog,
                                                  context,
                                                  Alert.ERROR,
                                                  "Please give cost!"
                                              );
                                            }else {
                                              onSave(context);
                                            }
                                          });
                                        },
                                        child: Text("Save")
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
              ),
              IconButton(
                icon: Icon(
                    Icons.delete,
                    size: 25
                ),
                onPressed: (){
                  onDelete(context);
                }
              ),
            ],
          ),
        ),
      ),
    );
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

  Future<List<AdCostPlan>> fetchAdCostPlanList() async {

    List<AdCostPlan> adCostPlanList = [];

    String url = baseUrl + "/app-constants/settings/ad-cost-plans";

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
      print("res $res");
      if (res['code'] == 200) {
        List<dynamic> adCostPlans = res['adCostPlans'];
        adCostPlans.asMap().forEach((key, value) {
          adCostPlanList.add(new AdCostPlan(
            cost: value['cost'],
            day: value['day']
          ));
        });
      }else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }else {
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    }
    return adCostPlanList;
  }

  void onDelete(BuildContext context) {

    String url = baseUrl + '/app-constants/settings/ad-cost-plans';
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
            futureAdCostPlanList = fetchAdCostPlanList();
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
      "adCostPlan": {
        "day": int.tryParse(dayCtl.text),
        "cost": int.tryParse(costCtl.text)
      }
    };

    String url = baseUrl + '/app-constants/settings/ad-cost-plans';
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
            futureAdCostPlanList = fetchAdCostPlanList();
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
      adCostPlan.day = null;
      adCostPlan.cost = null;
      dayCtl.clear();
      costCtl.clear();
    });
  }
}