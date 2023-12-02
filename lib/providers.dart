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

final fetchUserProvider = FutureProvider.autoDispose.family(
      (ref, String input) async {
        String email = input.split(",")[0];
        String password = input.split(",")[1];

    try {
      final response = await http.post(
        Uri.parse('https://172.18.0.3:3000/api/auth/login'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        ref.read(userProvider.notifier).update((state) => data);
        ref.read(userLoggedInProvider.notifier).update((state) => true);

        await storage.deleteAll();
        await storage.write(key: "email", value: email);
        await storage.write(key: "password", value: password);

        return data;
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred: $error');
    }
  },
);

final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final userLoggedInProvider = StateProvider<bool>((ref) => false);