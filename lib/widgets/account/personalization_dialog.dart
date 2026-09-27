// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

Future<void> showPersonalizationDialog(BuildContext context, AppState appState) {
  return showDialog(
    context: context,
    builder: (context) => _PersonalizationDialog(appState: appState),
  );
}

class _PersonalizationDialog extends StatefulWidget {
  const _PersonalizationDialog({required this.appState});

  final AppState appState;

  @override
  State<_PersonalizationDialog> createState() => _PersonalizationDialogState();
}

class _PersonalizationDialogState extends State<_PersonalizationDialog> {
  late final _nickname = TextEditingController(text: widget.appState.profile.nickname);
  late final _occupation = TextEditingController(text: widget.appState.profile.occupation);
  late final _about = TextEditingController(text: widget.appState.profile.about);
  late final _customInstructions =
      TextEditingController(text: widget.appState.profile.customInstructions);

  @override
  void dispose() {
    _nickname.dispose();
    _occupation.dispose();
    _about.dispose();
    _customInstructions.dispose();
    super.dispose();
  }

  void _save() {
    final profile = widget.appState.profile;
    profile.nickname = _nickname.text.trim();
    profile.occupation = _occupation.text.trim();
    profile.about = _about.text.trim();
    profile.customInstructions = _customInstructions.text.trim();
    widget.appState.updateProfile(profile);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved — Agnes will use this context in future replies'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Personalization'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Manage who you are and what Agnes remembers',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              Tooltip(
                message: 'Not available — no safe source to import memory from in this client.',
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.file_download_outlined, size: 18, color: AppColors.iconInactive),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Import memory from another AI', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('Auto-fill your profile using conversations from other AI providers.',
                                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.iconInactive),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nick name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(controller: _nickname),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Occupation', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(controller: _occupation),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('More about you', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _about,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "I'm an Analyst based in Singapore. I work mainly in Python and SQL.",
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Agnes uses this information to personalize responses across all tasks.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text('Custom Instructions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _customInstructions,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'No need to be too formal when chatting with me. Keep the tone relaxed, avoid complicated jargon.',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
