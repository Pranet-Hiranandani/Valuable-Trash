import 'package:flutter/material.dart';

class Alert extends StatelessWidget {
  final String content;
  final int alertype;
  final bool close;
  final VoidCallback button1func;
  final VoidCallback? button2func;
  final Widget button1child;
  final Widget? button2child;
  Alert({
    Key? key,
    required this.content,
    this.close = true,
    required this.button1func,
    this.button2func,
    required this.button1child,
    this.button2child,
    this.alertype = 0,
  }) : super(key: key);

  Image image() {
    if (alertype == 1) {
      return Image.asset("assets/icons/icon_success.png");
    } else if (alertype == 2) {
      return Image.asset("assets/icons/icon_warning.png");
    } else {
      return Image.asset("assets/icons/icon_info.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final ButtonStyle style = ElevatedButton.styleFrom(
      primary: Colors.green[700],
      minimumSize: Size(80, 40),
      enableFeedback: true,
    );
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      contentPadding: EdgeInsets.fromLTRB(17, 17, 17, 5),
      title: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
            child: GestureDetector(
              onTap: () {
                if (close == true) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              },
              child: Container(
                alignment: FractionalOffset.topRight,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/icons/close.png")),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: image(),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            this.content,
            style: TextStyle(fontSize: 19),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: style,
          onPressed: this.button1func,
          child: this.button1child,
        ),
        button2func != null
            ? ElevatedButton(
                onPressed: this.button2func,
                child: this.button2child,
                style: style,
              )
            : SizedBox(
                width: 0,
                height: 0,
              ),
      ],
    );
  }
}
