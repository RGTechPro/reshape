import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reshape/presentation/core_widgets/app_debounce.dart';
import 'package:reshape/presentation/core_widgets/form_field/form_fields.dart';
import 'package:reshape/repository/domain/chat/chat_repository.dart';
import 'package:reshape/repository/repository.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../core_widgets/text/animated_text.dart';

part 'chat_controller.dart';
part 'widgets/message_bubble.dart';

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
              return SizedBox.shrink();
            } else {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ).copyWith(
                    top: 24,
                  ),
                  child: ListView.builder(
                    controller: stateController.chatScrollController,
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
                          SizedBox(
                            height: 16,
                          ),
                          if (isGptResponseLoading)
                            _MessageBubble(
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
                  child: TextFormField(
                    controller: stateController.queryFieldController,
                    // isMandatory: true,

                    decoration: InputDecoration(
                      hintText: 'Ask ReShape..',
                    ),
                    // errorText: state.query.error,
                    onChanged: stateController.onChangedQuery,
                    maxLines: 3,
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: stateController.onPressedSend,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.black,
                    ),
                  ),
                  //  AppCircleButton(
                  //   minWidth: 40,
                  //   color: theme.colors.primary,
                  //   onPressed: stateController.onPressedSend,
                  //   child: Padding(
                  //     padding:const EdgeInsets.all(4),
                  //     child: AppImageProvider(
                  //       image: AppAssets.sendIcon,
                  //       width: 24,
                  //       height: 24,
                  //     ),
                  //   ),
                  // ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }
}
