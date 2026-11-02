import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Opens the system share sheet with [text] and, optionally, [files].
typedef Sharer = Future<void> Function(
    {String? text, List<XFile>? files, String? subject});

/// The share action; tests override it to record what is shared.
final shareProvider = Provider<Sharer>(
  (ref) => ({text, files, subject}) async {
    await SharePlus.instance
        .share(ShareParams(text: text, files: files, subject: subject));
  },
);
