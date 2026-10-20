# DevOps

A Flutter app for viewing your Azure DevOps work items (tickets) on your phone or desktop.

## Features

- **Work item list** per project, sorted by last change
  - Scope: *Assigned to me*, *Created by me* or *All*
  - Filter on open items only and on work item type (Bug, Task, User Story, ...)
  - Search by title, ID, tag or assignee; pull to refresh
- **Work item details**: description, state, assignee, priority, effort, original estimate / completed work, area and iteration path, tags, linked items and comments (including rendered @mentions), with a button to open the item in the browser
- **Android home screen widget** showing your open work items; tapping a ticket opens it in the app
- **Theming**: light/dark/system mode and optional dynamic colour (Material You)
- **17 languages**: ar, de, en, es, fr, hi, id, it, ja, ko, nl, pl, pt, ru, tr, uk, zh (follows the system language by default, English as fallback)

## Getting started

### Requirements

- Flutter SDK with Dart `^3.13.5`
- An Azure DevOps organization and a Personal Access Token (PAT)

### Run the app

```sh
flutter pub get
flutter run
```

Supported platforms in this repo: Android, iOS, Windows and Web. The home screen widget is Android only.

### Connect to Azure DevOps

On first launch the app asks for:

1. **Organization** – any of `myorg`, `dev.azure.com/myorg`, `https://myorg.visualstudio.com` or a full on-premises collection URL.
2. **Personal Access Token** – create one in Azure DevOps under *User settings → Personal access tokens* with these scopes:
   - **Work Items**: Read
   - **Project and Team**: Read

The connection is verified before it is saved. The PAT is kept in secure storage (`flutter_secure_storage`); other settings are stored in `shared_preferences`.

## Project structure

```
lib/
├── main.dart                     App entry point, theming and localization setup
├── models/work_item.dart         WorkItem, Project and comment models
├── services/
│   ├── app_state.dart            Settings, connection and theme state
│   ├── devops_api.dart           Azure DevOps REST API client (v7.1, WIQL)
│   └── home_widget_service.dart  Data feed for the Android home screen widget
├── screens/
│   ├── work_items_screen.dart    List with scope, filters and search
│   ├── work_item_detail_screen.dart
│   └── settings_screen.dart      Onboarding and settings
├── widgets/work_item_visuals.dart  Type/state icons and colours
└── l10n/                         ARB translation files and generated localizations
```

## Translations

Translations live in `lib/l10n/app_<locale>.arb`, with `app_en.arb` as the template. After changing or adding strings, regenerate the localization classes with:

```sh
flutter gen-l10n
```

(This also runs automatically on `flutter pub get` / `flutter run`, because `generate: true` is set in `pubspec.yaml`.)
