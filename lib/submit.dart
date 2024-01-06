import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:image_picker/image_picker.dart';

class SubmitPage extends StatelessWidget {
  const SubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Tytuł'),
            ),
            // Use DropdownButtonFormField for Lokacja
            // ...
            const TextField(
              decoration: InputDecoration(labelText: 'Opis'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pliki', style: TextStyle(fontSize: 16.0)),
        FormBuilderFilePicker(
          name: 'selectedFiles',
          previewImages: false,
          allowMultiple: true,
          withData: true,
          typeSelectors: const [
            TypeSelector(
              type: FileType.any,
              selector: Row(
                children: [
                  Icon(Icons.add_circle),
                ],
              ),
            ),
            TypeSelector(
              type: FileType.media,
              selector: Row(
                children: [
                  Icon(Icons.add_photo_alternate),
                  SizedBox(width: 8), // Add some spacing between buttons
                  Icon(Icons.videocam),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                var image = await picker.pickImage(source: ImageSource.camera);
              },
              child: const Icon(Icons.add_photo_alternate),
            ),
            ElevatedButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                var video = await picker.pickVideo(source: ImageSource.camera);
              },
              child: const Icon(Icons.videocam),
            ),
          ],
        ),
      ],
    );
  }
}