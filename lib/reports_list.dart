import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'report.dart';

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
      ),
      body: Consumer(
        builder: (context, ref, _) {
          ref.watch(fetchReportsListProvider);
          final reportsList = ref.watch(reportsListProvider);

          return reportsList != null && reportsList.isNotEmpty
              ? ListView.builder(
                  itemCount: reportsList.length,
                  itemBuilder: (context, index) {
                    final report = reportsList[index];
                    return ListTile(
                        title: Text(report['title'] ?? ''),
                        subtitle: Text(report['status'] ?? ''),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ReportPage(id: report["id"])),
                          );
                        });
                  },
                )
              : const Center(
                  child: Text('Brak aktywnych zgłoszeń'),
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