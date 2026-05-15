import 'package:http/http.dart' as http;
import 'dart:convert';

class DailyApiService {
  // Votre API Key Daily.co
  static const String API_KEY = '60539d759abecd714b0adfeca256a0e49489358447523ec3fc26e36314bc9dde';
  static const String API_URL = 'https://api.daily.co/v1';
  static const String SUBDOMAIN = 'crux';

  // Créer une room automatiquement
  static Future<String?> createRoom(String roomName) async {
    try {
      print('🔐 Creating Daily room: $roomName');

      final response = await http.post(
        Uri.parse('$API_URL/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY',
        },
        body: jsonEncode({
          'name': roomName,
          'privacy': 'public',
          'properties': {
            'enable_chat': true,
            'enable_screenshare': true,
            'enable_recording': true,
            'max_participants': 100,
          },
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final roomUrl = data['url'];
        print('✅ Room created: $roomUrl');
        return roomUrl;
      } else if (response.statusCode == 409) {
        // La room existe déjà, c'est bon
        print('⚠️ Room already exists');
        return 'https://$SUBDOMAIN.daily.co/$roomName';
      } else {
        print('❌ Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating room: $e');
      return null;
    }
  }

  // Générer un nom de room aléatoire
  static String generateRoomName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 9000) + 1000; // 4 chiffres aléatoires
    return 'ROOM-$random';
  }

  // Obtenir une room existante
  static Future<String?> getRoom(String roomName) async {
    try {
      print('🔍 Getting Daily room: $roomName');

      final response = await http.get(
        Uri.parse('$API_URL/rooms/$roomName'),
        headers: {
          'Authorization': 'Bearer $API_KEY',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final roomUrl = data['url'];
        print('✅ Room found: $roomUrl');
        return roomUrl;
      } else {
        print('⚠️ Room not found, will create it');
        return await createRoom(roomName);
      }
    } catch (e) {
      print('❌ Error getting room: $e');
      return null;
    }
  }
}
