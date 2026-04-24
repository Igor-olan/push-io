import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'server_discovery.dart';

class SocketService {
  late WebSocketChannel channel;

  Function(Map data)? onState;
  String myId = "";

  Future<bool> connectAuto() async {
    final discovery = ServerDiscovery();
    final url = await discovery.findServer();

    if (url == null) return false;

    channel = WebSocketChannel.connect(Uri.parse(url));
    _listen();
    return true;
  }

  void connectManual(String ip) {
    channel = WebSocketChannel.connect(Uri.parse("ws://$ip:3000"));
    _listen();
  }

  void _listen() {
    channel.stream.listen((data) {
      final json = jsonDecode(data);

      if (json['type'] == 'init') {
        myId = json['id'];
      }

      if (json['type'] == 'state') {
        onState?.call(json);
      }
    });
  }

  void sendInput(double x, double y, bool sprint, bool dash) {
    channel.sink.add(jsonEncode({
      "x": x,
      "y": y,
      "sprint": sprint,
      "dash": dash,
    }));
  }
}