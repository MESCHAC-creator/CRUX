import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meeting_model.dart';
import '../models/user_model.dart';

class MeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer une nouvelle réunion (l'utilisateur devient automatiquement hôte)
  Future<MeetingModel?> createMeeting(
    String title,
    String hostId,
    String hostName, {
    String mode = 'standard',
  }) async {
    try {
      print('📝 Creating meeting: $title');

      final meetingId = _generateMeetingId();
      final now = DateTime.now();

      final meeting = MeetingModel(
        id: meetingId,
        title: title,
        hostId: hostId,
        hostName: hostName,
        coHosts: [], // Aucun co-hôte au démarrage
        createdAt: now,
        mode: mode,
        isActive: true,
      );

      // Sauvegarder dans Firestore
      await _firestore.collection('meetings').doc(meetingId).set(
            meeting.toMap(),
            SetOptions(merge: true),
          );

      print('✅ Meeting created: $meetingId');
      return meeting;
    } catch (e) {
      print('❌ Error creating meeting: $e');
      return null;
    }
  }

  // Programmer une réunion (l'utilisateur devient automatiquement hôte)
  Future<MeetingModel?> scheduleMeeting(
    String title,
    String hostId,
    String hostName,
    DateTime scheduledAt, {
    String mode = 'standard',
  }) async {
    try {
      print('📅 Scheduling meeting: $title for $scheduledAt');

      final meetingId = _generateMeetingId();
      final now = DateTime.now();

      final meeting = MeetingModel(
        id: meetingId,
        title: title,
        hostId: hostId,
        hostName: hostName,
        coHosts: [],
        createdAt: now,
        scheduledAt: scheduledAt,
        mode: mode,
        isActive: false, // Pas encore active
      );

      // Sauvegarder dans Firestore
      await _firestore.collection('meetings').doc(meetingId).set(
            meeting.toMap(),
            SetOptions(merge: true),
          );

      print('✅ Meeting scheduled: $meetingId');
      return meeting;
    } catch (e) {
      print('❌ Error scheduling meeting: $e');
      return null;
    }
  }

  // Rejoindre une réunion existante
  Future<MeetingModel?> joinMeeting(String meetingId) async {
    try {
      print('🔗 Joining meeting: $meetingId');

      final doc =
          await _firestore.collection('meetings').doc(meetingId).get();

      if (!doc.exists) {
        print('❌ Meeting not found: $meetingId');
        return null;
      }

      final meeting = MeetingModel.fromMap(doc.data() ?? {});
      print('✅ Joined meeting: ${meeting.title}');
      return meeting;
    } catch (e) {
      print('❌ Error joining meeting: $e');
      return null;
    }
  }

  // Obtenir les réunions programmées de l'utilisateur
  Future<List<MeetingModel>> getScheduledMeetings(String userId) async {
    try {
      print('📋 Fetching scheduled meetings for user: $userId');

      final snapshot = await _firestore
          .collection('meetings')
          .where('hostId', isEqualTo: userId)
          .where('isActive', isEqualTo: false)
          .orderBy('scheduledAt')
          .get();

      final meetings = snapshot.docs
          .map((doc) => MeetingModel.fromMap(doc.data()))
          .toList();

      print('✅ Found ${meetings.length} scheduled meetings');
      return meetings;
    } catch (e) {
      print('❌ Error fetching scheduled meetings: $e');
      return [];
    }
  }

  // Obtenir les réunions actives de l'utilisateur
  Future<List<MeetingModel>> getActiveMeetings(String userId) async {
    try {
      print('📋 Fetching active meetings for user: $userId');

      final snapshot = await _firestore
          .collection('meetings')
          .where('hostId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final meetings = snapshot.docs
          .map((doc) => MeetingModel.fromMap(doc.data()))
          .toList();

      print('✅ Found ${meetings.length} active meetings');
      return meetings;
    } catch (e) {
      print('❌ Error fetching active meetings: $e');
      return [];
    }
  }

  // Ajouter un co-hôte à la réunion
  Future<bool> addCoHost(String meetingId, String coHostId) async {
    try {
      print('👥 Adding co-host: $coHostId to meeting: $meetingId');

      await _firestore.collection('meetings').doc(meetingId).update({
        'coHosts': FieldValue.arrayUnion([coHostId]),
      });

      print('✅ Co-host added');
      return true;
    } catch (e) {
      print('❌ Error adding co-host: $e');
      return false;
    }
  }

  // Retirer un co-hôte
  Future<bool> removeCoHost(String meetingId, String coHostId) async {
    try {
      print('👥 Removing co-host: $coHostId from meeting: $meetingId');

      await _firestore.collection('meetings').doc(meetingId).update({
        'coHosts': FieldValue.arrayRemove([coHostId]),
      });

      print('✅ Co-host removed');
      return true;
    } catch (e) {
      print('❌ Error removing co-host: $e');
      return false;
    }
  }

  // Terminer une réunion
  Future<bool> endMeeting(String meetingId) async {
    try {
      print('🏁 Ending meeting: $meetingId');

      await _firestore.collection('meetings').doc(meetingId).update({
        'isActive': false,
      });

      print('✅ Meeting ended');
      return true;
    } catch (e) {
      print('❌ Error ending meeting: $e');
      return false;
    }
  }

  // Générer un ID de réunion unique (6 caractères)
  String _generateMeetingId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch % 36;
    String id = '';
    for (int i = 0; i < 6; i++) {
      id += chars[(random + i) % chars.length];
    }
    return id;
  }
}
