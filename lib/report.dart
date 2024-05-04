import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    print(report);

    if(report != null) {
      ref.watch(fetchLocationProvider(report["location_id"]));
      location = ref.read(locationProvider);
    }

    print(report);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły zgłoszenia'),
        actions: const [
          NotificationsButton()
        ],
      ),
      body: report != null
          ? Container(
        padding: EdgeInsets.fromLTRB(5.w, 1.h, 0, 0),
        child: Column(
          children: [
            const Spacer(),
            Expanded(
              flex: 26,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(report['title']),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: Text(report['content']),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 5,
                    child: files != null && files.isNotEmpty
                        ? _FilesList(files: files)
                        : const Text("Brak plików."),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(report['status']),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 5,
                    child: location != null ? Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(location['street']),
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 2,
                          child: Text(location['city']),
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 2,
                          child: Text(location['postcode']),
                        ),
                      ],
                    ) : const CircularProgressIndicator()
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: Text(report['created_at']),
                  ),
                ],
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
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _FilesList extends StatelessWidget {
  final List<dynamic> files;

  const _FilesList({required this.files});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Adjust spacing between items
          child: SizedBox(
            width: 150, // Adjust width of each "box"
            child: file["filetype"] == "image"
                ? Image.network(
              "$host/files/${file["filename"]}",
              fit: BoxFit.cover,
            )
                : file["filetype"] == "document"
                ? GestureDetector(
              onTap: () {
                // Handle document tap
              },
              child: Container(
                color: Colors.grey, // Example background color for document "box"
                child: Center(
                  child: Text(
                    file["filename"],
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
                : ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(
                      videoUrl: "$host/files/${file["filename"]}",
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.blue, // Example background color for video "box"
                child: Center(
                  child: Text(
                    file["filename"],
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}