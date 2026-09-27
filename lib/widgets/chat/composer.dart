// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class Composer extends StatefulWidget {
  const Composer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final bool isSending;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _submit() {
    final text = widget.controller.text;
    if (text.trim().isEmpty || widget.isSending) return;
    widget.onSend(text);
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.controller.text.trim().isNotEmpty && !widget.isSending;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 24, maxHeight: 160),
            child: TextField(
              controller: widget.controller,
              minLines: 1,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'Assign a task or ask anything',
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.swap_vert, size: 20),
                color: AppColors.iconInactive,
                tooltip: 'Model options',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.extension_outlined, size: 20),
                color: AppColors.iconInactive,
                tooltip: 'Tools',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.attach_file, size: 20),
                color: AppColors.iconInactive,
                tooltip: 'Attach',
                onPressed: () {},
              ),
              const Spacer(),
              _SendButton(enabled: canSend, isSending: widget.isSending, onTap: _submit),
            ],
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.isSending, required this.onTap});

  final bool enabled;
  final bool isSending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryBlue : AppColors.iconInactive.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: isSending
            ? const Padding(
                padding: EdgeInsets.all(9),
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
      ),
    );
  }
}
