import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:streamer/models/user.dart';
import 'package:streamer/utils/const.dart';

class Participant extends StatefulWidget {
  final String channelName;
  final String userName;
  final int uid;

  const Participant({
    Key? key,
    required this.channelName,
    required this.userName,
    required this.uid,
  }) : super(key: key);

  @override
  State<Participant> createState() => _ParticipantState();
}

class _ParticipantState extends State<Participant> {
  final List<AgoraUser> _users = [];

  // Agora API Documentation
  // https://docs.agora.io/en/rtc/restfulapi/#/

  // Agora API Documentation for RTM Java Ref
  // https://docs.agora.io/en/Real-time-Messaging/API%20Reference/RTM_java/index.html
  late RtcEngine _engine;
  AgoraRtmClient? _client;
  AgoraRtmChannel? _channel;
  bool muted = false;
  bool videoDisabled = false;

  @override
  void initState() {
    super.initState();
    initializeAgora();
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    _channel?.leave();
    _client?.logout();
    _client?.destroy();
    super.dispose();
  }

  Future<void> initializeAgora() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(EnvironmentConfig.agoraId));
    _client = await AgoraRtmClient.createInstance(EnvironmentConfig.agoraId);

    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);

    //Callback for the RtC Engine
    _engine.setEventHandler(
      RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
        setState(
          () {
            _users.add(AgoraUser(uid: uid));
          },
        );
      }, leaveChannel: (stats) {
        setState(() {
          _users.clear();
        });
      }),
    );

    //Callback for the RtC Client
    _client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      // print("Private Message from " + peerId + ": " + (message.text));
    };

    _client?.onConnectionStateChanged = (int state, int reason) {
      // print("Connection state changed: " + state.toString() + ", reason: " + reason.toString());
      if (state == 5) {
        _channel?.leave();
        _client?.logout();
        _client?.destroy();
        // print("Logged out from Streameer.");
      }
    };
    // Join the RTM and RTC channels
    await _client?.login(null, widget.uid.toString());
    _channel = await _client?.createChannel(widget.channelName);
    await _channel?.join();
    await _engine.joinChannel(null, widget.channelName, null, widget.uid);

    //Callback for the RtC Channel
    _channel?.onMemberJoined = (AgoraRtmMember member) {
      // print(
      //     "Member joined: " + member.userId + ', channel: ' + member.channelId);
    };
    _channel?.onMemberLeft = (AgoraRtmMember member) {
      // print("Member left: " + member.userId + ', channel: ' + member.channelId);
    };
    _channel?.onMessageReceived = (AgoraRtmMessage message, AgoraRtmMember member) {
      // print("Public Message from " + member.userId + ": " + (message.text));
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [_broadcastView(), _toolbar()],
        ),
      ),
    );
  }

  Widget _toolbar() {
    return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onToggleVideoDisabled,
            child: Icon(
              videoDisabled ? Icons.videocam_off : Icons.videocam,
              color: videoDisabled ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: videoDisabled ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: const Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
        ]));
  }

  Widget _broadcastView() {
    if (_users.isEmpty) {
      return const Center(
        child: Text("No Users"),
      );
    }
    return Row(
      children: [
        Expanded(
          child: SurfaceView(),
        ),
      ],
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onToggleVideoDisabled() {
    setState(() {
      videoDisabled = !videoDisabled;
    });
    _engine.muteLocalVideoStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }
}
