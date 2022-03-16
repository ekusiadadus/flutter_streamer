import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamer/pages/director.dart';
import 'package:streamer/pages/participant.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _channelName = TextEditingController();
  final _userName = TextEditingController();
  late int uid;

  @override
  void initState() {
    super.initState();
    getUserUid();
  }

  Future<void> getUserUid() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? storedUid = preferences.getInt("localUid");
    if (storedUid != null) {
      uid = storedUid;
    } else {
      int time = DateTime.now().millisecondsSinceEpoch;
      uid = int.parse(time.toString().substring(1, time.toString().length - 3));
      preferences.setInt("localUid", uid);
      print("settingUID: $uid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/streamer.png"),
            const SizedBox(
              height: 5,
            ),
            const Text("Multi Streaming with Friends"),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: TextField(
                controller: _userName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  hintText: 'User Name',
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: TextField(
                controller: _channelName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  hintText: 'Channel Name',
                ),
              ),
            ),
            TextField(),
            TextButton(
              onPressed: () async {
                //take us to participant
                await [Permission.camera, Permission.microphone].request();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Participant(
                      channelName: _channelName.text,
                      userName: _userName.text,
                      uid: uid,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text(
                    'Participant',
                    style: TextStyle(fontSize: 20),
                  ),
                  Icon(
                    Icons.live_tv,
                  )
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                //take us to director
                await [Permission.camera, Permission.microphone].request();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Director(
                      channelName: _channelName.text,
                      uid: uid,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text(
                    'Director',
                    style: TextStyle(fontSize: 20),
                  ),
                  Icon(
                    Icons.cut,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
