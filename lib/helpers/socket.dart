import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocketHelper {
  SocketIO socket = SocketIOManager().createSocketIO(
    dotenv.env['BACKEND_URL'],
    '/',
  );

  SocketHelper() {
    _initSocket();
  }

  void _initSocket() {
    socket.init();
    socket.connect();
  }
}
