import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:val_trash/Alert.dart';
import 'package:val_trash/IdeaScreen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'Cofirmation.dart';

class TutorialPage extends StatefulWidget {
  final String label;
  final String index;
  final FirebaseFirestore db;
  final FirebaseStorage storage;
  final String title;
  final String imageurl;
  final bool inprogress;
  final int ind;
  TutorialPage({
    Key? key,
    required this.label,
    required this.index,
    required this.db,
    required this.storage,
    required this.title,
    required this.imageurl,
    required this.inprogress,
    required this.ind,
  }) : super(key: key);

  @override
  _TutorialPageState createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  int steps = 0;
  int images = 0;
  int currentimage = 0;
  int currentstep = 1;
  List stepslist = [];
  String imageurl = "";
  String text = "";
  double width = 1;
  double height = 1;
  bool multiple_images = false;
  bool multiple_steps = false;
  String label = "";
  IconData button_icon = Icons.arrow_forward_sharp;
  bool done = false;
  bool backbutton = false;
  String certificateurl = "";
  String certificatenameurl = "";
  String certificatephotourl = "";
  String source = "";
  List<String> imageurls = [];
  bool back = true;
  GlobalKey key = GlobalKey();

  Future settext(currentsteps) async {
    int ind = currentsteps + 1;
    Map list = {
      "title": widget.title,
      "imageurl": widget.imageurl,
      "label": widget.label,
      "index": widget.index,
      "currentstep": currentstep.toString(),
      "steps": steps.toString(),
    };
    Box<dynamic> profilebox = Hive.box("profile");
    profilebox.put("pending", true);
    Hive.openBox("progresslist");
    Box<dynamic> progresslist = Hive.box("progresslist");
    progresslist.put(0, list);
    setState(
      () {
        if (currentstep >= 2) {
          if (widget.inprogress == true) {
            back = true;
          } else {
            back = false;
          }
        }
        if (currentsteps == steps) {
          text = stepslist[ind].toString();
          button_icon = Icons.done;
          done = true;
          if (currentsteps > steps) {
            print("");
          }
        } else {
          text = stepslist[ind].toString();
          if (currentsteps != steps) {
            button_icon = Icons.arrow_forward_sharp;
            done = false;
          }
        }
      },
    );
  }

  Future setimage(currentimages) async {
    String downloadURL = "";
    String ref = widget.label +
        "/" +
        widget.index +
        "/" +
        currentimages.toString() +
        ".jpg";
    if (currentimages > steps) {
      print("");
    } else {
      downloadURL = await widget.storage.ref(ref).getDownloadURL();
    }
    setState(
      () {
        if (currentimages == steps) {
          print("");
        } else {
          imageurl = downloadURL;
        }
      },
    );
  }

  loadfirebase() async {
    label = widget.label;
    if (label == "Medium Size Plastic Bottle") {
      // Slight error in naming on firebase
      label = "Medium Plastic Bottle";
    }
    if (label == "Large Size Plastic Bottle") {
      // Slight error in naming on firebase
      label = "Large Plastic Bottle";
    }
    if (label == "Plastic Cutlery") {
      // Slight error in naming on firebase
      label = "Cutlery";
    }
    var snapshot = await widget.db.collection("Info").doc(label).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    List steplist = List.from(data[widget.index]);
    var step = steplist[0].toString();
    var image = steplist[1].toString();
    steps = int.parse(step);
    var snapshot1 =
        await widget.db.collection(widget.label).doc(widget.index).get();
    Map<String, dynamic> data1 = snapshot1.data() as Map<String, dynamic>;
    // for (int i = 0; i < int.parse(image);) {
    //   String ref =
    //       widget.label + "/" + widget.index + "/" + i.toString() + ".jpg";
    //   String link = await widget.storage.ref(ref).getDownloadURL();
    //   imageurls.add(link.toString());
    //   i = i + 1;
    // }
    //print(imageurls.length);
    //print(image);
    setState(
      () {
        label = label;
        source = data1['source'];
        if (step == "") {
          var alert = Alert(
            content:
                "There was an error with loading your tutorial. Please try again later.",
            button1func: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            button1child: Text("OK"),
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
        steps = int.parse(step);
        images = int.parse(image);
        stepslist = steplist;
        currentimage = 0;
        currentstep = 1;
        if (images > 1) {
          multiple_images = true;
        } else {
          multiple_images = false;
        }
        if (steps > 1) {
          multiple_steps = true;
        } else {
          multiple_steps = false;
        }
        if (widget.inprogress == true) {
          currentimage = widget.ind - 1;
          currentstep = widget.ind;
          if (multiple_images == false) {
            currentimage = 0;
          }
        }
        setimage(currentimage);
        settext(currentstep);
      },
    );
  }

  void back_button()  {
    setState(
      () {
        if (currentimage >= 1) {
          currentimage = currentimage - 1;
          setimage(currentimage);
        }
        if (currentstep > 1) {
          currentstep = currentstep - 1;
          settext(currentstep);
        }else{
          print("null");
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadfirebase();
  }

  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: key,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          "Repurpose",
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async => back,
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  imageurl != ""
                      ? CachedNetworkImage(
                          imageUrl: imageurl,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                        )
                      : CircularProgressIndicator(),
                  Text(
                    "   ",
                    style: TextStyle(fontSize: 6),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Source: $source",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    " ",
                    style: TextStyle(
                      fontSize: 4,
                    ),
                  ),
                  Text(
                    text,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: new ButtonBar(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: currentstep > 1 ? back_button : null,
                          child: Icon(Icons.arrow_back_sharp),
                        ),
                        ElevatedButton(
                          child: Icon(button_icon),
                          onPressed: () {
                            setState(
                              () {
                                if (done == false) {
                                  if (multiple_images == true) {
                                    if (currentimage < images) {
                                      currentimage = currentimage + 1;
                                      setimage(currentimage);
                                    }
                                  }
                                  if (multiple_steps == true) {
                                    if (currentstep < steps) {
                                      currentstep = currentstep + 1;
                                      settext(currentstep);
                                    }
                                  }
                                } else if (done == true) {
                                  var alert = Alert(
                                    content: "Have you completed the tutorial?",
                                    button1func: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ConfirmationPage(
                                            inprogress: widget.inprogress,
                                            storage: widget.storage,
                                            title: widget.title,
                                            imageurl: widget.imageurl,
                                          ),
                                        ),
                                      );
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
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  steps != 0
                      ? Padding(
                          child: SizedBox(
                            width: width / 1.5,
                            child: StepProgressIndicator(
                              totalSteps: steps,
                              currentStep: currentstep,
                              selectedColor: Colors.green,
                              unselectedColor: Colors.grey,
                              size: 6,
                              roundedEdges: Radius.circular(2.5),
                            ),
                          ),
                          padding: EdgeInsets.all(0),
                        )
                      : Text(""),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
