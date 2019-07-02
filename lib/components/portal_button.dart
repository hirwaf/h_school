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

    return GestureDetector(
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.all(5.0),
          height: 130.0,
          width: 130.0,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ),
          color: color ?? Colors.grey,
        ),
      ),
      onTap: callback,
    );
  }
}
