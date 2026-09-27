// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

Future<void> showAccountDialog(BuildContext context, AppState appState) {
  return showDialog(
    context: context,
    builder: (context) => _AccountDialog(appState: appState),
  );
}

class _AccountDialog extends StatefulWidget {
  const _AccountDialog({required this.appState});

  final AppState appState;

  @override
  State<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<_AccountDialog> {
  late final _username = TextEditingController(text: widget.appState.profile.username);
  late final _email = TextEditingController(text: widget.appState.profile.email);
  late final _phone = TextEditingController(text: widget.appState.profile.phone);
  late final _apiKey = TextEditingController(text: widget.appState.apiKey);
  bool _obscureKey = true;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final profile = widget.appState.profile;
    profile.username = _username.text.trim();
    profile.email = _email.text.trim();
    profile.phone = _phone.text.trim();
    widget.appState.updateProfile(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated'), duration: Duration(seconds: 1)),
    );
  }

  void _saveApiKey() {
    widget.appState.updateApiKey(_apiKey.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Secret key saved'), duration: Duration(seconds: 1)),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all local data?'),
        content: const Text(
          'This clears every conversation, scheduled task, profile field, and the saved secret key from this device. This cannot be undone.',
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.appState.deleteAccount();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Account'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.accentPurple.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, size: 36, color: AppColors.accentPurple),
                ),
              ),
              const SizedBox(height: 20),
              const _Label('Username'),
              Row(
                children: [
                  Expanded(child: TextField(controller: _username)),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: _saveProfile, child: const Text('Confirm')),
                ],
              ),
              const SizedBox(height: 14),
              const _Label('Email'),
              TextField(controller: _email, decoration: const InputDecoration(hintText: 'you@example.com')),
              const SizedBox(height: 14),
              const _Label('Phone'),
              TextField(controller: _phone),
              const Divider(height: 32),
              const _Label('Agnes AI Secret Key'),
              const SizedBox(height: 4),
              Text(
                Platform.isLinux
                    ? 'Used to authenticate chat requests to apihub.agnes-ai.com. Stored in this device\'s app data (not OS-keychain-backed on Linux).'
                    : 'Used to authenticate chat requests to apihub.agnes-ai.com. Stored in the OS keychain on this device only.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _apiKey,
                      obscureText: _obscureKey,
                      decoration: InputDecoration(
                        hintText: 'sk-...',
                        suffixIcon: IconButton(
                          icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setState(() => _obscureKey = !_obscureKey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: _saveApiKey, child: const Text('Save')),
                ],
              ),
              const Divider(height: 32),
              const _Label('General'),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Expanded(
                    child: Text('Interface Language', style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  DropdownButton<String>(
                    value: 'English',
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: '中文', child: Text('中文')),
                    ],
                    onChanged: (_) {},
                  ),
                ],
              ),
              const Divider(height: 32),
              Row(
                children: [
                  const Expanded(
                    child: Text('Subscription', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Tooltip(
                    message: 'Not available — no subscription API is documented for this client.',
                    child: OutlinedButton(onPressed: null, child: const Text('Upgrade')),
                  ),
                ],
              ),
              const Divider(height: 32),
              Row(
                children: [
                  const Expanded(
                    child: Text('System', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                    onPressed: _confirmDelete,
                    child: const Text('Delete Account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }
}
