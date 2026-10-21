import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/work_item.dart';
import '../services/devops_api.dart';

/// Lets the user tick the projects whose tickets are shown. Returns the
/// chosen project names, or null when the picker is dismissed. Shown as a
/// bottom sheet on phones and as a dialog on wider screens.
Future<List<String>?> showProjectPicker(
  BuildContext context, {
  required DevOpsApi api,
  List<String> current = const [],
}) {
  if (MediaQuery.sizeOf(context).width >= _dialogBreakpoint) {
    return showDialog<List<String>>(
      context: context,
      builder: (_) => ProjectPicker(api: api, current: current, dialog: true),
    );
  }
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => ProjectPicker(api: api, current: current),
  );
}

const _dialogBreakpoint = 600.0;

class ProjectPicker extends StatefulWidget {
  const ProjectPicker({
    super.key,
    required this.api,
    this.current = const [],
    this.dialog = false,
  });

  final DevOpsApi api;
  final List<String> current;
  final bool dialog;

  @override
  State<ProjectPicker> createState() => _ProjectPickerState();
}

class _ProjectPickerState extends State<ProjectPicker> {
  late final Future<List<Project>> _projects = widget.api.getProjects();
  late final Set<String> _selected = {...widget.current};
  String _query = '';

  void _apply(List<Project> projects) {
    // Keep the order of the project list rather than the order of ticking.
    Navigator.of(context).pop([
      for (final p in projects)
        if (_selected.contains(p.name)) p.name,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Project>>(
      future: _projects,
      builder: (context, snapshot) {
        if (widget.dialog) {
          final height = MediaQuery.sizeOf(context).height;
          return Dialog(
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 560,
              height: (height * 0.85).clamp(0.0, 800.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _buildContent(snapshot, null),
              ),
            ),
          );
        }
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, controller) => _buildContent(snapshot, controller),
        );
      },
    );
  }

  Widget _buildContent(AsyncSnapshot<List<Project>> snapshot, ScrollController? controller) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(l10n.chooseProjects, style: theme.textTheme.titleLarge),
              ),
              FilledButton(
                onPressed: snapshot.hasData && _selected.isNotEmpty
                    ? () => _apply(snapshot.data!)
                    : null,
                child: Text(l10n.apply),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchBar(
            hintText: l10n.searchProjectHint,
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildList(snapshot, controller)),
      ],
    );
  }

  Widget _buildList(AsyncSnapshot<List<Project>> snapshot, ScrollController? controller) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(l10n.loadProjectsFailed,
                  style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(l10n.error(snapshot.error!),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final projects =
        snapshot.data!.where((p) => p.name.toLowerCase().contains(_query)).toList();
    return ListView.builder(
      controller: controller,
      itemCount: projects.length,
      itemBuilder: (context, i) {
        final p = projects[i];
        return CheckboxListTile(
          secondary: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            child: Text(p.name[0].toUpperCase()),
          ),
          title: Text(p.name),
          subtitle: p.description == null || p.description!.isEmpty
              ? null
              : Text(p.description!, maxLines: 1, overflow: TextOverflow.ellipsis),
          value: _selected.contains(p.name),
          onChanged: (v) =>
              setState(() => v! ? _selected.add(p.name) : _selected.remove(p.name)),
        );
      },
    );
  }
}
