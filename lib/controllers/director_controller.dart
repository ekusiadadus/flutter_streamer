import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streamer/models/director_model.dart';
import 'package:streamer/utils/const.dart';

final directorController =
    StateNotifierProvider.autoDispose<DirectorController, DirectorModel>((ref) {
  return DirectorController(ref.read);
});

class DirectorController extends StateNotifier<DirectorModel> {
  final Reader read;
  DirectorController(this.read) : super(DirectorModel());

  Future<void> _initialize() async {
    RtcEngine _engine = await RtcEngine.createWithContext(
        RtcEngineContext(EnvironmentConfig.agoraId));
    AgoraRtmClient _client =
        await AgoraRtmClient.createInstance(EnvironmentConfig.agoraId);
    state = DirectorModel(engine: _engine, client: _client);
  }

  Future<void> joinCall({required String channelName, required int uid}) async {
    await _initialize();

    await state.engine?.enableVideo();
    await state.engine?.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await state.engine?.setClientRole(ClientRole.Broadcaster);

    //Callback for the RtC Engine
    state.engine?.setEventHandler(
      RtcEngineEventHandler(
          joinChannelSuccess: (channel, uid, elapsed) {
            print("Director $uid");
          },
          leaveChannel: (stats) {}),
    );

    //Callback for the RtC Client
    state.client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      print("Private Message from " + peerId + ": " + (message.text));
    };

    state.client?.onConnectionStateChanged = (int st, int reason) {
      print("Connection state changed: " +
          state.toString() +
          ", reason: " +
          reason.toString());
      if (st == 5) {
        state.channel?.leave();
        state.client?.logout();
        state.client?.destroy();
        print("Logged out from Streameer.");
      }
    };

    // Join the RTM and RTC channels
    await state.client?.login(null, uid.toString());
    state =
        state.copyWith(channel: await state.client?.createChannel(channelName));
    await state.channel?.join();
    await state.engine?.joinChannel(null, channelName, null, uid);

    //Callback for the RtC Channel
    state.channel?.onMemberJoined = (AgoraRtmMember member) {
      print(
          "Member joined: " + member.userId + ', channel: ' + member.channelId);
    };
    state.channel?.onMemberLeft = (AgoraRtmMember member) {
      print("Member left: " + member.userId + ', channel: ' + member.channelId);
    };
    state.channel?.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) {
      print("Public Message from " + member.userId + ": " + (message.text));
    };
  }

  Future<void> leaveCall() async {
    state.engine?.leaveChannel();
    state.engine?.destroy();
    state.channel?.leave();
    state.client?.logout();
    state.client?.destroy();
  }
}
