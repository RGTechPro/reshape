part of '../../chat_view.dart';

class _TextBoxOverlay extends ConsumerWidget {
  const _TextBoxOverlay();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(_vsProvider);
    final stateController = ref.read(_vsProvider.notifier);
    return Stack(
      children: [
        Positioned(
          left: 10,
          bottom: 110,
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F5),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'You can type your prompt here and click on the send button to send it.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: SizedBox(
            width: 300,
            child: TextFormX(
              onChanged: (v) {},
              maxLines: 2,
              enabled: false,
              // isProcessing: state.fetchTextFromSpeechAPiStatus ==
              //     ApiStatus.loading,
            ),
          ),
        ),
        Positioned(
          bottom: 150,
          right: 20,
          child: TextButton(
            child: const Text('Next ➨',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                )),
            onPressed: stateController.onPressedOverlayNext,
          ),
        ),
      _SkipButton(),
      ],
    );
  }
}
