import 'package:flutter/material.dart';
import 'package:remote_service_system_mobile_app/download.dart';
import 'package:sizer/sizer.dart';

class ImageViewPage extends StatefulWidget {
  final String imageUrl;

  const ImageViewPage({super.key, required this.imageUrl});

  @override
  ImageViewPageState createState() => ImageViewPageState();
}

class ImageViewPageState extends State<ImageViewPage> {
  double _rotation = 0;
  bool _isAppBarVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isAppBarVisible
          ? AppBar(
              title: const Text("Podgląd zdjęcia"),
              actions: [
                Padding(
                  padding: EdgeInsets.all(1.h),
                  child: DownloadWidget(url: widget.imageUrl),
                )
              ],
            )
          : null,
      body: Stack(
        children: [
          Center(
            child: RotatedBox(
              quarterTurns: _rotation ~/ (90 * (3.14159 / 180)),
              child: Image.network(widget.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isAppBarVisible = !_isAppBarVisible;
                  _rotation = !_isAppBarVisible ? 90 : 0;
                  _rotation %= 360;
                });
              },
              child: _isAppBarVisible
                  ? const Icon(Icons.rotate_right)
                  : const Icon(Icons.rotate_left),
            ),
          ),
        ],
      ),
    );
  }
}
