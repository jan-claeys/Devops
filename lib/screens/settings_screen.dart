import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/devops_api.dart';

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
      await DevOpsApi(organization: org, pat: pat).getProjects();
      if (!mounted) return;
      await AppScope.read(context).saveConnection(organization: org, pat: pat);
      if (!mounted) return;
      if (!widget.isOnboarding) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Verbinding opgeslagen')));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(widget.isOnboarding ? 'Welkom' : 'Instellingen'),
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
                            'Verbind met Azure DevOps om je tickets te bekijken.',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                        ],
                        Text('Verbinding', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _org,
                          decoration: const InputDecoration(
                            labelText: 'Organisatie',
                            hintText: 'bv. mijnbedrijf of https://dev.azure.com/mijnbedrijf',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Vul je organisatie in' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _pat,
                          obscureText: _obscure,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            labelText: 'Personal Access Token',
                            helperText: state.hasPat
                                ? 'Er is al een token opgeslagen. Vul opnieuw in om te wijzigen.'
                                : 'Scope nodig: Work Items (Read) en Project and Team (Read)',
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
                              (v == null || v.trim().isEmpty) ? 'Vul je token in' : null,
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
                          label: Text(_busy ? 'Verbinden…' : 'Verbinden'),
                        ),
                        if (!widget.isOnboarding) ...[
                          const SizedBox(height: 32),
                          Text('Weergave', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode_outlined),
                                  label: Text('Licht')),
                              ButtonSegment(
                                  value: ThemeMode.system,
                                  icon: Icon(Icons.brightness_auto_outlined),
                                  label: Text('Systeem')),
                              ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode_outlined),
                                  label: Text('Donker')),
                            ],
                            selected: {state.themeMode},
                            onSelectionChanged: (s) => state.setThemeMode(s.first),
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(
                                  value: false,
                                  icon: Icon(Icons.water_drop_outlined),
                                  label: Text('Azure-blauw')),
                              ButtonSegment(
                                  value: true,
                                  icon: Icon(Icons.palette_outlined),
                                  label: Text('Systeemkleur')),
                            ],
                            selected: {state.useDynamicColor},
                            onSelectionChanged: (s) => state.setUseDynamicColor(s.first),
                          ),
                          const SizedBox(height: 32),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error),
                            onPressed: () async {
                              final nav = Navigator.of(context);
                              await state.signOut();
                              nav.popUntil((r) => r.isFirst);
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('Afmelden'),
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
