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
    String title,
    String hostId,
    String hostName, {
    String mode = 'standard',
    String? password,
    bool waitingRoom = false,
  }) async {
    String id = generateMeetingCode();
    MeetingModel meeting = MeetingModel(
      id: id,
      title: title,
      hostId: hostId,
      hostName: hostName,
      createdAt: DateTime.now(),
      isActive: true,
      mode: mode,
      password: password,
      waitingRoom: waitingRoom,
    );

    try {
      await _firestore
          .collection('meetings')
          .doc(id)
          .set(meeting.toMap(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
      
      print('Meeting created: $id');
      return meeting;
    } catch (e) {
      print('Error creating meeting: $e');
      return meeting;
    }
  }

  Future<MeetingModel?> scheduleMeeting(
    String title,
    String hostId,
    String hostName,
    DateTime scheduledAt, {
    String? customCode,
    String mode = 'standard',
    String? password,
    bool waitingRoom = false,
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
      mode: mode,
      password: password,
      waitingRoom: waitingRoom,
    );

    try {
      await _firestore
          .collection('meetings')
          .doc(id)
          .set(meeting.toMap(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
      
      print('Meeting scheduled: $id');
      return meeting;
    } catch (e) {
      print('Error scheduling meeting: $e');
      return meeting;
    }
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
          .map((doc) => MeetingModel.fromMap(
              doc.data() as Map<String, dynamic>))
          .toList()
        ..sort((a, b) =>
            (a.scheduledAt ?? DateTime.now())
                .compareTo(b.scheduledAt ?? DateTime.now()));
    } catch (e) {
      print('Error getting scheduled meetings: $e');
      return [];
    }
  }

  Future<MeetingModel?> joinMeeting(String code) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('meetings')
          .doc(code.toUpperCase())
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        return MeetingModel.fromMap(
            doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error joining meeting: $e');
      return null;
    }
  }

  Future<void> endMeeting(String meetingId) async {
    try {
      await _firestore
          .collection('meetings')
          .doc(meetingId)
          .update({'isActive': false})
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error ending meeting: $e');
    }
  }
}
