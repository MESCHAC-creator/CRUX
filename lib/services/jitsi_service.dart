import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiService {
  final JitsiMeet _jitsiMeet = JitsiMeet();

  Future<void> joinMeeting({
    required String roomName,
    required String displayName,
    required String userEmail,
    bool audioMuted = false,
    bool videoMuted = false,
    Function()? onConferenceJoined,
    Function()? onConferenceTerminated,
    Function(dynamic)? onError,
  }) async {
    final options = JitsiMeetConferenceOptions(
      serverURL: 'https://meet.jit.si',
      room: roomName,
      configOverrides: {
        'startWithAudioMuted': audioMuted,
        'startWithVideoMuted': videoMuted,
        'subject': 'Reunion CRUX',
        'prejoinPageEnabled': false,
        'disableDeepLinking': true,
      },
      featureFlags: {
        'welcomepage.enabled': false,
        'calendar.enabled': false,
        'call-integration.enabled': false,
        'car-mode.enabled': false,
        'close-captions.enabled': true,
        'invite.enabled': true,
        'chat.enabled': true,
        'recording.enabled': true,
        'raise-hand.enabled': true,
        'reactions.enabled': true,
        'tile-view.enabled': true,
        'toolbox.alwaysVisible': false,
        'pip.enabled': true,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: displayName,
        email: userEmail,
      ),
    );
    await _jitsiMeet.join(options);
  }

  Future<void> hangUp() async {
    await _jitsiMeet.hangUp();
  }
}
