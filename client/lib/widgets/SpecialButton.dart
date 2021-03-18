import 'package:flutter/material.dart';

class SpecialButton extends StatelessWidget {
  final data;
  final Function onClick;
  const SpecialButton({
    Key key,
    this.data,
    this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: FlatButton(
        padding: EdgeInsets.symmetric(
            horizontal: data['padding'] + 10,
            vertical: data['padding']
        ),
        color: Colors.yellow,
        onPressed: onClick,
        child: Text(
          data['title'].toUpperCase(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: data['fontSize']
          ),
        ),
      ),
    );
  }
}