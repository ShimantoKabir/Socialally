import 'package:event_hub/event_hub.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  List<BarChartGroupData> rawBarGroups;
  List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex;
  var transactionData;

  List<dynamic> depositHistory;
  List<dynamic> withdrawHistory;
  List<dynamic> earningHistory;

  @override
  void initState() {
    super.initState();

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

}