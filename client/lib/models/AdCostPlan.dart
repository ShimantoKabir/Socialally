import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class AdCostPlan extends Equatable{
  int cost;
  int day;
  String txt;

  AdCostPlan({this.cost, this.day, this.txt});

  @override
  List<Object> get props => [cost, day, txt];

  @override
  bool get stringify => false;

}
