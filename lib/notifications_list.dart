import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'report.dart';

class NotificationsListPage extends StatelessWidget {
  const NotificationsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Powiadomienia")
      ),
      body: Consumer(
        builder: (context, ref, _) {
          ref.watch(fetchNotificationsListProvider);
          final notificationsList = ref.watch(notificationsListProvider);

          return notificationsList != null && notificationsList.isNotEmpty
              ? ListView.builder(
            itemCount: notificationsList.length,
            itemBuilder: (context, index) {
              final notification = notificationsList[index];

              return ListTile(
                title: Text(notification["content"]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ReportPage(id: notification["report_id"])),
                  );
                },
              );
            },
          ) : const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
