import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reshape/modules/core/domain/persistent_storage/persistent_storage.dart';
import 'package:reshape/presentation/core_widgets/app_debounce.dart';
import 'package:reshape/presentation/core_widgets/buttons/app_icon_button.dart';
import 'package:reshape/presentation/core_widgets/form_field/form_fields.dart';
import 'package:reshape/repository/domain/chat/chat_repository.dart';
import 'package:reshape/repository/repository.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../../core_widgets/text/animated_text.dart';

part 'chat_controller.dart';
part 'widgets/message_bubble.dart';
part 'widgets/overlays/stop_overlay.dart';
part 'widgets/overlays/text_box_overlay.dart';
part 'widgets/overlays/mic_overlay.dart';
part 'widgets/overlays/widgets/skip_button.dart';

class ChatView extends ConsumerWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_vsProvider);
    final stateController = ref.read(_vsProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Reshape',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          () {
            if (state.messages.isEmpty) {
              return const Expanded(
                  child: SizedBox(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Start a new chat with Reshape\n NOTE: Chats are not stored and would be refreshed on a new session.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ));
            } else {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ).copyWith(
                    top: 24,
                  ),
                  child: ListView.builder(
                    controller: stateController._chatScrollController,
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      int reversedIndex = state.messages.length - 1 - index;
                      bool isLatestMessage = index == 0 &&
                          stateController.isLastMessageAnimationEnabled;

                      if (state.fetchGptResponseAPiStatus !=
                          ApiStatus.loading) {
                        stateController.changeLastMessageAnimationStatus(
                          status: false,
                        );
                      }

                      bool isGptResponseLoading =
                          state.fetchGptResponseAPiStatus ==
                                  ApiStatus.loading &&
                              isLatestMessage;

                      return Column(
                        children: [
                          _MessageBubble(
                            message: state.messages[reversedIndex].content,
                            isMyMessage:
                                state.messages[reversedIndex].role == 'user',
                            isLatestMessage: isLatestMessage,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          if (isGptResponseLoading)
                            const _MessageBubble(
                              isFetching: true,
                            ),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }
          }(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      if (!state.isRecording)
                        TextFormX(
                          enabled:
                              state.currentOverlayState == OverlayState.none,
                          controller: stateController._queryFieldController,
                          onChanged: stateController.onChangedQuery,
                          maxLines: 2,
                          isProcessing: state.fetchTextFromSpeechAPiStatus ==
                              ApiStatus.loading,
                        ),
                      if (state.isRecording)
                        AudioWaveforms(
                          size: Size(MediaQuery.of(context).size.width, 80.0),
                          recorderController:
                              stateController._recordingController,
                          enableGesture: true,
                          waveStyle: WaveStyle(
                            waveColor: Colors.blue,
                            showDurationLabel: false,
                            spacing: 8.0,
                            scaleFactor: 280,
                            showBottom: false,
                            extendWaveform: true,
                            showMiddleLine: false,
                            gradient: ui.Gradient.linear(
                              const Offset(70, 50),
                              Offset(MediaQuery.of(context).size.width / 2, 0),
                              [
                                Colors.indigo,
                                Colors.blue,
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      if (stateController._queryFieldController.text.isNotEmpty)
                        AppIconButton(
                          onPressed: stateController.onPressedSend,
                          icon: Icons.send_rounded,
                        ),
                      if (stateController._queryFieldController.text.isEmpty)
                        AppIconButton(
                          iconSize: 40,
                          onPressed: stateController.onPressedMic,
                          icon: (state.isRecording)
                              ? Icons.stop_circle_rounded
                              : Icons.mic_rounded,
                          iconColor:
                              (state.isRecording) ? Colors.red : Colors.black,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          OverlayPortal(
            controller: stateController._overlayController,
            overlayChildBuilder: (BuildContext context) {
              return BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: () {
                  switch (state.currentOverlayState) {
                    case OverlayState.textBox:
                      return const _TextBoxOverlay();
                    case OverlayState.mic:
                      return const _MicOverlay();
                    case OverlayState.stop:
                      return const _StopOverlay();
                    default:
                      return const SizedBox.shrink();
                  }
                }(),
              );
            },
          )
        ],
      ),
    );
  }
}
