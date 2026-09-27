import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

class IconRail extends StatelessWidget {
  const IconRail({
    super.key,
    required this.section,
    required this.onSelectSection,
    required this.onNewChat,
    required this.onOpenSettings,
    required this.onOpenPersonalization,
  });

  final NavSection section;
  final ValueChanged<NavSection> onSelectSection;
  final VoidCallback onNewChat;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPersonalization;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: AppColors.railBackground,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _LogoMark(onTap: onNewChat),
          const SizedBox(height: 24),
          _RailButton(
            icon: Icons.add_comment_outlined,
            tooltip: 'New chat',
            selected: false,
            onTap: onNewChat,
          ),
          _RailButton(
            icon: Icons.search,
            tooltip: 'Search chats',
            selected: section == NavSection.search,
            onTap: () => onSelectSection(NavSection.search),
          ),
          _RailButton(
            icon: Icons.history_toggle_off,
            tooltip: 'Scheduled tasks',
            selected: section == NavSection.scheduled,
            onTap: () => onSelectSection(NavSection.scheduled),
          ),
          _RailButton(
            icon: Icons.auto_stories_outlined,
            tooltip: 'Library',
            selected: section == NavSection.library,
            onTap: () => onSelectSection(NavSection.library),
          ),
          _RailButton(
            icon: Icons.track_changes_outlined,
            tooltip: 'Personalization',
            selected: false,
            onTap: onOpenPersonalization,
          ),
          _RailButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            selected: false,
            onTap: onOpenSettings,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature isn\'t part of this client — only Chat calls the real Agnes AI API.')),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'New chat',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? AppColors.chipBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: selected ? AppColors.primaryBlue : AppColors.iconInactive,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
