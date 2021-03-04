import 'package:client/route/RouterGenerator.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: RouterGenerator().generate,
      title: 'W-engine',
      debugShowCheckedModeBanner: false
    );
  }
}
