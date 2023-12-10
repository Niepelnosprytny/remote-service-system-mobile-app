import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporty'),
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
                // Add more fields as needed
              );
            },
          )
              : const Center(
            child: Text('Brak aktywnych zgłoszeń'),
          );
        },
      ),
    );
  }
}