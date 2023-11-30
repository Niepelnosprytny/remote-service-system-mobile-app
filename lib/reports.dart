import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> reportsList = ['Report 1', 'Report 2', 'Report 3', 'Report 4', 'Report 5'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: reportsList.isEmpty
          ? const Center(
        child: Text('Brak aktywnych zgłoszeń'),
      )
          : ListView.builder(
        itemCount: reportsList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(reportsList[index]),
          );
        },
      ),
    );
  }
}