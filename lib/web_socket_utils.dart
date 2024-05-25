import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketUtils {
  late WebSocketChannel channel;

  WebSocketUtils(String url) {
    channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  void dispose() {
    channel.sink.close();
  }
}