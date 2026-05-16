import 'package:http/http.dart' as http;
import 'dart:convert';

class YouTubeLiveService {
  // Votre API Key Daily.co
  static const String API_KEY =
      '60539d759abecd714b0adfeca256a0e49489358447523ec3fc26e36314bc9dde';
  static const String API_URL = 'https://api.daily.co/v1';

  // Démarrer le stream YouTube avec image de couverture
  static Future<bool> startYouTubeStream(
    String roomName,
    String youtubeStreamKey,
    String streamTitle,
    String? coverImageUrl,
  ) async {
    try {
      print('🔴 Starting YouTube stream with cover image...');

      final response = await http.post(
        Uri.parse('$API_URL/rooms/$roomName/streaming'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY',
        },
        body: jsonEncode({
          'rtmpUrl': 'rtmps://a.rtmp.youtube.com/live2',
          'streamKey': youtubeStreamKey,
          'title': streamTitle,
          'properties': {
            'backgroundImage': coverImageUrl,
            'mode': 'screen-share',
          },
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ YouTube stream started with cover image');
        return true;
      } else {
        print('❌ Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  // Arrêter le streaming
  static Future<bool> stopYouTubeStream(String roomName) async {
    try {
      print('⏹️ Stopping YouTube stream...');

      final response = await http.delete(
        Uri.parse('$API_URL/rooms/$roomName/streaming'),
        headers: {
          'Authorization': 'Bearer $API_KEY',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ YouTube stream stopped');
        return true;
      } else {
        print('❌ Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  // Obtenir le statut du streaming
  static Future<Map<String, dynamic>?> getStreamingStatus(
      String roomName) async {
    try {
      print('📊 Getting streaming status...');

      final response = await http.get(
        Uri.parse('$API_URL/rooms/$roomName'),
        headers: {
          'Authorization': 'Bearer $API_KEY',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('❌ Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }
}
