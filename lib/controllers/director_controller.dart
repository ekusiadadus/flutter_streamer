import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streamer/models/director_model.dart';
import 'package:streamer/models/user.dart';
import 'package:streamer/utils/const.dart';

final directorController = StateNotifierProvider.autoDispose<DirectorController, DirectorModel>((ref) {
  return DirectorController(ref.read);
});

class DirectorController extends StateNotifier<DirectorModel> {
  final Reader read;
  DirectorController(this.read) : super(DirectorModel());

  Future<void> _initialize() async {
    RtcEngine _engine = await RtcEngine.createWithContext(RtcEngineContext(EnvironmentConfig.agoraId));
    AgoraRtmClient _client = await AgoraRtmClient.createInstance(EnvironmentConfig.agoraId);
    state = DirectorModel(engine: _engine, client: _client);
  }

  Future<void> joinCall({required String channelName, required int uid}) async {
    await _initialize();

    await state.engine?.enableVideo();
    await state.engine?.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await state.engine?.setClientRole(ClientRole.Broadcaster);

    //Callback for the RtC Engine
    state.engine?.setEventHandler(
      RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
        print("Director $uid");
      }, leaveChannel: (stats) {
        print("Channel Left");
      }, userJoined: (uid, elapsed) {
        print("User Joined " + uid.toString());
      }, userOffline: (uid, reason) {
        removeUser(uid: uid);
      }),
    );

    //Callback for the RtC Client
    state.client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      print("Private Message from " + peerId + ": " + (message.text));
    };

    state.client?.onConnectionStateChanged = (int st, int reason) {
      print("Connection state changed: " + state.toString() + ", reason: " + reason.toString());
      if (st == 5) {
        state.channel?.leave();
        state.client?.logout();
        state.client?.destroy();
        print("Logged out from Streameer.");
      }
    };

    // Join the RTM and RTC channels
    await state.client?.login(null, uid.toString());
    state = state.copyWith(channel: await state.client?.createChannel(channelName));
    await state.channel?.join();
    await state.engine?.joinChannel(null, channelName, null, uid);

    //Callback for the RtC Channel
    state.channel?.onMemberJoined = (AgoraRtmMember member) {
      print("Member joined: " + member.userId + ', channel: ' + member.channelId);
    };
    state.channel?.onMemberLeft = (AgoraRtmMember member) {
      print("Member left: " + member.userId + ', channel: ' + member.channelId);
    };
    state.channel?.onMessageReceived = (AgoraRtmMessage message, AgoraRtmMember member) {
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

  Future<void> addUserToLobby({required int uid}) async {
    state = state.copyWith(lobbyUsers: {
      ...state.lobbyUsers,
      AgoraUser(
        uid: uid,
        muted: true,
        videoDisabled: true,
        name: "todo",
        backgroundColor: Colors.blue,
      )
    });
  }

  Future<void> promoteToActiveUser({required int uid}) async {
    Set<AgoraUser> _tempLobby = state.lobbyUsers;
    Color? tempColor;
    String? tempName;

    for (int i = 0; i < _tempLobby.length; ++i) {
      if (_tempLobby.elementAt(i).uid == uid) {
        tempColor = _tempLobby.elementAt(i).backgroundColor;
        tempName = _tempLobby.elementAt(i).name;
        _tempLobby.remove(_tempLobby.elementAt(i));
      }
    }
    state = state.copyWith(
      activeUsers: {
        ...state.activeUsers,
        AgoraUser(
          uid: uid,
          backgroundColor: tempColor,
          name: tempName,
        )
      },
      lobbyUsers: _tempLobby,
    );
  }

  Future<void> demoteToLobbyUser({required int uid}) async {
    Set<AgoraUser> _tempActive = state.lobbyUsers;
    Color? tempColor;
    String? tempName;

    for (int i = 0; i < _tempActive.length; ++i) {
      if (_tempActive.elementAt(i).uid == uid) {
        tempColor = _tempActive.elementAt(i).backgroundColor;
        tempName = _tempActive.elementAt(i).name;
        _tempActive.remove(_tempActive.elementAt(i));
      }
    }
    state = state.copyWith(
      lobbyUsers: {
        ...state.lobbyUsers,
        AgoraUser(
          uid: uid,
          backgroundColor: tempColor,
          name: tempName,
          videoDisabled: true,
          muted: true,
        )
      },
      activeUsers: _tempActive,
    );
  }

  Future<void> removeUser({required int uid}) async {
    Set<AgoraUser> _tempActive = state.activeUsers;
    Set<AgoraUser> _tempLobby = state.lobbyUsers;
    for (int i = 0; i < _tempActive.length; ++i) {
      if (_tempActive.elementAt(i).uid == uid) {
        _tempActive.remove(_tempActive.elementAt(i));
      }
      for (int i = 0; i < _tempLobby.length; ++i) {
        if (_tempLobby.elementAt(i).uid == uid) {
          _tempLobby.remove(_tempLobby.elementAt(i));
        }
      }
    }

    state = state.copyWith(activeUsers: _tempActive, lobbyUsers: _tempLobby);
  }
}
