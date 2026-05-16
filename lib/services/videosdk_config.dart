class VideoSDKConfig {
  // ⚠️ REMPLACEZ PAR VOTRE API KEY VideoSDK
  static const String API_KEY = 'bd7e2f14-977a-4e85-8ef5-bf7357a879f2';
  
  // URL API VideoSDK
  static const String API_URL = 'https://api.videosdk.live';

  // Configuration
  static const String APP_NAME = 'CRUX';
  static const int DEFAULT_AUDIO_BIT_RATE = 128000;
  static const int DEFAULT_VIDEO_BIT_RATE = 2500000;
  
  // Timeouts
  static const Duration DEFAULT_TIMEOUT = Duration(seconds: 30);
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 15);

  // ValidationFunctions
  static bool isValidApiKey() {
    return API_KEY != 'YOUR_VIDEOSDK_API_KEY_HERE' && API_KEY.isNotEmpty;
  }

  static String getApiEndpoint(String endpoint) {
    return '$API_URL/$endpoint';
  }
}
