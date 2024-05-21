import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'download.dart';
import 'image_view.dart';
import 'providers.dart';
import 'video_player.dart';

class FilesList extends StatelessWidget {
  final List<dynamic> files;

  const FilesList({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 1.h, vertical: 0),
            width: 45.w,
            child: Stack(
              children: [
                file["filetype"] == "image"
                    ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewPage(
                          imageUrl: "$host/files/${file["filename"]}",
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    "$host/files/${file["filename"]}",
                    fit: BoxFit.cover,
                  ),
                )
                    : file["filetype"] == "document"
                    ? Container(
                  color: Colors.white,
                      width: 45.w,
                      height: 15.h,
                      child: Icon(
                                        Icons.file_copy,
                                        color: Colors.grey,
                                        size: 50.sp,
                                      ),
                    )
                    : ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerPage(
                          videoUrl: "$host/files/${file["filename"]}",
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    size: 25.sp,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                        color: Colors.black,
                        child: DownloadWidget(url: "$host/files/${file["filename"]}")
                    )
                )
              ],
            ),
          );
        },
      ),
    );
  }
}