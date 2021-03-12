import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class ChartOfAccount extends Equatable{
  int id;
  int ledgerId;
  String ledgerName;
  int type;


  ChartOfAccount({
    this.id,
    this.ledgerId,
    this.ledgerName,
    this.type
  });

  @override
  List<Object> get props => [id, ledgerId, ledgerName, type];

  @override
  bool get stringify => false;

}