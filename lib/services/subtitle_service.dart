import 'package:speech_to_text/speech_to_text.dart' as stt;

class SubtitleService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  Function(String)? onResult;
  Function(String)? onError;

  Future<void> initialize() async {
    final available = await _speechToText.initialize(
      onError: (error) => onError?.call(error.errorMsg),
      onStatus: (status) => print('Status: $status'),
    );
    if (!available) {
      onError?.call('Speech recognition not available');
    }
  }

  Future<void> startListening(String languageCode) async {
    if (!_isListening) {
      final available = await _speechToText.initialize();
      if (available) {
        _isListening = true;
        _speechToText.listen(
          onResult: (result) {
            _lastWords = result.recognizedWords;
            onResult?.call(_lastWords);
          },
          localeId: languageCode,
        );
      }
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      _isListening = false;
      _speechToText.stop();
    }
  }

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
}
