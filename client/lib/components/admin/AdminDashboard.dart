import 'dart:convert';
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:event_hub/event_hub.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/models/Transaction.dart';
import 'package:wengine/utilities/Alert.dart';
import 'package:wengine/utilities/DateManager.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  AdminDashboardState createState() => AdminDashboardState(userInfo: userInfo, eventHub: eventHub);
}

class Sales {
  final String year;
  final int sales;
  Sales(this.year, this.sales);
}

class AdminDashboardState extends State<AdminDashboard> {
  var userInfo;
  EventHub eventHub;
  AdminDashboardState({Key key, this.userInfo, this.eventHub});

  String startDate;
  String endDate;
  Future futureTransactionOverview;
  AlertDialog alertDialog;
  Future futureUserInfos;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;
  DateTime startInitDate;
  DateTime endInitDate;

  @override
  void initState() {
    super.initState();
    eventHub.fire("viewTitle","Manage User");
    startDate = DateManager.findFirstDateOfTheWeek(DateTime.now());
    endDate = DateManager.findLastDateOfTheWeek(DateTime.now());
    futureTransactionOverview = fetchTransactionOverview();
    alertText = "No operation running!";
    alertIcon = Container();
    needToFreezeUi = false;
    startInitDate = DateTime.parse(startDate);
    endInitDate = DateTime.parse(endDate);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: FutureBuilder(
          future: futureTransactionOverview,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var overView = snapshot.data;
              if(overView == null){
                return Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Text("No data found!"),
                  ),
                );
              }else {
                var overView = snapshot.data;
                List<charts.Series<Transaction, String>> seriesList = overView['seriesList'];
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: getHeading(
                            overView['grandTotalDeposit'],
                            overView['grandTotalWithdraw'],
                            overView['grandTotalEarning']
                          ),
                        ),
                        Divider(
                          height: 10,
                          color: Colors.lightGreen,
                          thickness: 1,
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlineButton(
                                  child: Text("START DATE"),
                                  onPressed: (){
                                    showDatePicker(
                                      context: context,
                                      initialDate: startInitDate,
                                      firstDate:  DateTime(
                                        DateTime.now().year
                                      ),
                                      lastDate: DateTime(
                                        DateTime.now().year + 1
                                      )
                                    ).then((value){
                                      setState(() {
                                        startInitDate = value;
                                        startDate = DateManager.getOnlyDate(value);
                                      });
                                    });
                                  }
                              ),
                              OutlineButton(
                                  child: Text("END DATE"),
                                  onPressed: (){
                                    showDatePicker(
                                      context: context,
                                      initialDate: endInitDate,
                                      firstDate:  DateTime(
                                          DateTime.now().year
                                      ),
                                      lastDate: DateTime(
                                          DateTime.now().year + 1
                                      )
                                    ).then((value){
                                      setState(() {
                                        endInitDate = value;
                                        endDate = DateManager.getOnlyDate(value);
                                      });
                                    });
                                  }
                              ),
                              OutlineButton(
                                  child: Text("SUBMIT"),
                                  onPressed: (){
                                    int diffDays = endInitDate.difference(startInitDate).inDays;
                                    if(diffDays > minimumDayDifferance){
                                      Alert.show(alertDialog, context, Alert.ERROR,
                                        "Day differance between start date and end date should be less then $minimumDayDifferance!"
                                      );
                                    } else {
                                      futureTransactionOverview = fetchTransactionOverview();
                                    }
                                  }
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          child: Text(
                              "Date Range: $startDate - $endDate",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                            ),
                          ),
                        ),
                        Container(
                          width: width,
                          height: height,
                          padding: EdgeInsets.all(10),
                          child: charts.BarChart(
                              seriesList,
                              animate: true,
                              vertical: false,
                              barGroupingType: charts.BarGroupingType.grouped,
                              defaultRenderer: charts.BarRendererConfig(
                                groupingType: charts.BarGroupingType.grouped,
                                strokeWidthPx: 1.0,
                              ),
                              selectionModels: [
                                charts.SelectionModelConfig(
                                    changedListener: (charts.SelectionModel model) {
                                      if(model.hasDatumSelection){

                                        int ledgerId = int.tryParse(model.selectedSeries[0].id);
                                        String createdAt = model.selectedSeries[0].domainFn(model.selectedDatum[0].index);
                                        eventHub.fire("redirectToTransaction",Transaction(
                                          ledgerId: ledgerId,
                                          createdAt: createdAt
                                        ));
                                      }
                                    }
                                )
                              ]
                          ),
                        )
                      ],
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
        bottomNavigationBar: AbsorbPointer(
          absorbing: needToFreezeUi,
          child: Container(
            color: Colors.black12,
            height: 50.0,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Visibility(
                    visible: needToFreezeUi,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      strokeWidth: 2,
                    )
                ),
              ],
            ),
          ),
        )
    );
  }

  List<Widget> getHeading(double deposit,double withdraw,double earning){
    return [
      Card(
        color: Colors.green,
        child: Container(
          padding: EdgeInsets.all(10),
          height: 100,
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${deposit.toString()}£",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                ),
              ),
              Text(
                "Deposit",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25
                ),
              )
            ],
          ),
        ),
      ),
      Card(
        color: Colors.red,
        child: Container(
          height: 100,
          width: 200,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${withdraw.toString()}£",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                ),
              ),
              Text(
                "Withdraw",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25
                ),
              )
            ],
          ),
        ),
      ),
      Card(
        color: Colors.blue,
        child: Container(
          height: 100,
          width: 200,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${earning.toString()}£",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                ),
              ),
              Text(
                "Earning",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25
                ),
              )
            ],
          ),
        ),
      )
    ];
  }

  Future<dynamic> fetchTransactionOverview() async {

    List<charts.Series<Transaction, String>> seriesList = [];
    var overView;
    final random = Random();
    String url = baseUrl + "/transactions/overview?start-date=$startDate&end-date=$endDate";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if(res['code'] == 200){

        var transactionHistory = res['overView']['transactionHistory'];
        List<Transaction> dth = [];
        List<Transaction> wth = [];
        List<Transaction> eth = [];

        transactionHistory.forEach((element) {
          dth.add(Transaction(
              amount: element['dailyTotalDeposit'],
              // amount: random.nextInt(100).toDouble(),
              createdAt: element['date']
          ));
          wth.add(Transaction(
              amount: element['dailyTotalWithdraw'],
              // amount: random.nextInt(100).toDouble(),
              createdAt: element['date']
          ));
          eth.add(Transaction(
              amount: element['dailyTotalEarning'],
              // amount: random.nextInt(100).toDouble(),
              createdAt: element['date']
          ));
        });

        seriesList.add(charts.Series<Transaction, String>(
          id: "${res['overView']['depositLedgerId']}",
          domainFn: (Transaction transaction, _) => transaction.createdAt,
          measureFn: (Transaction transaction, _) => transaction.amount,
          data: dth,
          fillColorFn: (Transaction sales, _) {
            return charts.MaterialPalette.green.shadeDefault;
          },
        ));

        seriesList.add(charts.Series<Transaction, String>(
          id: "${res['overView']['withdrawLedgerId']}",
          domainFn: (Transaction transaction, _) => transaction.createdAt,
          measureFn: (Transaction transaction, _) => transaction.amount,
          data: wth,
          fillColorFn: (Transaction sales, _) {
            return charts.MaterialPalette.red.shadeDefault;
          },
        ));

        seriesList.add(charts.Series<Transaction, String>(
          id: "${res['overView']['earningLedgerId']}",
          domainFn: (Transaction transaction, _) => transaction.createdAt,
          measureFn: (Transaction transaction, _) => transaction.amount,
          data: eth,
          fillColorFn: (Transaction sales, _) {
            return charts.MaterialPalette.blue.shadeDefault;
          },
        ));

        overView = {
          "grandTotalDeposit" : res['overView']['grandTotalDeposit'],
          "grandTotalWithdraw" : res['overView']['grandTotalWithdraw'],
          "grandTotalEarning" : res['overView']['grandTotalEarning'],
          "seriesList" : seriesList,
        };

      }
    }

    setState(() {
      needToFreezeUi = false;
    });

    return overView;
  }

}