import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final data;
  final Function onClick;
  const MenuItem({
    Key key,
    this.data,
    this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: onClick,
        child: Text(
          data['title'].toUpperCase(),
          style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: data['fontSize']
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
         horizontal: data['padding']
      ),
      margin: EdgeInsets.symmetric(
          vertical: data['margin']
      ),
    );
  }
}
