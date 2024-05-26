import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remote_service_system_mobile_app/files_list.dart';
import 'package:remote_service_system_mobile_app/providers.dart';
import 'package:remote_service_system_mobile_app/web_socket_utils.dart';
import 'package:sizer/sizer.dart';
import 'files_picker.dart';
import 'notifications_list.dart';

class CommentsPage extends ConsumerStatefulWidget {
  final int reportId;
  final String reportTitle;

  const CommentsPage({super.key, required this.reportId, required this.reportTitle});

  @override
  ConsumerState<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> {
  WebSocketUtils? commentsSocket;
  bool isPickingFiles = false;
  String newComment = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    commentsSocket = WebSocketUtils(
        "wss://sebastianinc.toadres.pl/api/websockets/chatroom");
    ref.read(fetchCommentsProvider(widget.reportId));
    ref.read(fetchReportHandledByProvider(widget.reportId));
  }

  @override
  void dispose() {
    commentsSocket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider);
    final user = ref.watch(userProvider);
    final files = ref.watch(reportFilesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Komentarze"),
        actions: const [NotificationsButton()],
      ),
      body: Visibility(
        visible: isLoaded,
        replacement: const Center(
            child: CircularProgressIndicator()
        ),
        child: Column(
          children: [
            Expanded(
              child: comments != null && comments.isNotEmpty
                  ? ListView.builder(
                reverse: true,
                shrinkWrap: true,
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
                        padding: EdgeInsets.symmetric(horizontal: 0.5.h, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: user?["id"] == comment["created_by"] ? const Color(0xFF7db3b4) : const Color(0xFFc77f89),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 1.5.h),
                              child: Text(
                                comment["content"],
                                style: const TextStyle(
                                    color: Colors.white
                                ),
                              ),
                            ),
                            files != null && commentFiles(files, comment["id"]).isNotEmpty
                                ? Padding(
                              padding: EdgeInsets.fromLTRB(1.5.w, 1.5.h, 1.5.w, 0),
                              child: FilesList(files: commentFiles(files, comment["id"])),
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
              visible: !commentSubmitted || !filesLoaded,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 10.h,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7db3b4),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Center(
                        child: SizedBox(
                            height: 2.5.h,
                            width: 2.5.h,
                            child: CircularProgressIndicator()
                        )
                    ),
                  ),
                ),
            ),
            Visibility(
                visible: isPickingFiles,
                child: const SingleChildScrollView(
                    child: FilesPicker()
                )
            ),
            Form(
              key: formKey,
              child: Padding(
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
                        initialValue: "",
                        textAlign: TextAlign.left,
                        onChanged: (value) {
                          newComment = value;
                        },
                        validator: (value) {
                          if(value == null || value.isEmpty) {
                            return "Wypełnij komentarz";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Wpisz komentarz",
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 1.5.h),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(1.5.h),
                      child: GestureDetector(
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              Map<String, dynamic> data = {
                                "content": newComment,
                                "report_id": widget.reportId,
                                "created_by": ref.read(userProvider)?["id"]
                              };

                              Map<String, dynamic> notificationData = {
                                "content": "Nowy komentarz dla ${widget.reportTitle}",
                                "report_id": widget.reportId,
                                "users": ref.read(reportHandledByProvider)
                              };

                              ref.read(submitNotificationProvider(notificationData));

                              ref.read(submitCommentProvider(data));

                              FocusManager.instance.primaryFocus?.unfocus();

                              commentsSocket?.sendMessage(jsonEncode({"message": 'init', "reportId": widget.reportId}));

                              setState(() {
                                formKey.currentState?.reset();
                                newComment = "";
                                isPickingFiles = false;
                              });
                            }
                          },
                          child: const Icon(Icons.send, color: Colors.blue)
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 0.5.h,
            )
          ],
        ),
      ),
    );
  }
}

List<dynamic> commentFiles(List<dynamic> files, dynamic commentId) {
  List<dynamic> commentFiles = [];

  for (int i = 0; i < files.length; i++) {
    if (files[i]["comment_id"] == commentId) {
      commentFiles.add(files[i]);
    }
  }

  return commentFiles;
}
