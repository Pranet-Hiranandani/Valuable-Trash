import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:val_trash/Classify.dart';
import 'package:val_trash/NavBar.dart';
import 'TutorialScreen.dart' as tutorial;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'RecyclingCenter.dart';

class IdeaPage extends StatefulWidget {
  final String label;
  IdeaPage({Key? key, required this.label}) : super(key: key);

  @override
  _IdeaPageState createState() => _IdeaPageState();
}

class _IdeaPageState extends State<IdeaPage> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  var stream;
  String dropdownValue = "All";
  String dropdownValue1 = "Latest";
  bool descending = true;
  var img = CircleAvatar();
  String url = "";
  Future loadapp() async {
    Firebase.initializeApp();
    db = FirebaseFirestore.instance;
    setState(
      () {
        db = db;
      },
    );
  }

  Future refresh() async {}

  Future reclick_photo() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClassifyImage(recycle: false)),
    );
  }

  @override
  void initState() {
    super.initState();
    loadapp();
  }

  @override
  Widget build(context) {
    int color = 3;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Repurpose",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async => false,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(
                widget.label,
              )
              .orderBy(
                'id',
                descending: descending,
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else
              return Padding(
                padding: EdgeInsets.all(4),
                child: RefreshIndicator(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              12,
                              5,
                              5,
                              6,
                            ),
                            child: DropdownButton<String>(
                              value: dropdownValue,
                              elevation: 16,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                              underline: Container(
                                height: 2,
                                color: Colors.black,
                              ),
                              onChanged: (String? newValue) {
                                setState(
                                  () {
                                    dropdownValue = newValue!;
                                  },
                                );
                              },
                              items: <String>[
                                'All',
                                'Easy',
                                'Medium',
                                'Hard',
                              ].map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              15,
                              5,
                              5,
                              6,
                            ),
                            child: DropdownButton<String>(
                              hint: Text("Sort by"),
                              value: dropdownValue1,
                              elevation: 16,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                              underline: Container(
                                height: 2,
                                color: Colors.black,
                              ),
                              onChanged: (String? newValue) {
                                setState(
                                  () {
                                    dropdownValue1 = newValue!;
                                    if (newValue == 'Latest') {
                                      descending = true;
                                      refresh();
                                    }
                                    if (newValue == 'Oldest') {
                                      descending = false;
                                      refresh();
                                    }
                                  },
                                );
                              },
                              items: <String>['Latest', 'Oldest']
                                  .map<DropdownMenuItem<String>>(
                                (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: ListView(
                          children: snapshot.data!.docs.map(
                            (doc) {
                              var ind = doc.reference.id;
                              bool display = false;
                              String title = (doc)['title'].toString();
                              String difficulty =
                                  (doc)['difficulty'].toString();
                              String imageurl = doc['link'].toString();
                              List<Color> _colors = <Color>[
                                Colors.lightGreen,
                                Colors.yellow,
                                Colors.cyanAccent,
                                Colors.deepOrange,
                              ];
                              if (difficulty == "EASY") {
                                color = 0;
                              }
                              if (difficulty == "MEDIUM") {
                                color = 1;
                              }
                              if (difficulty == "HARD") {
                                color = 3;
                              }
                              Widget cards = Container(
                                width: 0.0,
                                height: 0.0,
                              );
                              Widget card = Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  horizontalTitleGap: 11,
                                  contentPadding: EdgeInsets.all(5),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: width / 15,
                                    foregroundImage: CachedNetworkImageProvider(
                                      imageurl,
                                    ),
                                  ),
                                  title: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    difficulty,
                                  ),
                                  tileColor: _colors[color],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            tutorial.TutorialPage(
                                          label: widget.label,
                                          db: db,
                                          index: ind,
                                          storage: storage,
                                          title: title,
                                          imageurl: imageurl,
                                          inprogress: false,
                                          ind: 0,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                              if (dropdownValue == "All") {
                                display = true;
                                cards = card;
                              }
                              if (difficulty == "EASY") {
                                color = 0;
                                if (dropdownValue == "Easy") {
                                  display = true;
                                  cards = card;
                                }
                              }
                              if (difficulty == "MEDIUM") {
                                color = 1;
                                if (dropdownValue == "Medium") {
                                  display = true;
                                  cards = card;
                                }
                              }
                              if (difficulty == "HARD") {
                                color = 3;
                                if (dropdownValue == "Hard") {
                                  display = true;
                                  cards = card;
                                }
                              }
                              String labels = widget.label;
                              return cards;
                            },
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                  onRefresh: refresh,
                ),
              );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: reclick_photo,
        tooltip: 'Reclick the image',
        child: Icon(
          Icons.camera_alt_rounded,
        ),
      ),
    );
  }
}
