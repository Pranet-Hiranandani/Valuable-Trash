import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:line_icons/line_icons.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:val_trash/TabNavigator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home.dart';
import 'IdeaScreen.dart';
import 'TutorialScreen.dart';
import 'RecyclingCenter.dart';
import 'UploadIdea.dart';
import 'NavBar.dart';

class MyHomePage extends StatefulWidget {
  var trylogin;
  MyHomePage({
    Key? key,
    this.trylogin,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var google_sign_in = GoogleSignIn();
  var init = Firebase.initializeApp();
  ImageLabeler imageLabeler = GoogleMlKit.vision.imageLabeler();
  late Box<dynamic> pagebox;
  int index = -1;
  double confidence = 0;
  String labeltext = "Click an image of the waste that you'd like to reuse";
  String result134 = "";
  String logins = "Sign into Valuable Trash";
  String email = "";
  String name = "";
  var _image;
  String path = "";
  String imageurl = "";
  bool button = false;
  bool recycle = false;
  bool login = false;
  final screens = [
    MyHomePage(),
    UploadIdea(),
  ];
  int currentindex = 0;
  IconData loggedin = Icons.login;
  var user;
  late FirebaseAuth auth;
  late FirebaseFirestore db;
  String _currentPage = "Home";
  List<String> pageKeys = [
    "Home",
    "Reuse",
    "Recycle",
    "ProfilePage",
  ];
  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Home": GlobalKey<NavigatorState>(),
    "Reuse": GlobalKey<NavigatorState>(),
    "Recycle": GlobalKey<NavigatorState>(),
    "ProfilePage": GlobalKey<NavigatorState>(),
  };
  int _selectedIndex = 0;

  get key => null;

  void _selectTab(String tabItem, int index) {
    /*if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]?.currentState?.popUntil(
            (route) => route.isFirst,
          );
    } else {*/
      setState(
        () {
          _currentPage = pageKeys[index];
          _selectedIndex = index;
        },
      );
  }

  Future loadModel() async {
    //Tflite.close();
    await Hive.initFlutter();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await Hive.openBox('profile');
    await Hive.openBox('progresslist');
    await Hive.openBox('completedlist');
    pagebox = await Hive.openBox("page");
    pagebox.put("page", 0);
    changepage();
  }

  void changepage() {
    if (pagebox.get("page") != _selectedIndex) {
      _selectTab(
        pageKeys[pagebox.get("page")],
        pagebox.get("page"),
      );
      setState(
        () {
          _selectedIndex = pagebox.get("page");
        },
      );
    }
    new Future.delayed(
      new Duration(milliseconds: 100),
      () async {
        changepage();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentPage]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentPage != "Home") {
            _selectTab("Home", 0);
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 37,
          enableFeedback: true,
          currentIndex: _selectedIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedLabelStyle: TextStyle(
            color: Colors.black,
          ),
          selectedLabelStyle: TextStyle(
            color: Colors.green,
          ),
          elevation: 5,
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (value) async {
            if (value != _selectedIndex) {
              await pagebox.put('page', value);
              _selectTab(pageKeys[value], value);
            }
          },
          items: [
            BottomNavigationBarItem(
              tooltip: "Home Screen",
              label: "Home",
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              tooltip: "Repurpose your Waste",
              label: "Repurpose",
              icon: Icon(
                Icons.restore_from_trash_rounded,
                //color: Colors.grey[800],
              ),
            ),
            BottomNavigationBarItem(
              tooltip: "Locate a Recycling Center",
              label: "Recycle",
              icon: Icon(Icons.location_on_sharp),
            ),
            BottomNavigationBarItem(
              tooltip: "Profile and Settings Menu",
              label: "Profile",
              icon: Icon(Icons.person_rounded),
            ),
          ],
        ),
        /*appBar: AppBar(
          title: Text(
            "Valuable Trash",
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        ),*/
        body: Stack(
          children: <Widget>[
            _buildOffstageNavigator("Home"),
            _buildOffstageNavigator("Reuse"),
            _buildOffstageNavigator("Recycle"),
            _buildOffstageNavigator("ProfilePage"),
          ],
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem]!,
        tabItem: tabItem,
      ),
    );
  }
}
