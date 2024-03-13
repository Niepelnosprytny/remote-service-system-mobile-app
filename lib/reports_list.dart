import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'notifications_list.dart';
import 'providers.dart';
import 'report.dart';
import 'submit.dart';

class ReportsListPage extends StatelessWidget {
  const ReportsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje zgłoszenia'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: const [
          NotificationsButton()
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          ref.watch(fetchReportsListProvider);
          final reportsList = ref.watch(reportsListProvider);

          return Column(
            children: [
              Expanded(
                flex: 27,
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 1.h, 0, 0),
                  child: reportsList != null && reportsList.isNotEmpty
                      ? ListView.builder(
                          itemCount: reportsList.length,
                          itemBuilder: (context, index) {
                            final report = reportsList[index];

                            return Card(
                              child: ListTile(
                                  title: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 1.5.h),
                                        child: Text(report['title'] ?? ''),
                                      )
                                  ),
                                  subtitle: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(report["status"] ?? ''),
                                        Text(report["created_at"]),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ReportPage(id: report["id"])),
                                    );
                                  }),
                            );
                          },
                        )
                      : const Center(
                          child: Text('Brak aktywnych zgłoszeń'),
                        ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SubmitPage()),
                    );
                  },
                  child: const Text("Utwórz nowe zgłoszenie"),
                )
              ),
              const Spacer()
            ],
          );
        },
      ),
      drawer: const _OptionsDrawer(),
    );
  }
}

class _OptionsDrawer extends ConsumerWidget {
  const _OptionsDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text('Opcje'),
          ),
          ListTile(
            title: const Text('Wyloguj się'),
            onTap: () async {
              ref.watch(reportProvider.notifier).update((state) => null);
              ref.watch(reportsListProvider.notifier).update((state) => []);
              ref.watch(userProvider.notifier).update((state) => null);
              ref.watch(tokenProvider.notifier).update((state) => null);
              await storage.deleteAll();
              ref.watch(userLoggedInProvider.notifier).update((state) => false);
            },
          ),
        ],
      ),
    );
  }
}