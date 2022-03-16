import 'package:flutter/material.dart';
import 'package:streamer/pages/director.dart';
import 'package:streamer/pages/participant.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(),
            TextField(),
            TextButton(
              onPressed: () {
                //take us to participant
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Participant()),
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
              onPressed: () {
                //take us to director
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Director()),
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
