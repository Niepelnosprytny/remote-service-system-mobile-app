import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> reportsList = ['Report 1', 'Report 2', 'Report 3', 'Report 4', 'Report 5'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Column(
        children: [
          Expanded(
            child: reportsList.isEmpty
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
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final mapData = ref.watch(userProvider);
                final rawData = const JsonEncoder.withIndent('  ').convert(mapData);

                if (mapData != null) {
                  return SingleChildScrollView(
                    child: Text(
                      rawData,
                      style: const TextStyle(fontSize: 24),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      )
    );
  }
}