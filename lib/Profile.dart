import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:val_trash/Alert.dart';
import 'package:val_trash/TutorialScreen.dart';
import 'package:val_trash/UploadIdea.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool login = false;
  String imageurl =
      "https://icon-library.com/images/default-profile-icon/default-profile-icon-16.jpg";
  String email = "";
  String name = "";
  var db;
  var storage;
  var google_sign_in = GoogleSignIn();
  List<List> completed = [];
  int ind = 0;
  Map progresslist = {};
  late GoogleSignInAccount? user;
  var auth;
  var profilebox;
  late Box<dynamic> completedbox;
  int completedboxlength = 0;
  double completedheight = 1;
  double width = 1;
  double height = 1;
  bool pending = false;
  bool complete = false;
  MainAxisAlignment alignment = MainAxisAlignment.center;
  Future log_in() async {
    user = await google_sign_in.signIn().catchError(
      (e) {
        print(
          e.toString(),
        );
        var alert = SnackBar(
          content: Text(
            "There was an Error with Signing You In",
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(alert);
      },
    );
    if (user != null) {
      auth = FirebaseAuth.instance;
      final GoogleSignInAuthentication googleSignInAuthentication =
          await user!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential userCredential =
          await auth.signInWithCredential(credential).catchError(
        (e) {
          print(
            e.toString(),
          );
          var alert = SnackBar(
            content: Text(
              "There was an Error with Signing You In",
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(alert);
        },
      );
      profilebox.put("email", user!.email);
      profilebox.put(
        "name",
        user!.displayName!,
      );
      profilebox.put(
        "imageurl",
        user!.photoUrl!,
      );
      profilebox.put("loggedin", true);
      CollectionReference data = FirebaseFirestore.instance.collection("Users");
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      data.doc(user!.email).set(
        {
          "imageurl": user!.photoUrl,
          "name": user!.displayName,
          "points": 0,
          "email": user!.email,
          "messaging_token": token,
        },
      );
      setState(
        () {
          imageurl = user!.photoUrl!;
          email = user!.email;
          name = user!.displayName!;
          login = true;
        },
      );
      var nam = user!.displayName;
      var alert = Alert(
        content:
            "Welcome $nam, its great to see that you're making an effort to reduce your carbon footprint by repurposing and recycling your waste.",
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
  }

  Future logout() async {
    var alert = Alert(
        content: "Confirm to Sign out from $email",
        button1func: () async {
          await google_sign_in.signOut();
          Navigator.of(context, rootNavigator: true).pop();
          profilebox.delete("email");
          profilebox.delete("name");
          profilebox.delete("imageurl");
          profilebox.put("loggedin", false);
          setState(
            () {
              login = false;
              imageurl =
                  "https://icon-library.com/images/default-profile-icon/default-profile-icon-16.jpg";
            },
          );
        },
        button1child: Icon(Icons.done));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future load() async {
    await Hive.initFlutter();
    await Hive.openBox('profile');
    await Hive.openBox('completedlist');
    await Hive.openBox('progresslist');
    if (Hive.box('profile').containsKey('loggedin') == false) {
      Box<dynamic> box = await Hive.openBox('profile');
      box.put('loggedin', false);
      box.put('completed', false);
      box.put('pending', false);
    }
    setState(
      () {
        profilebox = Hive.box("profile");
        if (profilebox.get("loggedin") == true) {
          imageurl = profilebox.get('imageurl');
          name = profilebox.get('name');
          email = profilebox.get('email');
        }
        login = profilebox.get('loggedin');
        storage = FirebaseStorage.instance;
        db = FirebaseFirestore.instance;
        if (login == false) {
          imageurl =
              "https://icon-library.com/images/default-profile-icon/default-profile-icon-16.jpg";
        }
      },
    );
    check();
  }

  Future check() async {
    if (profilebox != null) {
      setState(() {
        pending = profilebox.get('pending');
      });
      if (profilebox.get('pending')! == true) {
        Box<dynamic> pendingbox = Hive.box("progresslist");
        Map proglist = pendingbox.get(0);
        setState(
          () {
            progresslist = proglist;
            ind = int.parse(
              progresslist['index'],
            );
            pending = true;
            alignment = MainAxisAlignment.start;
          },
        );
      }
      if (profilebox.get('completed') == true) {
        /*List<String> empty = [];
      prefs.setStringList('completedlist', empty);*/
        setState(
          () {
            completedbox = Hive.box('completedlist');
            alignment = MainAxisAlignment.start;
            complete = true;
            completedboxlength = completedbox.length;
            if (completedboxlength == 1) {
              completedheight = height / 11.5;
            }
            if (completedboxlength == 2) {
              completedheight = height / 6;
            }
            if (completedboxlength >= 3) {
              completedheight = height / 4.3;
            }
          },
        );
      }
    }
    new Future.delayed(
      new Duration(milliseconds: 2000),
      () async {
        check();
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
    check();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: load,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: SizedBox(
                    width: width / 3,
                    height: width / 3,
                    child: CircleAvatar(
                      onForegroundImageError: (exception, stackTrace) {
                        print(exception);
                      },
                      foregroundImage: CachedNetworkImageProvider(
                        imageurl,
                      ),
                    ),
                  ),
                ),
                login == true
                    ? Padding(
                        padding: EdgeInsets.all(2),
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(2),
                        child: Text(
                          "User",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                login == true
                    ? Padding(
                        padding: EdgeInsets.all(2),
                        child: Text(
                          email,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 0,
                        height: 0,
                      ),
                Padding(
                  padding: EdgeInsets.fromLTRB(3, 4, 3, 4),
                  child: InkWell(
                    onTap: () {
                      if (login == true) {
                        logout();
                      } else {
                        log_in();
                      }
                    },
                    child: SizedBox(
                      height: height / 13,
                      width: width / 2.25,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            login == true
                                ? Icon(
                                    Icons.logout_rounded,
                                    size: height / 20,
                                    color: Colors.black,
                                  )
                                : Icon(
                                    Icons.login_rounded,
                                    size: height / 20,
                                    color: Colors.black,
                                  ),
                            Text("   "),
                            login == true
                                ? Text(
                                    "Sign Out",
                                    style: TextStyle(
                                        fontSize: 21, color: Colors.black),
                                  )
                                : Text(
                                    "Sign in",
                                    style: TextStyle(
                                        fontSize: 21, color: Colors.black),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                pending == true
                    ? Card(
                        elevation: 5,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
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
                            ),
                            SizedBox(
                              height: height / 14,
                              child: ListTile(
                                contentPadding:
                                    EdgeInsets.fromLTRB(7, 0, 0.5, 0),
                                minVerticalPadding: 0,
                                horizontalTitleGap: width / 40,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TutorialPage(
                                        label: progresslist['label'],
                                        db: db,
                                        index: progresslist['index'],
                                        storage: storage,
                                        title: progresslist['title'],
                                        imageurl: progresslist['imageurl'],
                                        inprogress: true,
                                        ind: int.parse(
                                            progresslist['currentstep']),
                                      ),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  radius: width / 17.5,
                                  backgroundColor: Colors.white,
                                  foregroundImage: CachedNetworkImageProvider(
                                    progresslist['imageurl'],
                                  ),
                                ),
                                title: Text(
                                  progresslist['title'],
                                ),
                                subtitle: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 15, 1),
                                  child: StepProgressIndicator(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    totalSteps:
                                        int.parse(progresslist['steps']),
                                    currentStep:
                                        int.parse(progresslist["currentstep"]),
                                    selectedColor: Colors.green,
                                    unselectedColor: Colors.grey,
                                    size: 6,
                                    roundedEdges: Radius.circular(2.5),
                                  ),
                                ),
                              ),
                            ),
                            Text(" ")
                          ],
                        ),
                      )
                    : SizedBox(
                        width: 0,
                        height: 0,
                      ),
                Card(
                  elevation: 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                          ? Center(
                              child: SizedBox(
                                height: height / 12,
                                width: width,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemExtent: height / 13.7,
                                  padding: EdgeInsets.all(0),
                                  itemCount: completedboxlength,
                                  itemBuilder: (context, i) {
                                    Map map = completedbox.get(0);
                                    return ListTile(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(7, 1, 0.5, 1),
                                      horizontalTitleGap: width / 40,
                                      leading: CircleAvatar(
                                        radius: width / 17.5,
                                        backgroundColor: Colors.white,
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                          map['imageurl'],
                                        ),
                                      ),
                                      title: Text(
                                        map['title'],
                                      ),
                                      subtitle: Text(
                                        map['time'],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : SizedBox(
                              width: 0,
                              height: 0,
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
