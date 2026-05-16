import 'package:http/http.dart' as http;
import 'dart:convert';
import 'videosdk_config.dart';

class VideoSDKService {
  // Créer un token de réunion
  static Future<String?> createMeetingToken(String meetingId) async {
    try {
      print('🎫 Creating VideoSDK token for meeting: $meetingId');

      final response = await http
          .post(
            Uri.parse('${VideoSDKConfig.API_URL}/tokens'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': VideoSDKConfig.API_KEY,
            },
            body: jsonEncode({
              'meetingId': meetingId,
              'name': 'CRUX User',
              'role': 'SPEAKER',
            }),
          )
          .timeout(VideoSDKConfig.DEFAULT_TIMEOUT);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        print('✅ Token created: $token');
        return token;
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }

  // Créer une réunion
  static Future<String?> createMeeting(String meetingId) async {
    try {
      print('📞 Creating VideoSDK meeting: $meetingId');

      // VideoSDK crée automatiquement les réunions
      // Pas besoin d'appel API pour créer
      // Simplement utiliser le meetingId
      print('✅ Meeting ready: $meetingId');
      return meetingId;
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }

  // Démarrer le live streaming YouTube
  static Future<bool> startYouTubeLiveStream(
    String meetingId,
    String youtubeStreamKey,
    String streamTitle,
  ) async {
    try {
      print('🔴 Starting YouTube Live Stream...');

      final response = await http
          .post(
            Uri.parse('${VideoSDKConfig.API_URL}/meetings/$meetingId/livestream'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': VideoSDKConfig.API_KEY,
            },
            body: jsonEncode({
              'outputs': [
                {
                  'key': youtubeStreamKey,
                  'url': 'rtmps://a.rtmp.youtube.com/live2',
                }
              ],
            }),
          )
          .timeout(VideoSDKConfig.DEFAULT_TIMEOUT);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ YouTube Live Stream started');
        return true;
      } else {
        print('❌ Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return false;
    }
  }

  // Arrêter le live streaming
  static Future<bool> stopYouTubeLiveStream(String meetingId) async {
    try {
      print('⏹️ Stopping YouTube Live Stream...');

      final response = await http
          .delete(
            Uri.parse('${VideoSDKConfig.API_URL}/meetings/$meetingId/livestream'),
            headers: {
              'Authorization': VideoSDKConfig.API_KEY,
            },
          )
          .timeout(VideoSDKConfig.DEFAULT_TIMEOUT);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ YouTube Live Stream stopped');
        return true;
      } else {
        print('❌ Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return false;
    }
  }

  // Obtenir les infos de la réunion
  static Future<Map<String, dynamic>?> getMeetingInfo(String meetingId) async {
    try {
      print('📊 Getting meeting info...');

      final response = await http
          .get(
            Uri.parse('${VideoSDKConfig.API_URL}/meetings/$meetingId'),
            headers: {
              'Authorization': VideoSDKConfig.API_KEY,
            },
          )
          .timeout(VideoSDKConfig.DEFAULT_TIMEOUT);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('❌ Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }

  // Valider la configuration
  static bool validateConfiguration() {
    if (!VideoSDKConfig.isValidApiKey()) {
      print('❌ VideoSDK API Key not configured!');
      return false;
    }
    print('✅ VideoSDK configured correctly');
    return true;
  }
}
