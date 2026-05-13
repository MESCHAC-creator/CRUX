class MeetingModel {
  final String id;
  final String title;
  final String hostId;
  final String hostName;
  final DateTime createdAt;
  final bool isActive;
  final DateTime? scheduledAt;
  final bool isScheduled;

  MeetingModel({
    required this.id,
    required this.title,
    required this.hostId,
    required this.hostName,
    required this.createdAt,
    required this.isActive,
    this.scheduledAt,
    this.isScheduled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'hostId': hostId,
      'hostName': hostName,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'isScheduled': isScheduled,
    };
  }

  factory MeetingModel.fromMap(Map<String, dynamic> map) {
    return MeetingModel(
      id: map['id'],
      title: map['title'],
      hostId: map['hostId'],
      hostName: map['hostName'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
      scheduledAt: map['scheduledAt'] != null
          ? DateTime.parse(map['scheduledAt'])
          : null,
      isScheduled: map['isScheduled'] ?? false,
    );
  }
}
