// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class QuickActionChip {
  const QuickActionChip(this.icon, this.label, this.prompt);
  final IconData icon;
  final String label;
  final String prompt;
}

const quickActionChips = [
  QuickActionChip(Icons.slideshow_outlined, 'AI Slides', 'Create a slide deck about '),
  QuickActionChip(Icons.language_outlined, 'Build website', 'Build a website that '),
  QuickActionChip(Icons.brush_outlined, 'AI Design', 'Design an image of '),
  QuickActionChip(Icons.grid_on_outlined, 'AI Sheet', 'Create a spreadsheet for '),
];

class QuickActionRow extends StatelessWidget {
  const QuickActionRow({super.key, required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final chip in quickActionChips)
          _Chip(icon: chip.icon, label: chip.label, onTap: () => onSelect(chip.prompt)),
        _Chip(icon: Icons.more_horiz, label: 'More', onTap: () {}),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

const _suggestions = [
  'Why are metaphors useful in storytelling',
  'How to keep motivated when learning languages',
  'How can I cook dried beans faster',
];

class SuggestedForYou extends StatefulWidget {
  const SuggestedForYou({super.key, required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  State<SuggestedForYou> createState() => _SuggestedForYouState();
}

class _SuggestedForYouState extends State<SuggestedForYou> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Suggested for you',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              color: AppColors.iconInactive,
              onPressed: () => setState(() {}),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.iconInactive,
              onPressed: () => setState(() => _dismissed = true),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 640;
          final children = [
            for (final s in _suggestions)
              _SuggestionTile(text: s, onTap: () => widget.onSelect(s)),
          ];
          return isNarrow
              ? Column(children: children)
              : Row(
                  children: children
                      .map((c) => Expanded(child: c))
                      .toList(),
                );
        }),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(text, style: const TextStyle(fontSize: 13.5)),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 16, color: AppColors.iconInactive),
            ],
          ),
        ),
      ),
    );
  }
}

class OfferBanner extends StatefulWidget {
  const OfferBanner({super.key});

  @override
  State<OfferBanner> createState() => _OfferBannerState();
}

class _OfferBannerState extends State<OfferBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Limited-time offer',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 6),
                Text(
                  'Subscribe to get more credits, unlock more powerful models, and access more task capabilities.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.card_giftcard, size: 40, color: AppColors.gold.withValues(alpha: 0.7)),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => setState(() => _dismissed = true),
          ),
        ],
      ),
    );
  }
}
