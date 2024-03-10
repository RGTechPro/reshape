part of '../chat_view.dart';

class _MessageBubble extends ConsumerWidget {
  final String? message;
  final bool isMyMessage;
  final bool isFetching;
  final bool isLatestMessage;

  const _MessageBubble({
    this.message,
    this.isMyMessage = false,
    this.isFetching = false,
    this.isLatestMessage = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_vsProvider);
    final stateController = ref.read(_vsProvider.notifier);

    String messageText = message ?? '';

    if (isFetching) {
      messageText = 'ReShape is Typing...';
    }

    return Align(
      alignment: (isMyMessage) ? Alignment.bottomRight : Alignment.centerLeft,
      child: Container(
        margin: isMyMessage
            ? const EdgeInsets.only(left: 48)
            : const EdgeInsets.only(right: 48),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              isMyMessage ? const Color(0xFF965EFF) : const Color(0xFF383739),
          borderRadius: BorderRadius.only(
            topLeft: isMyMessage ? const Radius.circular(8) : Radius.zero,
            topRight: isMyMessage ? Radius.zero : const Radius.circular(8),
            bottomRight: const Radius.circular(8),
            bottomLeft: const Radius.circular(8),
          ),
          border: Border.all(
            color: const Color.fromRGBO(241, 241, 241, 0.30).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: () {
          final isAvaGeneratingMessage =
              !isMyMessage && isLatestMessage || isFetching;

          if (isAvaGeneratingMessage) {
            return Column(
              children: [
                AnimatedTextKit(
                  key: Key(messageText),
                  isRepeatingAnimation: false,
                  repeatForever: false,
                  displayFullTextOnTap: true,
                  totalRepeatCount: 0,
                  animatedTexts: [
                    TyperAnimatedText(
                      messageText,
                      speed: Duration(milliseconds: isFetching ? 12 : 24),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  onFinished: () => stateController
                      .changeLastMessageAnimationStatus(status: false),
                ),
                if (state.fetchSpeechFromTextAPiStatus == ApiStatus.loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.multitrack_audio),
                        Text(
                          'Audio is being generated...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            );
          }
          return Text(
            message ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          );
        }(),
      ),
    );
  }
}
