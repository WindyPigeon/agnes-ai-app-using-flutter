// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import 'composer.dart';
import 'message_bubble.dart';
import 'suggested_cards.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.appState});

  final AppState appState;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    await widget.appState.sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _insertQuickPrompt(String prompt) {
    _controller.text = prompt;
    _controller.selection = TextSelection.collapsed(offset: prompt.length);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final convo = widget.appState.activeConversation;
        if (convo == null || convo.isEmpty) {
          return _WelcomeState(
            controller: _controller,
            isSending: widget.appState.isSending,
            onSend: _send,
            onQuickPrompt: _insertQuickPrompt,
          );
        }

        _scrollToBottom();

        return Column(
          children: [
            _ConversationHeader(title: convo.title),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
                itemCount: convo.messages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final message = convo.messages[index];
                  final isLastAssistant = index == convo.messages.length - 1 &&
                      message.role == MessageRole.assistant &&
                      !widget.appState.isSending;
                  return MessageBubble(
                    message: message,
                    onRegenerate: isLastAssistant
                        ? () async {
                            await widget.appState.regenerateLast();
                            _scrollToBottom();
                          }
                        : null,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
              child: Composer(
                controller: _controller,
                isSending: widget.appState.isSending,
                onSend: _send,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  const _ConversationHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          IconButton(icon: const Icon(Icons.star_border, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.ios_share, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.description_outlined, size: 20), onPressed: () {}),
        ],
      ),
    );
  }
}

class _WelcomeState extends StatelessWidget {
  const _WelcomeState({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.onQuickPrompt,
  });

  final TextEditingController controller;
  final bool isSending;
  final ValueChanged<String> onSend;
  final ValueChanged<String> onQuickPrompt;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  children: const [
                    TextSpan(text: 'Welcome ', style: TextStyle(color: AppColors.primaryBlue)),
                    TextSpan(text: 'What can I do for you?'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Composer(controller: controller, isSending: isSending, onSend: onSend),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: QuickActionRow(onSelect: onQuickPrompt),
              ),
              const SizedBox(height: 28),
              SuggestedForYou(onSelect: (s) => onSend(s)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
