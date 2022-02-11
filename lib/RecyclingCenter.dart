import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:val_trash/Classify.dart';
import 'package:val_trash/NavBar.dart';

class RecylingCenter extends StatefulWidget {
  final String label;
  RecylingCenter({Key? key, required this.label}) : super(key: key);

  @override
  _RecylingCenterState createState() => _RecylingCenterState();
}

class _RecylingCenterState extends State<RecylingCenter> {
  String url = "";

  Future change_url() async {
    PermissionStatus permission = await Permission.location.request();
    if (permission.isGranted) {
      if (widget.label == "Soda Can") {
        setState(
          () {
            url =
                "https://www.google.com/maps/search/nearest+alumium+recycling+center/";
          },
        );
      } else {
        setState(
          () {
            url =
                "https://www.google.com/maps/search/nearest+plastic+recycling+center/";
          },
        );
      }
    } else {
      var alert = SnackBar(
        content: Text(
          "Location Permission is required to locate a recycling center.",
          textAlign: TextAlign.center,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(alert);
    }
  }

  @override
  void initState() {
    super.initState();
    change_url();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         
        automaticallyImplyLeading: false,
        title: Text(
          "Recycle",
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async => false,
        child: url != ""
            ? WebView(
                initialUrl: url,
                javascriptMode: JavascriptMode.unrestricted,
                navigationDelegate: (NavigationRequest request) async {
                  await launch(request.url);
                  return NavigationDecision.navigate;
                },
                geolocationEnabled: true,
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Reclick the image",
        child: Icon(Icons.camera_alt_rounded),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassifyImage(
                recycle: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
