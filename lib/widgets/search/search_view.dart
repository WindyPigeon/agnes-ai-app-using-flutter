// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../models/conversation.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.appState});

  final AppState appState;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  String _relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(dt.year, dt.month, dt.day))
        .inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final q = _query.text.trim().toLowerCase();
        final all = widget.appState.recentConversations;
        final filtered = q.isEmpty
            ? all
            : all.where((c) {
                if (c.title.toLowerCase().contains(q)) return true;
                return c.messages.any((m) => m.content.toLowerCase().contains(q));
              }).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _query,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search for chats',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 24),
                if (filtered.isNotEmpty) ...[
                  const Text('RECENT',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                ],
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            q.isEmpty ? 'No chats yet' : 'No chats match "$q"',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final convo = filtered[index];
                            return _ChatRow(
                              convo: convo,
                              dateLabel: _relativeDate(convo.updatedAt),
                              onTap: () => widget.appState.openConversation(convo.id),
                              onDelete: () => widget.appState.deleteConversation(convo.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.convo,
    required this.dateLabel,
    required this.onTap,
    required this.onDelete,
  });

  final Conversation convo;
  final String dateLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                convo.title.isEmpty ? 'New chat' : convo.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(dateLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppColors.iconInactive,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
