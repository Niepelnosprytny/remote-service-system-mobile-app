import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:remote_service_system_mobile_app/main.dart';


const host = "https://sebastianinc.toadres.pl";

AndroidOptions _getAndroidOptions() =>
    const AndroidOptions(
      encryptedSharedPreferences: true,
    );
final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

final storageUserProvider = FutureProvider.autoDispose<void>((ref) async {
  final Map<String, String> credentials = await storage.readAll();

  if (credentials.isNotEmpty) {
    ref.read(fetchUserProvider("${credentials["email"]},${credentials["password"]}"));
  }

  ref.onDispose(() {});
});

final fetchUserProvider = FutureProvider.autoDispose.family((ref, String input) async {
  String email = input.split(",")[0];
  String password = input.split(",")[1];

  final response = await http.post(
    Uri.parse('$host/api/auth/login'),
    body: {'email': email, 'password': password},
  );

  final body = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 200) {
    ref.read(userProvider.notifier).update((state) => body["body"]["user"]);
    ref.read(tokenProvider.notifier).update((state) => body["body"]["token"]);
    ref.read(userLoggedInProvider.notifier).update((state) => true);

    await storage.deleteAll();
    await storage.write(key: "email", value: email);
    await storage.write(key: "password", value: password);
  } else {
    snackBarKey.currentState?.showSnackBar(
        const SnackBar(
            content: Text("Nieprawidłowy email lub hasło")
        )
    );
    throw Exception('Nie udało się zalogować. Błąd: ${body["body"]}');
  }
});

final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
final tokenProvider = StateProvider<String?>((ref) => null);
final userLoggedInProvider = StateProvider<bool>((ref) => false);

final fetchReportsListProvider = FutureProvider.autoDispose((ref) async {
  final response = await http.post(
    Uri.parse('$host/api'),
    headers: {
      'authorization': 'Bearer ${ref.read(tokenProvider)}',
    },
    body: """
      SELECT report.id,
        report.title,
        report.status,
        report.created_at,
        report.location_id
      FROM report, user
      WHERE report.created_by = user.id
      AND report.id = ${ref.read(userProvider)?["id"]}
      """
  );

  final body = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 200) {
    ref.read(reportsListProvider.notifier).update((state) => body["body"]);
  } else {
    snackBarKey.currentState?.showSnackBar(
        const SnackBar(
            content: Text("Nie udało się załadować listy zgłoszeń")
        )
    );
    throw Exception('Nie udało się zaladować listy zgłoszeń. Błąd: ${body["body"]}');
  }
});

final reportsListProvider = StateProvider<List<dynamic>?>((ref) => []);

final fetchReportProvider = FutureProvider.autoDispose.family((ref, int id) async {
  final response = await http.get(
    Uri.parse('$host/api/report/$id'),
    headers: {
      'authorization': 'Bearer ${ref.read(tokenProvider)}',
    },
  );

  final body = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 200) {
    ref.read(reportProvider.notifier).update((state) => body["body"]);
  } else {
    snackBarKey.currentState?.showSnackBar(
        const SnackBar(
            content: Text("Nie udało się załadować szczegółów zgłoszenia")
        )
    );
    throw Exception('Nie udało się załadować szczegółów zgłoszenia. Błąd: ${body["body"]}');
  }
});

final reportProvider = StateProvider<Map<String, dynamic>?>((ref) => null);