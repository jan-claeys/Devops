import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../screens/settings_screen.dart';
import '../services/devops_api.dart';

/// Tells why an action, such as a vote or a comment, failed. Azure DevOps
/// answers 401 or 403 when the token lacks the scope in [scopeHint] or the
/// account lacks the permission, so both are named then.
void showActionError(BuildContext context, Object error, {required String scopeHint}) {
  final l10n = context.l10n;
  final message = switch (error) {
    DevOpsException(kind: DevOpsError.unauthorized, :final serverMessage) ||
    DevOpsException(statusCode: 403, :final serverMessage) =>
      [l10n.actionDenied, scopeHint, ?serverMessage].join('\n'),
    _ => l10n.error(error),
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    showCloseIcon: true,
    duration: const Duration(seconds: 8),
  ));
}

/// Button below an error: to the settings when the token is invalid or has
/// expired, as trying again won't help then; otherwise it tries again.
class ErrorAction extends StatelessWidget {
  const ErrorAction({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (error case DevOpsException(kind: DevOpsError.unauthorized)) {
      return FilledButton.tonalIcon(
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
          // A new token doesn't change the organization, so nothing reloads by itself.
          onRetry();
        },
        icon: const Icon(Icons.settings_outlined),
        label: Text(l10n.settings),
      );
    }
    return FilledButton.tonalIcon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: Text(l10n.retry),
    );
  }
}
