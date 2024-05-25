import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:remote_service_system_mobile_app/main.dart';
import 'package:intl/intl.dart';

const host = "https://sebastianinc.toadres.pl";
//const host = "http://192.168.1.35:3001";

AndroidOptions _getAndroidOptions() => const AndroidOptions(
  encryptedSharedPreferences: true,
);

List<dynamic> formatDate(List<dynamic> list) {
  return list.map((item) {
    final date = DateTime.parse(item["created_at"]);
    final formattedDate = DateFormat("HH:mm dd.MM.yyyy").format(date);
    return {...item, "created_at": formattedDate};
  }).toList();
}

List<dynamic>? sortByDate(List<dynamic>? list, {bool desc = false}) {
  if (list == null || list.isEmpty) {
    return [];
  }

  list.sort((a, b) {
    DateTime dateA = DateTime.parse(a['created_at']);
    DateTime dateB = DateTime.parse(b['created_at']);
    return desc ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
  });

  return list;
}

final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

final storageUserProvider = FutureProvider.autoDispose<void>((ref) async {
  final Map<String, String> credentials = await storage.readAll();

  if (credentials.isNotEmpty) {
    ref.read(fetchUserProvider("${credentials["email"]},${credentials["password"]}"));
  }

  ref.onDispose(() {});
});

final fetchUserProvider = FutureProvider.autoDispose.family((ref, String input) async {
  isLoaded = false;

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

    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken();

    var deviceToken = jsonEncode({
      "token": token,
      "user_id": ref.read(userProvider)?["id"]
    });

    ref.read(submitDeviceTokenProvider(deviceToken));
  } else {
    snackBarKey.currentState?.showSnackBar(
        const SnackBar(content: Text("Nieprawidłowy email lub hasło")));
  }

  isLoaded = true;
});

final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
final tokenProvider = StateProvider<String?>((ref) => null);
final userLoggedInProvider = StateProvider<bool>((ref) => false);

final fetchReportsListProvider = FutureProvider.autoDispose((ref) async {
  isLoaded = false;

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
      """,
      );

      final body = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

      if (body["status"] == 200) {
        ref.read(reportsListProvider.notifier).update((state) => formatDate(body["body"]));
      } else {
        ref.read(reportsListProvider.notifier).update((state) => null);
      }

isLoaded = true;
    });

final reportsListProvider = StateProvider<List<dynamic>?>((ref) => []);

final fetchCommentsProvider = FutureProvider.autoDispose.family((ref, int id) async {
  isLoaded = false;
  
  final response = await http.get(
        Uri.parse('$host/api/comment/byReport/$id'),
        headers: {
          'authorization': 'Bearer ${ref.read(tokenProvider)}',
        }
      );

      final body = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

      if (body["status"] == 200) {
        var data = sortByDate(body["body"], desc: true);

        ref.read(commentsProvider.notifier).update((state) => formatDate(data!));
      } else {
        ref.read(commentsProvider.notifier).update((state) => []);
      }

      isLoaded = true;
});

final commentsProvider = StateProvider<List<dynamic>?>((ref) => []);

final fetchReportProvider = FutureProvider.autoDispose.family((ref, int id) async {
  isLoaded = false;

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
    ref.read(reportProvider.notifier).update((state) => null);
  }

  isLoaded = true;
});

final reportProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final fetchLocationsListProvider = FutureProvider.autoDispose((ref) async {
  final response = await http.post(
      Uri.parse('$host/api'),
      headers: {
        'authorization': 'Bearer ${ref.read(tokenProvider)}',
      },
      body
          : """
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

  final body =
  jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 200) {
    ref.read(locationsListProvider.notifier).update((state) => body["body"]);
  } else {
    ref.read(locationsListProvider.notifier).update((state) => null);
  }
});

final locationsListProvider = StateProvider<List<dynamic>?>((ref) => []);

final fetchNotificationsListProvider = FutureProvider.autoDispose((ref) async {
  final response = await http.get(
      Uri.parse('$host/api/notification/byUser/${ref.read(userProvider)?["id"]}'),
      headers: {
        'authorization': 'Bearer ${ref.read(tokenProvider)}',
      });

  final body =
  jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 200) {
    ref.read(notificationsListProvider.notifier).update((state) => formatDate(sortByDate(body["body"], desc: true)!));
  } else {
    ref.read(notificationsListProvider.notifier).update((state) => null);
  }
});

final notificationsListProvider = StateProvider<List<dynamic>?>((ref) => []);

final fetchReportFilesListProvider = FutureProvider.autoDispose.family((ref, int id) async {
  final response = await http.post(
      Uri.parse('$host/api'),
      headers: {
        'authorization': 'Bearer ${ref.read(tokenProvider)}',
      },
      body: "SELECT * FROM file WHERE report_id = $id");

  final body =
  jsonDecode(const Utf8Decoder().convert(response.bodyBytes));


  if (body["status"] == 200) {
    ref.read(reportFilesListProvider.notifier).update((state) => body["body"]);
  } else {
    ref.read(reportFilesListProvider.notifier).update((state) => null);
  }
});

final reportFilesListProvider = StateProvider<List<dynamic>?>((ref) => []);

final submitReportProvider = FutureProvider.autoDispose.family((ref, String report) async {
  final response = await http.post(
    Uri.parse('$host/api/report'),
    headers: {
      'authorization': 'Bearer ${ref.read(tokenProvider)}',
      'Content-Type': 'application/json'
    },
    body: report,
  );

  final body = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 201) {
    if(filesList.isNotEmpty) {
      var data = {
        "reportId": body["body"],
        "commentId": null
      };

      ref.read(submitFilesProvider(data));
    }

    snackBarKey.currentState?.showSnackBar(
        const SnackBar(content: Text("Pomyślnie wysłano zgłoszenie"))
    );
  } else {
    snackBarKey.currentState?.showSnackBar(
        SnackBar(
            content: Text("Błąd podczas wysyłania zgłoszenia: ${body["body"]}")));
  }
});

final submitCommentProvider = FutureProvider.autoDispose.family((ref, Map<String, dynamic> comment) async {
  final response = await http.post(
    Uri.parse('$host/api/comment'),
    headers: {
      'authorization': 'Bearer ${ref.read(tokenProvider)}',
      'Content-Type': 'application/json'
    },
    body: jsonEncode(comment),
  );

  final body = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 201) {
    if(filesList.isNotEmpty) {
      var data = {
        "reportId": comment["report_id"],
        "commentId": body["body"]
      };

      ref.read(submitFilesProvider(data));
    }
  } else {
    snackBarKey.currentState?.showSnackBar(
        SnackBar(
            content: Text("Błąd podczas wysyłania komentarza: ${body["body"]}")));
  }
});

final submitFilesProvider = FutureProvider.autoDispose.family((ref, Map<String, dynamic> data) async {
  filesLoaded = false;

  final request = http.MultipartRequest('POST', Uri.parse('$host/api/file'));
  
  for (var file in filesList) {
    var part = await http.MultipartFile.fromPath(
      'file',
      file.path,
    );

    request.files.add(part);
  }

  request.fields['report_id'] = data["reportId"].toString();
  request.fields['comment_id'] = data["commentId"].toString();

  request.headers['Content-Type'] = 'multipart/form-data';
  request.headers['authorization'] = 'Bearer ${ref.read(tokenProvider)}';

  final response = await request.send();

  if (response.statusCode == 200) {
    snackBarKey.currentState?.showSnackBar(
        const SnackBar(content: Text("Pomyślnie wysłano pliki")));
  } else {
    snackBarKey.currentState?.showSnackBar(
        SnackBar(
            content: Text("Błąd podczas wysyłania plików: ${response.statusCode}")));
  }

  filesList = [];
  filesLoaded = true;
});

List<File> filesList = [];
bool filesLoaded = true;

final fetchLocationProvider = FutureProvider.autoDispose.family((ref, int id) async {
  final response = await http.get(
      Uri.parse('$host/api/location/$id'),
      headers: {
        'authorization': 'Bearer ${ref.read(tokenProvider)}',
        'Content-Type': 'application/json'
      });

  final body =
  jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 200) {
    ref.read(locationProvider.notifier).update((state) => body["body"]);
  } else {
    ref.read(locationProvider.notifier).update((state) => null);
  }
});

final locationProvider = StateProvider<dynamic>((ref) => null);

final submitDeviceTokenProvider =
FutureProvider.autoDispose.family((ref, String deviceToken) async {
  final response = await http.post(
      Uri.parse('$host/api/deviceToken'),
      headers: {
        'authorization': 'Bearer ${ref.read(tokenProvider)}',
        'Content-Type': 'application/json'
      },
      body: deviceToken);

  final body =
  jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] != 201) {
    snackBarKey.currentState?.showSnackBar(
        SnackBar(
            content: Text("Bład podczas wysyłania tokenu urządzenia: ${body["body"]}"))
    );
  }
});

final updateSeenProvider = FutureProvider.autoDispose.family((ref, Map<String, dynamic> data) async {
  isLoaded = false;

  final response = await http.patch(
      Uri.parse('$host/api/userNotification/updateSeen'),
      headers: {
        'authorization': 'Bearer ${ref.read(tokenProvider)}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data));

  final body
  =
  jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 200) {
    snackBarKey.currentState?.showSnackBar(
        const SnackBar(content: Text("Pomyślnie oznaczono jako przeczytane"))
    );
  } else {
    snackBarKey.currentState?.showSnackBar(
        SnackBar(
            content: Text("Bład podczas zmiany statusu powiadomień: ${body["body"]}"))
    );
  }

  isLoaded = true;
});

final submitNotificationProvider = FutureProvider.autoDispose.family((ref, Map<String, dynamic> data) async {
  await http.post(
      Uri.parse('$host/api/notification'),
      headers: {
        'authorization': 'Bearer ${ref.read(tokenProvider)}',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data));
});

final fetchReportHandledByProvider = FutureProvider.autoDispose.family((ref, int id) async {
  final response = await http.post(
      Uri.parse('$host/api'),
      headers: {
        'authorization': 'Bearer ${ref.read(tokenProvider)}',
      },
      body
          : """
      SELECT user_id FROM report_handled_by WHERE report_id = $id
      """
  );

  final body = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));

  if (body["status"] == 200) {
    List<int> ids = (body["body"] as List).map((item) => item["user_id"] as int).toList();

    int userId = ref.read(userProvider)?["id"];

    if (!ids.contains(userId)) {
      ids.add(userId);
    }
    
    ref.read(reportHandledByProvider.notifier).update((state) => ids);
  } else {
    ref.read(reportHandledByProvider.notifier).update((state) => []);
  }
});

final reportHandledByProvider = StateProvider<List<dynamic>>((ref) => []);

bool isLoaded = true;