import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  RtcEngine? _engine;
  bool _isRecording = false;

  Future<void> initialize() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: '3ed3eb7e29c245df8fcd7eb10a346a3d',
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    await _engine!.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.enableAudio();
    await _engine!.enableVideo();
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 400,
      ),
    );
    await _engine!.startPreview();
  }

  Future<void> joinChannel(String channelName, {String? token}) async {
    await _engine!.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  Future<void> enableLowBandwidthMode() async {
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 320, height: 180),
        frameRate: 10,
        bitrate: 150,
      ),
    );
  }

  Future<void> disableLowBandwidthMode() async {
    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 400,
      ),
    );
  }

  Future<void> leaveChannel() async {
    try {
      await _engine!.leaveChannel();
      await _engine!.stopPreview();
    } catch (e) {
      // ignore
    }
  }

  Future<void> muteLocalAudio(bool mute) async {
    await _engine!.muteLocalAudioStream(mute);
  }

  Future<void> muteLocalVideo(bool mute) async {
    await _engine!.muteLocalVideoStream(mute);
  }

  Future<void> muteRemoteAudio(int uid, bool mute) async {
    await _engine!.muteRemoteAudioStream(uid: uid, mute: mute);
  }

  Future<void> muteRemoteVideo(int uid, bool mute) async {
    await _engine!.muteRemoteVideoStream(uid: uid, mute: mute);
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
      _isRecording = false;
      return false;
    }
  }

  Future<void> stopRecording() async {
    try {
      await _engine!.stopAudioRecording();
    } catch (e) {
      // ignore
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
        onJoinSuccess?.call();
      },
      onUserJoined: (connection, uid, elapsed) {
        onUserJoined?.call(uid);
      },
      onUserOffline: (connection, uid, reason) {
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
    ));
  }

  Future<void> dispose() async {
    if (_isRecording) await stopRecording();
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (e) {
      // ignore
    }
    _engine = null;
  }

  bool get isRecording => _isRecording;
  RtcEngine? get engine => _engine;
}
