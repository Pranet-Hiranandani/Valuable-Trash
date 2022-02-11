import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:val_trash/Article.dart';
import 'package:val_trash/Classify.dart';
import 'package:val_trash/Profile.dart';
import 'package:val_trash/UploadIdea.dart';
import 'package:val_trash/homepage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FixedExtentScrollController fixedExtentScrollController =
      FixedExtentScrollController();
  double width = 200;
  double height = 200;
  List<Widget> articles = [];
  List<Widget> tips = [];
  int _current = 0;
  String name = "";
  List tipstext = [];
  String tip = "";
  int docs = 0;
  bool loggedin = false;
  late QuerySnapshot docref;
  late Stream<QuerySnapshot<Object?>> docdata;
  late Box<dynamic> pagebox;
  var db;

  Future load() async {
    await Hive.initFlutter();
    await Hive.openBox('profile');
    if (Hive.box('profile').containsKey('loggedin') == false) {
      Box<dynamic> box = await Hive.openBox('profile');
      box.put('loggedin', false);
      box.put('completed', false);
      box.put('pending', false);
    }
    WidgetsFlutterBinding.ensureInitialized();
    var init = await Firebase.initializeApp();
    db = FirebaseFirestore.instance;
    await db.collection('Tips').get().then(
      (QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach(
          (doc) {
            setState(
              () {
                List texts = doc['0'];
                tip = texts[0];
                tipstext = texts.sublist(1);
                articles = [];
                _current = 0;
              },
            );
          },
        );
      },
    );
    await db.collection('Articles').get().then(
      (QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach(
          (doc) {
            articles.add(
              Card(
                elevation: 6,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticlePage(
                          url: doc['article'],
                        ),
                      ),
                    );
                  },
                  child: SizedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: CachedNetworkImage(
                              imageUrl: doc['image'],
                              progressIndicatorBuilder:
                                  (context, url, progress) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(4, 0, 4, 4),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              doc['headline'],
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    tipstext.shuffle();
    articles.shuffle();
    Box<dynamic> profilebox = Hive.box("profile");
    await Hive.openBox('page');
    setState(
      () {
        pagebox = Hive.box('page');
        loggedin = profilebox.get('loggedin')!;
        if (loggedin == true) {
          var nam = profilebox.get('name')!;
          var split = nam.split(" ");
          name = split[0];
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    tips = [
      for (String tip in tipstext)
        SizedBox(
          width: width / 2,
          height: height / 4.5,
          child: Card(
            elevation: 4,
            color: Colors.green,
            child: Padding(
              padding: EdgeInsets.all(
                8,
              ),
              child: Center(
                child: Text(
                  tip,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => load(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              loggedin == true
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 6, 8, 2),
                          child: RichText(
                            text: TextSpan(
                              style: new TextStyle(
                                fontSize: 22.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(text: 'Hi '),
                                new TextSpan(
                                  text: name,
                                  style: new TextStyle(
                                    color: Colors.green[800],
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    )
                  : SizedBox(
                      width: 0,
                      height: 0,
                    ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 8,
                          top: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Top Picks for You",
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      articles.length != 0
                          ? Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8, 0, 8, 1),
                                  child: Container(
                                    height: height / 3,
                                    child: CarouselSlider(
                                      options: CarouselOptions(
                                        autoPlayInterval: Duration(seconds: 10),
                                        autoPlay: true,
                                        enlargeCenterPage: true,
                                        aspectRatio: 1.5,
                                        onPageChanged: (index, reason) {
                                          setState(
                                            () {
                                              _current = index;
                                            },
                                          );
                                        },
                                      ),
                                      items: articles,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (var i in articles)
                                      Container(
                                        height: 12.0,
                                        width: 12.0,
                                        margin: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              (Theme.of(context).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black)
                                                  .withOpacity(
                                            _current == articles.indexOf(i)
                                                ? 0.8
                                                : 0.3,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            )
                          : Padding(
                              padding: EdgeInsets.all(15),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: SizedBox(
                  height: height / 3.5,
                  width: width,
                  child: Card(
                    elevation: 5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Quick Actions",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () async {
                                  pagebox.put('page', 1);
                                  /*Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ClassifyImage(recycle: false),
                                    ),
                                  );*/
                                },
                                child: SizedBox(
                                  height: height / 9,
                                  width: width / 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.restore_from_trash_rounded,
                                        size: height / 17,
                                      ),
                                      Text(
                                        "Repurpose",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                "       ",
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  pagebox.put("page", 2);
                                },
                                child: SizedBox(
                                  height: height / 9,
                                  width: width / 4,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(2, 0, 2, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: height / 18,
                                        ),
                                        Text(
                                          "Recycle",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UploadIdea(),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  height: height / 9,
                                  width: width / 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.upload,
                                        size: height / 17,
                                      ),
                                      Text(
                                        "Contribute",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                "       ",
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  pagebox.put("page", 3);
                                },
                                child: SizedBox(
                                  height: height / 9,
                                  width: width / 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: height / 17,
                                      ),
                                      Text(
                                        "Profile",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: SizedBox(
                  width: width,
                  height: height / 3.5,
                  child: Card(
                    elevation: 5,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Tip of the Week",
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        tipstext.length != 0
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: width / 2.5,
                                    height: height / 4.5,
                                    child: Card(
                                      elevation: 4,
                                      color: Colors.green,
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          8,
                                        ),
                                        child: Center(
                                          child: Text(
                                            tip,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: width / 1.8,
                                    height: height / 4.5,
                                    child: CarouselSlider(
                                      items: tips,
                                      options: CarouselOptions(
                                        autoPlay: false,
                                        enlargeCenterPage: true,
                                        aspectRatio: 0.8,
                                        viewportFraction: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: EdgeInsets.all(15),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
