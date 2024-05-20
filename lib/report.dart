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
  
  for(int i = 0; i < files.length; i++) {
    if(files[i]["comment_id"] == null) {
      filesList.add(files[i]);
    }
  }
  
  return filesList;
}

class ReportPage extends ConsumerWidget {
  final int id;

  const ReportPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(fetchReportProvider(id));
    final report = ref.watch(reportProvider);
    ref.read(fetchReportFilesListProvider(id));
    final files = ref.watch(reportFilesListProvider);
    dynamic location;
    dynamic formattedDate;

    if (report != null) {
      ref.read(fetchLocationProvider(report["location_id"]));
      location = ref.watch(locationProvider);
      formattedDate =
          DateFormat("HH:mm dd.MM.yyyy").format(DateTime.parse(report["created_at"]));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły zgłoszenia'),
        actions: const [NotificationsButton()],
      ),
      body: report != null
          ? Container(
        padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 0),
        child: Column(
          children: [
            Expanded(
              flex: 27,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      formattedDate != null
                          ? Container(
                        padding: EdgeInsets.fromLTRB(0, 1.5.h, 0, 0),
                        width: double.infinity,
                        child: Text(
                          formattedDate,
                          textAlign: TextAlign.end,
                        ),
                      )
                          : SizedBox(height: 1.5.h),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 1.5.h, 0, 1.5.h),
                        child: Text(
                          report['title'],
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 1.5.h, 0, 1.5.h),
                        child: Text(report['status']),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 1.5.h, 0, 1.5.h),
                        child: Center(child: Text(report['content'])),
                      ),
                      files != null && reportFiles(files).isNotEmpty
                          ? Container(
                          padding: EdgeInsets.fromLTRB(0, 1.5.h, 0, 1.5.h),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 1.5.h),
                                child: const Text("Pliki"),
                              ),
                              FilesList(files: reportFiles(files)),
                            ],
                          )
                      )
                          : Container(
                        padding: EdgeInsets.fromLTRB(0, 1.5.h, 0, 1.5.h),
                        child: const Text("Brak plików."),
                      ),
                      location != null
                          ? Container(
                        padding: EdgeInsets.fromLTRB(0, 1.5.h, 0, 1.5.h),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0.5.h, 0, 0.5.h),
                              child: const Text("Adres"),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0.5.h, 0, 0.5.h),
                              child: Text(
                                "${location['city']}, ${location['street']} ${location['postcode']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                          : const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CommentsPage(reportId: report["id"]))
                  );
                },
                child: const Text(
                    "Komentarze",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      )
          : const CircularProgressIndicator(),
    );
  }
}