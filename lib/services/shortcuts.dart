/// The shortcuts a long press on the app icon offers on Android
/// (res/xml/shortcuts.xml). They open the app as a home screen widget row
/// does, with one of these links.
enum AppShortcut {
  /// The open pull requests the user created or reviews.
  myPullRequests('devops://shortcut/my-pull-requests'),

  /// The pipeline runs that are going.
  activeRuns('devops://shortcut/active-runs'),

  /// The tickets.
  tickets('devops://shortcut/tickets');

  const AppShortcut(this.uri);

  final String uri;

  static AppShortcut? fromUri(Uri? uri) {
    final text = uri?.toString();
    return values.where((s) => s.uri == text).firstOrNull;
  }
}
