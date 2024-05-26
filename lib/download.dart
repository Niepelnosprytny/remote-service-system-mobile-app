import 'dart:io';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
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
      child: SizedBox(
        width: 5.h,
        height: 5.h,
        child: Padding(
                padding: EdgeInsets.all(0.5.h),
                child: _downloading ? const CircularProgressIndicator() : const Icon(
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
      await Permission.storage.request();

      Directory? directory = await getDownloadsDirectory();
      String? downloadPath = directory?.path;
      String fileName = url.split('/').last;

      final task = DownloadTask(
          url: url,
          filename: fileName,
          directory: downloadPath ?? "SebastianInc",
          requiresWiFi: false,
          allowPause: false,
      );

      final result = await FileDownloader().download(task);

      if(result.status == TaskStatus.complete) {
        snackBarKey.currentState?.showSnackBar(
            const SnackBar(content: Text("Pomyślnie pobrano plik"))
        );
      }

      setState(() {
        _downloading = false;
      });
    } catch (error) {
      snackBarKey.currentState?.showSnackBar(
          SnackBar(content: Text("Bład podczas pobierania pliku: $error")));
      setState(() {
        _downloading = false;
      });
    }
  }
}
