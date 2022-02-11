import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:val_trash/Alert.dart';
import 'package:val_trash/home.dart';
import 'homepage.dart';
import 'NavBar.dart';

class UploadIdea extends StatefulWidget {
  const UploadIdea({Key? key}) : super(key: key);

  @override
  _UploadIdeaState createState() => _UploadIdeaState();
}

class _UploadIdeaState extends State<UploadIdea> {
  TextEditingController textController = new TextEditingController();
  TextEditingController textController1 = new TextEditingController();
  FirebaseStorage _storage = FirebaseStorage.instance;
  CollectionReference data =
      FirebaseFirestore.instance.collection("User_Ideas");
  bool login = false;
  String title = "";
  String text = "";
  String email = "";
  String name = "";
  String images = "";
  String imageurl = "";
  List<XFile>? filelist = [];
  double height = 1;
  double width = 1;
  late Box profilebox;
  var picker = ImagePicker();
  String error = "";
  Future Select_Images() async {
    var pickedFileList = await picker.pickMultiImage();
    if (pickedFileList != null) {
      images = pickedFileList.length.toString() + " image/s selected";
    }
    setState(
      () {
        filelist = pickedFileList;
      },
    );
  }

  Future Upload_Data() async {
    DateTime now = DateTime.now();
    String date = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    text = textController.text;
    title = textController1.text;
    if (login == true) {
      if (title != "") {
        if (text != "") {
          if (filelist!.length != 0) {
            await data.add(
              {
                "Steps": text,
                "Title": title,
                "Upload_time": date,
                "Email": email,
                "Name": name,
              },
            );
            filelist?.forEach(
              (element) =>
                  Upload_Images(element, filelist!.indexOf(element), email),
            );
            var alert = Alert(
              content:
                  "Your idea was uploaded! Thank you for contributing to the Valuable Trash Community.",
              button1func: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              button1child: Icon(Icons.done),
            );
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );
          } else if (filelist!.length == 0) {
            var alert = Alert(
              content: "Please select at least one image!",
              button1func: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              button1child: Icon(Icons.done),
            );
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return alert;
              },
            );
          }
        } else {
          var alert = Alert(
            content: "Please enter the steps for your idea!",
            button1func: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            button1child: Icon(Icons.done),
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
      } else {
        var alert = Alert(
          content: "Please enter a title for your idea!",
          button1func: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          button1child: Icon(Icons.done),
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
    } else {
      var alert = Alert(
        content: "Please sign in to the Valuable Trash community to continue!",
        button1func: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
        button1child: Icon(Icons.done),
      );
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  Future Upload_Images(XFile file, int index, String email) async {
    DateTime now = DateTime.now();
    String date = DateFormat('kk mm ss \n EEE d MMM').format(now);
    File files = new File(file.path);
    String fileName = files.path.split('/').last;
    var reference =
        await _storage.ref().child("User Upload/$title-$email/$index.png");
    var uploadTask = await reference.putFile(files);
  }

  Future getemail() async {
    profilebox = Hive.box('profile');
    if (profilebox.get('loggedin') == true) {
      setState(
        () {
          email = profilebox.get('email').toString();
          name = profilebox.get('name').toString();
          imageurl = profilebox.get('imageurl').toString();
          login = true;
        },
      );
    }
    /*if (profilebox.get('loggedin') == false) {
      setState(
        () {
          login = false;
        },
      );
      Widget okButton = ElevatedButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      );
      var alert = Alert(
          content:
              "Please sign in to the Valuable Trash community to continue!",
          button1func: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          button1child: Icon(Icons.done));
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }*/
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    getemail();
    var avatar = login != false
        ? Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: CircleAvatar(
                foregroundImage: CachedNetworkImageProvider(imageurl),
              ),
            ),
          )
        : Text("");
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          "Contribute",
          style: TextStyle(fontSize: 24),
        ),
        actions: [avatar],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: Upload_Data,
        child: Icon(Icons.done),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              Material(
                elevation: 10,
                child: TextFormField(
                  scrollPadding: EdgeInsets.all(5),
                  decoration: InputDecoration(
                      hintText: 'Enter the title of your idea',
                      contentPadding: EdgeInsets.all(10)),
                  autocorrect: true,
                  minLines: 1,
                  maxLines: 2,
                  controller: textController1,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              Text(" "),
              Material(
                elevation: 10,
                child: TextFormField(
                  scrollPadding: EdgeInsets.all(5),
                  decoration: InputDecoration(
                      hintText: 'Add your steps',
                      contentPadding: EdgeInsets.all(10)),
                  autocorrect: true,
                  minLines: 10,
                  maxLines: 25,
                  controller: textController,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              Text(" "),
              Text(images),
              ElevatedButton(
                  onPressed: Select_Images, child: Icon(Icons.photo_library)),
            ],
          ),
        ),
      ),
    );
  }
}
