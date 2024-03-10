part of '../../chat_view.dart';

class _TextBoxOverlay extends ConsumerWidget {
  const _TextBoxOverlay();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final stateController = ref.read(_vsProvider.notifier);
    final _mediaQuery = MediaQuery.of(context);

    return Stack(
      children: [
        Positioned(
          left: 10,
          bottom: 110,
          child: Container(
            width: _mediaQuery.size.width * 0.5,
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
          bottom: _mediaQuery.size.height * 0.03,
          left: _mediaQuery.size.height * 0.025,
          child: SizedBox(
            width: _mediaQuery.size.width * 0.75,
            child: TextFormX(
              onChanged: (v) {},
              maxLines: 2,
              enabled: false,
            ),
          ),
        ),
        Positioned(
          bottom: _mediaQuery.size.width * 0.35,
          right: _mediaQuery.size.height * 0.025,
          child: TextButton(
            onPressed: stateController.onPressedOverlayNext,
            child: const Text('Next ➨',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                )),
          ),
        ),
        const _SkipButton(),
      ],
    );
  }
}
