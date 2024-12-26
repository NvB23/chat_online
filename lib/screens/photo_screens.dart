import 'package:flutter/material.dart';

class PhotoScreens extends StatelessWidget {
  const PhotoScreens({super.key, required this.imageData});

  final String imageData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.black,
      body: Center(child: Image.network(imageData)),
    );
  }
}
