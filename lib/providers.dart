import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final fetchUserProvider = FutureProvider.autoDispose.family(
      (ref, String input) async {
    try {
      final response = await http.post(
        Uri.parse('https://172.18.0.3:3000/api/auth/login'),
        body: {'email': input.split(",")[0], 'password': input.split(",")[1]},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        ref.read(userProvider.notifier).update((state) => data);
        return data;
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred: $error');
    }
  },
);

final userProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final userLoggedInProvider = StateProvider<bool>((ref) => false);