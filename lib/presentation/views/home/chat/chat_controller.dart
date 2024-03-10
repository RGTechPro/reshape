part of 'chat_view.dart';

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
  final Uint8List userSpeech;
  final FieldState<String> query;
  final GptMessage gptResponse;
  final List<GptMessage> messages;

  _ViewState({
    required this.fetchGptResponseAPiStatus,
    required this.fetchSpeechFromTextAPiStatus,
    required this.fetchTextFromSpeechAPiStatus,
    required this.isGptTyping,
    required this.isRecording,
    required this.gptSpeech,
    required this.userSpeech,
    required this.query,
    required this.gptResponse,
    required this.messages,
  });

  _ViewState.init()
      : this(
          fetchGptResponseAPiStatus: ApiStatus.init,
          fetchSpeechFromTextAPiStatus: ApiStatus.init,
          fetchTextFromSpeechAPiStatus: ApiStatus.init,
          isGptTyping: false,
          isRecording: false,
          gptSpeech: Uint8List(0),
          userSpeech: Uint8List(0),
          query: FieldState.initial(value: ''),
          gptResponse: GptMessage(role: '', content: ''),
          messages: [],
        );

  _ViewState copyWith({
    ApiStatus? fetchGptResponseAPiStatus,
    ApiStatus? fetchSpeechFromTextAPiStatus,
    ApiStatus? fetchTextFromSpeechAPiStatus,
    bool? isGptTyping,
    bool? isRecording,
    Uint8List? gptSpeech,
    Uint8List? userSpeech,
    FieldState<String>? query,
    GptMessage? gptResponse,
    List<GptMessage>? messages,
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
      userSpeech: userSpeech ?? this.userSpeech,
      query: query ?? this.query,
      gptResponse: gptResponse ?? this.gptResponse,
      messages: messages ?? this.messages,
    );
  }
}

class _VSController extends StateNotifier<_ViewState> {
  _VSController() : super(_ViewState.init());
  late ScrollController chatScrollController;
  late TextEditingController queryFieldController;
  late AppDebounce _debounce;
  final double listTileHeight = 100;
  final _filePath = '/tmp/my-audio.m4a';
  late Stream<Uint8List> _stream;
  late StreamSubscription<Uint8List> _audioStreamSubscription;
  late AudioPlayer _player;
  late AudioRecorder _recorder;
  final focusNode = FocusNode();

  bool isLastMessageAnimationEnabled = false;

  void initState() {
    _player = AudioPlayer();
    _recorder = AudioRecorder();
    chatScrollController = ScrollController();
    queryFieldController = TextEditingController();
    _debounce = AppDebounce(
      Duration(milliseconds: 250),
    );
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      _scrollChatListToBottom();
    });
  }

  void _listenToStream() {
    _audioStreamSubscription = _stream.listen(
      (event) {
        state = state.copyWith(
          userSpeech: event,
        );
      },
      onDone: () {
        print('done');
      },
    );
  }

  void _scrollChatListToBottom() {
    if (state.messages.isNotEmpty) {
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
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
    if (await _recorder.hasPermission()) {
      _stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
        ),
      );
      _listenToStream();
      // await _recorder.start(const RecordConfig(), path: _filePath);
    }
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
    _audioStreamSubscription.cancel();
  }

  void onPressedMic() async {
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

    final _chatRepository = ChatRepository();
    print(state.userSpeech);
    final audioFile = (state.userSpeech.isNotEmpty)
        ? MultipartFile.fromBytes(
          state.userSpeech,
          contentType: MediaType('audio', 'pcm'),
          // _recorder.convertBytesToInt16(state.userSpeech)  ,
            
          )
        : null;

    final response = await _chatRepository.getTextFromSpeech(
        request: GetTextFromSpeechRequest(
      audioFile: audioFile!,
    ));

    void onSuccess(GetTextFromSpeechSuccess success) {
      state = state.copyWith(
        fetchTextFromSpeechAPiStatus: ApiStatus.success,
        query: state.query.copyWith(
          value: success.text,
        ),
      );
      queryFieldController.text = success.text;
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

    final _chatRepository = ChatRepository();

    final response = await _chatRepository.getGptResponse(
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

    final _chatRepository = ChatRepository();

    final response = await _chatRepository.getSpeechFromText(
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

  void onPressedSend() {
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
      queryFieldController.clear();
    }
  }

  void changeLastMessageAnimationStatus({bool status = false}) {
    isLastMessageAnimationEnabled = status;
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
    _recorder.dispose();
  }
}
