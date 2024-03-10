part of '../../chat_view.dart';

class _MicOverlay extends ConsumerWidget {
  const _MicOverlay();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final stateController = ref.read(_vsProvider.notifier);
    return Stack(
      children: [
        Positioned(
          right: 10,
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
                'You can click on the mic button to start recording. Try Now!!',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          right: 20,
          child: AppIconButton(
            iconSize: 50,
            onPressed: stateController.onPressedMic,
            icon: Icons.mic_rounded,
            iconColor: Colors.black,
          ),
        ),
        Positioned(
          bottom: 140,
          left: 20,
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
