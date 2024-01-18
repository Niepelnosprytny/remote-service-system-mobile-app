import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:remote_service_system_mobile_app/main.dart';

const host = "https://sebastianinc.toadres.pl";
// const host = "http://172.18.0.2:3000";

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
      AND report.created_by = ${ref.read(userProvider)?["id"]}
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

final fetchLocationsListProvider = FutureProvider.autoDispose((ref) async {
  final response = await http.post(
      Uri.parse('$host/api'),
      headers: {
        'authorization': 'Bearer ${ref.read(tokenProvider)}',
      },
      body: """
      SELECT location.id,
        location.name,
        location.street,
        location.city,
        location.postcode
      FROM location, user
      WHERE location.client = user.employer
      AND user.id = ${ref.read(userProvider)?["id"]}
      """
  );

  final body = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 200) {
    ref.read(locationsListProvider.notifier).update((state) => body["body"]);
  } else {
    snackBarKey.currentState?.showSnackBar(
        const SnackBar(
            content: Text("Nie udało się załadować listy lokacji")
        )
    );
    throw Exception('Nie udało się zaladować listy zgłoszeń. Błąd: ${body["body"]}');
  }
});

final locationsListProvider = StateProvider<List<dynamic>?>((ref) => []);

final submitReportProvider = FutureProvider.autoDispose.family((ref, String report) async {
  final response = await http.post(
    Uri.parse('$host/api/report'),
    headers: {
      'authorization': 'Bearer ${ref.read(tokenProvider)}',
      'Content-Type': 'application/json'
    },
    body: report
  );

  final body = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 201 && ref.read(filesListProvider)!.isNotEmpty) {
    try {
      var data = {
        "reportId": body["body"],
        "commentId": null
      };

      ref.read(submitFilesProvider(data));

    } catch (error) {
      SnackBar(
          content: Text("Błąd podczas wysyłania zgłoszenia: ${body["body"]}")
      );
    }

    snackBarKey.currentState?.showSnackBar(
        const SnackBar(
            content: Text("Pomyślnie wysłano zgłoszenie")
        )
    );
  } else {
    snackBarKey.currentState?.showSnackBar(
        SnackBar(
            content: Text("Błąd podczas wysyłania zgłoszenia: ${body["body"]}")
        )
    );
  }
});

final submitFilesProvider = FutureProvider.autoDispose.family((ref, Map<String, dynamic> data) async {
  final request = http.MultipartRequest('POST', Uri.parse('$host/api/file'));

    for (var file in ref.read(filesListProvider)!) {
      var part = await http.MultipartFile.fromPath(
        'file',
        await file.path,
      );

      request.files.add(part);
    }

    request.fields['report_id'] = data["reportId"].toString();
    request.fields['comment_id'] = data["commentId"].toString();

    request.headers['Content-Type'] = 'multipart/form-data';
    request.headers['authorization'] = 'Bearer ${ref.read(tokenProvider)}';

    final response = await request.send();

    if (response.statusCode == 201) {
      snackBarKey.currentState?.showSnackBar(
          const SnackBar(
              content: Text("Pomyślnie wysłano pliki")
          )
      );
    } else {
      snackBarKey.currentState?.showSnackBar(
          SnackBar(
              content: Text("Błąd podczas wysyłania plików: ${response.statusCode}")
          )
      );
    }
});

final filesListProvider = StateProvider<List<dynamic>?>((ref) => []);