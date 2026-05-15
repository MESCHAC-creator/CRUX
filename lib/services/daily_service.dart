import 'package:http/http.dart' as http;
import 'dart:convert';

class DailyService {
  static const String API_KEY = '60539d759abecd714b0adfeca256a0e49489358447523ec3fc26e36314bc9dde';
  static const String API_URL = 'https://api.daily.co/v1';

  // Créer une room Daily
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
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final roomUrl = data['url'];
        print('✅ Room created: $roomUrl');
        return roomUrl;
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

  // Obtenir une room existante
  static Future<String?> getRoom(String roomName) async {
    try {
      print('🔍 Getting Daily room: $roomName');

      final response = await http.get(
        Uri.parse('$API_URL/rooms/$roomName'),
        headers: {
          'Authorization': 'Bearer $API_KEY',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final roomUrl = data['url'];
        print('✅ Room found: $roomUrl');
        return roomUrl;
      } else if (response.statusCode == 404) {
        print('⚠️ Room not found, creating new one');
        return await createRoom(roomName);
      } else {
        print('❌ Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting room: $e');
      return null;
    }
  }

  // Générer un token d'accès pour la room
  static Future<String?> getAccessToken(String roomUrl) async {
    try {
      print('🔑 Generating access token for: $roomUrl');

      final response = await http.post(
        Uri.parse('$API_URL/meeting-tokens'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY',
        },
        body: jsonEncode({
          'properties': {
            'room_name': _extractRoomName(roomUrl),
            'is_owner': false,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        print('✅ Token generated');
        return token;
      } else {
        print('❌ Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error generating token: $e');
      return null;
    }
  }

  // Extraire le nom de la room de l'URL
  static String _extractRoomName(String roomUrl) {
    // https://crux.daily.co/room123 → room123
    return roomUrl.split('/').last;
  }
}
