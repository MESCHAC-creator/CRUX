import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  RtcEngine? _engine;
  bool _isRecording = false;

  Future<void> initialize() async {
    final micStatus = await Permission.microphone.request();
    final cameraStatus = await Permission.camera.request();
    
    print('Mic: ${micStatus.isDenied}, Camera: ${cameraStatus.isDenied}');
    
    if (micStatus.isDenied || cameraStatus.isDenied) {
      throw Exception('Permissions refusees');
    }

    _engine = createAgoraRtcEngine();
    
    await _engine!.initialize(const RtcEngineContext(
      appId: '3ed3eb7e29c245df8fcd7eb10a346a3d',
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await _engine!.enableAudio();
    await _engine!.enableVideo();
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 480),
        frameRate: 15,
        bitrate: 800,
      ),
    );

    await _engine!.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster);
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    await _engine!.startPreview();
    
    print('Agora initialized successfully');
  }

  Future<void> joinChannel(String channelName,
      {String? token}) async {
    try {
      await _engine!.joinChannel(
        token: '',
        channelId: channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile:
              ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          enableAudioRecordingOrPlayout: true,
        ),
      );
    } catch (e) {
      print('Erreur joinChannel: $e');
      rethrow;
    }
  }

  Future<void> enableLowBandwidthMode() async {
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 320, height: 240),
        frameRate: 10,
        bitrate: 200,
      ),
    );
  }

  Future<void> disableLowBandwidthMode() async {
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 480),
        frameRate: 15,
        bitrate: 800,
      ),
    );
  }

  Future<void> leaveChannel() async {
    try {
      await _engine!.stopPreview();
      await _engine!.leaveChannel();
    } catch (e) {
      print('Erreur leaveChannel: $e');
    }
  }

  Future<void> muteLocalAudio(bool mute) async {
    try {
      await _engine!.muteLocalAudioStream(mute);
    } catch (e) {
      print('Erreur muteLocalAudio: $e');
    }
  }

  Future<void> muteLocalVideo(bool mute) async {
    try {
      await _engine!.muteLocalVideoStream(mute);
    } catch (e) {
      print('Erreur muteLocalVideo: $e');
    }
  }

  Future<void> muteRemoteAudio(int uid, bool mute) async {
    try {
      await _engine!.muteRemoteAudioStream(uid: uid, mute: mute);
    } catch (e) {
      print('Erreur muteRemoteAudio: $e');
    }
  }

  Future<void> muteRemoteVideo(int uid, bool mute) async {
    try {
      await _engine!.muteRemoteVideoStream(
          uid: uid, mute: mute);
    } catch (e) {
      print('Erreur muteRemoteVideo: $e');
    }
  }

  Future<bool> startRecording() async {
    try {
      await _engine!.startAudioRecording(
        const AudioRecordingConfiguration(
          filePath: '/sdcard/Download/crux_recording.aac',
        ),
      );
      _isRecording = true;
      return true;
    } catch (e) {
      print('Erreur startRecording: $e');
      _isRecording = false;
      return false;
    }
  }

  Future<void> stopRecording() async {
    try {
      await _engine!.stopAudioRecording();
    } catch (e) {
      print('Erreur stopRecording: $e');
    }
    _isRecording = false;
  }

  void registerEventHandler({
    Function(int uid)? onUserJoined,
    Function(int uid)? onUserOffline,
    Function()? onJoinSuccess,
    Function(int uid, int volume)? onUserSpeaking,
  }) {
    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        print('Joined channel successfully');
        onJoinSuccess?.call();
      },
      onUserJoined: (connection, uid, elapsed) {
        print('User joined: $uid');
        onUserJoined?.call(uid);
      },
      onUserOffline: (connection, uid, reason) {
        print('User offline: $uid');
        onUserOffline?.call(uid);
      },
      onAudioVolumeIndication: (connection, speakers,
          speakerNumber, totalVolume) {
        for (final speaker in speakers) {
          if ((speaker.volume ?? 0) > 50) {
            onUserSpeaking?.call(
                speaker.uid ?? 0, speaker.volume ?? 0);
          }
        }
      },
      onError: (err, msg) {
        print('Agora error: $err - $msg');
      },
    ));
  }

  Future<void> dispose() async {
    if (_isRecording) await stopRecording();
    try {
      await _engine?.stopPreview();
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (e) {
      print('Erreur dispose: $e');
    }
    _engine = null;
  }

  bool get isRecording => _isRecording;
  RtcEngine? get engine => _engine;
}
