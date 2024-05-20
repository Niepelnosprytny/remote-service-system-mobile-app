import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:remote_service_system_mobile_app/notifications_list.dart';
import 'package:remote_service_system_mobile_app/providers.dart';
import 'package:sizer/sizer.dart';

import 'files_picker.dart';

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
                      const FilesPicker(),
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
                        "users": []
                      });

                      ref.read(submitReportProvider(report));
                    },
                    child: const Text(
                        "Wyślij zgłoszenie",
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),
            ],
          ),
        ));
  }
}