class MeetingModel {
  final String id;
  final String title;
  final String hostId;
  final String hostName;
  final List<String> coHosts;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final String mode;
  final bool isActive;

  MeetingModel({
    required this.id,
    required this.title,
    required this.hostId,
    required this.hostName,
    this.coHosts = const [],
    required this.createdAt,
    this.scheduledAt,
    this.mode = 'standard',
    this.isActive = true,
  });

  // Convertir en Map pour Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'hostId': hostId,
      'hostName': hostName,
      'coHosts': coHosts,
      'createdAt': createdAt,
      'scheduledAt': scheduledAt,
      'mode': mode,
      'isActive': isActive,
    };
  }

  // Créer depuis Firebase
  factory MeetingModel.fromMap(Map<String, dynamic> map) {
    return MeetingModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      hostId: map['hostId'] ?? '',
      hostName: map['hostName'] ?? '',
      coHosts: List<String>.from(map['coHosts'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      scheduledAt: map['scheduledAt']?.toDate(),
      mode: map['mode'] ?? 'standard',
      isActive: map['isActive'] ?? true,
    );
  }

  // Copier avec modifications
  MeetingModel copyWith({
    String? id,
    String? title,
    String? hostId,
    String? hostName,
    List<String>? coHosts,
    DateTime? createdAt,
    DateTime? scheduledAt,
    String? mode,
    bool? isActive,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      coHosts: coHosts ?? this.coHosts,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      mode: mode ?? this.mode,
      isActive: isActive ?? this.isActive,
    );
  }
}
