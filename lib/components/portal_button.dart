import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback callback;
  final Color color;

  const Button({Key key, this.text, this.callback, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return RaisedButton(
      child: ClipOval(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          height: 140.0,
          width: 140.0,
          child: Center(
            child: Text(
              text,
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          color: color,
        ),
      ),
      onPressed: callback,
      padding: EdgeInsets.all(10),
      elevation: 5.2,
    );
  }
}
