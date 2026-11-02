import 'package:flutter/material.dart';

/// A tab that is not built yet: an app bar and a short note.
class ComingSoon extends StatelessWidget {
  /// Creates a placeholder titled [title] showing [message].
  const ComingSoon({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  /// App bar title.
  final String title;

  /// Large icon above the message.
  final IconData icon;

  /// What will appear here.
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
