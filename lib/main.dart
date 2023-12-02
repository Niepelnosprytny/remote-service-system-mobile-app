import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'reports.dart';
import 'providers.dart';
import 'dart:io';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );

  HttpOverrides.global = DevHttpOverrides();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool userLoggedIn = ref.watch(userLoggedInProvider);
    ref.watch(storageUserProvider);

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