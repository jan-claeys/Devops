import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../services/app_state.dart';
import '../services/devops_api.dart';
import '../services/home_widget_service.dart';
import '../services/logging.dart';

final _log = Logger('SettingsScreen');

const _author = 'Jan Claeys';
final _repositoryUrl = Uri.parse('https://github.com/jan-claeys/Devops');
final _patDocsUrl = Uri.parse(
    'https://learn.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate');

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.isOnboarding = false});

  /// Shown as the first screen when no connection is configured yet.
  final bool isOnboarding;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _org;
  final _pat = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _org = TextEditingController(text: AppScope.read(context).organization ?? '');
  }

  @override
  void dispose() {
    _org.dispose();
    _pat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final org = _org.text.trim();
    final pat = _pat.text.trim();
    try {
      // Verify the connection before storing it.
      final client = AppScope.read(context).httpClient;
      await DevOpsApi(organization: org, pat: pat, client: client).getProjects();
      if (!mounted) return;
      await AppScope.read(context).saveConnection(organization: org, pat: pat);
      if (!mounted) return;
      if (!widget.isOnboarding) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.connectionSaved)));
      }
    } catch (e, st) {
      logFailure(_log, 'Verifying the connection failed', e, st);
      setState(() => _error = context.l10n.error(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(widget.isOnboarding ? l10n.welcome : l10n.settings),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.isOnboarding) ...[
                          Text(
                            l10n.onboardingIntro,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                        ],
                        Text(l10n.connection, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _org,
                          decoration: InputDecoration(
                            labelText: l10n.organization,
                            hintText: l10n.organizationHint,
                            prefixIcon: const Icon(Icons.business_outlined),
                          ),
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? l10n.organizationRequired : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _pat,
                          obscureText: _obscure,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            labelText: l10n.personalAccessToken,
                            helperText: state.hasPat
                                ? l10n.tokenAlreadyStored
                                : l10n.tokenScopeHint,
                            helperMaxLines: 2,
                            prefixIcon: const Icon(Icons.key_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          onFieldSubmitted: (_) => _save(),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? l10n.tokenRequired : null,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          Card.filled(
                            color: theme.colorScheme.errorContainer,
                            child: ListTile(
                              leading: Icon(Icons.error_outline,
                                  color: theme.colorScheme.onErrorContainer),
                              title: Text(_error!,
                                  style:
                                      TextStyle(color: theme.colorScheme.onErrorContainer)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _busy ? null : _save,
                          icon: _busy
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.link),
                          label: Text(_busy ? l10n.connecting : l10n.connect),
                        ),
                        const SizedBox(height: 16),
                        const _TokenHelp(),
                        if (!widget.isOnboarding) ...[
                          const SizedBox(height: 32),
                          Text(l10n.appearance, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          SegmentedButton<ThemeMode>(
                            segments: [
                              ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: const Icon(Icons.light_mode_outlined),
                                  label: Text(l10n.themeLight)),
                              ButtonSegment(
                                  value: ThemeMode.system,
                                  icon: const Icon(Icons.brightness_auto_outlined),
                                  label: Text(l10n.themeSystem)),
                              ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: const Icon(Icons.dark_mode_outlined),
                                  label: Text(l10n.themeDark)),
                            ],
                            selected: {state.themeMode},
                            onSelectionChanged: (s) => state.setThemeMode(s.first),
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(
                                  value: false,
                                  icon: const Icon(Icons.water_drop_outlined),
                                  label: Text(l10n.colorAzureBlue)),
                              ButtonSegment(
                                  value: true,
                                  icon: const Icon(Icons.palette_outlined),
                                  label: Text(l10n.colorSystem)),
                            ],
                            selected: {state.useDynamicColor},
                            onSelectionChanged: (s) => state.setUseDynamicColor(s.first),
                          ),
                          const SizedBox(height: 32),
                          Text(l10n.language, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          const _LanguagePicker(),
                          if (errorReportingAvailable) ...[
                            const SizedBox(height: 32),
                            Text(l10n.privacy, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              secondary: const Icon(Icons.bug_report_outlined),
                              title: Text(l10n.sendErrorReports),
                              subtitle: Text(l10n.sendErrorReportsHint),
                              value: state.sendErrorReports,
                              onChanged: state.setSendErrorReports,
                            ),
                          ],
                          const SizedBox(height: 32),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error),
                            onPressed: () async {
                              final nav = Navigator.of(context);
                              await state.signOut();
                              TicketsHomeWidget.refresh(state);
                              nav.popUntil((r) => r.isFirst);
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(l10n.signOut),
                          ),
                          const SizedBox(height: 32),
                          Text(l10n.about, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          const _AboutTile(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Explains how to create a Personal Access Token with the minimum scopes.
class _TokenHelp extends StatelessWidget {
  const _TokenHelp();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final steps = [
      l10n.tokenHelpStep1,
      l10n.tokenHelpStep2,
      l10n.tokenHelpStep3,
      l10n.tokenHelpStep4,
    ];
    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        leading: const Icon(Icons.help_outline),
        title: Text(l10n.tokenHelpTitle),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        children: [
          for (final (i, step) in steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 24, child: Text('${i + 1}.')),
                  Expanded(child: Text(step)),
                ],
              ),
            ),
          Text(
            l10n.tokenHelpPermissions,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () => launchUrl(_patDocsUrl, mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.tokenHelpDocs),
          ),
        ],
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = context.l10n;
    // An empty code stands for following the system language.
    return DropdownMenu<String>(
      // Rebuild so the "system language" label follows a language change.
      key: ValueKey(l10n.localeName),
      expandedInsets: EdgeInsets.zero,
      leadingIcon: const Icon(Icons.language),
      initialSelection: state.locale?.languageCode ?? '',
      dropdownMenuEntries: [
        DropdownMenuEntry(value: '', label: l10n.languageSystem),
        for (final MapEntry(key: code, value: name) in languageNames.entries)
          DropdownMenuEntry(value: code, label: name),
      ],
      onSelected: (code) =>
          state.setLocale(code == null || code.isEmpty ? null : Locale(code)),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '';
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.appVersion(version)),
          subtitle: Text(l10n.madeBy(_author)),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => launchUrl(_repositoryUrl, mode: LaunchMode.externalApplication),
        );
      },
    );
  }
}
