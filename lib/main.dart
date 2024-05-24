import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final GlobalKey<ScaffoldMessengerState> snackBarKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
@override
void initState() {
  super.initState();
  FirebaseMessaging.onMessageOpenedApp.listen(
        (RemoteMessage message) {
      final reportId = message.data['reportId'];

      setState(() {
        ref.read(fetchNotificationsListProvider);
        ref.read(fetchCommentsProvider(reportId));
        isLoaded = true;
      });

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
}

  @override
  Widget build(BuildContext context) {
    final bool userLoggedIn = ref.watch(userLoggedInProvider);
    ref.read(storageUserProvider);

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          home: Visibility(
            visible: userLoggedIn || isLoaded,
            replacement: const Center(
              child: CircularProgressIndicator(),
            ),
            child: userLoggedIn ? const ReportsListPage() : const LoginPage()
          ),
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