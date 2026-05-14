class ParticipantModel {
  final String uid;
  final String name;
  final String email;
  bool isMuted;
  bool isVideoOff;
  bool isHandRaised;
  bool isCoHost;
  bool isWaiting;
  final int agoraUid;

  ParticipantModel({
    required this.uid,
    required this.name,
    required this.email,
    this.isMuted = false,
    this.isVideoOff = false,
    this.isHandRaised = false,
    this.isCoHost = false,
    this.isWaiting = false,
    required this.agoraUid,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'isMuted': isMuted,
      'isVideoOff': isVideoOff,
      'isHandRaised': isHandRaised,
      'isCoHost': isCoHost,
      'isWaiting': isWaiting,
      'agoraUid': agoraUid,
    };
  }

  factory ParticipantModel.fromMap(Map<String, dynamic> map) {
    return ParticipantModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isMuted: map['isMuted'] ?? false,
      isVideoOff: map['isVideoOff'] ?? false,
      isHandRaised: map['isHandRaised'] ?? false,
      isCoHost: map['isCoHost'] ?? false,
      isWaiting: map['isWaiting'] ?? false,
      agoraUid: map['agoraUid'] ?? 0,
    );
  }
}
