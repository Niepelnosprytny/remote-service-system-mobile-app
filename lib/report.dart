import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:remote_service_system_mobile_app/comments.dart';
import 'package:remote_service_system_mobile_app/files_list.dart';
import 'package:remote_service_system_mobile_app/notifications_list.dart';
import 'package:sizer/sizer.dart';
import 'providers.dart';

List<dynamic> reportFiles(List<dynamic> files) {
  var filesList = [];
  for (var file in files) {
    if (file["comment_id"] == null) {
      filesList.add(file);
    }
  }
  return filesList;
}

class ReportPage extends ConsumerStatefulWidget {
  final int id;

  const ReportPage({super.key, required this.id});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {

  @override
  void initState() {
    super.initState();
    ref.read(fetchReportProvider(widget.id));
    ref.read(fetchReportFilesListProvider(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(reportProvider);
    final files = ref.watch(reportFilesListProvider);
    dynamic location;
    String? formattedDate;

    if (report != null) {
      ref.read(fetchLocationProvider(report["location_id"]));
      location = ref.watch(locationProvider);
      formattedDate = DateFormat("HH:mm dd.MM.yyyy").format(DateTime.parse(report["created_at"]));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły zgłoszenia'),
        actions: const [NotificationsButton()],
      ),
      body: report != null ? Visibility(
        visible: isLoaded,
        replacement: const Center(
          child: CircularProgressIndicator(),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: [
                Expanded(
                  flex: 27,
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          if (formattedDate != null)
                            Container(
                              padding: EdgeInsets.only(top: 1.5.h),
                              width: double.infinity,
                              child: Text(
                                formattedDate,
                                textAlign: TextAlign.end,
                              ),
                            )
                          else
                            SizedBox(height: 1.5.h),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            child: Text(
                              report['title'],
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            child: Text(report['status']),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            child: Center(child: Text(report['content'])),
                          ),
                          if (files != null && reportFiles(files).isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(bottom: 1.5.h),
                                    child: const Text("Pliki"),
                                  ),
                                  FilesList(files: reportFiles(files)),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              child: const Text("Brak plików."),
                            ),
                          if (location != null)
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                                    child: const Text("Adres"),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                                    child: Text(
                                      "${location['city']}, ${location['street']} ${location['postcode']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentsPage(reportId: report["id"]),
                        ),
                      );
                    },
                    child: const Text(
                      "Komentarze",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ) : const Center(child: CircularProgressIndicator()),
    );
  }
}