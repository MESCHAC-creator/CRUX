import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  RtcEngine? _engine;
  bool _isRecording = false;

  Future<void> initialize() async {
    try {
      final micStatus = await Permission.microphone.request();
      final cameraStatus = await Permission.camera.request();
      
      print('🎤 Mic: $micStatus');
      print('📹 Camera: $cameraStatus');
      
      if (micStatus.isDenied || cameraStatus.isDenied) {
        throw Exception('Permissions refusees: Mic=$micStatus, Camera=$cameraStatus');
      }

      _engine = createAgoraRtcEngine();
      print('✅ Engine created');
      
      await _engine!.initialize(const RtcEngineContext(
        appId: '3ed3eb7e29c245df8fcd7eb10a346a3d',
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      print('✅ Engine initialized');

      await _engine!.enableAudio();
      print('✅ Audio enabled');
      
      await _engine!.enableVideo();
      print('✅ Video enabled');

      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 15,
          bitrate: 800,
        ),
      );
      print('✅ Video encoder configured');

      await _engine!.setClientRole(
          role: ClientRoleType.clientRoleBroadcaster);
      print('✅ Client role set');
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      await _engine!.startPreview();
      print('✅ Preview started - CAMERA SHOULD SHOW NOW');
      
    } catch (e) {
      print('❌ Initialize error: $e');
      rethrow;
    }
  }

  Future<void> joinChannel(String channelName,
      {String? token}) async {
    try {
      print('🔗 Joining channel: $channelName');
      
      await _engine!.joinChannel(
        token: token ?? '',
        channelId: channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          enableAudioRecordingOrPlayout: true,
        ),
      );
      
      print('✅ Joined channel: $channelName');
    } catch (e) {
      print('❌ Join channel error: $e');
      rethrow;
    }
  }

  Future<void> enableLowBandwidthMode() async {
    try {
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 320, height: 240),
          frameRate: 10,
          bitrate: 200,
        ),
      );
      print('✅ Low bandwidth mode enabled');
    } catch (e) {
      print('❌ Error enabling low bandwidth: $e');
    }
  }

  Future<void> disableLowBandwidthMode() async {
    try {
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 15,
          bitrate: 800,
        ),
      );
      print('✅ Normal mode enabled');
    } catch (e) {
      print('❌ Error disabling low bandwidth: $e');
    }
  }

  Future<void> leaveChannel() async {
    try {
      await _engine!.stopPreview();
      await _engine!.leaveChannel();
      print('✅ Left channel');
    } catch (e) {
      print('❌ Error leaving channel: $e');
    }
  }

  Future<void> muteLocalAudio(bool mute) async {
    try {
      await _engine!.muteLocalAudioStream(mute);
      print('✅ Audio mute: $mute');
    } catch (e) {
      print('❌ Error muting audio: $e');
    }
  }

  Future<void> muteLocalVideo(bool mute) async {
    try {
      await _engine!.muteLocalVideoStream(mute);
      print('✅ Video mute: $mute');
    } catch (e) {
      print('❌ Error muting video: $e');
    }
  }

  Future<void> muteRemoteAudio(int uid, bool mute) async {
    try {
      await _engine!.muteRemoteAudioStream(uid: uid, mute: mute);
      print('✅ Remote audio mute: uid=$uid, mute=$mute');
    } catch (e) {
      print('❌ Error muting remote audio: $e');
    }
  }

  Future<void> muteRemoteVideo(int uid, bool mute) async {
    try {
      await _engine!.muteRemoteVideoStream(uid: uid, mute: mute);
      print('✅ Remote video mute: uid=$uid, mute=$mute');
    } catch (e) {
      print('❌ Error muting remote video: $e');
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
      print('✅ Recording started');
      return true;
    } catch (e) {
      print('❌ Error starting recording: $e');
      _isRecording = false;
      return false;
    }
  }

  Future<void> stopRecording() async {
    try {
      await _engine!.stopAudioRecording();
      print('✅ Recording stopped');
    } catch (e) {
      print('❌ Error stopping recording: $e');
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
        print('✅ onJoinChannelSuccess - Elapsed: $elapsed ms');
        onJoinSuccess?.call();
      },
      onUserJoined: (connection, uid, elapsed) {
        print('✅ onUserJoined: $uid (elapsed: $elapsed ms)');
        onUserJoined?.call(uid);
      },
      onUserOffline: (connection, uid, reason) {
        print('✅ onUserOffline: $uid (reason: $reason)');
        onUserOffline?.call(uid);
      },
      onAudioVolumeIndication: (connection, speakers,
          speakerNumber, totalVolume) {
        for (final speaker in speakers) {
          if ((speaker.volume ?? 0) > 50) {
            print('🔊 User speaking: uid=${speaker.uid}, volume=${speaker.volume}');
            onUserSpeaking?.call(
                speaker.uid ?? 0, speaker.volume ?? 0);
          }
        }
      },
      onError: (err, msg) {
        print('❌ Agora error: $err - $msg');
      },
      onConnectionStateChanged: (connection, state, reason) {
        print('🔄 Connection state: $state, reason: $reason');
      },
      onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
        print('📹 Remote video state: uid=$remoteUid, state=$state, reason=$reason');
      },
      onRemoteAudioStateChanged: (connection, remoteUid, state, reason, elapsed) {
        print('🎤 Remote audio state: uid=$remoteUid, state=$state, reason=$reason');
      },
    ));
  }

  Future<void> dispose() async {
    try {
      if (_isRecording) await stopRecording();
      await _engine?.stopPreview();
      await _engine?.leaveChannel();
      await _engine?.release();
      print('✅ Agora disposed successfully');
    } catch (e) {
      print('❌ Error disposing: $e');
    }
    _engine = null;
  }

  bool get isRecording => _isRecording;
  RtcEngine? get engine => _engine;
  bool get isInitialized => _engine != null;
}
