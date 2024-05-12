import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:remote_service_system_mobile_app/image_view.dart';
import 'package:remote_service_system_mobile_app/notifications_list.dart';
import 'package:sizer/sizer.dart';
import 'providers.dart';
import 'video_player.dart';

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
                      files != null && files.isNotEmpty
                          ? Container(
                          padding: EdgeInsets.fromLTRB(0, 1.5.h, 0, 1.5.h),
                          child: _FilesList(files: files))
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
                onPressed: () {},
                child: const Text("Komentarze"),
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

class _FilesList extends StatelessWidget {
  final List<dynamic> files;

  const _FilesList({required this.files});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 0.5.h),
            child: Column(
              children: [
                file["filetype"] == "image"
                    ? SizedBox(
                  height: 10.h,
                  width: 35.w,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewPage(
                            imageUrl: "$host/files/${file["filename"]}",
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      "$host/files/${file["filename"]}",
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    : file["filetype"] == "document"
                    ? SizedBox(
                  height: 10.h,
                  width: 35.w,
                  child: Icon(
                    Icons.file_copy,
                    color: Colors.grey,
                    size: 50.sp,
                  ),
                )
                    : SizedBox(
                  height: 10.h,
                  width: 35.w,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerPage(
                            videoUrl: "$host/files/${file["filename"]}",
                          ),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      size: 25.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  height: 3.h,
                  width: 35.w,
                  color: const Color(0xFF373F51),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        downloadFile("$host/files/${file["filename"]}");
                      },
                      child: Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: Text(
                              file["filename"],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFFF4F4F4)),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Icon(
                              size: 15.sp,
                              Icons.download,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}