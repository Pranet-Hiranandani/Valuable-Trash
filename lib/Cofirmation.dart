import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:val_trash/Alert.dart';
import 'package:val_trash/Classify.dart';
import 'package:val_trash/NavBar.dart';
import 'package:val_trash/Profile.dart';
import 'homepage.dart';

class ConfirmationPage extends StatefulWidget {
  final FirebaseStorage storage;
  final String title;
  final String imageurl;
  final bool inprogress;
  ConfirmationPage({
    Key? key,
    required this.storage,
    required this.title,
    required this.imageurl,
    required this.inprogress,
  }) : super(key: key);

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  bool confirm = false;
  bool visible1 = true;
  bool visible2 = false;
  String path = "";
  String name = "";
  bool login = false;
  String url = "";
  ByteData? _byteData;
  String filename = "";
  bool image = false;
  bool certificate = false;
  String imagefile = "";
  String urls = "";
  String photourl = "";
  double width = 1;
  double height = 1;
  String nameurl = "";
  ScreenshotController controller = ScreenshotController();
  ScreenshotController controller1 = ScreenshotController();
  var profilebox;
  var file;
  var alignment = MainAxisAlignment.start;
  GlobalKey key = GlobalKey();
  GlobalKey key1 = GlobalKey();
  late Uint8List byte;
  IconData photoicon = Icons.add_a_photo;

  Future confirmation() async {
    if (confirm == true) {
      final DateTime now = DateTime.now();
      String time = DateFormat('d/M/y h:mm a').format(now).toString();
      Map listtoadd = {
        "time": time,
        "title": widget.title,
        "imageurl": widget.imageurl,
        "verification": 0,
      };
      await Hive.openBox("completedlist");
      Box<dynamic> completedlist = Hive.box('completedlist');
      completedlist.put(completedlist.length, listtoadd);
      Box<dynamic> profile = Hive.box("profile");
      profile.put("completed", true);
      profile.put("pending", false);
      setState(
        () {
          profilebox = profile;
          visible1 = false;
          visible2 = true;
          certificate = true;
          alignment = MainAxisAlignment.center;
        },
      );
    }
  }

  Future share_image() async {
    final directory = await getApplicationDocumentsDirectory();
    File imag = File(filename);
    if (image == true) {
      byte = (await controller1.capture())!;
      await imag.writeAsBytes(
        byte,
      );
    }
    if (image == false) {
      byte = (await controller.capture())!;
      await imag.writeAsBytes(
        byte,
      );
    }
    Share.shareFiles([imag.path],
        text:
            "I creatively reused my waste using Valuable Trash, an AI powered smart app. Why don't you try it too?");
  }

  Future function() async {
    Directory dir = await getApplicationDocumentsDirectory();
    DateTime now = DateTime.now();
    String date = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    date = date + ".png";
    String pathName = p.join(dir.path, date);
    filename = pathName;
    var certificateurl =
        await widget.storage.ref("Certificates/1.png").getDownloadURL();
    var certificatenameurl =
        await widget.storage.ref("Certificates/0.png").getDownloadURL();
    var certificatephotourl =
        await widget.storage.ref("Certificates/2.png").getDownloadURL();
    setState(
      () {
        profilebox = Hive.box('profile');
        file = File(pathName);
        urls = certificateurl;
        nameurl = certificatenameurl;
        photourl = certificatephotourl;
        if (profilebox.get('loggedin') == true) {
          name = profilebox.get('name');
          login = true;
          url = nameurl;
        } else {
          name = "";
          login = false;
          url = urls;
        }
      },
    );
  }

  Future get_image() async {
    XFile? images;
    var alert = Alert(
      content: "Where would you like to select the image from?",
      button1func: () async {
        Navigator.of(context, rootNavigator: true).pop();
        images = await ImagePicker().pickImage(source: ImageSource.camera);
        setState(
          () {
            certificate = false;

            image = true;
            imagefile = images!.path;
          },
        );
      },
      button1child: Icon(
        Icons.photo_camera,
        size: 30,
      ),
      button2child: Icon(Icons.photo_library),
      button2func: () async {
        Navigator.of(context, rootNavigator: true).pop();
        images = await ImagePicker().pickImage(source: ImageSource.gallery);
        setState(
          () {
            certificate = false;
            image = true;
            imagefile = images!.path;
            photoicon = Icons.hide_image;
          },
        );
      },
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    function();
  }

  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: widget.inprogress == false
            ? AppBar(
                automaticallyImplyLeading: false,
                title: Text(
                  "Repurpose",
                  style: TextStyle(fontSize: 24),
                ),
              )
            : AppBar(
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_back_rounded),
                ),
                title: Text(
                  "Repurpose",
                  style: TextStyle(fontSize: 24),
                ),
              ),
        body: Center(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: alignment,
                children: [
                  Visibility(
                    visible: visible1,
                    child: Text(
                      " ",
                    ),
                  ),
                  Visibility(
                    visible: visible1,
                    child: Text(
                      "We Require you to Confirm the Following",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 23),
                    ),
                  ),
                  Visibility(
                    visible: visible1,
                    child: Text(" "),
                  ),
                  Visibility(
                    visible: visible1,
                    child: Container(
                      width: width,
                      child: Card(
                        child: ListTile(
                          title: Text(
                            "I heareby confirm that I have reused my waste using Valuable Trash",
                          ),
                          trailing: Checkbox(
                            value: confirm,
                            onChanged: (bool? value) {
                              setState(
                                () {
                                  confirm = value!;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: visible1,
                    child: Text(" "),
                  ),
                  Visibility(
                    visible: visible1,
                    child: ElevatedButton(
                      onPressed: confirmation,
                      child: Text("Proceed"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: Visibility(
                      visible: certificate,
                      child: Center(
                        child: Screenshot(
                          controller: controller,
                          child: SizedBox(
                            height: height / 3.15,
                            width: width,
                            child: Stack(
                              children: [
                                url != ""
                                    ? Center(
                                        child: CachedNetworkImage(
                                          imageUrl: url,
                                          width: width,
                                          height: height / 3.15,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                Container(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Text(
                                        name,
                                        style: GoogleFonts.bebasNeue(
                                          fontSize: 35,
                                          color:
                                              Color.fromRGBO(30, 104, 111, 1),
                                        ),
                                      ),
                                    ),
                                    height: height / 5.2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: image,
                    child: Padding(
                      padding: EdgeInsets.all(1),
                      child: Center(
                        child: Screenshot(
                          controller: controller1,
                          child: SizedBox(
                            height: height / 3.15,
                            width: width,
                            child: Stack(
                              children: [
                                photourl != ""
                                    ? Center(
                                        child: CachedNetworkImage(
                                          imageUrl: photourl,
                                          width: width,
                                          height: height / 3.15,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      )
                                    : CircularProgressIndicator(),
                                Center(
                                  child: SizedBox(
                                    width: width * 0.95,
                                    height: height / 3.35,
                                    child: Align(
                                      child: Image.file(
                                        File(imagefile),
                                        height: height / 5.5,
                                        width: width * 0.425,
                                      ),
                                      alignment: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Visibility(
                      visible: visible2,
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Center(
                                child: ButtonBar(
                                  buttonPadding:
                                      EdgeInsets.fromLTRB(30, 0, 30, 0),
                                  alignment: MainAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      onPressed: () {
                                        if (image == false) {
                                          get_image();
                                        }
                                        if (image == true) {
                                          setState(
                                            () {
                                              certificate = true;
                                              image = false;
                                              photoicon = Icons.add_a_photo;
                                            },
                                          );
                                        }
                                      },
                                      child: Icon(photoicon),
                                    ),
                                    FloatingActionButton(
                                      onPressed: share_image,
                                      child: Icon(Icons.share),
                                    ),
                                    FloatingActionButton(
                                      onPressed: () async {
                                        await [Permission.storage].request();
                                        var bytes = Uint8List(2);
                                        if (image == true) {
                                          bytes =
                                              (await controller1.capture())!;
                                        }
                                        if (image == false) {
                                          bytes = (await controller.capture())!;
                                        }
                                        DateTime now = DateTime.now();
                                        String date =
                                            DateFormat('kk-mm-ss \n EEE d MMM')
                                                .format(now);
                                        if (bytes != Uint8List(2)) {
                                          final result =
                                              await ImageGallerySaver.saveImage(
                                                  bytes,
                                                  name: date);
                                          if (result['isSuccess']) {
                                            var alert = SnackBar(
                                              content: Text(
                                                "The Certificate was Saved!",
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(alert);
                                          } else {
                                            var alert = SnackBar(
                                              content: Text(
                                                "There was an error in saving the image",
                                              ),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(alert);
                                          }
                                        }
                                      },
                                      child: Icon(Icons.save),
                                    ),
                                    widget.inprogress == false
                                        ? FloatingActionButton(
                                            child: Icon(Icons.camera_alt),
                                            tooltip: "Repurpose your Waste",
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ClassifyImage(
                                                    recycle: false,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : SizedBox(
                                            width: 0,
                                            height: 0,
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
