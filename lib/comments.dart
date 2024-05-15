import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_service_system_mobile_app/providers.dart';

class CommentsPage extends ConsumerWidget {
  const CommentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(webSocketProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Komentarze"),
      ),
      body: asyncValue.when(
        data: (socket) {
          // Handle when data is available
          return Text(socket.toString());
        },
        loading: () {
          // Handle when loading
          return const CircularProgressIndicator();
        },
        error: (error, stackTrace) {
          // Handle when an error occurs
          return Text('Error: $error');
        },
      ),
    );
  }
}