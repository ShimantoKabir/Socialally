import 'package:client/constants.dart';
import 'package:client/route/RouterGenerator.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
        initialRoute: '/',
        onGenerateRoute: RouterGenerator().generate,
        title: 'W-engine',
        theme: getThemeData(textTheme),
        debugShowCheckedModeBanner: false);
  }
}
