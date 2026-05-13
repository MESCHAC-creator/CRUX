import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meeting_model.dart';
import 'dart:math';

class MeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateMeetingCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(6,
            (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<MeetingModel?> createMeeting(
      String title, String hostId, String hostName) async {
    try {
      String id = generateMeetingCode();
      MeetingModel meeting = MeetingModel(
        id: id,
        title: title,
        hostId: hostId,
        hostName: hostName,
        createdAt: DateTime.now(),
        isActive: true,
      );
      await _firestore
          .collection('meetings')
          .doc(id)
          .set(meeting.toMap());
      return meeting;
    } catch (e) {
      return null;
    }
  }

  Future<MeetingModel?> scheduleMeeting({
    required String title,
    required String hostId,
    required String hostName,
    required DateTime scheduledAt,
    String? customCode,
    String? description,
  }) async {
    try {
      String id = customCode?.toUpperCase() ?? generateMeetingCode();
      DocumentSnapshot existing =
      await _firestore.collection('meetings').doc(id).get();
      if (existing.exists) return null;
      MeetingModel meeting = MeetingModel(
        id: id,
        title: title,
        hostId: hostId,
        hostName: hostName,
        createdAt: DateTime.now(),
        isActive: false,
        scheduledAt: scheduledAt,
        description: description,
      );
      await _firestore
          .collection('meetings')
          .doc(id)
          .set(meeting.toMap());
      return meeting;
    } catch (e) {
      return null;
    }
  }

  Future<MeetingModel?> joinMeeting(String code) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection('meetings').doc(code).get();
      if (doc.exists) {
        return MeetingModel.fromMap(
            doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<MeetingModel>> getScheduledMeetings(String hostId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('meetings')
          .where('hostId', isEqualTo: hostId)
          .where('isActive', isEqualTo: false)
          .get();
      return snapshot.docs
          .map((doc) => MeetingModel.fromMap(
          doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> activateMeeting(String meetingId) async {
    try {
      await _firestore
          .collection('meetings')
          .doc(meetingId)
          .update({'isActive': true});
    } catch (e) {
      // ignore
    }
  }
}