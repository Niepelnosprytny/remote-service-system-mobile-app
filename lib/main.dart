import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'reports_list.dart';
import 'providers.dart';
import 'package:sizer/sizer.dart';
import 'theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );
}

final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool userLoggedIn = ref.watch(userLoggedInProvider);
    ref.watch(storageUserProvider);

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          home: userLoggedIn ? const ReportsListPage() : const LoginPage(),
          title: "Sebastian Inc. mobile app",
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          scaffoldMessengerKey: snackBarKey,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}