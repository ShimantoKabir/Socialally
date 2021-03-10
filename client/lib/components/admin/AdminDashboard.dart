import 'dart:convert';

import 'package:event_hub/event_hub.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:wengine/constants.dart';
import 'package:wengine/utilities/DateManager.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({Key key, this.userInfo, this.eventHub}) : super(key: key);
  final userInfo;
  final EventHub eventHub;
  @override
  AdminDashboardState createState() => AdminDashboardState(userInfo: userInfo, eventHub: eventHub);
}

class AdminDashboardState extends State<AdminDashboard> {
  var userInfo;
  EventHub eventHub;
  AdminDashboardState({Key key, this.userInfo, this.eventHub});

  Color depositColor = Colors.green;
  Color withdrawColor = Colors.red;
  Color earningColor = Colors.blue;
  double barWidth = 7.0;
  double barSpace = 10.0;
  String startDate;
  String endDate;

  List<BarChartGroupData> rawBarGroups;
  List<BarChartGroupData> showingBarGroups;
  Future futureTransactionOverview;

  int touchedGroupIndex;
  var transactionData;

  List<dynamic> depositHistory;
  List<dynamic> withdrawHistory;
  List<dynamic> earningHistory;

  AlertDialog alertDialog;
  Future futureUserInfos;
  Widget alertIcon;
  String alertText;
  bool needToFreezeUi;

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

    transactionData = {
      "deposit": {
        "totalDeposit" : 100,
        "startDate" : "2021-03-08",
        "endDate" : "2021-03-08",
        "history" : [
          {
            "date" : "2021-03-08",
            "totalDeposit" : 25
          },
          {
            "date" : "2021-03-08",
            "totalDeposit" : 50
          },
          {
            "date" : "2021-03-08",
            "totalDeposit" : 75
          },
          {
            "date" : "2021-03-08",
            "totalDeposit" : 100
          }
        ]
      },
      "withdraw": {
        "totalWithdraw" : 100,
        "startDate" : "2021-03-08",
        "endDate" : "2021-03-08",
        "history" : [
          {
            "date" : "2021-03-08",
            "totalWithdraw" : 25
          },
          {
            "date" : "2021-03-08",
            "totalWithdraw" : 53
          },
          {
            "date" : "2021-03-08",
            "totalWithdraw" : 75
          },
          {
            "date" : "2021-03-08",
            "totalWithdraw" : 100
          }
        ]
      },
      "earning" : {
        "totalEarning" : 100,
        "startDate" : "2021-03-08",
        "endDate" : "2021-03-08",
        "history" : [
          {
            "date" : "2021-03-08",
            "totalEarning" : 25
          },
          {
            "date" : "2021-03-08",
            "totalEarning" : 55
          },
          {
            "date" : "2021-03-08",
            "totalEarning" : 75
          },
          {
            "date" : "2021-03-08",
            "totalEarning" : 100
          }
        ]
      }
    };

    List<BarChartGroupData> items = [];

    depositHistory = transactionData['deposit']['history'];
    withdrawHistory = transactionData['withdraw']['history'];
    earningHistory = transactionData['earning']['history'];

    int index = 0;
    depositHistory.forEach((element) {
      items.add(makeGroupData(
          index,
          element['totalDeposit'],
          withdrawHistory[index]['totalWithdraw'],
          earningHistory[index]['totalEarning']
      ));
      index++;
    });

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
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
                    child: Text("No Data found!"),
                  ),
                );
              }else {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  color: const Color(0xff2c4260),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            makeTransactionsIcon(),
                            const SizedBox(
                              width: 38,
                            ),
                            const Text(
                              'Transactions',
                              style: TextStyle(color: Colors.white, fontSize: 22),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            const Text(
                              'state',
                              style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 38,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: BarChart(
                              BarChartData(
                                barTouchData: BarTouchData(
                                    touchTooltipData: BarTouchTooltipData(
                                        tooltipBgColor: Colors.green,
                                        getTooltipItem: (
                                            BarChartGroupData barChartGroupData,
                                            int a,
                                            BarChartRodData barChartRodData,
                                            int b){
                                          return BarTooltipItem("A = $a, B = $b",TextStyle(
                                              color: Colors.white
                                          ));
                                        }
                                    )
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: SideTitles(
                                      showTitles: true,
                                      getTextStyles: (value) => TextStyle(
                                          color: Color(0xff7589a2),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14
                                      ),
                                      margin: 20,
                                      getTitles: (double value) {
                                        return earningHistory[value.toInt()]['date'];
                                      }
                                  ),
                                  leftTitles: SideTitles(
                                      showTitles: false,
                                      getTextStyles: (value) => const TextStyle(
                                          color: Color(0xff7589a2),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14
                                      ),
                                      margin: 32,
                                      reservedSize: 14
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                barGroups: showingBarGroups,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
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
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: const Color(0xff2c4260),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  makeTransactionsIcon(),
                  const SizedBox(
                    width: 38,
                  ),
                  const Text(
                    'Transactions',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Text(
                    'state',
                    style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(
                height: 38,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.green,
                          getTooltipItem: (
                              BarChartGroupData barChartGroupData,
                              int a,
                              BarChartRodData barChartRodData,
                              int b){
                            return BarTooltipItem("A = $a, B = $b",TextStyle(
                              color: Colors.white
                            ));
                          }
                        )
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: SideTitles(
                          showTitles: true,
                          getTextStyles: (value) => TextStyle(
                            color: Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14
                          ),
                          margin: 20,
                          getTitles: (double value) {
                            return earningHistory[value.toInt()]['date'];
                          }
                        ),
                        leftTitles: SideTitles(
                          showTitles: false,
                          getTextStyles: (value) => const TextStyle(
                            color: Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14
                          ),
                          margin: 32,
                          reservedSize: 14
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      barGroups: showingBarGroups,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int index,double deposit, double withdraw, double earning) {
    return BarChartGroupData(barsSpace: barSpace, x: index, barRods: [
      BarChartRodData(
        y: deposit,
        colors: [depositColor],
        width: barWidth,
      ),
      BarChartRodData(
        y: withdraw,
        colors: [withdrawColor],
        width: barWidth,
      ),
      BarChartRodData(
        y: earning,
        colors: [earningColor],
        width: barWidth,
      )
    ]);
  }

  Widget makeTransactionsIcon() {
    const double width = 4.5;
    const double space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }

  Future<dynamic> fetchTransactionOverview() async {

    var overView;
    String url = baseUrl + "/transactions/overview?start-date=$startDate&end-date=$endDate";

    var response = await get(url);
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if(res['code'] == 200){
        overView = res['overView'];
      }
    }

    setState(() {
      needToFreezeUi = false;
    });

    return overView;
  }

}