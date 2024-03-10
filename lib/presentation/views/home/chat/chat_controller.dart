part of 'chat_view.dart';

enum OverlayState {
  mic,
  stop,
  textBox,
  none,
}

final _vsProvider =
    StateNotifierProvider.autoDispose<_VSController, _ViewState>((ref) {
  final stateController = _VSController();

  stateController.initState();

  return stateController;
});

class _ViewState {
  final ApiStatus fetchGptResponseAPiStatus;
  final ApiStatus fetchSpeechFromTextAPiStatus;
  final ApiStatus fetchTextFromSpeechAPiStatus;
  final bool isGptTyping;
  final bool isRecording;
  final Uint8List gptSpeech;
  final FieldState<String> query;
  final GptMessage gptResponse;
  final List<GptMessage> messages;
  final OverlayState currentOverlayState;

  _ViewState({
    required this.fetchGptResponseAPiStatus,
    required this.fetchSpeechFromTextAPiStatus,
    required this.fetchTextFromSpeechAPiStatus,
    required this.isGptTyping,
    required this.isRecording,
    required this.gptSpeech,
    required this.query,
    required this.gptResponse,
    required this.messages,
    required this.currentOverlayState,
  });

  _ViewState.init()
      : this(
          fetchGptResponseAPiStatus: ApiStatus.init,
          fetchSpeechFromTextAPiStatus: ApiStatus.init,
          fetchTextFromSpeechAPiStatus: ApiStatus.init,
          isGptTyping: false,
          isRecording: false,
          gptSpeech: Uint8List(0),
          query: FieldState.initial(value: ''),
          gptResponse: GptMessage(role: '', content: ''),
          messages: [],
          currentOverlayState: OverlayState.none,
        );

  _ViewState copyWith({
    ApiStatus? fetchGptResponseAPiStatus,
    ApiStatus? fetchSpeechFromTextAPiStatus,
    ApiStatus? fetchTextFromSpeechAPiStatus,
    bool? isGptTyping,
    bool? isRecording,
    Uint8List? gptSpeech,
    FieldState<String>? query,
    GptMessage? gptResponse,
    List<GptMessage>? messages,
    OverlayState? currentOverlayState,
  }) {
    return _ViewState(
      fetchGptResponseAPiStatus:
          fetchGptResponseAPiStatus ?? this.fetchGptResponseAPiStatus,
      fetchSpeechFromTextAPiStatus:
          fetchSpeechFromTextAPiStatus ?? this.fetchSpeechFromTextAPiStatus,
      fetchTextFromSpeechAPiStatus:
          fetchTextFromSpeechAPiStatus ?? this.fetchTextFromSpeechAPiStatus,
      isGptTyping: isGptTyping ?? this.isGptTyping,
      isRecording: isRecording ?? this.isRecording,
      gptSpeech: gptSpeech ?? this.gptSpeech,
      query: query ?? this.query,
      gptResponse: gptResponse ?? this.gptResponse,
      messages: messages ?? this.messages,
      currentOverlayState: currentOverlayState ?? this.currentOverlayState,
    );
  }
}

class _VSController extends StateNotifier<_ViewState> {
  _VSController() : super(_ViewState.init());
  late ScrollController _chatScrollController;
  late TextEditingController _queryFieldController;
  late RecorderController _recordingController;
  late OverlayPortalController _overlayController;
  final double listTileHeight = 100;
  String? _filePath;
  late AudioPlayer _player;
  late AppStorage _appStorage;
  final focusNode = FocusNode();

  bool isLastMessageAnimationEnabled = false;

  void initState() {
    _player = AudioPlayer();
    _chatScrollController = ScrollController();
    _queryFieldController = TextEditingController();
    _recordingController = RecorderController();
    _overlayController = OverlayPortalController();
    _appStorage = AppStorage.persistentStorage();
    resolveOverlay();
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      _scrollChatListToBottom();
    });
  }

  void resolveOverlay() async {
    bool? shouldShowOverlay =
        await _appStorage.retrieveBool(key: 'shouldShowOverlay');

    if (shouldShowOverlay == null || shouldShowOverlay) {
      _overlayController.show();
      state = state.copyWith(
        currentOverlayState: OverlayState.textBox,
      );
    }
  }

  void _scrollChatListToBottom() {
    if (state.messages.isNotEmpty) {
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void changeStateToTyping() {
    if (!state.isGptTyping) {
      changeLastMessageAnimationStatus(status: true);
      state = state.copyWith(
        isGptTyping: true,
      );
    }
  }

  void resetGptTyping() {
    if (state.isGptTyping) {
      changeLastMessageAnimationStatus(status: true);
      state = state.copyWith(
        isGptTyping: false,
      );
    }
  }

  void onChangedQuery(String value) {
    state = state.copyWith(
      query: state.query.copyWith(
        value: value,
        error: '',
      ),
    );
  }

  void playSound() async {
    await _player.play(BytesSource(state.gptSpeech));
  }

  void stopSound() async {
    await _player.stop();
  }

  Future<void> startRecording() async {
    final hasPermission = await _recordingController.checkPermission();
    if (hasPermission) {
      await _recordingController.record();
    }
  }

  Future<void> stopRecording() async {
    _filePath = await _recordingController.stop();
    _recordingController.refresh();
  }

  void onPressedMic() async {
    if (state.currentOverlayState == OverlayState.textBox) {
      return;
    }
    if (!state.isRecording && state.currentOverlayState == OverlayState.stop) {
      onPressedOverlayNext();
      return;
    }
    onPressedOverlayNext();

    state = state.copyWith(
      isRecording: !state.isRecording,
    );

    if (state.isRecording) {
      await startRecording();
    } else {
      await stopRecording();
      getTextFromSpeech();
    }
  }

  Future<void> getTextFromSpeech() async {
    state = state.copyWith(
      fetchTextFromSpeechAPiStatus: ApiStatus.loading,
    );

    final chatRepository = ChatRepository();

    final audioFile = await MultipartFile.fromFile(
      _filePath!,
    );

    final response = await chatRepository.getTextFromSpeech(
        request: GetTextFromSpeechRequest(
      audioFile: audioFile,
    ));

    void onSuccess(GetTextFromSpeechSuccess success) {
      state = state.copyWith(
        fetchTextFromSpeechAPiStatus: ApiStatus.success,
        query: state.query.copyWith(
          value: success.text,
        ),
      );
      _queryFieldController.text = success.text;
    }

    void onFailure(GetTextFromSpeechFailure failure) {
      state = state.copyWith(
        fetchTextFromSpeechAPiStatus: ApiStatus.failed,
      );
    }

    response.resolve(onSuccess, onFailure);
  }

  bool get isQueryVerified {
    final hasQuery = state.query.value.isNotEmpty;
    if (!hasQuery) {
      state = state.copyWith(
        query: state.query.copyWith(
          error: 'Please enter a query',
        ),
      );
    }
    final hasQueryError = state.query.error.isNotEmpty;
    return !hasQueryError;
  }

  Future<void> getGptResponse() async {
    stopSound();
    state = state.copyWith(
      fetchGptResponseAPiStatus: ApiStatus.loading,
    );

    final chatRepository = ChatRepository();

    final response = await chatRepository.getGptResponse(
        request: GetGptResponseRequest(messages: state.messages));

    void onSuccess(GetGptResponseSuccess success) {
      state = state.copyWith(
        fetchGptResponseAPiStatus: ApiStatus.success,
        gptResponse: success.chatResponse.choices.first.message,
        messages: [
          ...state.messages,
          success.chatResponse.choices.first.message
        ],
      );
      getTextToSpeech();
      resetGptTyping();
    }

    void onFailure(GetGptResponseFailure failure) {
      state = state.copyWith(
        fetchGptResponseAPiStatus: ApiStatus.failed,
      );
    }

    response.resolve(onSuccess, onFailure);
  }

  Future<void> getTextToSpeech() async {
    state = state.copyWith(
      fetchSpeechFromTextAPiStatus: ApiStatus.loading,
    );

    final chatRepository = ChatRepository();

    final response = await chatRepository.getSpeechFromText(
        request: GetSpeechFromTextRequest(text: state.gptResponse.content));

    void onSuccess(GetSpeechFromTextSuccess success) {
      state = state.copyWith(
        fetchSpeechFromTextAPiStatus: ApiStatus.success,
        gptSpeech: success.speech,
      );
      playSound();
    }

    void onFailure(GetSpeechFromTextFailure failure) {
      state = state.copyWith(
        fetchSpeechFromTextAPiStatus: ApiStatus.failed,
      );
    }

    response.resolve(onSuccess, onFailure);
  }

  void onPressedOverlayNext() async {
    switch (state.currentOverlayState) {
      case OverlayState.mic:
        state = state.copyWith(
          currentOverlayState: OverlayState.stop,
        );
        break;
      case OverlayState.stop:
        state = state.copyWith(
          currentOverlayState: OverlayState.none,
        );
        _overlayController.hide();
        await _appStorage.storeBool(key: 'shouldShowOverlay', data: false);
        break;
      case OverlayState.textBox:
        state = state.copyWith(
          currentOverlayState: OverlayState.mic,
        );
        break;
      case OverlayState.none:
        break;
    }
  }

  void onPressedOverlaySkip() async {
    state = state.copyWith(
      currentOverlayState: OverlayState.none,
    );
    _overlayController.hide();

    await _appStorage.storeBool(key: 'shouldShowOverlay', data: false);
  }

  void onPressedSend() {
    if (state.currentOverlayState != OverlayState.none) {
      return;
    }

    onPressedOverlayNext();

    if (isQueryVerified) {
      final messages = state.messages;
      messages.add(GptMessage(role: 'user', content: state.query.value));
      state = state.copyWith(
        messages: messages,
      );
      getGptResponse();
      changeStateToTyping();
      state = state.copyWith(
        query: state.query.copyWith(
          value: '',
          error: '',
        ),
      );
      _queryFieldController.clear();
    }
  }

  void changeLastMessageAnimationStatus({bool status = false}) {
    isLastMessageAnimationEnabled = status;
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
    _recordingController.dispose();
  }
}
