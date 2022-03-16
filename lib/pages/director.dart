import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:streamer/controllers/director_controller.dart';
import 'package:streamer/models/director_model.dart';

class Director extends StatefulWidget {
  final String channelName;
  final int uid;
  const Director({
    Key? key,
    required this.channelName,
    required this.uid,
  }) : super(key: key);

  @override
  State<Director> createState() => _DirectorState();
}

class _DirectorState extends State<Director> {
  @override
  void initState() {
    super.initState();
    context
        .read(directorController.notifier)
        .joinCall(channelName: widget.channelName, uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context,
          T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
        DirectorController directorNotifier =
            watch(directorController.notifier);
        DirectorModel directorData = watch(directorController);
        return Scaffold(
          body: Center(
            child: Text("Director"),
          ),
        );
      },
    );
  }
}
