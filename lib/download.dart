import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';
import 'package:sizer/sizer.dart';
import 'package:downloadsfolder/downloadsfolder.dart';

class DownloadWidget extends StatefulWidget {
  final String url;

  const DownloadWidget({super.key, required this.url});

  @override
  DownloadWidgetState createState() => DownloadWidgetState();
}

class DownloadWidgetState extends State<DownloadWidget> {
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _downloadFile(widget.url);
      },
      child: SizedBox(
        width: 5.h,
        height: 5.h,
        child: Padding(
          padding: EdgeInsets.all(0.5.h),
          child: _downloading
              ? const CircularProgressIndicator()
              : const Icon(
            Icons.file_download,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _downloadFile(String url) async {
    setState(() {
      _downloading = true;
    });

    try {
      var status = await Permission.storage.status;

      if (!status.isGranted) {
        await Permission.storage.request();
      }

      Directory directory = await getDownloadDirectory();
      String downloadPath = directory.path;
      String fileName = url.split('/').last;
      String filePath = '$downloadPath/$fileName';

      final response = await http.get(Uri.parse(url));

      if(response.statusCode == 200) {
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        snackBarKey.currentState?.showSnackBar(
            const SnackBar(content: Text("Pomyślnie pobrano plik")));
      }
    } catch (error) {
      snackBarKey.currentState?.showSnackBar(
          SnackBar(content: Text("Błąd podczas pobierania pliku: $error")));
    } finally {
      setState(() {
        _downloading = false;
      });
    }
  }
}