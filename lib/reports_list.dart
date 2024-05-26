import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'notifications_list.dart';
import 'providers.dart';
import 'report.dart';
import 'submit.dart';

class ReportsListPage extends ConsumerStatefulWidget {
  const ReportsListPage({super.key});

  @override
  ConsumerState<ReportsListPage> createState() => _ReportsListPageState();
}

class _ReportsListPageState extends ConsumerState<ReportsListPage> {

  @override

  void initState() {
    super.initState();
    ref.read(fetchReportsListProvider);
  }

@override
  Widget build(BuildContext context) {
    final reportsList = ref.watch(reportsListProvider);

    int changeColor(status) {
      if(status == "Otwarte") {
        return 0xFFFFFFFF;
      } else if (status == "W trakcie realizacji") {
        return 0xFFd77382;
      } else if (status == "Duplikat") {
        return 0xFF7db3b4;
      } else {
        return 0xFF96c919;
      }
    }

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
        actions: const [NotificationsButton()],
      ),
      body: Visibility(
        visible: isLoaded || !filesLoaded,
        replacement: const Center(
          child: CircularProgressIndicator(),
        ),
        child: Column(
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
                      color: Color(changeColor(report["status"])),
                      child: ListTile(
                        title: Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 1.5.h),
                            child: Text(report['title'] ?? ''),
                          ),
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
                              builder: (context) => ReportPage(id: report["id"]),
                            ),
                          ).then((_) {
                            ref.read(reportProvider.notifier).update((state) => null);
                            ref.read(locationProvider.notifier).update((state) => null);
                            ref.read(reportFilesListProvider.notifier).update((state) => []);
                          });
                        },
                      ),
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
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(85.w, 10.h)
                ),
                child: const Text(
                    "Utwórz nowe zgłoszenie",
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      drawer: const _OptionsDrawer(),
    );
  }
}

class _OptionsDrawer extends ConsumerWidget {
  const _OptionsDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 17.5.h,
          child: Drawer(
            width: 40.w,
            child: ListView(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(5.w, 0.5.h, 0, 0),
                    child: Text(
                      "Opcje",
                      style: TextStyle(
                        fontSize: 15.sp
                      )
                    )
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
          ),
        ),
      ],
    );
  }
}