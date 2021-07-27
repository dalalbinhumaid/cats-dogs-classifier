import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading;
  XFile _image;
  List _prediction;
  String _label;
  double _confidence;
  double _other;

  @override
  void initState() {
    super.initState();
    _loading = true;
    load().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null
                      ? Container()
                      : Container(
                          height: MediaQuery.of(context).size.width * 0.65,
                          child: Image.file(File(_image.path))),
                  _prediction == null
                      ? Text('')
                      : Text(
                          "${_prediction[0]['label']}:${_prediction[0]['confidence'].toStringAsFixed(2)}%"),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.add),
      ),
    );
  }

  load() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  pickImage() async {
    var imagePicker =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imagePicker == null) return null;

    setState(() {
      _loading = true;
      _image = imagePicker;
    });

    predict(imagePicker);
  }

  predict(XFile image) async {
    var prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      imageMean: 127.5,
      imageStd: 127.5,
      threshold: 0.5,
    );

    setState(() {
      _loading = false;
      _prediction = prediction;
    });
  }
}
