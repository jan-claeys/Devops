import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/shortcuts.dart';
import 'dashboard_screen.dart';
import 'pipelines_screen.dart';
import 'pull_requests_screen.dart';
import 'work_items_screen.dart';

/// Switches between the overview, the tickets, the pull requests and the
/// pipelines: a navigation bar at the bottom on phones, a rail on the side on
/// wider screens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const _railBreakpoint = 600.0;

  int _index = 0;
  final _pullRequests = GlobalKey<PullRequestsScreenState>();
  final _pipelines = GlobalKey<PipelinesScreenState>();

  /// Switches to the pipelines, as a tap on the notification of several
  /// running runs does.
  void showPipelines() => setState(() => _index = 3);

  /// Shows what an app shortcut on the home screen stands for.
  void showShortcut(AppShortcut shortcut) {
    switch (shortcut) {
      case AppShortcut.myPullRequests:
        setState(() => _index = 2);
        _pullRequests.currentState?.showMine();
      case AppShortcut.activeRuns:
        setState(() => _index = 3);
        _pipelines.currentState?.showActive();
      case AppShortcut.tickets:
        setState(() => _index = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void select(int i) => setState(() => _index = i);
    // Keeps all tabs alive. IndexedStack leaves tickers running, so the
    // hidden tabs disable them itself; the overview and the pipelines pause
    // refreshing then.
    final body = IndexedStack(
      index: _index,
      children: [
        for (final (i, tab) in [
          DashboardScreen(
            onShowTickets: () => select(1),
            onShowPullRequests: () {
              select(2);
              _pullRequests.currentState?.showMine();
            },
            onShowPipelines: () => select(3),
          ),
          const WorkItemsScreen(),
          PullRequestsScreen(key: _pullRequests),
          PipelinesScreen(key: _pipelines),
        ].indexed)
          TickerMode(enabled: i == _index, child: tab),
      ],
    );
    final destinations = [
      (Icons.dashboard_outlined, Icons.dashboard, l10n.dashboard),
      (Icons.assignment_outlined, Icons.assignment, l10n.tickets),
      (Icons.call_merge, Icons.call_merge, l10n.pullRequests),
      (Icons.rocket_launch_outlined, Icons.rocket_launch, l10n.pipelines),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < _railBreakpoint) {
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: select,
            destinations: [
              for (final (icon, selectedIcon, label) in destinations)
                NavigationDestination(
                    icon: Icon(icon), selectedIcon: Icon(selectedIcon), label: label),
            ],
          ),
        );
      }
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        body: Row(
          children: [
            SafeArea(
              right: false,
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                selectedIndex: _index,
                onDestinationSelected: select,
                labelType: NavigationRailLabelType.all,
                groupAlignment: -0.85,
                destinations: [
                  for (final (icon, selectedIcon, label) in destinations)
                    NavigationRailDestination(
                        icon: Icon(icon),
                        selectedIcon: Icon(selectedIcon),
                        label: Text(label)),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      );
    });
  }
}
