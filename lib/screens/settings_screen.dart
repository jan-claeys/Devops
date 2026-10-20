import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/app_state.dart';
import '../services/devops_api.dart';
import '../services/home_widget_service.dart';

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
    } catch (e) {
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
