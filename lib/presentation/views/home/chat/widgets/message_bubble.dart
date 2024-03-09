part of '../chat_view.dart';

class _MessageBubble extends ConsumerWidget {
  final String? message;
  final bool isMyMessage;
  final bool isFetching;
  final bool isLatestMessage;

  const _MessageBubble({
    super.key,
    this.message,
    this.isMyMessage = false,
    this.isFetching = false,
    this.isLatestMessage = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateController = ref.read(_vsProvider.notifier);

    String messageText = message ?? '';

    if (isFetching) {
      messageText = 'ReShape is Typing...';
    }

    return Align(
      alignment: (isMyMessage) ? Alignment.bottomRight : Alignment.centerLeft,
      child: Container(
        margin: isMyMessage
            ? EdgeInsets.only(left: 48)
            : EdgeInsets.only(right: 48),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isMyMessage ? Color(0xFF965EFF) : Color(0xFF383739),
          borderRadius: BorderRadius.only(
            topLeft: isMyMessage ? Radius.circular(8) : Radius.zero,
            topRight: isMyMessage ? Radius.zero : Radius.circular(8),
            bottomRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
          border: Border.all(
            color: Color.fromRGBO(241, 241, 241, 0.30).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: () {
          final isAvaGeneratingMessage =
              !isMyMessage && isLatestMessage || isFetching;

          if (isAvaGeneratingMessage) {
            return AnimatedTextKit(
              key: Key(messageText),
              isRepeatingAnimation: false,
              repeatForever: false,
              displayFullTextOnTap: true,
              totalRepeatCount: 0,
              animatedTexts: [
                TyperAnimatedText(
                  messageText,
                  speed: Duration(milliseconds: isFetching ? 12 : 24),
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              onFinished: () => stateController
                  .changeLastMessageAnimationStatus(status: false),
            );
          }
          return Text(
            message ?? '',
            style: TextStyle(
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
