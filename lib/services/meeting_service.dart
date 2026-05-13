import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meeting_model.dart';
import 'dart:math';

class MeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateMeetingCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(
        6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<MeetingModel?> createMeeting(
      String title, String hostId, String hostName) async {
    String id = generateMeetingCode();
    MeetingModel meeting = MeetingModel(
      id: id,
      title: title,
      hostId: hostId,
      hostName: hostName,
      createdAt: DateTime.now(),
      isActive: true,
    );
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await _firestore
            .collection('meetings')
            .doc(id)
            .set(meeting.toMap())
            .timeout(const Duration(seconds: 15));
        DocumentSnapshot verify = await _firestore
            .collection('meetings')
            .doc(id)
            .get()
            .timeout(const Duration(seconds: 10));
        if (verify.exists) return meeting;
      } catch (e) {
        if (attempt == 3) return null;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return null;
  }

  Future<MeetingModel?> scheduleMeeting(
    String title,
    String hostId,
    String hostName,
    DateTime scheduledAt, {
    String? customCode,
  }) async {
    String id = customCode ?? generateMeetingCode();
    MeetingModel meeting = MeetingModel(
      id: id,
      title: title,
      hostId: hostId,
      hostName: hostName,
      createdAt: DateTime.now(),
      isActive: true,
      scheduledAt: scheduledAt,
      isScheduled: true,
    );
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await _firestore
            .collection('meetings')
            .doc(id)
            .set(meeting.toMap())
            .timeout(const Duration(seconds: 15));
        DocumentSnapshot verify = await _firestore
            .collection('meetings')
            .doc(id)
            .get()
            .timeout(const Duration(seconds: 10));
        if (verify.exists) return meeting;
      } catch (e) {
        if (attempt == 3) return null;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return null;
  }

  Future<List<MeetingModel>> getScheduledMeetings(String hostId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('meetings')
          .where('hostId', isEqualTo: hostId)
          .where('isScheduled', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 10));
      return snapshot.docs
          .map((doc) =>
              MeetingModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => (a.scheduledAt ?? DateTime.now())
            .compareTo(b.scheduledAt ?? DateTime.now()));
    } catch (e) {
      return [];
    }
  }

  Future<MeetingModel?> joinMeeting(String code) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('meetings')
            .doc(code.toUpperCase())
            .get()
            .timeout(const Duration(seconds: 15));
        if (doc.exists) {
          return MeetingModel.fromMap(
              doc.data() as Map<String, dynamic>);
        } else {
          return null;
        }
      } catch (e) {
        if (attempt == 3) return null;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return null;
  }
}
