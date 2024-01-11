import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remote_service_system_mobile_app/providers.dart';

class SubmitPage extends StatelessWidget {
  const SubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tworzenie zgłoszenia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Tytuł'),
            ),
            Consumer(
              builder: (context, ref, child) {
                ref.watch(fetchLocationsListProvider);
                final locationsList = ref.watch(locationsListProvider);

                List<DropdownMenuItem<int>> dropdownItems = [];

                if (locationsList != null) {
                  for (var location in locationsList) {
                    dropdownItems.add(
                      DropdownMenuItem<int>(
                        value: location['id'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(location['name']),
                            Text(location["street"]),
                            Text(location["city"]),
                            Text(location["postcode"]),
                         ],
                        ),
                      ),
                    );
                  }
                }

                return DropdownButtonFormField(
                  items: dropdownItems,
                  decoration: const InputDecoration(
                    labelText: "Lokacja",
                  ),
                  isDense: false,
                  onChanged: (value) {},
                );
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Opis'),
              maxLines: 3,
            ),
            _FilesPicker(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // TODO: Implement the form submission logic
          // Use the selected files from the file picker
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}

class _FilesPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormFieldState<List<PlatformFile>?>> _filePickerKey =
    GlobalKey<FormFieldState<List<PlatformFile>?>>();
    final List<PlatformFile> files = [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pliki'),
        FormBuilderFilePicker(
          key: _filePickerKey,
          initialValue: files,
          name: 'selectedFiles',
          previewImages: false,
          allowMultiple: true,
          withData: true,
          onChanged: (value) async {
            print("Zaczyna się...");
            print("File: $value");
          },
          typeSelectors: [
            TypeSelector(
              type: FileType.media,
              selector: Icon(Icons.photo_sharp)
            ),
            TypeSelector(
              type: FileType.any,
              selector: Icon(Icons.folder_sharp),
            ),
            TypeSelector(
              type: FileType.any,
              selector: IconButton(
                icon: Icon(Icons.photo_sharp),
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  XFile? result = await picker.pickImage(source: ImageSource.camera);

                  if (result != null) {
                    files.add(PlatformFile(
                      name: result.name,
                      path: result.path,
                      size: await result.length(),
                      bytes: await result.readAsBytes(),
                      readStream: result.openRead(),
                      identifier: result.path,
                    ));

                    final formFieldState = _filePickerKey.currentState;
                    formFieldState?.didChange(files);
                  }
                },
              ),
            ),
            TypeSelector(
                type: FileType.any,
                selector: IconButton(
                  icon: Icon(Icons.videocam_sharp),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    try {
                      XFile? result = await picker.pickVideo(source: ImageSource.camera);;

                      if (result != null) {
                        files.add(PlatformFile(
                          name: result.name,
                          path: result.path,
                          size: await result.length(),
                          bytes: await result.readAsBytes(),
                          readStream: result.openRead(),
                          identifier: result.path,
                        ));

                        final formFieldState = _filePickerKey.currentState;
                        formFieldState?.didChange(files);
                      }

                      print("Rezultat: $result");
                      print("Pliki: $files");
                    } catch (error) {
                      print(error);
                    }

                    print("Sukces");
                  },
                ),
            )
          ],
        ),
      ],
    );
  }
}