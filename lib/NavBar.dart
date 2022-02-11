import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:val_trash/UploadIdea.dart';
import 'TutorialScreen.dart';
import 'homepage.dart' as main;

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  var storage;
  var db;
  BoxDecoration box = BoxDecoration(color: Colors.green);
  String email = '';
  String name = '';
  String imageurl = '';
  bool login = false;
  List<List> completed = [];
  double height = 0;
  double width = 0;
  bool? complete = false;
  bool? pending = false;
  AutoSizeText text = AutoSizeText("");
  int ind = 0;
  List<String> progresslist = [];
  double navbarheight = 4;
  double photoheight = 2.5;
  Future getdata() async {
    var prefs = null;//change later
    setState(
      () {
        complete = prefs.getBool('completed');
        pending = prefs.getBool('pending');
        storage = FirebaseStorage.instance;
        db = FirebaseFirestore.instance;
        navbarheight = height / 3.4;
        photoheight = height / 2.5;
      },
    );
    if (pending == true) {
      List<String> proglist = prefs.getStringList('progresslist')!;
      setState(
        () {
          photoheight = height / 3;
          if (complete == true) {
            navbarheight = height / 3.8;
          }
          progresslist = proglist;
          ind = int.parse(
            progresslist[4],
          );
        },
      );
    }
    if (prefs.getBool('completed') == true) {
      /*List<String> empty = [];
      prefs.setStringList('completedlist', empty);*/
      List<String>? completedlist = prefs.getStringList('completedlist');

      //prefs.clear();
      List<List> lists = [];
      for (var list in completedlist!) {
        List split = list.split(',');
        lists.add(split);
      }
      lists = new List.from(lists.reversed);

      setState(
        () {
          photoheight = height / 3;
          completed = lists;
        },
      );
    }
    if (prefs.getBool('loggedin') == true) {
      setState(
        () {
          login = true;
          email = prefs.getString('email').toString();
          name = prefs.getString('name').toString();
          imageurl = prefs.getString('imageurl').toString();
          box = BoxDecoration(
              image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    imageurl,
                  ),
                  fit: BoxFit.cover));
          text = AutoSizeText(
            name,
            maxFontSize: 30,
            minFontSize: 23,
            style: GoogleFonts.openSans(color: Colors.black),
          );
        },
      );
    } else {
      setState(
        () {
          name = '';
          email = '';
          text = AutoSizeText(
            "Valuable Trash",
            minFontSize: 27,
            maxFontSize: 35,
          );
          login = false;
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Drawer(
      elevation: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: photoheight,
            child: UserAccountsDrawerHeader(
              decoration: box,
              accountName: AutoSizeText(
                "",
                maxFontSize: 30,
                minFontSize: 23,
                style: GoogleFonts.roboto(
                  color: Colors.black,
                ),
              ),
              accountEmail: text,
            ),
          ),
          SizedBox(
            height: navbarheight,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.home,
                    size: 35,
                    color: Colors.grey[800],
                  ),
                  title: AutoSizeText(
                    "Home",
                    maxFontSize: 30,
                    minFontSize: 20,
                    style: GoogleFonts.roboto(),
                  ),
                  onTap: () {
                    route() {
                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => main.MyHomePage(),
                        ),
                      );
                    }

                    startTime() async {
                      var duration = new Duration(seconds: 1);
                      var alert = AlertDialog(
                        content: SizedBox(
                          child: Center(child: CircularProgressIndicator()),
                          height: 50.0,
                          width: 50.0,
                        ),
                      );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                      return new Timer(duration, route);
                    }

                    route();
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.upload,
                    size: 35,
                    color: Colors.grey[800],
                  ),
                  title: AutoSizeText(
                    "Contribute",
                    maxFontSize: 30,
                    minFontSize: 20,
                    style: GoogleFonts.roboto(),
                  ),
                  onTap: () {
                    route() {
                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadIdea(),
                        ),
                      );
                    }

                    startTime() async {
                      var duration = new Duration(seconds: 1);
                      var alert = AlertDialog(
                        content: SizedBox(
                          child: Center(child: CircularProgressIndicator()),
                          height: 50.0,
                          width: 50.0,
                        ),
                      );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                      return new Timer(duration, route);
                    }

                    route();
                  },
                ),
                Divider(),
                ListTile(
                  autofocus: true,
                  leading: login == true
                      ? Icon(
                          Icons.logout,
                          size: 35,
                          color: Colors.grey[800],
                        )
                      : Icon(
                          Icons.login,
                          size: 35,
                          color: Colors.grey[800],
                        ),
                  title: login == true
                      ? AutoSizeText(
                          "Sign out",
                          maxFontSize: 30,
                          minFontSize: 20,
                          style: GoogleFonts.roboto(),
                        )
                      : AutoSizeText(
                          "Sign in",
                          maxFontSize: 30,
                          minFontSize: 20,
                          style: GoogleFonts.roboto(),
                        ),
                  onTap: () {
                    route() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => main.MyHomePage(
                            trylogin: true,
                          ),
                        ),
                      );
                    }

                    startTime() async {
                      var duration = new Duration(seconds: 1);
                      var alert = AlertDialog(
                        content: SizedBox(
                          child: Center(child: CircularProgressIndicator()),
                          height: 50.0,
                          width: 50.0,
                        ),
                      );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                      return new Timer(duration, route);
                    }

                    route();
                  },
                ),
                Divider(),
              ],
            ),
          ),
          pending == true
              ? SizedBox(
                  height: height / 22,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 16, 0, 0),
                      child: Text(
                        "Pending Tutorials",
                        style: TextStyle(fontSize: 19),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
          pending == true
              ? SizedBox(
                  height: height / 14,
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(7, 0, 0.5, 0),
                    minVerticalPadding: 0,
                    horizontalTitleGap: width / 40,
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TutorialPage(
                            label: progresslist[2],
                            db: db,
                            index: progresslist[3],
                            storage: storage,
                            title: progresslist[0],
                            imageurl: progresslist[1],
                            inprogress: true,
                            ind: ind,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: width / 17.5,
                      backgroundColor: Colors.white,
                      foregroundImage: CachedNetworkImageProvider(
                        progresslist[1],
                      ),
                    ),
                    title: Text(
                      progresslist[0],
                    ),
                    subtitle: LinearPercentIndicator(
                      padding: EdgeInsets.fromLTRB(2, 1, 10, 0),
                      progressColor: Colors.green,
                      percent: int.parse(
                            progresslist[4],
                          ) /
                          int.parse(
                            progresslist[5],
                          ),
                    ),
                  ),
                )
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
          pending == true
              ? complete == true
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : SizedBox(
                      width: 0,
                      height: 0,
                    )
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
          complete == true
              ? SizedBox(
                  height: height / 22,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 16, 0, 0),
                      child: Text(
                        "Completed Tutorials",
                        style: TextStyle(fontSize: 19),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
          complete == true
              ? SizedBox(
                  height: height / 4.3,
                  width: width,
                  child: ListView.builder(
                    itemExtent: height / 13.7,
                    padding: EdgeInsets.all(0),
                    itemCount: completed.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        contentPadding: EdgeInsets.fromLTRB(7, 1, 0.5, 1),
                        horizontalTitleGap: width / 40,
                        leading: CircleAvatar(
                          radius: width / 17.5,
                          backgroundColor: Colors.white,
                          foregroundImage: CachedNetworkImageProvider(
                            completed[i][2].toString(),
                          ),
                        ),
                        title: Text(
                          completed[i][1].toString(),
                        ),
                        subtitle: Text(
                          completed[i][0].toString(),
                        ),
                      );
                    },
                  ),
                )
              : SizedBox(
                  width: 0,
                  height: 0,
                ),
        ],
      ),
    );
  }
}
