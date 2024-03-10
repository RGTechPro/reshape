part of '../../../chat_view.dart';

class _SkipButton extends ConsumerWidget {
  const _SkipButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateController = ref.read(_vsProvider.notifier);
    return Positioned(
      top: 80,
      right: 10,
      child: TextButton(
        onPressed: stateController.onPressedOverlaySkip,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F5),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0.1,
                blurRadius: 1,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Skip ⏩',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                )),
          ),
        ),
      ),
    );
  }
}
