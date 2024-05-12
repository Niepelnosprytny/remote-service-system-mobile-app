import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remote_service_system_mobile_app/notifications_list.dart';
import 'package:remote_service_system_mobile_app/providers.dart';
import 'package:sizer/sizer.dart';

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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Tworzenie zgłoszenia'),
          actions: const [NotificationsButton()],
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 0),
          child: Column(
            children: [
              Expanded(
                flex: 27,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 2.5.h,
                      ),
                      TextFormField(
                          controller: titleController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                              labelText: 'Tytuł',
                              hintText: "Wprowadź tytuł"),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Wprowadź tytuł';
                            }
                            return null;
                          }),
                      SizedBox(
                        height: 2.5.h,
                      ),
                      Consumer(builder: (context, ref, child) {
                        ref.watch(fetchLocationsListProvider);
                        final locationsList = ref.watch(locationsListProvider);

                        List<DropdownMenuItem<int>> dropdownItems = [];

                        if (locationsList != null) {
                          for (var location in locationsList) {
                            dropdownItems.add(
                              DropdownMenuItem<int>(
                                value: location['id'],
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(0, 1.h, 0, 1.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(location['name']),
                                      Text("ul. ${location["street"]}"),
                                      Text("${location["postcode"]} ${location["city"]}"),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        }

                        return DropdownButtonFormField(
                          items: dropdownItems,
                          hint: const Text("Wybierz lokację"),
                          decoration: const InputDecoration(labelText: "Lokacja"),
                          isDense: false,
                          onChanged: (value) {
                            selectedLocation = value;
                          },
                        );
                      }),
                      SizedBox(
                        height: 2.5.h,
                      ),
                      TextFormField(
                          controller: descriptionController,
                          keyboardType: TextInputType.text,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Opis',
                            hintText: "Wprowadź opis",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Wprowadź opis';
                            }
                            return null;
                          }),
                      SizedBox(
                        height: 2.5.h,
                      ),
                      _FilesPicker(),
                      SizedBox(
                        height: 2.5.h,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Consumer(builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () {
                      String report = jsonEncode({
                        "title": titleController.text,
                        "content": descriptionController.text,
                        "status": "Otwarte",
                        "location_id": selectedLocation,
                        "created_by": ref.watch(userProvider)?["id"],
                      });

                      ref.read(submitReportProvider(report));
                    },
                    child: const Text("Wyślij zgłoszenie"),
                  );
                }),
              ),
              const Spacer(),
            ],
          ),
        ));
  }
}

class _FilesPicker extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FilesPicker> createState() => _FilesPickerState();
}

class _FilesPickerState extends ConsumerState<_FilesPicker> {
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