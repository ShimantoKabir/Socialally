import 'dart:convert';

import 'package:client/constants.dart';
import 'package:client/models/Transaction.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Requisition extends StatefulWidget {
  Requisition({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  RequisitionState createState() => RequisitionState(userInfo: userInfo, eventHub: eventHub);
}

class RequisitionState extends State<Requisition> {
  var userInfo;
  EventHub eventHub;
  RequisitionState({Key key, this.userInfo, this.eventHub});

  AlertDialog alertDialog;
  Future futureTransactions;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  int pageIndex = 0;
  int perPage = 10;
  int pageNumber = 0;
  int listPosition;
  Transaction transaction;
  TextEditingController transactionIdCtl = new TextEditingController();

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle","Requisition");
    futureTransactions = fetchTransactions();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;
    transaction = null;
    listPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: FutureBuilder(
            future: futureTransactions,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Transaction> transactions = snapshot.data;

                if(transactions.length == 0){
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                      child: Text("No transaction found!"),
                    ),
                  );
                }else {
                  return Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            sortAscending: true,
                            columns: <DataColumn>[
                              DataColumn(
                                label: Text('Sl'),
                              ),
                              DataColumn(
                                label: Text("Tx Id"),
                              ),
                              DataColumn(
                                label: Text("Payment Gateway"),
                              ),
                              DataColumn(
                                label: Text("Type"),
                              ),
                              DataColumn(
                                label: Text("Account Number"),
                              ),
                              DataColumn(
                                label: Text("Amount"),
                              ),
                              DataColumn(
                                label: Text("Status"),
                              ),
                              DataColumn(
                                label: Text("Date"),
                              )
                            ],
                            rows: List<DataRow>.generate(
                                transactions.length, (index) => DataRow(
                                onSelectChanged: (value){
                                  if(!needToFreezeUi){
                                    setState(() {
                                      transaction = transactions[index];
                                      listPosition = index;
                                    });
                                  }
                                },
                                cells: [
                                  DataCell(Text("${index+1}")),
                                  DataCell(
                                      Text("${transactions[index].transactionId}")
                                  ),
                                  DataCell(Text("${transactions[index].paymentGatewayName}")),
                                  DataCell(Text("${transactions[index].ledgerName}")),
                                  DataCell(Text("${transactions[index].accountNumber}")),
                                  DataCell(Text("${transactions[index].amount}")),
                                  DataCell(Text("${transactions[index].status}")),
                                  DataCell(Text("${transactions[index].createdAt}"))
                                ]
                              )
                            ),
                          ),
                        ),
                        flex: 7
                      ),
                      Visibility(
                        visible: transaction != null
                            && transaction.status == "Pending",
                        child: Expanded(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border(
                                // top: BorderSide(
                                //     color: Colors.grey
                                // ),
                                // left: BorderSide(
                                //     color: Colors.grey
                                // ),
                                // bottom: BorderSide(
                                //     color: Colors.grey
                                // )
                              )
                            ),
                            child: transaction == null ? Container() : Column(
                              children: [
                                Text("Type: ${transaction.ledgerName}"),
                                SizedBox(height: 10),
                                Text("Amount: ${transaction.creditAmount}"),
                                SizedBox(height: 10),
                                Text("Account Number: ${transaction.accountNumber}"),
                                SizedBox(height: 10),
                                Text("Applied Date: ${transaction.createdAt}"),
                                SizedBox(height: 10),
                                Text("Status: ${transaction.createdAt}"),
                                SizedBox(height: 10),
                                transaction.ledgerId == 102 ||
                                    transaction.ledgerId == 106 ?
                                entryField("Transaction Id",transactionIdCtl) :
                                Text("TransactionId: ${
                                    transaction.transactionId}"),
                                SizedBox(height: 10),
                                Visibility(
                                  child: OutlineButton(
                                      onPressed: (){
                                        onUpdate(context,"Approved",transactions);
                                      },
                                      child: Text("Approved"),
                                    ),
                                  visible: transaction.status == "Pending",
                                ),
                                SizedBox(height: 10),
                                Visibility(
                                  child: OutlineButton(
                                    onPressed: (){
                                      onUpdate(context,"Declined",transactions);
                                    },
                                    child: Text("Declined"),
                                  ),
                                  visible: transaction.status == "Pending",
                                ),
                                SizedBox(height: 10),
                                OutlineButton(
                                  onPressed: (){
                                    setState(() {
                                      listPosition = null;
                                      transaction = null;
                                    });
                                  },
                                  child: Text("Close"),
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
              } else {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        bottomNavigationBar: AbsorbPointer(
          absorbing: needToFreezeUi,
          child: Container(
            color: Colors.black12,
            height: 50.0,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(icon: Icon(Icons.filter_alt_outlined), onPressed: (){

                }),
                Visibility(
                    visible: needToFreezeUi,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      strokeWidth: 2,
                    )
                ),
                Row(
                  children: [
                    IconButton(
                        icon: Icon(
                            Icons.arrow_back_ios,
                            size: 15
                        ),
                        onPressed: (){
                          if(pageIndex < 1){
                            Alert.show(alertDialog, context, Alert.ERROR, "Your are already in the first page!");
                          }else {
                            pageNumber--;
                            pageIndex = pageIndex - perPage;
                            needToFreezeUi = true;
                            setState(() {
                              futureTransactions = fetchTransactions();
                            });
                          }
                        }
                    ),
                    Text("${pageNumber+1}"),
                    IconButton(
                        icon: Icon(
                            Icons.arrow_forward_ios,
                            size: 15
                        ),
                        onPressed: (){
                          pageIndex = pageIndex + perPage;
                          needToFreezeUi = true;
                          pageNumber++;
                          setState(() {
                            futureTransactions = fetchTransactions();
                          });
                        }
                    )
                  ],
                )
              ],
            ),
          ),
        )
    );
  }

  Future<List<Transaction>> fetchTransactions() async {

    List<Transaction> transactionList = [];
    String url = baseUrl + "/transactions/query?par-page=$perPage&page-index=$pageIndex";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);

      List<dynamic> transactions = res['transactions'];

      transactions.asMap().forEach((key, value) {
        transactionList.add(new Transaction(
          id: value["id"],
          createdAt: value["createdAt"],
          transactionId: value["transactionId"].toString(),
          amount: double.tryParse(value["amount"].toString()),
          creditAmount: double.tryParse(value["creditAmount"].toString()),
          debitAmount: double.tryParse(value["debitAmount"].toString()),
          paymentGatewayName: value['paymentGatewayName'],
          accountHolderId: value['accountHolderId'],
          accountNumber: value['accountNumber'].toString(),
          ledgerId: value['ledgerId'],
          ledgerName: value['ledgerName'],
          status: value['status']
        ));
      });
    }
    setState(() {
      needToFreezeUi = false;
    });
    return transactionList;
  }

  void onUpdate(BuildContext context,String status,List<Transaction> transactions) {

    var request = {
      "transaction": {
        "id": transactions[listPosition].id,
        "status": status,
        "transactionId" : transactionIdCtl.text,
        "ledgerId" : transactions[listPosition].ledgerId,
        "accountHolderId" : transactions[listPosition].accountHolderId,
        "debitAmount" : transactions[listPosition].debitAmount,
        "creditAmount" : transactions[listPosition].creditAmount,
        "paymentGatewayName" : transactions[listPosition].paymentGatewayName,
      }
    };

    String url = baseUrl + '/transactions';
    Map<String, String> headers = {"Content-type": "application/json"};

    setState(() {
      needToFreezeUi = true;
      transaction = null;
    });

    put(url, headers: headers, body: json.encode(request)).then((response) {
      setState(() {
        needToFreezeUi = false;
      });
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        if (body['code'] == 200) {
          setState(() {
            transactions[listPosition].status = status;
            if(transactions[listPosition].ledgerId == 102){
              transactions[listPosition].transactionId = transactionIdCtl.text;
            }
          });
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

  Widget entryField(String title, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
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

}