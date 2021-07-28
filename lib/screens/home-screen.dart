import 'dart:io';

import 'package:cats_and_dogs_classifier/colors.dart';
import 'package:cats_and_dogs_classifier/screens/view-image-screen.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading;
  Image _image;
  XFile _imagePath;
  List _prediction;
  String _label;
  String _confidence;
  TextStyle textStylePrimary = GoogleFonts.openSans(
    textStyle: TextStyle( color: ThemeColor.SECONDARY_LIGHT, fontSize: 18.0),
  );
  TextStyle textStyleSecondary = GoogleFonts.openSans(
    textStyle: TextStyle(fontWeight: FontWeight.bold, color: ThemeColor.SECONDARY,fontSize: 18.0),
  );

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
      backgroundColor: ThemeColor.PRIMARY_DARK,
      body: Container(
        padding: EdgeInsets.only(top: 150, left: 50, right: 50, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: 300.0,
                child: selectImage(),
              ),
            ),
            SizedBox(height: 50),
            selectText(),
            SizedBox(height: 30),
            displayIcons(),
            SizedBox(height: 30),
            viewImage(),
          ],
        ),
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
      _imagePath = imagePicker;
      _image = Image.file(File(imagePicker.path));
    });

    predict(imagePicker);
  }

  pickImageFromCamera() async {
    var imagePicker =
    await ImagePicker().pickImage(source: ImageSource.camera);

    if (imagePicker == null) return null;

    setState(() {
      _loading = true;
      _imagePath = imagePicker;
      _image = Image.file(File(imagePicker.path));
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
      _label = transform(_prediction[0]['label']);
      _confidence = convert(_prediction[0]['confidence']);
    });
  }

  String transform(str) {
    String label = str.replaceAll(RegExp(r'[0-9 | s]'), '');
    label = label.toLowerCase();
    return label;
  }

  String convert(value) {
    double confidence = value * 100;
    return confidence.toStringAsFixed(2);
  }

  Image selectImage() {
    if (!_loading) {
      if (_label == 'dog') return Image.asset('assets/images/dog.png');
      if (_label == 'cat')
        return Image.asset('assets/images/cat.png');
      else
        return Image.asset('assets/images/upload.png');
    } else
      return Image.asset('assets/images/load.png');
  }

  RichText selectText() {
    if (_prediction == null)
      return RichText(
        text: TextSpan(
          text: 'Upload an image from your ',
          style: textStylePrimary,
          children: [
            TextSpan(text: 'gallery ', style: textStyleSecondary),
            TextSpan(text: 'or from your ', style: textStylePrimary),
            TextSpan(text: 'camera ', style: textStyleSecondary),
            TextSpan(text: 'to get started!', style: textStylePrimary),
          ],
        ),
        textAlign: TextAlign.center,
      );
    else
      return RichText(
        text: TextSpan(
          text: 'Your image is a ',
          style: textStylePrimary,
          children: [
            TextSpan(text: _label, style: textStyleSecondary),
            TextSpan(text: ' with an accuracy of ', style: textStylePrimary),
            TextSpan(text: '$_confidence%', style: textStyleSecondary),
          ],
        ),
        textAlign: TextAlign.center,
      );
  }

  Row displayIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            color: Color(0xFF074749F),
            splashColor: Color(0xFFCBCBCB),
            splashRadius: 40,
            icon: Icon(Icons.drive_folder_upload),
            onPressed: pickImage),
        SizedBox(
          width: 25,
        ),
        IconButton(
            color: Color(0xFF074749F),
            splashColor: Color(0xFFCBCBCB),
            splashRadius: 40,
            icon: Icon(Icons.camera_alt_outlined),
            onPressed: pickImageFromCamera),
      ],
    );
  }

  viewImage() {
      if (_image == null)
        return Container();
      else
        return Container(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ViewImage(_imagePath)));
          },
          style: ElevatedButton.styleFrom(
            primary: Color(0xFF9E9EBC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0.0,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'View Image',
                    style: GoogleFonts.openSans(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Icon(Icons.arrow_forward_rounded)
                ]),
          ),
        ),
      );
  }
}
