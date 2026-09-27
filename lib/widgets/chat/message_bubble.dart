// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/chat_message.dart';
import '../../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.onRegenerate,
  });

  final ChatMessage message;
  final VoidCallback? onRegenerate;

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: _isUser
                ? const EdgeInsets.symmetric(horizontal: 18, vertical: 12)
                : EdgeInsets.zero,
            decoration: _isUser
                ? BoxDecoration(
                    color: AppColors.userBubble,
                    borderRadius: BorderRadius.circular(18),
                  )
                : null,
            child: SelectableText(
              message.content.isEmpty && message.isStreaming ? '...' : message.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: message.isError ? AppColors.danger : AppColors.textPrimary,
              ),
            ),
          ),
          if (!_isUser && !message.isStreaming && message.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            _AssistantActions(message: message, onRegenerate: onRegenerate),
          ],
        ],
      ),
    );
  }
}

class _AssistantActions extends StatelessWidget {
  const _AssistantActions({required this.message, this.onRegenerate});

  final ChatMessage message;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionIcon(
          icon: Icons.thumb_up_outlined,
          onTap: () {},
        ),
        _ActionIcon(
          icon: Icons.thumb_down_outlined,
          onTap: () {},
        ),
        _ActionIcon(
          icon: Icons.copy_outlined,
          onTap: () {
            Clipboard.setData(ClipboardData(text: message.content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
            );
          },
        ),
        _ActionIcon(
          icon: Icons.bookmark_border,
          onTap: () {},
        ),
        if (onRegenerate != null)
          _ActionIcon(
            icon: Icons.refresh,
            onTap: onRegenerate!,
          ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      color: AppColors.textSecondary,
      splashRadius: 18,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      onPressed: onTap,
    );
  }
}
