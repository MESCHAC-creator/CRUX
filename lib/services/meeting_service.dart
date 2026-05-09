import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meeting_model.dart';
import 'dart:math';

class MeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Générer un code de réunion
  String generateMeetingCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Créer une réunion
  Future<MeetingModel?> createMeeting(String title, String hostId, String hostName) async {
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
      await _firestore.collection('meetings').doc(id).set(meeting.toMap());
      return meeting;
    } catch (e) {
      return null;
    }
  }

  // Rejoindre une réunion
  Future<MeetingModel?> joinMeeting(String code) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('meetings').doc(code).get();
      if (doc.exists) {
        return MeetingModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}