import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class MyLocation extends Equatable{
  String regionName;
  String countryName;

  MyLocation({
    this.regionName,
    this.countryName
  });

  @override
  List<Object> get props => [countryName,regionName];

  @override
  bool get stringify => false;
}