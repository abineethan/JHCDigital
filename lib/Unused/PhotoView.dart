import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageFromUrl extends StatelessWidget {
  final String imageUrl;

  // Constructor to accept the image URL as a parameter
  ImageFromUrl({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: PhotoView(
        imageProvider: NetworkImage(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered,
      )),
    );
  }
}
