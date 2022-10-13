import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

enum AppWebSocketMessageType {
  counterChanged,
  text,
}

class AppWebSocketMessage {
  final AppWebSocketMessageType type;
  final String content;

  const AppWebSocketMessage({
    required this.type,
    required this.content,
  });

  factory AppWebSocketMessage.text(String message) => AppWebSocketMessage(
        type: AppWebSocketMessageType.text,
        content: message,
      );

  factory AppWebSocketMessage.fromMap(Map<String, dynamic> map) =>
      AppWebSocketMessage(
        content: map['content'] as String? ?? 'EMPTY',
        type: AppWebSocketMessageType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => AppWebSocketMessageType.text,
        ),
      );

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'content': content,
      };
}

class AppWebSocketServer {
  AppWebSocketServer._();

  final StreamController<AppWebSocketMessage> _messagesCtrl =
      StreamController<AppWebSocketMessage>.broadcast();

  final StreamController<String> _responsesCtrl = StreamController<String>();

  void sendMessage(AppWebSocketMessage message, {Duration? delay}) {
    if (delay != null) {
      Future.delayed(delay, () => _messagesCtrl.add(message));
    } else {
      _messagesCtrl.add(message);
    }
  }

  void onMessage(void Function(AppWebSocketMessage) handler) {
    _responsesCtrl.stream.listen((value) {
      AppWebSocketMessage message;
      try {
        message = AppWebSocketMessage.fromMap(
          Map<String, dynamic>.from(jsonDecode(value)),
        );
      } catch (e) {
        message = AppWebSocketMessage.text(value);
      }

      handler.call(message);
    });
  }

  factory AppWebSocketServer.listen(Uri uri) {
    final wsServer = AppWebSocketServer._();

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(webSocketHandler((webSocket) {
      wsServer._messagesCtrl.stream.listen((event) {
        webSocket.sink.add(jsonEncode(event.toMap()));
      });

      webSocket.stream.listen((message) {
        wsServer._responsesCtrl.sink.add(message);
      });
    }));

    final httpServer =
        shelf_io.serve(handler, uri.host, uri.port).then((server) {
      server.autoCompress = true;
      print('Serving at ws://${server.address.host}:${server.port}');
    });

    return wsServer;
  }
}
