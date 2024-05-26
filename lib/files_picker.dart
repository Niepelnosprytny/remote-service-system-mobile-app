import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:mime/mime.dart';
import 'providers.dart';

class FilesPicker extends StatefulWidget {
  const FilesPicker({super.key});

  @override
  FilesPickerState createState() => FilesPickerState();
}

class FilesPickerState extends State<FilesPicker> {
  bool limitReached = false;
  bool filesLoaded = true;

  static const int maxFiles = 5;

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowCompression: true,
      withData: false,
      withReadStream: false,
      lockParentWindow: true,
      dialogTitle: 'Wybierz plik',
    );

    if (result != null) {
      setState(() {
        filesList.add(File(result.files.first.path!));
        limitReached = filesList.length >= maxFiles;
      });
    }
  }

  Future<void> pickMediaFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowCompression: true,
      withData: false,
      withReadStream: false,
      lockParentWindow: true,
      dialogTitle: 'Wybierz plik',
    );

    if (result != null) {
      setState(() {
        filesList.add(File(result.files.first.path!));
        limitReached = filesList.length >= maxFiles;
      });
    }
  }

  Future<void> pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        filesList.add(File(pickedFile.path));
        limitReached = filesList.length >= maxFiles;
      });
    }
  }

  Future<void> pickVideoFromCamera() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        filesList.add(File(pickedFile.path));
        limitReached = filesList.length >= maxFiles;
      });
    }
  }

  void removeFile(File file) {
    setState(() {
      filesList.remove(file);
      limitReached = filesList.length >= maxFiles;
    });
  }

  String getFileType(File file) {
    final mimeType = lookupMimeType(file.path);
    if (mimeType != null) {
      if (mimeType.startsWith('image/')) {
        return 'image';
      } else if (mimeType.startsWith('video/')) {
        return 'video';
      }
    }
    return 'document';
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (FormFieldState<List<File>> state) {
        return InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Pliki'
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: limitReached ? null : pickFiles,
                    icon: const Icon(Icons.description, size: 36),
                  ),
                  IconButton(
                    onPressed: limitReached ? null : pickMediaFiles,
                    icon: const Icon(Icons.image, size: 36),
                  ),
                  IconButton(
                    onPressed: limitReached ? null : pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt, size: 36),
                  ),
                  IconButton(
                    onPressed: limitReached ? null : pickVideoFromCamera,
                    icon: const Icon(Icons.videocam, size: 36),
                  ),
                ],
              ),
              if (limitReached)
                Padding(
                  padding: EdgeInsets.all(1.5.h),
                  child: Text(
                    "Możesz dodać maksymalnie 5 plików",
                    style: TextStyle(color: Colors.red, fontSize: 12.sp),
                  ),
                ),
              SizedBox(
                height: 15.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filesList.length,
                  itemBuilder: (context, index) {
                    final file = filesList[index];
                    final fileType = getFileType(file);

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 1.h),
                      width: 45.w,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: fileType == 'image'
                                ? Image.file(file, fit: BoxFit.cover)
                                : fileType == 'video'
                                ? Container(
                              color: Colors.black87,
                              child: Center(
                                child: Icon(Icons.play_arrow, size: 50.sp, color: Colors.white),
                              ),
                            )
                                : Container(
                              color: Colors.black26,
                              child: Center(
                                child: Icon(Icons.description_sharp, color: Colors.black54, size: 50.sp),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => removeFile(file),
                              child: Container(
                                width: 25.sp,
                                height: 25.sp,
                                color: Colors.black,
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              color: Colors.black,
                              width: 45.w,
                              padding: EdgeInsets.fromLTRB(1.h, 0.5.h, 2.5.h, 0.5.h),
                              child: Text(
                                file.path.split('/').last,
                                style: TextStyle(color: Colors.white, fontSize: 10.sp),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}