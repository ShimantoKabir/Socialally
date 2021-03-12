import 'dart:convert';

import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:wengine/models/ChartOfAccount.dart';
import 'package:wengine/models/Transaction.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/models/UserInfo.dart';
import 'package:wengine/utilities/Alert.dart';

class ManualTransaction extends StatefulWidget {

  ManualTransaction({
    Key key,
    this.userInfo,
    this.eventHub
  }) : super(key: key);

  final userInfo;
  final EventHub eventHub;

  @override
  ManualTransactionState createState() => ManualTransactionState(
      userInfo: userInfo,
      eventHub: eventHub
  );
}

class ManualTransactionState extends State<ManualTransaction> {

  var userInfo;
  EventHub eventHub;

  ManualTransactionState({
    Key key,
    this.userInfo,
    this.eventHub
  });

  TextEditingController amountCtl = TextEditingController();
  TextEditingController userInfoIdCtl = TextEditingController();
  SuggestionsBoxController suggestionsBoxController  = SuggestionsBoxController();
  var defaultAdCost;
  bool needToFreezeUi = false;
  Widget alertIcon;
  String alertText;
  AlertDialog alertDialog;
  Transaction transaction;
  ChartOfAccount chartOfAccount;
  UserInfo ui;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle","Job Advertisement");
    alertText = "No operation running.";
    alertIcon = Container();

    transaction = new Transaction(
      id: null,
      ledgerId: null,
      ledgerName: null,
      amount: null,
      accountHolderId: null
    );

    chartOfAccount = new ChartOfAccount(
      type: null,
      ledgerId: null,
      ledgerName: "Select",
      id: null
    );

    ui = new UserInfo(
      id: null,
      firstName: null,
      userInfoId: null
    );

    List<dynamic> chartOfAccounts = userInfo['chartOfAccounts'];
    chartOfAccounts.asMap().forEach((key, chartOfAccount) {
      bool isValueExist = false;
      chartOfAccountDropDownList.forEach((element) {
        if (element.value.id == chartOfAccount['id']) {
          isValueExist = true;
        }
      });
      if (!isValueExist) {
        ChartOfAccount coa = new ChartOfAccount(
            id: chartOfAccount["id"],
            ledgerId: chartOfAccount["ledgerId"],
            ledgerName: chartOfAccount["ledgerName"],
            type: chartOfAccount["type"]
        );
        chartOfAccountDropDownList.add(DropdownMenuItem(
            value: coa,
            child: Text(coa.ledgerName)
        ));
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                showRequiredHeading("User Info Id"),
                OutlineButton(
                  onPressed: (){
                    clearSuggestion(context);
                  },
                  child: Text("Clear Suggestion"),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TypeAheadField(
              suggestionsBoxController: suggestionsBoxController,
              textFieldConfiguration: TextFieldConfiguration(
                  controller: userInfoIdCtl,
                  decoration: InputDecoration(
                      hintText: "Search your posted job ....",
                      border: OutlineInputBorder()
                  )
              ),
              suggestionsCallback: (pattern) async {
                return fetchProject(pattern);
              },
              itemBuilder: (context, UserInfo ui) {
                return ListTile(
                    leading: Icon(Icons.people),
                    title: Text(ui.userInfoId)
                );
              },
              onSuggestionSelected: (UserInfo selectedUi) {
                setState(() {
                  userInfoIdCtl.text = ui.userInfoId;
                  ui.id = selectedUi.id;
                  ui.userInfoId = selectedUi.userInfoId;
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            showRequiredHeading("Account"),
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
                child: DropdownButton<ChartOfAccount>(
                  value: chartOfAccount,
                  isExpanded: true,
                  underline: SizedBox(),
                  onChanged: (ChartOfAccount coa) {
                    setState(() {
                      chartOfAccount.id = coa.id;
                      chartOfAccount.ledgerName = coa.ledgerName;
                      chartOfAccount.type = coa.type;
                      chartOfAccount.ledgerId = coa.ledgerId;
                    });
                  },
                  items: chartOfAccountDropDownList
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
    );
  }

  void clearSuggestion(BuildContext context) {
    userInfoIdCtl.clear();
    suggestionsBoxController.close();
    ui.id = null;
    ui.firstName = null;
    ui.userInfoId = null;
  }

  Future<List<UserInfo>> fetchProject(String pattern) async {

    List<UserInfo> userInfoList = [];
    String url = baseUrl + "/users/user-info-id/query?user-info-id=$pattern";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['code'] == 200) {
        List<dynamic> userInfos = res['userInfos'];
        userInfos.asMap().forEach((key, ui) {
          userInfoList.add(new UserInfo(
              id: ui['id'],
              firstName: null,
              userInfoId: ui['userInfoId']
          ));
        });
      }
    }
    return userInfoList;
  }

  bool verifyInput(BuildContext context) {
    bool isInputVerified = true;
    String errMsg;

    if (userInfoIdCtl.text.isEmpty) {
      errMsg = "Please select a user info id!";
      isInputVerified = false;
    }else if(chartOfAccount.ledgerName == "Select"){
      errMsg = "Please select an account!";
      isInputVerified = false;
    }else if(amountCtl.text.isEmpty){
      errMsg = "Please give an amount!";
      isInputVerified = false;
    }

    if (!isInputVerified) {
      Alert.show(alertDialog, context, Alert.ERROR, errMsg);
    }
    return isInputVerified;
  }

  void onSave(BuildContext context) {

  }

  void onReset(BuildContext context) {

  }

}