import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'providers.dart';

class FilesPicker extends ConsumerStatefulWidget {
  const FilesPicker({super.key});

  @override
  ConsumerState<FilesPicker> createState() => FilesPickerState();
}

class FilesPickerState extends ConsumerState<FilesPicker> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormFieldState<List<PlatformFile>?>> filePickerKey =
    GlobalKey<FormFieldState<List<PlatformFile>?>>();

    void xFileToPlatformFile(result) async {
      if (result != null) {
        final file = PlatformFile(
          name: await result.name,
          path: await result.path,
          size: await result.length(),
          bytes: await result.readAsBytes(),
          readStream: await result.openRead(),
          identifier: await result.path,
        );

        ref.read(filesListProvider.notifier).update((state) {
          return [
            ...(state ?? []),
            file,
          ];
        });

        final formFieldState = filePickerKey.currentState;
        formFieldState?.didChange(ref.read(filesListProvider));

        setState(() {});
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderFilePicker(
          key: filePickerKey,
          decoration: const InputDecoration(
            labelText: "Pliki",
          ),
          initialValue: ref.read(filesListProvider),
          name: "Pliki",
          previewImages: true,
          allowMultiple: true,
          maxFiles: 5,
          withData: true,
          withReadStream: true,
          onChanged: (value) {
            ref.read(filesListProvider.notifier).update((state) => value);
          },
          typeSelectors: [
            TypeSelector(
              type: FileType.media,
              selector: Column(
                children: [
                  Icon(
                    Icons.photo_sharp,
                    size: 20.sp,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  const Text("Galeria"), // Label "Galeria"
                ],
              ),
            ),
            TypeSelector(
              type: FileType.any,
              selector: Column(
                children: [
                  Icon(
                    Icons.folder_sharp,
                    size: 20.sp,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  const Text("Pliki"), // Label "Pliki"
                ],
              ),
            ),
            TypeSelector(
              type: FileType.any,
              selector: GestureDetector(
                onTap: () async {
                  await Permission.storage.request();
                  await Permission.camera.request();

                  final ImagePicker picker = ImagePicker();
                  XFile? result =
                  await picker.pickImage(source: ImageSource.camera);

                  xFileToPlatformFile(result);
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.camera_sharp,
                      size: 20.sp,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    const Text("Zdjęcie"),
                  ],
                ),
              ),
            ),
            TypeSelector(
              type: FileType.any,
              selector: GestureDetector(
                onTap: () async {
                  await Permission.storage.request();
                  await Permission.camera.request();

                  final ImagePicker picker = ImagePicker();

                  XFile? result = await picker.pickVideo(
                    source: ImageSource.camera,
                    maxDuration: const Duration(seconds: 30),
                  );

                  xFileToPlatformFile(result);
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.videocam_sharp,
                      size: 20.sp,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    const Text("Wideo"), // Add label "Wideo"
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}