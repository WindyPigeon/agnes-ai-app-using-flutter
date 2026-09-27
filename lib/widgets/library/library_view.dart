// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class LibraryView extends StatelessWidget {
  const LibraryView({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            children: [
              const Text('Library', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              SizedBox(
                width: 220,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, size: 18),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 84, color: AppColors.iconInactive),
                const SizedBox(height: 20),
                const Text('There is no content in the library',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Build your own knowledge base by creating new tasks.',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: appState.startNewChat,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Create a new task'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
