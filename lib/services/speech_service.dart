import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService with ChangeNotifier {
  SpeechService() : _speech = stt.SpeechToText();

  final stt.SpeechToText _speech;
  bool _available = false;
  bool _listening = false;
  String _recognizedText = '';
  String get recognizedText => _recognizedText;
  bool get isListening => _listening;
  bool get isAvailable => _available;

  Future<bool> init({String? localeId}) async {
    _available = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
      debugLogging: false,
    );
    notifyListeners();
    if (_available && localeId != null && localeId.isNotEmpty) {
      final locales = await _speech.locales();
      final found = locales.firstWhere(
        (l) => l.localeId == localeId,
        orElse: () => locales.isNotEmpty
            ? locales.first
            : stt.LocaleName('en_US', 'en_US'),
      );
      _selectedLocaleId = found.localeId;
    }
    return _available;
  }

  String? _selectedLocaleId;

  Future<void> start({String? localeId}) async {
    if (!_available) {
      await init(localeId: localeId);
    }
    _recognizedText = '';
    _listening = true;
    notifyListeners();
    await _speech.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        notifyListeners();
      },
      localeId: localeId ?? _selectedLocaleId,
      listenMode: stt.ListenMode.confirmation,
      partialResults: true,
      cancelOnError: true,
    );
  }

  Future<void> stop() async {
    _listening = false;
    await _speech.stop();
    notifyListeners();
  }

  Future<void> cancel() async {
    _listening = false;
    _recognizedText = '';
    await _speech.cancel();
    notifyListeners();
  }

  void _onStatus(String status) {
    if (status == 'notListening') {
      _listening = false;
      notifyListeners();
    }
  }

  void _onError(Object error) {
    _listening = false;
    notifyListeners();
  }
}
