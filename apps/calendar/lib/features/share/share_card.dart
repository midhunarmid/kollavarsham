import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kollavarsham_flutter/kollavarsham_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/share.dart';
import '../../l10n/app_localizations.dart';
import '../day/day_info.dart';
import '../day/panchangam_view.dart';

/// The frame of every share card: a coloured header with [title] and
/// [subtitle], a body, and the site address at the bottom.
class ShareCardFrame extends StatelessWidget {
  /// Creates the frame.
  const ShareCardFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.icon = Icons.calendar_month,
  });

  /// Large heading.
  final String title;

  /// Line under the heading.
  final String subtitle;

  /// Card body.
  final Widget child;

  /// Icon beside the heading.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      width: 360,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: scheme.primary,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(icon, color: scheme.onPrimary, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: theme.textTheme.titleLarge!
                                .copyWith(color: scheme.onPrimary)),
                        Text(subtitle,
                            style: theme.textTheme.bodyMedium!
                                .copyWith(color: scheme.onPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(20), child: child),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                '${AppLocalizations.of(context).appTitle} · calendar.armid.in',
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall!
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card with a day's panchangam.
class PanchangamCard extends StatelessWidget {
  /// Creates the card for [info].
  const PanchangamCard({
    super.key,
    required this.info,
    required this.script,
    this.malayalamDigits = false,
    this.festivals = const [],
  });

  /// The day.
  final DayInfo info;

  /// Script of names.
  final MalayalamScript script;

  /// Whether to use Malayalam digits.
  final bool malayalamDigits;

  /// Festival names of the day.
  final List<String> festivals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ShareCardFrame(
      title: info.date
          .format('d MMMM y', script: script, malayalamDigits: malayalamDigits),
      subtitle: MaterialLocalizations.of(context)
          .formatFullDate(info.date.toGregorian()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final f in festivals)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(f,
                  style: theme.textTheme.titleMedium!
                      .copyWith(color: theme.colorScheme.primary)),
            ),
          PanchangamTable(info: info, script: script),
        ],
      ),
    );
  }
}

/// A greeting card for a pirannal or birthday.
class GreetingCard extends StatelessWidget {
  /// Creates the card.
  const GreetingCard({
    super.key,
    required this.greeting,
    required this.lines,
  });

  /// The greeting, e.g. "Happy pirannal, Midhun!".
  final String greeting;

  /// Lines under it: the star, the dates.
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ShareCardFrame(
      icon: Icons.cake_outlined,
      title: greeting,
      subtitle: lines.isEmpty ? '' : lines.first,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lines.skip(1))
            Text(l, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Icon(Icons.celebration_outlined,
              size: 40, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}

/// Renders the boundary behind [key] as a PNG.
Future<XFile?> captureCard(GlobalKey key, String name) async {
  final boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return null;
  final image = await boundary.toImage(pixelRatio: 3);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (bytes == null) return null;
  return XFile.fromData(bytes.buffer.asUint8List(),
      mimeType: 'image/png', name: name);
}

/// Shows [card] in a dialog with a button that shares it as an image named
/// [fileName], with [text] alongside.
Future<void> showShareCardDialog(
  BuildContext context,
  WidgetRef ref, {
  required Widget card,
  required String fileName,
  String? text,
}) {
  final key = GlobalKey();
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.all(12),
      content: SingleChildScrollView(
        child: RepaintBoundary(key: key, child: card),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton.icon(
          key: const Key('share-card'),
          icon: const Icon(Icons.share_outlined),
          label: Text(l10n.share),
          onPressed: () async {
            final file = await captureCard(key, fileName);
            if (file == null) return;
            await ref.read(shareProvider)(
                files: [file], fileNames: [fileName], text: text);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
