import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  RtcEngine? _engine;
  bool _isRecording = false;
  int? _localUid;

  Future<void> initialize() async {
    try {
      print('=== INITIALIZING AGORA ===');
      
      // 1. REQUEST PERMISSIONS - MUST SUCCEED
      print('Step 1: Requesting permissions...');
      final micStatus = await Permission.microphone.request();
      final cameraStatus = await Permission.camera.request();
      
      print('Microphone: $micStatus');
      print('Camera: $cameraStatus');
      
      if (micStatus.isDenied || cameraStatus.isDenied) {
        throw Exception('PERMISSIONS DENIED - Mic: $micStatus, Camera: $cameraStatus');
      }

      // 2. CREATE ENGINE
      print('Step 2: Creating RTC Engine...');
      _engine = createAgoraRtcEngine();

      // 3. INITIALIZE WITH APP ID
      print('Step 3: Initializing with App ID...');
      await _engine!.initialize(const RtcEngineContext(
        appId: '729bb936e5084d53897e43c58ee8e946',
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // 4. REGISTER EVENT HANDLER BEFORE ANYTHING ELSE
      print('Step 4: Registering event handler...');
      _registerEventHandler();

      // 5. ENABLE AUDIO
      print('Step 5: Enabling audio...');
      await _engine!.enableAudio();

      // 6. ENABLE VIDEO
      print('Step 6: Enabling video...');
      await _engine!.enableVideo();

      // 7. SET VIDEO CONFIG
      print('Step 7: Setting video configuration...');
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 15,
          bitrate: 800,
        ),
      );

      // 8. SET CLIENT ROLE BEFORE PREVIEW
      print('Step 8: Setting client role...');
      await _engine!.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );

      // 9. LONGER DELAY - CRITICAL!
      print('Step 9: Waiting 1 second for engine stability...');
      await Future.delayed(const Duration(seconds: 1));

      // 10. START PREVIEW - LAST STEP
      print('Step 10: Starting preview...');
      await _engine!.startPreview();

      print('=== AGORA INITIALIZED SUCCESSFULLY ===');
      print('Camera should be visible now!');

    } catch (e) {
      print('ERROR DURING INITIALIZATION: $e');
      rethrow;
    }
  }

  void _registerEventHandler() {
    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        print('✅ Joined channel: ${connection.channelId}');
        print('   Local UID: ${connection.localUid}');
        _localUid = connection.localUid;
      },
      
      onUserJoined: (connection, uid, elapsed) {
        print('User joined: $uid');
      },
      
      onUserOffline: (connection, uid, reason) {
        print('User offline: $uid');
      },
      
      onError: (err, msg) {
        print('ERROR: $err - $msg');
      },
      
      onConnectionStateChanged: (connection, state, reason) {
        print('Connection state: $state, reason: $reason');
      },
    ));
  }

  Future<void> joinChannel(String channelName, {String? token}) async {
    try {
      print('\nJOINING CHANNEL: $channelName');
      
      if (_engine == null) {
        throw Exception('Engine not initialized');
      }

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
      
      print('✅ Join request sent');
      
    } catch (e) {
      print('ERROR: $e');
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
      print('Low bandwidth enabled');
    } catch (e) {
      print('Error: $e');
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
      print('Normal mode enabled');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> leaveChannel() async {
    try {
      await _engine!.stopPreview();
      await _engine!.leaveChannel();
      print('Left channel');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> muteLocalAudio(bool mute) async {
    try {
      await _engine!.muteLocalAudioStream(mute);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> muteLocalVideo(bool mute) async {
    try {
      await _engine!.muteLocalVideoStream(mute);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> muteRemoteAudio(int uid, bool mute) async {
    try {
      await _engine!.muteRemoteAudioStream(uid: uid, mute: mute);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> muteRemoteVideo(int uid, bool mute) async {
    try {
      await _engine!.muteRemoteVideoStream(uid: uid, mute: mute);
    } catch (e) {
      print('Error: $e');
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
      print('Recording started');
      return true;
    } catch (e) {
      print('Error: $e');
      _isRecording = false;
      return false;
    }
  }

  Future<void> stopRecording() async {
    try {
      await _engine!.stopAudioRecording();
      print('Recording stopped');
    } catch (e) {
      print('Error: $e');
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
        print('✅ JOIN SUCCESS: ${connection.channelId}');
        _localUid = connection.localUid;
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
      
      onAudioVolumeIndication: (connection, speakers, speakerNumber, totalVolume) {
        for (final speaker in speakers) {
          if ((speaker.volume ?? 0) > 50) {
            onUserSpeaking?.call(speaker.uid ?? 0, speaker.volume ?? 0);
          }
        }
      },
      
      onError: (err, msg) {
        print('ERROR: $err - $msg');
      },
      
      onConnectionStateChanged: (connection, state, reason) {
        print('Connection: $state');
      },
    ));
  }

  Future<void> dispose() async {
    try {
      if (_isRecording) await stopRecording();
      await _engine?.stopPreview();
      await _engine?.leaveChannel();
      await _engine?.release();
      print('Disposed');
    } catch (e) {
      print('Error: $e');
    }
    _engine = null;
    _localUid = null;
  }

  bool get isRecording => _isRecording;
  RtcEngine? get engine => _engine;
  bool get isInitialized => _engine != null;
  int? get localUid => _localUid;
}
