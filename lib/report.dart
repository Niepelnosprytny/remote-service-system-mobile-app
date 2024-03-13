import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_service_system_mobile_app/notifications_list.dart';
import 'package:sizer/sizer.dart';
import 'providers.dart';

class ReportPage extends ConsumerWidget {
  final int id;

  const ReportPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(fetchReportProvider(id));
    final report = ref.watch(reportProvider);

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
                          child: Text(report['title'])
                      ),
                      const Spacer(),
                      Expanded(
                          flex: 2,
                          child: Text(report['content'])
                      ),
                      const Spacer(),
                      Expanded(
                          flex: 2,
                          child: Text(report['status'])
                      ),
                      const Spacer(),
                      Expanded(
                          flex: 2,
                          child: Text(report['created_at'])
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
                const Spacer()
              ],
            ),
          )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}