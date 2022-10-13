import 'package:flutter_parent/application/app_websocket_server.dart';

class WsProvider {
  const WsProvider._();

  static AppWebSocketServer? _ws;

  static AppWebSocketServer get ws => _ws!;
  static set ws(AppWebSocketServer value) => _ws = value;
}
