import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketHelper {
  IO.Socket _socket = IO.io(dotenv.env['BACKEND_URL'], IO.OptionBuilder().setTransports(['websocket']).build());
  IO.Socket get socket => _socket;

  SocketHelper() {
    _initSocket();
  }

  void _initSocket() {
    _socket.onConnect((_) {
      print('c001 socket connect');
    });
    // socket.on('event', (data) => print(data));
    _socket.onDisconnect((_) => print('disconnect'));
    // socket.on('fromServer', (_) => print(_));
  }
}
