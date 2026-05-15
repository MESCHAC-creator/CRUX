import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  RtcEngine? _engine;
  bool _isRecording = false;
  int? _localUid;

  Future<void> initialize() async {
    try {
      print('=== AGORA INITIALIZATION START ===');
      
      // 1. REQUEST PERMISSIONS FIRST
      final micStatus = await Permission.microphone.request();
      final cameraStatus = await Permission.camera.request();
      
      print('🎤 Microphone: $micStatus');
      print('📹 Camera: $cameraStatus');
      
      if (micStatus.isDenied || cameraStatus.isDenied) {
        throw Exception('Permissions denied - Mic: $micStatus, Camera: $cameraStatus');
      }

      // 2. CREATE ENGINE
      print('📱 Creating Agora RTC Engine...');
      _engine = createAgoraRtcEngine();
      
      // 3. INITIALIZE ENGINE
      print('🔧 Initializing engine with App ID...');
      await _engine!.initialize(const RtcEngineContext(
        appId: '729bb936e5084d53897e43c58ee8e946',
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      print('✅ Engine initialized');

      // 4. ENABLE AUDIO
      print('🎤 Enabling audio...');
      await _engine!.enableAudio();
      print('✅ Audio enabled');
      
      // 5. ENABLE VIDEO
      print('📹 Enabling video...');
      await _engine!.enableVideo();
      print('✅ Video enabled');

      // 6. SET VIDEO CONFIGURATION
      print('⚙️ Setting video configuration...');
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 15,
          bitrate: 800,
        ),
      );
      print('✅ Video configuration set');

      // 7. SET CLIENT ROLE
      print('👤 Setting client role to BROADCASTER...');
      await _engine!.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );
      print('✅ Client role set to BROADCASTER');
      
      // 8. SMALL DELAY TO ENSURE EVERYTHING IS READY
      print('⏳ Waiting for engine to be ready...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 9. START PREVIEW (THIS SHOWS LOCAL CAMERA)
      print('🎥 Starting camera preview...');
      await _engine!.startPreview();
      print('✅ CAMERA PREVIEW STARTED - VIDEO SHOULD APPEAR NOW!');
      
      print('=== AGORA INITIALIZATION COMPLETE ===');
      
    } catch (e) {
      print('❌ INITIALIZATION ERROR: $e');
      rethrow;
    }
  }

  Future<void> joinChannel(String channelName, {String? token}) async {
    try {
      print('\n=== JOINING CHANNEL: $channelName ===');
      
      if (_engine == null) {
        throw Exception('Engine not initialized! Call initialize() first');
      }

      print('🔗 Calling joinChannel with:');
      print('   - channelId: $channelName');
      print('   - uid: 0 (auto-assign)');
      print('   - token: ${token?.isEmpty ?? true ? "empty" : "provided"}');
      
      await _engine!.joinChannel(
        token: token ?? '',
        channelId: channelName,
        uid: 0, // 0 means auto-assign UID
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
      
      print('✅ Join channel request sent successfully');
      print('=== WAITING FOR onJoinChannelSuccess CALLBACK ===\n');
      
    } catch (e) {
      print('❌ JOIN CHANNEL ERROR: $e');
      rethrow;
    }
  }

  Future<void> enableLowBandwidthMode() async {
    try {
      print('🌐 Enabling LOW BANDWIDTH mode...');
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
      print('🌐 Disabling LOW BANDWIDTH mode (returning to normal)...');
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
      print('\n=== LEAVING CHANNEL ===');
      await _engine!.stopPreview();
      await _engine!.leaveChannel();
      print('✅ Left channel successfully');
    } catch (e) {
      print('❌ Error leaving channel: $e');
    }
  }

  Future<void> muteLocalAudio(bool mute) async {
    try {
      await _engine!.muteLocalAudioStream(mute);
      print('🎤 Local audio muted: $mute');
    } catch (e) {
      print('❌ Error muting audio: $e');
    }
  }

  Future<void> muteLocalVideo(bool mute) async {
    try {
      await _engine!.muteLocalVideoStream(mute);
      print('📹 Local video muted: $mute');
    } catch (e) {
      print('❌ Error muting video: $e');
    }
  }

  Future<void> muteRemoteAudio(int uid, bool mute) async {
    try {
      await _engine!.muteRemoteAudioStream(uid: uid, mute: mute);
      print('🎤 Remote audio muted (uid: $uid): $mute');
    } catch (e) {
      print('❌ Error muting remote audio: $e');
    }
  }

  Future<void> muteRemoteVideo(int uid, bool mute) async {
    try {
      await _engine!.muteRemoteVideoStream(uid: uid, mute: mute);
      print('📹 Remote video muted (uid: $uid): $mute');
    } catch (e) {
      print('❌ Error muting remote video: $e');
    }
  }

  Future<bool> startRecording() async {
    try {
      print('\n=== STARTING AUDIO RECORDING ===');
      await _engine!.startAudioRecording(
        const AudioRecordingConfiguration(
          filePath: '/sdcard/Download/crux_recording.aac',
        ),
      );
      _isRecording = true;
      print('✅ Audio recording started');
      print('   Path: /sdcard/Download/crux_recording.aac');
      return true;
    } catch (e) {
      print('❌ Error starting recording: $e');
      _isRecording = false;
      return false;
    }
  }

  Future<void> stopRecording() async {
    try {
      print('\n=== STOPPING AUDIO RECORDING ===');
      await _engine!.stopAudioRecording();
      print('✅ Audio recording stopped');
      print('   Saved to: /sdcard/Download/crux_recording.aac');
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
        print('\n✅✅✅ onJoinChannelSuccess ✅✅✅');
        print('   Channel: ${connection.channelId}');
        print('   Local UID: ${connection.localUid}');
        print('   Elapsed: ${elapsed}ms');
        _localUid = connection.localUid;
        onJoinSuccess?.call();
      },
      
      onUserJoined: (connection, uid, elapsed) {
        print('\n👤 onUserJoined');
        print('   Remote UID: $uid');
        print('   Elapsed: ${elapsed}ms');
        onUserJoined?.call(uid);
      },
      
      onUserOffline: (connection, uid, reason) {
        print('\n👤 onUserOffline');
        print('   Remote UID: $uid');
        print('   Reason: $reason');
        onUserOffline?.call(uid);
      },
      
      onAudioVolumeIndication: (connection, speakers, speakerNumber, totalVolume) {
        for (final speaker in speakers) {
          if ((speaker.volume ?? 0) > 50) {
            print('🔊 User speaking: uid=${speaker.uid}, volume=${speaker.volume}');
            onUserSpeaking?.call(speaker.uid ?? 0, speaker.volume ?? 0);
          }
        }
      },
      
      onError: (err, msg) {
        print('❌ Agora ERROR: $err - $msg');
      },
      
      onConnectionStateChanged: (connection, state, reason) {
        print('🔄 Connection state changed: $state (reason: $reason)');
      },
      
      onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
        print('📹 Remote video state: uid=$remoteUid, state=$state, reason=$reason');
      },
      
      onRemoteAudioStateChanged: (connection, remoteUid, state, reason, elapsed) {
        print('🎤 Remote audio state: uid=$remoteUid, state=$state, reason=$reason');
      },
      
      onLocalVideoStats: (connection, sourceType, stats) {
        print('📊 Local video stats: resolution=${stats.width}x${stats.height}, fps=${stats.sentFrameRate}');
      },
    ));
  }

  Future<void> dispose() async {
    try {
      print('\n=== DISPOSING AGORA ===');
      if (_isRecording) await stopRecording();
      await _engine?.stopPreview();
      await _engine?.leaveChannel();
      await _engine?.release();
      print('✅ Agora disposed successfully');
    } catch (e) {
      print('❌ Error disposing: $e');
    }
    _engine = null;
    _localUid = null;
  }

  bool get isRecording => _isRecording;
  RtcEngine? get engine => _engine;
  bool get isInitialized => _engine != null;
  int? get localUid => _localUid;
}
