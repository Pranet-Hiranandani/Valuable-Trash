import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:val_trash/Alert.dart';
import 'package:val_trash/IdeaScreen.dart';
import 'package:val_trash/Profile.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:val_trash/RecyclingCenter.dart';

class ClassifyImage extends StatefulWidget {
  bool recycle;
  ClassifyImage({Key? key, required this.recycle}) : super(key: key);

  @override
  _ClassifyImageState createState() => _ClassifyImageState();
}

class _ClassifyImageState extends State<ClassifyImage> {
  String result134 = "";
  var _image;
  String path = "";
  int index = -1;
  double confidence = 0;
  ImageLabeler imageLabeler = GoogleMlKit.vision.imageLabeler();
  bool alert = true;
  bool loading = true;
  double height = 0;
  double width = 0;
  String object = "";
  bool result = false;
  IconData icon = Icons.info;
  Future getimage(ImageSource imageSource) async {
    final picker = ImagePicker();
    var image = await picker.pickImage(
      source: imageSource,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image != null) {
      classifyImage(image.path);
      setState(
        () {
          alert = false;
          loading = true;
        },
      );
    }
    setState(
      () {
        if (image != null) {
          path = image.path;
          _image = File(path);
        }
      },
    );
  }

  Future loadModel() async {
    //Tflite.close();
    WidgetsFlutterBinding.ensureInitialized();
    final options = CustomImageLabelerOptions(
        customModel: CustomLocalModel.asset,
        customModelPath: 'flutter_assets/assets/tflite/model.tflite',
        confidenceThreshold: 0.5);
    imageLabeler = await GoogleMlKit.vision.imageLabeler(options);
    imageLabeler.close();
    /*var loading = await Tflite.loadModel(
      model: 'assets/tflite/model_unquant.tflite',
      labels: 'assets/tflite/labels(2).txt',
    );*/
  }

  Future classifyImage(paths) async {
    List<ImageLabel> label;
    final inputImage = InputImage.fromFilePath(paths);
    if (inputImage != null) {
      label = await imageLabeler.processImage(inputImage);
      if (label.length == 0) {
        var alert = Alert(
          content:
              "We couldn't detect any waste materials. Please try changing the angle and reclick the image.",
          button1func: () {
            Navigator.of(context, rootNavigator: true).pop();
            getimage(ImageSource.camera);
          },
          button1child: Icon(
            Icons.photo_camera,
            size: 30,
          ),
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
      for (ImageLabel label in label) {
        final int inde = label.index;
        final double confidenc = label.confidence;
        List<String> labels = [];
        await rootBundle.loadString('assets/tflite/modellabels.txt').then(
          (q) {
            for (String i in LineSplitter().convert(q)) {
              labels.add(i);
            }
          },
        );
        setState(
          () {
            index = inde;
            confidence = confidenc;
            result134 = "${labels[inde]}";
            loading = false;
            result = true;
            if (result134 == "Medium Size Plastic Bottle") {
              object = "Plastic Bottle";
            }
            if (result134 == "Large Size Plastic Bottle") {
              object = "Plastic Bottle";
            }
            if (result134 == "Small Plastic Bottle") {
              object = "Plastic Bottle";
            }
            if (result134 == "Plastic Bag") {
              object = "Plastic Bag";
              icon = Icons.shopping_bag;
            }
            if (result134 == "Plastic Glass") {
              object = "Plastic Glass";
              icon = Icons.local_drink;
            }
            if (result134 == "Soda Can") {
              object = "Soda Can";
            }
            if (result134 == "Rectangular Plastic Box") {
              object = "Plastic Box";
              icon = Icons.check_box_outline_blank_rounded;
            }
            if (result134 == "Plastic Cutlery") {
              object = "Plastic Cutlery";
            }
            if (result134 == "Circular Plastic Box") {
              object = "Plastic Box";
              icon = Icons.check_box_outline_blank_rounded;
            }
          },
        );
      }
    } else {
      print("Image is null");
    }
    /*var result = await Tflite.runModelOnImage(
      path: paths,
      numResults: 9,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print(result);
    if (result != null) {
      String label = "${result[0]["label"]}";
      print(label);
    }*/
  }

  void initState() {
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: widget.recycle == false
            ? Text(
                "Repurpose",
                style: TextStyle(
                  fontSize: 24,
                ),
              )
            : Text(
                "Recycle",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
      ),
      body: Stack(
        children: [
          Visibility(
              visible: result,
              child: Alert(
                content:
                    "A $object has been detected. Would you like to proceed or re-take the image?",
                button1func: () {
                  setState(
                    () {
                      result = false;
                      alert = true;
                    },
                  );
                },
                button1child: Icon(
                  Icons.photo_camera,
                  size: 30,
                ),
                button2func: () {
                  if (widget.recycle == false) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IdeaPage(label: result134),
                      ),
                    );
                  }
                  if (widget.recycle == true) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecylingCenter(label: result134),
                      ),
                    );
                  }
                },
                button2child: Icon(
                  Icons.done,
                  size: 30,
                ),
              )),
          Visibility(
            visible: loading,
            child: Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                ),
              ),
            ),
          ),
          Visibility(
              visible: alert,
              child: Alert(
                content:
                    "Please make sure that you click a clear image of the waste material.",
                button1func: () {
                  getimage(ImageSource.camera);
                },
                button1child: Icon(
                  Icons.photo_camera,
                  size: 30,
                ),
                close: false,
              )),
        ],
      ),
    );
  }
}
