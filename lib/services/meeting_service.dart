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

    for (int attempt = 1; attempt <= 5; attempt++) {
      try {
        await _firestore
            .collection('meetings')
            .doc(id)
            .set(meeting.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 20));

        await Future.delayed(const Duration(milliseconds: 500));

        DocumentSnapshot verify = await _firestore
            .collection('meetings')
            .doc(id)
            .get()
            .timeout(const Duration(seconds: 15));

        if (verify.exists) {
          return meeting;
        }
      } catch (e) {
        print('Tentative $attempt échouée: $e');
        if (attempt < 5) {
          await Future.delayed(
              Duration(seconds: attempt * 2));
        }
      }
    }

    return meeting;
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

    for (int attempt = 1; attempt <= 5; attempt++) {
      try {
        await _firestore
            .collection('meetings')
            .doc(id)
            .set(meeting.toMap(), SetOptions(merge: true))
            .timeout(const Duration(seconds: 20));

        await Future.delayed(const Duration(milliseconds: 500));

        DocumentSnapshot verify = await _firestore
            .collection('meetings')
            .doc(id)
            .get()
            .timeout(const Duration(seconds: 15));

        if (verify.exists) {
          return meeting;
        }
      } catch (e) {
        print('Tentative $attempt échouée: $e');
        if (attempt < 5) {
          await Future.delayed(
              Duration(seconds: attempt * 2));
        }
      }
    }

    return meeting;
  }

  Future<List<MeetingModel>> getScheduledMeetings(
      String hostId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('meetings')
          .where('hostId', isEqualTo: hostId)
          .where('isScheduled', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 20));

      return snapshot.docs
          .map((doc) => MeetingModel.fromMap(
              doc.data() as Map<String, dynamic>))
          .toList()
        ..sort((a, b) =>
            (a.scheduledAt ?? DateTime.now())
                .compareTo(b.scheduledAt ?? DateTime.now()));
    } catch (e) {
      print('Erreur getScheduledMeetings: $e');
      return [];
    }
  }

  Future<MeetingModel?> joinMeeting(String code) async {
    for (int attempt = 1; attempt <= 5; attempt++) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('meetings')
            .doc(code.toUpperCase())
            .get()
            .timeout(const Duration(seconds: 20));

        if (doc.exists) {
          return MeetingModel.fromMap(
              doc.data() as Map<String, dynamic>);
        } else {
          return null;
        }
      } catch (e) {
        print('Tentative $attempt joinMeeting échouée: $e');
        if (attempt < 5) {
          await Future.delayed(
              Duration(seconds: attempt * 2));
        }
      }
    }
    return null;
  }

  Future<void> endMeeting(String meetingId) async {
    try {
      await _firestore
          .collection('meetings')
          .doc(meetingId)
          .update({'isActive': false})
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      print('Erreur endMeeting: $e');
    }
  }
}
