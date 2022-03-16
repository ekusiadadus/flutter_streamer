import 'package:flutter/material.dart';

class Director extends StatefulWidget {
  final String channelName;
  const Director({
    Key? key,
    required this.channelName,
  }) : super(key: key);

  @override
  State<Director> createState() => _DirectorState();
}

class _DirectorState extends State<Director> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Director"),
      ),
    );
  }
}
