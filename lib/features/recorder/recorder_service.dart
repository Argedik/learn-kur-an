// Lightweight wrapper around the record package and permission handling.
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class RecorderService {
  RecorderService({AudioRecorder? recorder}) : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  Future<bool> ensurePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final requested = await Permission.microphone.request();
    return requested.isGranted;
  }

  Future<String?> startRecording() async {
    final hasPermission = await ensurePermission();
    if (!hasPermission) return null;

    final hasRecorderPermission = await _recorder.hasPermission();
    if (!hasRecorderPermission) return null;

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav),
    );
    return 'Recording started';
  }

  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    return path;
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
