// Immutable state model for the recorder screen.
class RecorderState {
  final bool microphoneGranted;
  final RecorderStatus status;
  final String? lastFilePath;
  final String selectedSyllable;
  final String? errorMessage;

  const RecorderState({
    required this.microphoneGranted,
    required this.status,
    required this.selectedSyllable,
    this.lastFilePath,
    this.errorMessage,
  });

  RecorderState copyWith({
    bool? microphoneGranted,
    RecorderStatus? status,
    String? lastFilePath,
    String? selectedSyllable,
    String? errorMessage,
  }) {
    return RecorderState(
      microphoneGranted: microphoneGranted ?? this.microphoneGranted,
      status: status ?? this.status,
      lastFilePath: lastFilePath ?? this.lastFilePath,
      selectedSyllable: selectedSyllable ?? this.selectedSyllable,
      errorMessage: errorMessage,
    );
  }

  static RecorderState initial() => const RecorderState(
        microphoneGranted: false,
        status: RecorderStatus.idle,
        selectedSyllable: 'ثَ',
        lastFilePath: null,
        errorMessage: null,
      );
}

enum RecorderStatus { idle, recording, recorded }
