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
  final bool isGptTyping;
  final Uint8List gptSpeech;
  final FieldState<String> query;
  final GptMessage gptResponse;
  final List<GptMessage> messages;

  _ViewState({
    required this.fetchGptResponseAPiStatus,
    required this.fetchSpeechFromTextAPiStatus,
    required this.isGptTyping,
    required this.gptSpeech,
    required this.query,
    required this.gptResponse,
    required this.messages,
  });

  _ViewState.init()
      : this(
          fetchGptResponseAPiStatus: ApiStatus.init,
          fetchSpeechFromTextAPiStatus: ApiStatus.init,
          isGptTyping: false,
          gptSpeech: Uint8List(0),
          query: FieldState.initial(value: ''),
          gptResponse: GptMessage(role: '', content: ''),
          messages: [],
        );

  _ViewState copyWith({
    ApiStatus? fetchGptResponseAPiStatus,
    ApiStatus? fetchSpeechFromTextAPiStatus,
    bool? isGptTyping,
    Uint8List? gptSpeech,
    FieldState<String>? query,
    GptMessage? gptResponse,
    List<GptMessage>? messages,
  }) {
    return _ViewState(
      fetchGptResponseAPiStatus:
          fetchGptResponseAPiStatus ?? this.fetchGptResponseAPiStatus,
      fetchSpeechFromTextAPiStatus:
          fetchSpeechFromTextAPiStatus ?? this.fetchSpeechFromTextAPiStatus,
      isGptTyping: isGptTyping ?? this.isGptTyping,
      gptSpeech: gptSpeech ?? this.gptSpeech,
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
  final focusNode = FocusNode();

  bool isLastMessageAnimationEnabled = false;

  void initState() {
    chatScrollController = ScrollController();
    queryFieldController = TextEditingController();
    _debounce = AppDebounce(
      Duration(milliseconds: 250),
    );
    Future.delayed(Duration(milliseconds: 500)).then((value) {
      _scrollChatListToBottom();
    });
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
    final player = AudioPlayer();
    print(state.gptSpeech);
    await player.play(BytesSource(state.gptSpeech));
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
  }
}
