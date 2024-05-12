import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'report.dart';
import 'reports_list.dart';
import 'providers.dart';
import 'package:sizer/sizer.dart';
import 'theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey<ScaffoldMessengerState>();
bool isListening = false;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool userLoggedIn = ref.watch(userLoggedInProvider);
    ref.watch(storageUserProvider);

    if (!isListening) {
      FirebaseMessaging.onMessageOpenedApp.listen(
            (RemoteMessage message) {
          final reportId = message.data['reportId'];
          ref.read(fetchNotificationsListProvider);

          if (reportId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportPage(id: reportId),
              ),
            );
          }
        },
      );

      FirebaseMessaging.onMessage.listen((message) {
        ref.read(fetchNotificationsListProvider);
      });

      isListening = true;
    }

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          home: userLoggedIn ? const ReportsListPage() : const LoginPage(),
          title: "Sebastian Inc. mobile app",
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.lightTheme(),
          scaffoldMessengerKey: snackBarKey,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}