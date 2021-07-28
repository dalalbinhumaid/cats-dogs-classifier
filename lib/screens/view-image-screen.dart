import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ViewImage extends StatelessWidget {
  final XFile image;

  ViewImage(this.image);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Image.file(File(image.path)),
    );
  }
}
