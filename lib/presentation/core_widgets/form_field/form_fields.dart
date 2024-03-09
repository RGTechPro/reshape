class FieldState<T> {
  final T value;
  final bool isActive;
  final String error;
  final AssetUploadState? uploadState;

  FieldState({
    required this.value,
    this.isActive = false,
    required this.error,
    this.uploadState,
  });

  FieldState.initial({required T value, bool? isActive})
      : this(
          value: value,
          isActive: isActive ?? true,
          error: '',
          uploadState: AssetUploadState.initial(),
        );

  FieldState<T> copyWith({
    T? value,
    bool? isActive,
    String? error,
    AssetUploadState? uploadState,
  }) {
    return FieldState(
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
      error: error ?? this.error,
      uploadState: uploadState ?? this.uploadState,
    );
  }
}


enum AssetUploadStatus { init, progress, success, failed }

class AssetUploadState {
  final AssetUploadStatus status;
  double? percentage;

  AssetUploadState({
    required this.status,
    this.percentage,
  });

  AssetUploadState.initial()
      : this(
          status: AssetUploadStatus.init,
          percentage: 0.0,
        );

  AssetUploadState.progress()
      : this(
          status: AssetUploadStatus.progress,
          percentage: 1.0,
        );

  AssetUploadState.success()
      : this(
          status: AssetUploadStatus.success,
          percentage: 0.0,
        );

  AssetUploadState.failed()
      : this(
          status: AssetUploadStatus.failed,
          percentage: 0.0,
        );

  AssetUploadState copyWith({
    AssetUploadStatus? status,
    double? percentage,
  }) {
    return AssetUploadState(
      status: status ?? this.status,
      percentage: percentage ?? this.percentage,
    );
  }
}
