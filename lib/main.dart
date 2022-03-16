import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streamer/pages/home.dart';

class EnvironmentConfig {
  static const agoraId = String.fromEnvironment(
    'AGORA_ID',
    defaultValue: 'AGORA_ID',
  );
  static const agoraChannelName = String.fromEnvironment(
    'AGORA_CHANNEL_NAME',
    defaultValue: 'test',
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Home(),
      ),
    );
  }
}
