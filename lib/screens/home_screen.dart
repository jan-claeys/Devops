import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'pipelines_screen.dart';
import 'work_items_screen.dart';

/// Switches between the tickets and the pipelines: a navigation bar at the
/// bottom on phones, a rail on the side on wider screens.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _railBreakpoint = 600.0;

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Keeps both tabs alive. IndexedStack leaves tickers running, so the
    // hidden tab disables them itself; the pipelines pause refreshing then.
    final body = IndexedStack(
      index: _index,
      children: [
        for (final (i, tab) in const [WorkItemsScreen(), PipelinesScreen()].indexed)
          TickerMode(enabled: i == _index, child: tab),
      ],
    );
    final destinations = [
      (Icons.assignment_outlined, Icons.assignment, l10n.tickets),
      (Icons.rocket_launch_outlined, Icons.rocket_launch, l10n.pipelines),
    ];
    void select(int i) => setState(() => _index = i);

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
