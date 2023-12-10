import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  try {
    final response = await http.post(
      Uri.parse('https://172.18.0.3:3000/api/auth/login'),
      body: {'email': email, 'password': password},
    );

    final body = json.decode(response.body);

    if (body["status"] == 200) {
      ref.read(userProvider.notifier).update((state) => body["body"]["user"]);
      ref.read(tokenProvider.notifier).update((state) => body["body"]["token"]);
      ref.read(userLoggedInProvider.notifier).update((state) => true);

      await storage.deleteAll();
      await storage.write(key: "email", value: email);
      await storage.write(key: "password", value: password);
    } else {
      throw Exception('Nie udało się zalogować. Błąd: ${body["body"]}');}
  } catch (error) {
    throw Exception('Wystąpił błąd: $error');
  }
});

final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);
final tokenProvider = StateProvider<String?>((ref) => null);
final userLoggedInProvider = StateProvider<bool>((ref) => false);

final fetchReportsListProvider = FutureProvider.autoDispose((ref) async {
  try {
    final response = await http.post(
      Uri.parse('https://172.18.0.3:3000/api'),
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

    final body = json.decode(response.body);

    if (body["status"] == 200) {
      ref.read(reportsListProvider.notifier).update((state) => body["body"]);
    } else {
      throw Exception('Nie udało się zaladować listy raportów. Błąd: ${body["body"]}');
    }
  } catch (error) {
    throw Exception('Wystąpił problem: $error');
  }
});

final reportsListProvider = StateProvider<List<dynamic>?>((ref) => []);