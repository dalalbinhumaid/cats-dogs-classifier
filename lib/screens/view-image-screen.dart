import 'dart:io';
import 'dart:ui';
import 'package:cats_and_dogs_classifier/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ViewImage extends StatelessWidget {
  final XFile image;

  ViewImage(this.image);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.PRIMARY_DARK,
      body: Stack(
        children: [
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: ThemeColor.PRIMARY, size: 36,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(50),
              height: MediaQuery.of(context).size.height*0.85,
              child: ClipRRect(
                child: Image.file(File(image.path)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

