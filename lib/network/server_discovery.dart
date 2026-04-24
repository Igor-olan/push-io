import 'dart:convert';
import 'package:udp/udp.dart';

class ServerDiscovery {
  Future<String?> findServer() async {
    final receiver = await UDP.bind(Endpoint.any(port: Port(41234)));

    try {
      await for (final datagram in receiver.asStream(
        timeout: const Duration(seconds: 3),
      )) {
        if (datagram == null) continue;

        final msg = utf8.decode(datagram.data);
        final json = jsonDecode(msg);

        if (json['type'] == 'DISCOVERY') {
          final ip = datagram.address.address;
          final port = json['port'];

          receiver.close();
          return "ws://$ip:$port";
        }
      }
    } catch (e) {
      print("Discovery error: $e");
    }

    receiver.close();
    return null;
  }
}