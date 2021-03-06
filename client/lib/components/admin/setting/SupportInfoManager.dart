import 'dart:convert';
import 'package:wengine/constants.dart';
import 'package:wengine/models/AdCostPlan.dart';
import 'package:wengine/models/SupportInfo.dart';
import 'package:wengine/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

class SupportInfoManager extends StatefulWidget {
  SupportInfoManager({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  SupportInfoManagerState createState() => SupportInfoManagerState(
      userInfo: userInfo,
      eventHub: eventHub
  );
}

class SupportInfoManagerState extends State<SupportInfoManager> {
  var userInfo;
  EventHub eventHub;

  SupportInfoManagerState({Key key, this.userInfo, this.eventHub});

  AlertDialog alertDialog;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  Future futureSupportInfoList;
  bool isSideBoxOpen;

  TextEditingController nameCtl = new TextEditingController();
  TextEditingController addressCtl = new TextEditingController();
  SupportInfo supportInfo;

  @override
  void initState() {
    super.initState();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    futureSupportInfoList = fetchSupportInfoList();
    isSideBoxOpen = false;
    supportInfo = new SupportInfo(
      name: null,
      address: null
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: needToFreezeUi,
      child: Scaffold(
        body: FutureBuilder(
            future: futureSupportInfoList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<SupportInfo> supportInfos = snapshot.data;
                if(supportInfos.length == 0){
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: inputForm(context),
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
                            itemCount: supportInfos.length,
                            itemBuilder: (context, index) {
                              return Container(
                                color: Colors.black12,
                                child: ListTile(
                                  title: Text("${supportInfos[index].name}"),
                                  subtitle: Text("${supportInfos[index].address}")
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
                              child: inputForm(context),
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
                    print("hi");
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

  Widget inputForm(BuildContext context){
    return Container(
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
              title: "Name",
              controller: nameCtl
          ),
          SizedBox(height: 20),
          entryField(
              title: "Address",
              controller: addressCtl
          ),
          SizedBox(height: 10),
          OutlineButton(
              onPressed: (){
                setState(() {
                  if(nameCtl.text.isEmpty){
                    Alert.show(
                        alertDialog,
                        context,
                        Alert.ERROR,
                        "Please give a name!"
                    );
                  } else if(addressCtl.text.isEmpty){
                    Alert.show(
                        alertDialog,
                        context,
                        Alert.ERROR,
                        "Please give a address!"
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

  Future<List<SupportInfo>> fetchSupportInfoList() async {

    List<SupportInfo> supportInfoList = [];

    String url = baseUrl + "/app-constants/settings/support-infos";

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
        List<dynamic> supportInfos = res['supportInfos'];
        supportInfos.asMap().forEach((key, value) {
          supportInfoList.add(new SupportInfo(
            name : value['name'],
            address : value['address']
          ));
        });
      }else {
        Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
      }
    }else {
      Alert.show(alertDialog, context, Alert.ERROR, Alert.ERROR_MSG);
    }
    return supportInfoList;
  }

  void onDelete(BuildContext context) {

    String url = baseUrl + '/app-constants/settings/support-infos';
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
            futureSupportInfoList = fetchSupportInfoList();
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
      "supportInfo": {
        "name": nameCtl.text,
        "address": addressCtl.text
      }
    };

    String url = baseUrl + '/app-constants/settings/support-infos';
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
            futureSupportInfoList = fetchSupportInfoList();
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
      supportInfo.name = null;
      supportInfo.address = null;
      nameCtl.clear();
      addressCtl.clear();
    });
  }
}