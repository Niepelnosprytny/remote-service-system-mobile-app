import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_service_system_mobile_app/files_list.dart';
import 'package:remote_service_system_mobile_app/providers.dart';
import 'package:sizer/sizer.dart';
import 'files_picker.dart';
import 'notifications_list.dart';

List<dynamic> commentFiles(List<dynamic> files, int commentId) {
  List<dynamic> commentFiles = [];

  for(int i = 0; i < files.length; i++) {
    if(files[i]["comment_id"] == commentId) {
      commentFiles.add(files);
    }
  }

  return commentFiles;
}

class CommentsPage extends ConsumerStatefulWidget {
  final int reportId;

  const CommentsPage({super.key, required this.reportId});

  @override
  ConsumerState<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> {
  bool isPickingFiles = false;

  @override
  Widget build(BuildContext context) {
    ref.read(fetchCommentsProvider(widget.reportId));
    final comments = ref.watch(commentsProvider);
    final user = ref.watch(userProvider);
    final files = ref.watch(reportFilesListProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Komentarze"),
        actions: const [NotificationsButton()],
      ),
      body: Column(
        children: [
          Expanded(
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
                      child: Column(
                        children: [
                          Text(
                            comment["content"],
                            style: const TextStyle(
                              color: Colors.white
                            ),
                          ),
                          files != null && commentFiles(files, comment["id"]).isNotEmpty
                      ? Padding(
                        padding: EdgeInsets.fromLTRB(1.5.w, 1.5.h, 1.5.w, 0),
                        child: FilesList(files: files),
                      )
                              : const SizedBox(height: 0)
                        ],
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
          Visibility(
              visible: isPickingFiles,
              child: const FilesPicker()
          ),
          Padding(
            padding: EdgeInsets.all(1.5.h),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(1.5.h),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPickingFiles = !isPickingFiles;
                      });
                    },
                    child: const Icon(Icons.attach_file, color: Colors.grey),
                  ),
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
          SizedBox(
            height: 0.5.h,
          )
        ],
      ),
    );
  }
}