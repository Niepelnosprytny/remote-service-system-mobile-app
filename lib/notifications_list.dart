import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'providers.dart';
import 'report.dart';
import 'package:badges/badges.dart' as badges;

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
          ref.read(fetchNotificationsListProvider);
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
                            Text(notification["created_at"]),
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

class NotificationsButton extends StatelessWidget {
  const NotificationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      var notificationsCount = ref.watch(notificationsListProvider)!.where((notification) => notification['seen'] == 0).length;

      return badges.Badge(
        badgeContent: Text(
          notificationsCount.toString(),
          style: const TextStyle(
              color: Colors.white
          ),
        ),
        showBadge: notificationsCount > 0,
        position: badges.BadgePosition.topEnd(top: 0, end: 5),
        badgeStyle: const badges.BadgeStyle(
            badgeColor: Colors.red
        ),
        child: IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsListPage(),
              ),
            );
          },
        ),
      );
    },
    );
  }
}