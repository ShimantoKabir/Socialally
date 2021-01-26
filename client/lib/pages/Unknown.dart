import 'package:flutter/material.dart';

class Unknown extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error,size: 30,color: Colors.red),
            SizedBox(width: 10),
            Text("Page not found",style: TextStyle(fontSize: 30))
          ],
        ),
      ),
    );
  }
}