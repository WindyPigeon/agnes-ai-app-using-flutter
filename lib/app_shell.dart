// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'widgets/account/account_dialog.dart';
import 'widgets/account/personalization_dialog.dart';
import 'widgets/chat/chat_view.dart';
import 'widgets/icon_rail.dart';
import 'widgets/library/library_view.dart';
import 'widgets/scheduled/scheduled_view.dart';
import 'widgets/search/search_view.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.outerBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.panelBackground,
                boxShadow: [
                  BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedBuilder(
                    animation: appState,
                    builder: (context, _) => IconRail(
                      section: appState.section,
                      onSelectSection: appState.selectSection,
                      onNewChat: appState.startNewChat,
                      onOpenSettings: () => showAccountDialog(context, appState),
                      onOpenPersonalization: () => showPersonalizationDialog(context, appState),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _Header(appState: appState),
                        Expanded(child: _Content(appState: appState)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () => showAccountDialog(context, appState),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accentPurple,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return switch (appState.section) {
          NavSection.chat => ChatView(appState: appState),
          NavSection.search => SearchView(appState: appState),
          NavSection.scheduled => ScheduledView(appState: appState),
          NavSection.library => LibraryView(appState: appState),
        };
      },
    );
  }
}
