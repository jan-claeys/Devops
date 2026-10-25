import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../l10n/l10n.dart';
import '../models/work_item.dart';
import '../services/app_state.dart';
import '../services/logging.dart';
import 'work_item_visuals.dart';

final _log = Logger('AssigneePicker');

/// Lets the user pick whom to assign [item] to, from the team members of its
/// project. Completes with the choice, whose assignee is null to leave the
/// item unassigned, or with null when cancelled.
Future<({Identity? assignee})?> showAssigneePicker(BuildContext context, WorkItem item) =>
    showModalBottomSheet<({Identity? assignee})>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _AssigneePicker(item: item),
    );

class _AssigneePicker extends StatefulWidget {
  const _AssigneePicker({required this.item});

  final WorkItem item;

  @override
  State<_AssigneePicker> createState() => _AssigneePickerState();
}

class _AssigneePickerState extends State<_AssigneePicker> {
  final _search = TextEditingController();
  late final Future<Identity?> _me;
  late final Future<List<Identity>> _members;

  @override
  void initState() {
    super.initState();
    final api = AppScope.read(context).api!;
    _me = api.getCurrentUser().then<Identity?>((me) => me, onError: (Object e, StackTrace st) {
      logFailure(_log, 'Loading the current user failed', e, st);
      return null;
    });
    _members = api.getProjectMembers(widget.item.project).catchError((Object e, StackTrace st) {
      logFailure(_log, 'Loading the members of ${widget.item.project} failed', e, st);
      throw e;
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _isAssignee(Identity person) => isSamePerson(person, widget.item.assignedTo);

  void _pick(Identity? assignee) => Navigator.of(context).pop((assignee: assignee));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final query = _search.text.trim().toLowerCase();
    bool matches(Identity p) =>
        query.isEmpty ||
        p.displayName.toLowerCase().contains(query) ||
        (p.uniqueName?.toLowerCase().contains(query) ?? false);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(l10n.changeAssignee, style: theme.textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchBar(
              controller: _search,
              hintText: l10n.searchPeopleHint,
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<Identity?>(
              future: _me,
              builder: (context, meSnapshot) => FutureBuilder<List<Identity>>(
                future: _members,
                builder: (context, snapshot) {
                  final me = meSnapshot.data;
                  final members = (snapshot.data ?? const <Identity>[]).where(matches).toList();
                  return ListView(
                    children: [
                      if (me != null && query.isEmpty && !_isAssignee(me))
                        ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person_add_alt_1)),
                          title: Text(l10n.assignToMe),
                          onTap: () => _pick(me),
                        ),
                      if (query.isEmpty && widget.item.assignedTo != null)
                        ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person_off_outlined)),
                          title: Text(l10n.unassigned),
                          onTap: () => _pick(null),
                        ),
                      if (query.isEmpty) const Divider(),
                      if (snapshot.hasError)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(l10n.membersLoadFailed,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        )
                      else if (snapshot.connectionState != ConnectionState.done)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (members.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(l10n.noPeopleFound,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        )
                      else
                        for (final person in members)
                          ListTile(
                            leading: PersonAvatar(person, radius: 20),
                            title: Text(person.displayName),
                            subtitle: person.uniqueName == null ? null : Text(person.uniqueName!),
                            trailing: _isAssignee(person) ? const Icon(Icons.check) : null,
                            onTap: _isAssignee(person) ? null : () => _pick(person),
                          ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Whether [a] and [b] are the same person: identity references don't always
/// carry an id, so the unique name counts too.
bool isSamePerson(Identity? a, Identity? b) {
  if (a == null || b == null) return false;
  if (a.id != null && b.id != null) return a.id == b.id;
  return a.uniqueName != null &&
      a.uniqueName!.toLowerCase() == b.uniqueName?.toLowerCase();
}
