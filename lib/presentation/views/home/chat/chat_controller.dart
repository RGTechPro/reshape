part of 'chat_view.dart';

final _vsProvider =
    StateNotifierProvider.autoDispose<_VSController, _ViewState>((ref) {
  final stateController = _VSController();

  stateController.initState();

  return stateController;
});

class _ViewState {
  final ApiStatus fetchGptResponseAPiStatus;
  final bool isGptTyping;

  final FieldState<String> query;
  final GptMessage gptResponse;
  final List<GptMessage> messages;

  _ViewState({
    required this.fetchGptResponseAPiStatus,
    required this.isGptTyping,
    required this.query,
    required this.gptResponse,
    required this.messages,
  });

  _ViewState.init()
      : this(
          fetchGptResponseAPiStatus: ApiStatus.init,
          isGptTyping: false,
          query: FieldState.initial(value: ''),
          gptResponse: GptMessage(role: '', content: ''),
          messages: [],
        );

  _ViewState copyWith({
    ApiStatus? fetchGptResponseAPiStatus,
    bool? isGptTyping,
    FieldState<String>? query,
    GptMessage? gptResponse,
    List<GptMessage>? messages,
  }) {
    return _ViewState(
      fetchGptResponseAPiStatus:
          fetchGptResponseAPiStatus ?? this.fetchGptResponseAPiStatus,
      isGptTyping: isGptTyping ?? this.isGptTyping,
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
      resetGptTyping();
    }

    void onFailure(GetGptResponseFailure failure) {
      state = state.copyWith(
        fetchGptResponseAPiStatus: ApiStatus.failed,
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
