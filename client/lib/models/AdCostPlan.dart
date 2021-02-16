import 'package:equatable/equatable.dart';

class AdCostPlan extends Equatable{
  final int cost;
  final int day;
  final String txt;

  AdCostPlan({this.cost, this.day, this.txt});

  @override
  List<Object> get props => [cost, day, txt];

  @override
  bool get stringify => false;

}
