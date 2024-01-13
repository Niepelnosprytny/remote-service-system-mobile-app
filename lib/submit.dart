import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remote_service_system_mobile_app/providers.dart';

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});


@override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
@override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    int? selectedLocation = 0;

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
              controller: titleController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  labelText: 'Tytuł',
                  hintText: "Wprowadź tytuł"
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wprowadź tytuł';
                }
                return null;
              }
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
                  hint: const Text("Wybierz lokację"),
                  decoration: const InputDecoration(
                      labelText: "Lokacja"
                  ),
                  isDense: false,
                  onChanged: (value) {
                    selectedLocation = value;
                    },
                );
                },
            ),
            TextFormField(
              controller: descriptionController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  labelText: 'Opis',
                  hintText: "Wprowadź opis"
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wprowadź opis';
                }
                return null;
              }
            ),
            _FilesPicker(),
          ],
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          return FloatingActionButton(
            onPressed: () {
              String report = jsonEncode({
                "title": titleController.text,
                "content": descriptionController.text,
                "status": "Otwarte",
                "location_id": selectedLocation,
                "created_by": ref.watch(userProvider)?["id"],
              });

              ref.watch(submitReportProvider(report));
              },
            child: const Text("Wyślij zgłoszenie"),
          );
          },
      ),
    );
  }
}

class _FilesPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormFieldState<List<PlatformFile>?>> filePickerKey =
    GlobalKey<FormFieldState<List<PlatformFile>?>>();
    final List<PlatformFile> files = [];

    void xFileToPlatformFile(result) async {
      if (result != null) {
        files.add(PlatformFile(
          name: result.name,
          path: result.path,
          size: await result.length(),
          bytes: await result.readAsBytes(),
          readStream: result.openRead(),
          identifier: result.path,
        ));

        final formFieldState = filePickerKey.currentState;
        formFieldState?.didChange(files);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pliki'),
        FormBuilderFilePicker(
          key: filePickerKey,
          initialValue: files,
          name: 'selectedFiles',
          previewImages: false,
          allowMultiple: true,
          maxFiles: 6,
          withData: true,
          typeSelectors: [
            const TypeSelector(
              type: FileType.media,
              selector: Icon(Icons.photo_sharp)
            ),
            const TypeSelector(
              type: FileType.any,
              selector: Icon(Icons.folder_sharp),
            ),
            TypeSelector(
              type: FileType.any,
              selector: IconButton(
                icon: const Icon(Icons.photo_sharp),
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  XFile? result = await picker.pickImage(source: ImageSource.camera);

                  xFileToPlatformFile(result);
                },
              ),
            ),
            TypeSelector(
                type: FileType.any,
                selector: IconButton(
                  icon: const Icon(Icons.videocam_sharp),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    XFile? result = await picker.pickVideo(
                        source: ImageSource.camera,
                        maxDuration: const Duration(seconds: 30)
                    );

                    xFileToPlatformFile(result);
                  },
                ),
            )
          ],
        ),
      ],
    );
  }
}