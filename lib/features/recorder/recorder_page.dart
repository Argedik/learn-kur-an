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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5F4), Color(0xFFF6FBFB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(selectedSyllable: _state.selectedSyllable),
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(icon: Icons.my_library_books_outlined, title: 'Hedef Hece'),
                        const SizedBox(height: 12),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              isExpanded: true,
                              value: _state.selectedSyllable,
                              items: _syllables
                                  .map(
                                    (hece) => DropdownMenuItem<String>(
                                      value: hece,
                                      child: Text(
                                        hece,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                      ),
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
                          ),
                        ),
                        const SizedBox(height: 20),
                        _SectionTitle(icon: Icons.mic_none_rounded, title: 'Kayıt Kontrolleri'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed:
                                    _state.status == RecorderStatus.recording ? null : _startRecording,
                                icon: const Icon(Icons.fiber_manual_record_rounded),
                                label: const Text('Ses Kaydet'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _state.status == RecorderStatus.recording ? _stopRecording : null,
                                icon: const Icon(Icons.stop_circle_outlined),
                                label: const Text('Durdur'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _SectionTitle(icon: Icons.info_outline, title: 'Durum Özeti'),
                        const SizedBox(height: 12),
                        Wrap(
                          runSpacing: 12,
                          spacing: 12,
                          children: [
                            _StatusChip(
                              label: 'İzin',
                              value: _state.microphoneGranted ? 'Verildi' : 'Bekleniyor',
                              icon: _state.microphoneGranted ? Icons.lock_open : Icons.lock_outline,
                              color: _state.microphoneGranted
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                            ),
                            _StatusChip(
                              label: 'Durum',
                              value: _statusText,
                              icon: Icons.audiotrack,
                              color: Colors.blue.shade100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StatusInfoTile(
                          label: 'Son kayıt path',
                          value: _state.lastFilePath ?? '- henüz yok -',
                        ),
                        if (_state.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _state.errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.selectedSyllable});

  final String selectedSyllable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Günlük pratik için hazır',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Seçilen hece: $selectedSyllable',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            CircleAvatar(
              radius: 26,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              child: Icon(Icons.graphic_eq_rounded, color: theme.colorScheme.primary),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
