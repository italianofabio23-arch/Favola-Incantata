import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_piper_tts/flutter_piper_tts.dart';
import 'package:path_provider/path_provider.dart';

class PiperVoiceService {
  PiperTTS? _tts;

  bool get isReady => _tts != null;

  Future<void> initializeMamma() async {
    if (_tts != null) return;

    final directory = await getApplicationSupportDirectory();

    final modelPath = '${directory.path}/paola.onnx';
    final configPath = '${directory.path}/paola.onnx.json';

    final modelFile = File(modelPath);
    final configFile = File(configPath);

    if (!await modelFile.exists()) {
      final modelData =
          await rootBundle.load('assets/voices/paola/paola.onnx');

      final bytes = modelData.buffer.asUint8List(
        modelData.offsetInBytes,
        modelData.lengthInBytes,
      );

      await modelFile.writeAsBytes(bytes, flush: true);
    }

    if (!await configFile.exists()) {
      final configData =
          await rootBundle.load('assets/voices/paola/paola.onnx.json');

      final bytes = configData.buffer.asUint8List(
        configData.offsetInBytes,
        configData.lengthInBytes,
      );

      await configFile.writeAsBytes(bytes, flush: true);
    }

    _tts = await PiperTTS.create(
      modelPath: modelPath,
      configPath: configPath,
    );
  }

  Future<void> speak(String text) async {
    final tts = _tts;
    if (tts == null) return;

    await tts.speak(
      text,
      waitForCompletion: true,
    );
  }

  Future<void> stop() async {
    await _tts?.stop();
  }

  Future<void> dispose() async {
    await _tts?.dispose();
    _tts = null;
  }
}
