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

## Releases

Development happens on `develop`; `main` holds released code. Every push to `main` runs [`.github/workflows/release.yml`](.github/workflows/release.yml), which builds a signed APK and a Windows zip and publishes them as GitHub release `v<version>`, with `<version>` taken from `pubspec.yaml`. If that version is already released, the workflow skips the build.

To release:

1. On `develop`, bump `version` in `pubspec.yaml` following [semantic versioning](https://semver.org) (`1.0.0` → `1.0.1` for fixes, `1.1.0` for features, `2.0.0` for breaking changes).
2. Merge `develop` into `main` and push.

The build number (`+N`) in `pubspec.yaml` is only used for local builds; CI uses the workflow run number, so it always increases.

### Signing key

The APK is signed with an upload keystore that is stored in GitHub secrets. Keep a backup of the keystore and its passwords: without them, users cannot update to new versions. To create one:

```sh
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Add these repository secrets (*Settings → Secrets and variables → Actions*):

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `base64 -w 0 upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | `upload` |
| `ANDROID_KEY_PASSWORD` | key password |

For signed local release builds, put the keystore in `android/app/` and create `android/key.properties` (both are ignored by git):

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=upload-keystore.jks
```
