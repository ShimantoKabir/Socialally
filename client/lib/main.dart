import 'package:wengine/route/RouterGenerator.dart';
import 'package:flutter/material.dart';
// hi
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: RouterGenerator().generate,
      title: 'WorkersEngine',
      debugShowCheckedModeBanner: false
    );
  }
}
