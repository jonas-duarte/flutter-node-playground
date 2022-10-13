import 'package:flutter/material.dart';
import 'package:flutter_parent/application/app.dart';
import 'package:flutter_parent/application/app_websocket_server.dart';
import 'package:flutter_parent/application/ws_provider.dart';

void main() {
  WsProvider.ws = AppWebSocketServer.listen(Uri.parse('ws://localhost:8080'))
    ..onMessage((wsMessage) {
      print('*** MSG: ${wsMessage.content}');
    });

  runApp(
    const MyApp(),
  );

  Future.delayed(const Duration(seconds: 10), () {
    WsProvider.ws
      ..sendMessage(AppWebSocketMessage.text('oie 111'))
      ..sendMessage(AppWebSocketMessage.text('oie 222'),
          delay: const Duration(milliseconds: 500))
      ..sendMessage(AppWebSocketMessage.text('oie 333'),
          delay: const Duration(milliseconds: 1000))
      ..sendMessage(AppWebSocketMessage.text('oie 444'),
          delay: const Duration(milliseconds: 1500));
  });
}
