import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_service_system_mobile_app/providers.dart';
import 'package:sizer/sizer.dart';

class CommentsPage extends ConsumerWidget {
  final int reportId;

  const CommentsPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(fetchCommentsProvider(reportId));
    final comments = ref.watch(commentsProvider);
    final user = ref.watch(userProvider);


    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Komentarze"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 27,
            child: comments != null && comments.isNotEmpty
                ? ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                final comment = comments[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                  child: Align(
                    alignment: user?["id"] == comment["created_by"] ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 80.w
                      ),
                      padding: EdgeInsets.all(2.h),
                      decoration: BoxDecoration(
                        color: user?["id"] == comment["created_by"] ? const Color(0xFF7db3b4) : const Color(0xFFc77f89),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Text(
                        comment["content"]
                      ),
                    ),
                  ),
                );
                              },
                            )
                : const Center(
              child: Text("Brak komentarzy"),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(1.5.h),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(1.5.h),
                  child: const Icon(Icons.attach_file, color: Colors.grey),
                ),
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: "Wpisz komentarz",
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 1.5.h),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(1.5.h),
                  child: const Icon(Icons.send, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}