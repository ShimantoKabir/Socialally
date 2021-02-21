import 'dart:convert';

import 'package:client/constants.dart';
import 'package:client/models/Transaction.dart';
import 'package:client/utilities/Alert.dart';
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class History extends StatefulWidget {
  History({Key key, this.eventHub, this.userInfo}) : super(key: key);
  final userInfo;
  final EventHub eventHub;

  @override
  HistoryState createState() =>
      HistoryState(key: key, eventHub: eventHub, userInfo: userInfo);
}

class HistoryState extends State<History> {
  var userInfo;
  EventHub eventHub;

  HistoryState({Key key, this.eventHub, this.userInfo});

  AlertDialog alertDialog;
  Future futureTransactions;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  int pageIndex = 0;
  int perPage = 10;
  int pageNumber = 0;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle","History");
    futureTransactions = fetchTransactions();
    alertText = "No operation running.";
    alertIcon = Container();
    needToFreezeUi = false;
    pageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
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
                  return SingleChildScrollView(
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
                          cells: [
                            DataCell(Text("${index+1}")),
                            DataCell(Text(transactions[index].transactionId)),
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
    String url = baseUrl + "/transactions/query?user-info-id=${userInfo['id']}&par-page=$perPage&page-index=$pageIndex";
    print("url = $url");

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);

      print("res $res");
      List<dynamic> transactions = res['transactions'];

      transactions.asMap().forEach((key, value) {
        transactionList.add(new Transaction(
          createdAt: value["createdAt"],
          transactionId: value["transactionId"].toString(),
          debitAmount: double.tryParse(value["debitAmount"].toString()),
          creditAmount: double.tryParse(value["creditAmount"].toString()),
          paymentGatewayName: value['paymentGatewayName'],
          accountNumber: value['accountNumber'].toString(),
          ledgerId: value['ledgerId'],
          ledgerName: value['ledgerName'],
          amount: double.tryParse(value['amount'].toString()),
          status: value['status']
        ));
      });
    }

    setState(() {
      needToFreezeUi = false;
    });
    return transactionList;
  }

}