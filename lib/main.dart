import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'reports.dart';
import 'providers.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool userLoggedIn = ref.watch(userLoggedInProvider);

    if (userLoggedIn) {
      return const MaterialApp(
        home: ReportsPage()
      );
    } else {
      return const MaterialApp(
        home: LoginPage()
      );
    }
  }
}