import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'providers.dart';
import 'report.dart';

String formatDate(String dateString) {
  final DateTime dateTime = DateTime.parse(dateString);
  final formattedDate = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} '
      '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  return formattedDate;
}

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
              ? Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                                itemCount: notificationsList.length,
                                itemBuilder: (context, index) {
                    final notification = notificationsList[index];
                    
                    return Card(
                      child: ListTile(
                        title: Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 1.5.h),
                              child: Text(
                                notification["content"],
                                style: TextStyle(
                                  fontWeight: notification["seen"] == 0 ? FontWeight.bold : FontWeight.normal
                                ),
                              ),
                            )
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(formatDate(notification["created_at"])),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ReportPage(id: notification["report_id"])),
                          );
                        },
                      ),
                    );
                                },
                              ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        var ids = [];
                        for(int i = 0; i < notificationsList.length; i++) {
                          if(notificationsList[i]["seen"] == 0) {
                            ids.add(notificationsList[i]["user_notification_id"]);
                          }
                        }

                        Map<String, dynamic> data = {
                          "seen": 1,
                          "ids": ids
                        };

                        ref.watch(updateSeenProvider(data));
                      },
                      child: const Text("Oznacz jako przeczytane")
                  )
                ],
              ) : const Center(
            child: CircularProgressIndicator(),
          );
        }
      )
    );
  }
}
