import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

const String agoraAppId = '3ed3eb7e29c245df8fcd7eb10a346a3d';

class AgoraService {
  RtcEngine? _engine;
  bool _isRecording = false;

  Future<void> initialize() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    await _engine!.enableVideo();
    await _engine!.startPreview();
  }

  Future<void> joinChannel(String channelName, {String? token}) async {
    await _engine!.joinChannel(
      token: token ?? '',
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await _engine!.leaveChannel();
    await _engine!.stopPreview();
  }

  Future<void> muteLocalAudio(bool mute) async {
    await _engine!.muteLocalAudioStream(mute);
  }

  Future<void> muteLocalVideo(bool mute) async {
    await _engine!.muteLocalVideoStream(mute);
  }

  Future<bool> startRecording() async {
    try {
      await _engine!.startAudioRecording(const AudioRecordingConfiguration(
        filePath: '/sdcard/Download/crux_recording.aac',
        encode: AudioEncodingType.audioEncodingTypeAac,
        quality: AudioRecordingQuality.audioRecordingQualityHigh,
      ));
      _isRecording = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> stopRecording() async {
    try {
      await _engine!.stopAudioRecording();
      _isRecording = false;
    } catch (e) {
      _isRecording = false;
    }
  }

  Future<bool> startYoutubeLive(String streamKey) async {
    try {
      final config = LiveTranscoding(
        width: 1280,
        height: 720,
        videoBitrate: 2000,
        videoFramerate: 30,
        audioSampleRate: AudioSampleRateType.audioSampleRate44100,
        audioBitrate: 128,
        audioChannels: 2,
        transcodingUsers: [
          const TranscodingUser(
            uid: 0,
            x: 0,
            y: 0,
            width: 1280,
            height: 720,
          ),
        ],
      );
      await _engine!.startRtmpStreamWithTranscoding(
        url: 'rtmp://a.rtmp.youtube.com/live2/$streamKey',
        transcoding: config,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> stopYoutubeLive(String streamKey) async {
    try {
      await _engine!.stopRtmpStream(
        url: 'rtmp://a.rtmp.youtube.com/live2/$streamKey',
      );
    } catch (e) {
      // ignore
    }
  }

  void registerEventHandler({
    Function(int uid)? onUserJoined,
    Function(int uid)? onUserOffline,
    Function()? onJoinSuccess,
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
    ));
  }

  Future<void> dispose() async {
    if (_isRecording) await stopRecording();
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }

  bool get isRecording => _isRecording;
  RtcEngine? get engine => _engine;
}
