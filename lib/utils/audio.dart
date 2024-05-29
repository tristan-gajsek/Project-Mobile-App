import "dart:async";

import "package:flutter_sound/flutter_sound.dart";

class AudioRecorder {
  FlutterSoundRecorder? _recorder = FlutterSoundRecorder();
  StreamSubscription<Food> _recordingSubscription;
  double _maxVolume = 0.0;

  Future<void> startRecording() async {
    _recordingSubscription = _recorder!.startRecorder(toFile: 'path_to_audio_file').listen((event) {
      if (event.decibels! > _maxVolume) {
        _maxVolume = event.decibels!;
      }
    });
    Timer(Duration(minutes: 1), () {
      stopRecording();
    });
  }

  Future<void> stopRecording() async {
    await _recorder!.stopRecorder();
    await _recorder!.closeAudioSession();
    _recordingSubscription?.cancel();
    _recorder = null;
  }

  double get maxVolume => _maxVolume;
}

You can use this `AudioRecorder` class to record audio and then check the maximum volume:

AudioRecorder _audioRecorder = AudioRecorder();
await _audioRecorder.startRecording();
// Wait for 1 minute...
double maxVolume = _audioRecorder.maxVolume;
print('Max volume: $maxVolume');
