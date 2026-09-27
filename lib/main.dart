// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

/// Optional seed key for first run, passed via
/// `--dart-define=AGNES_SEED_API_KEY=sk-...` so the secret never lives in
/// source. If empty, the user is prompted to add their key in Account
/// settings; nothing is sent anywhere until they do.
const _seedApiKey = String.fromEnvironment('AGNES_SEED_API_KEY');

void main() {
  runApp(const AgnesApp());
}

class AgnesApp extends StatefulWidget {
  const AgnesApp({super.key});

  @override
  State<AgnesApp> createState() => _AgnesAppState();
}

class _AgnesAppState extends State<AgnesApp> {
  final _appState = AppState();
  late final Future<void> _init = _appState.init(seedApiKey: _seedApiKey);

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agnes AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: FutureBuilder<void>(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: AppColors.outerBackground,
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return AppShell(appState: _appState);
        },
      ),
    );
  }
}
