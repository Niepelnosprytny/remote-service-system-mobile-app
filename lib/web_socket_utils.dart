import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketUtils {
  final WebSocketChannel channel;

  WebSocketUtils(String url) : channel = WebSocketChannel.connect(Uri.parse(url));

  void listen(Function onMessageReceived) {
    channel.stream.listen((message) {
      print('Received: $message');
      onMessageReceived();
    });
  }

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  void dispose() {
    channel.sink.close();
  }
}