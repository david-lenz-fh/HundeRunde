import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starter_flutter/controllers/theme_controller.dart';
import 'package:starter_flutter/services/pocketbase_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Abmelden?'),
        content: const Text('Möchtest du dich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      context.read<PocketBaseService>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Darstellung', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeController.themeMode,
                  title: const Text('Light Theme'),
                  secondary: const Icon(Icons.light_mode_outlined),
                  onChanged: (value) {
                    if (value != null) themeController.setThemeMode(value);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeController.themeMode,
                  title: const Text('Dark Theme'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  onChanged: (value) {
                    if (value != null) themeController.setThemeMode(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Abmelden'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
