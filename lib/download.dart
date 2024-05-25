import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remote_service_system_mobile_app/main.dart';
import 'package:sizer/sizer.dart';

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
      child: _downloading
          ? Padding(
            padding: EdgeInsets.all(8.5.h),
            child: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
          )
          : Padding(
            padding: EdgeInsets.all(0.5.h),
            child: const Icon(
                    Icons.file_download,
                    color: Colors.white,
                  ),
          ),
    );
  }

  Future<void> _downloadFile(String url) async {
    setState(() {
      _downloading = true;
    });

    try {
      await Permission.storage.request();

      Directory? directory = await getDownloadsDirectory();
      String? downloadPath = directory?.path;
      String fileName = url.split('/').last;
      String filePath = '$downloadPath/$fileName';

      http.Response response = await http.get(Uri.parse(url));
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      snackBarKey.currentState?.showSnackBar(
          const SnackBar(
              content: Text("Pomyślnie pobrano plik"))
      );

      setState(() {
        _downloading = false;
      });
    } catch (error) {
      snackBarKey.currentState?.showSnackBar(
          SnackBar(
              content: Text("Bład podczas pobierania pliku: $error"))
      );
      setState(() {
        _downloading = false;
      });
    }
  }
}