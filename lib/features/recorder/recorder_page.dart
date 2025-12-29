// Recorder screen showing controls and live status for the MVP.
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../shared/widgets/status_info_tile.dart';
import 'recorder_service.dart';
import 'recorder_state.dart';

class RecorderPage extends StatefulWidget {
  const RecorderPage({super.key});

  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  final RecorderService _recorderService = RecorderService();
  RecorderState _state = RecorderState.initial();

  List<String> get _syllables => const ['ثَ', 'ثِ', 'ثُ'];

  @override
  void dispose() {
    _recorderService.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() {
      _state = _state.copyWith(errorMessage: null);
    });

    final hasPermission = await _recorderService.ensurePermission();
    if (!hasPermission) {
      setState(() {
        _state = _state.copyWith(
          microphoneGranted: false,
          errorMessage: 'Mikrofon izni verilmedi. Lütfen ayarlardan izin verin.',
        );
      });
      return;
    }

    final recorderStatus = await Permission.microphone.status;
    final startedMessage = await _recorderService.startRecording();
    if (startedMessage == null) {
      setState(() {
        _state = _state.copyWith(
          microphoneGranted: recorderStatus.isGranted,
          status: RecorderStatus.idle,
          errorMessage:
              'Kayıt başlatılamadı. Mikrofon izni veya donanım erişimi doğrulanamadı.',
        );
      });
      return;
    }
    setState(() {
      _state = _state.copyWith(
        microphoneGranted: recorderStatus.isGranted,
        status: RecorderStatus.recording,
        lastFilePath: startedMessage,
      );
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorderService.stopRecording();
    setState(() {
      _state = _state.copyWith(
        status: path == null ? RecorderStatus.idle : RecorderStatus.recorded,
        lastFilePath: path ?? _state.lastFilePath,
      );
    });
  }

  String get _statusText {
    switch (_state.status) {
      case RecorderStatus.idle:
        return 'Hazır';
      case RecorderStatus.recording:
        return 'Kayıt alınıyor';
      case RecorderStatus.recorded:
        return 'Kayıt alındı';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elif-Ba Ses Eğitimi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hedef Hece',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _state.selectedSyllable,
              items: _syllables
                  .map(
                    (hece) => DropdownMenuItem<String>(
                      value: hece,
                      child: Text(hece),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _state = _state.copyWith(selectedSyllable: value);
                });
              },
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _state.status == RecorderStatus.recording ? null : _startRecording,
                  icon: const Icon(Icons.mic),
                  label: const Text('Ses Kaydet'),
                ),
                OutlinedButton.icon(
                  onPressed: _state.status == RecorderStatus.recording ? _stopRecording : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Durdur'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Bilgi Alanı',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            StatusInfoTile(
              label: 'İzin durumu',
              value: _state.microphoneGranted ? 'Verildi' : 'Bekleniyor / Reddedildi',
            ),
            const SizedBox(height: 8),
            StatusInfoTile(
              label: 'Kayıt durumu',
              value: _statusText,
            ),
            const SizedBox(height: 8),
            StatusInfoTile(
              label: 'Son kayıt path',
              value: _state.lastFilePath ?? '- henüz yok -',
            ),
            if (_state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _state.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
