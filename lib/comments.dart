import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_service_system_mobile_app/providers.dart';

class CommentsPage extends ConsumerWidget {
  final int reportId;

  const CommentsPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(webSocketProvider);
    ref.read(fetchCommentsProvider(reportId));
    final comments = ref.read(commentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Komentarze"),
      ),
      body: Column(
        children: [
          asyncValue.when(
            data: (socket) {
              print(socket);

              return Text(socket.toString());
            },
            loading: () {
              return const CircularProgressIndicator();
            },
            error: (error, stackTrace) {
              print(error);
              return Text('Error: $error');
            },
          ),
        //   ListView.builder(
        //     itemCount: comments?.length,
        //     itemBuilder: (context, index) {
        //       final comment = comments?[index];
        //       return ListTile(
        //         title: Text(comment['content']),
        //         subtitle: Text(comment['created_at']),
        //       );
        //     },
        //   )
         ],
      ),
    );
  }
}