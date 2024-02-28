import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_service_system_mobile_app/notifications_list.dart';
import 'providers.dart';

class ReportPage extends ConsumerWidget {
  final int id;

  const ReportPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(fetchReportProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły zgłoszenia'),
        actions: const [
          NotificationsButton()
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final reportData = ref.watch(reportProvider);

          if (reportData != null) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${reportData['id']}'),
                    Text('Title: ${reportData['title']}'),
                    Text('Content: ${reportData['content']}'),
                    Text('Status: ${reportData['status']}'),
                    Text('Created At: ${reportData['created_at']}'),
                    Text('Location ID: ${reportData['location_id']}'),
                    Text('Created By: ${reportData['created_by']}'),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}