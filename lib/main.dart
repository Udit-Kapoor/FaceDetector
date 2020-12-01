import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:ml_vision/cpainter.dart';
import 'dart:ui' as ui;
import 'package:rflutter_alert/rflutter_alert.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  final picker = ImagePicker();
  List<Face> _faces = new List<Face>();

  ui.Image img;

  void processor() async {
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(_image);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
    _faces = await faceDetector.processImage(visionImage);

//
//      // If classification was enabled with FaceDetectorOptions:
//      if (face.smilingProbability != null) {
//        final double smileProb = face.smilingProbability;
//      }
//
//      // If face tracking was enabled with FaceDetectorOptions:
//      if (face.trackingId != null) {
//        final int id = face.trackingId;
//      }
//    }
    faceDetector.close();

    if (_faces.isEmpty) {
      Alert(
        context: context,
        type: AlertType.error,
        title: "No Faces Found",
        desc: "Please Try Another Image",
        buttons: [
          DialogButton(
            child: Text(
              "Okay",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    }

    final data = await _image.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        img = value;
        _faces = _faces;
      }),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    final data = await pickedFile.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        img = value;

        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
        _faces = new List<Face>();
      }),
    );
  }

  Future getImageFromFile() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    final data = await pickedFile.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        img = value;

        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
        _faces = new List<Face>();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(child: Text('Face Detector')),
      ),
      body: Center(
          child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: img == null
                  ? Text('No image selected.')
                  : Center(
                      child: FittedBox(
                        child: SizedBox(
                          width: img.width.toDouble(),
                          height: img.height.toDouble(),
                          child: CustomPaint(
                            painter: FacePainter(img, _faces),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: getImage,
                  tooltip: 'Pick Image',
                  icon: Icon(Icons.add_a_photo),
                  iconSize: 50.0,
                ),
                SizedBox(
                  width: 50,
                ),
                IconButton(
                  onPressed: getImageFromFile,
                  tooltip: 'Pick Image',
                  icon: Icon(Icons.filter),
                  iconSize: 50.0,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: processor,
              child: Container(
                child: Text(
                  'PROCESS',
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
