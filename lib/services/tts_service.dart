import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService with ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("fr-FR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      notifyListeners();
      print("TTS Error: $msg");
    });
  }

  Future<void> speak(String text, {String language = 'fr-FR'}) async {
    if (text.isNotEmpty) {
      await _flutterTts.setLanguage(language);
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  bool get isSpeaking => _isSpeaking;
}