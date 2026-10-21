# DevOps

A Flutter app for viewing your Azure DevOps work items (tickets) and following your pipeline runs on your phone or desktop.

## Features

- **Work item list** per project, sorted by last change
  - Scope: *Assigned to me*, *Created by me* or *All*
  - Filter on open items only and on work item type (Bug, Task, User Story, ...)
  - Search by title, ID, tag or assignee; pull to refresh
- **Work item details**: description, state, assignee, priority, effort, original estimate / completed work, area and iteration path, tags, linked items and comments (including rendered @mentions), with a button to open the item in the browser
- **Pipelines**: the latest builds and releases of the selected projects with status, branch, duration and who started them
  - Show all runs, only builds or only releases; filter on active runs and search by pipeline, branch or person; refreshes automatically while a run is in progress or waiting for approval
  - Run details: progress bar, stages with their jobs and tasks (status, duration, errors and warnings), with a button to open the run in the browser
  - YAML pipelines (including deployment stages), classic build pipelines and classic release pipelines; releases show their stages, the artifact version and who still has to approve a stage
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
2. **Personal Access Token** – see [Create a Personal Access Token](#create-a-personal-access-token) below.

The connection is verified before it is saved. The PAT is kept in secure storage (`flutter_secure_storage`); other settings are stored in `shared_preferences`.

### Create a Personal Access Token

The app only reads data, so a read-only token is enough. Microsoft's official guide: [Use personal access tokens](https://learn.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate).

1. Sign in to your organization (`https://dev.azure.com/{yourorganization}`).
2. Open **User settings** (the icon next to your profile picture, top right) → **Personal access tokens**.
3. Click **+ New Token**.
4. Fill in:
   - **Name** – for example `DevOps app`.
   - **Organization** – the organization you will connect to (or *All accessible organizations*).
   - **Expiration** – up to one year; when the token expires, the app reports *Not authorized* and you need to enter a new token in *Settings*.
   - **Scopes** – choose **Custom defined** and select only:

     | Scope | Permission | Used for |
     | --- | --- | --- |
     | **Work Items** | Read (`vso.work`) | WIQL queries, work item details, links, comments and attachments/images |
     | **Project and Team** | Read (`vso.project`) | Listing the projects in the organization (also used to verify the connection) |
     | **Build** | Read (`vso.build`) | Pipeline runs and their stages, jobs and tasks |
     | **Release** | Read (`vso.release`) | Releases of classic release pipelines, their stages and approvals |

     Click *Show all scopes* if a scope is not visible. Do not choose *Full access*.
5. Click **Create** and copy the token right away – Azure DevOps shows it only once.
6. Paste it in the app's **Personal Access Token** field and tap **Connect**.

A token can never do more than your own account. You also need:

- An access level of at least **Stakeholder** (or **Basic**) in the organization.
- Read access to the projects and area paths whose work items you want to see (by default, members of a project's *Readers* or *Contributors* group have this).
- The *View builds* permission on the pipelines and *View releases* on the release pipelines you want to follow (also granted to *Readers* and *Contributors* by default).

Tokens created before the pipelines were added lack the **Build** and **Release** scopes: the *Pipelines* tab then reports *Not authorized*, or only shows the builds with a warning that the releases couldn't be loaded. Edit the token in Azure DevOps to add the scopes (the token itself stays the same) or create a new one.

Releases are read from the release management API: `vsrm.dev.azure.com/{organization}` (or `{organization}.vsrm.visualstudio.com`). On Azure DevOps Server it is the collection URL itself.

If you cannot create a token, your organization's administrators may have restricted PAT creation by policy; see [Manage personal access tokens using policies](https://learn.microsoft.com/azure/devops/organizations/accounts/manage-pats-with-policies-for-administrators). For Azure DevOps Server (on-premises) the steps are the same, starting from your collection URL.

## Project structure

```
lib/
├── main.dart                     App entry point, theming and localization setup
├── models/
│   ├── work_item.dart            WorkItem, Project and comment models
│   └── pipeline_run.dart         Builds, releases and their timeline (stages, jobs, tasks)
├── services/
│   ├── app_state.dart            Settings, connection and theme state
│   ├── devops_api.dart           Azure DevOps REST API client (v7.1, WIQL, builds, releases)
│   └── home_widget_service.dart  Data feed for the Android home screen widget
├── screens/
│   ├── home_screen.dart          Tabs for tickets and pipelines
│   ├── work_items_screen.dart    List with scope, filters and search
│   ├── work_item_detail_screen.dart
│   ├── pipelines_screen.dart     Latest runs, refreshed while runs are in progress
│   ├── pipeline_run_screen.dart  Progress of one run
│   └── settings_screen.dart      Onboarding and settings
├── widgets/
│   ├── work_item_visuals.dart    Type/state icons and colours
│   ├── pipeline_visuals.dart     Run status icons and colours
│   └── ...                       Shared cards, empty states, Markdown, project picker
└── l10n/                         ARB translation files and generated localizations
```

## Translations

Translations live in `lib/l10n/app_<locale>.arb`, with `app_en.arb` as the template. After changing or adding strings, regenerate the localization classes with:

```sh
flutter gen-l10n
```

(This also runs automatically on `flutter pub get` / `flutter run`, because `generate: true` is set in `pubspec.yaml`.)

## Releases

Every push to `main` runs [`.github/workflows/release.yml`](.github/workflows/release.yml). It reads the version from `pubspec.yaml` and, if there is no GitHub release `v<version>` yet, runs the tests, builds a signed APK and a Windows installer ([`windows/installer/devops.iss`](windows/installer/devops.iss), Inno Setup) and publishes them as release `v<version>`. If that version is already released, the workflow does nothing, so regular pushes to `main` are fine.

To release a new version:

1. Bump `version` in [`pubspec.yaml`](pubspec.yaml) following [semantic versioning](https://semver.org):
   - `1.0.0` → `1.0.1` for bug fixes
   - `1.0.0` → `1.1.0` for new features
   - `1.0.0` → `2.0.0` for breaking changes
2. Commit and push to `main`.
3. Follow the build under *Actions*; when it is done, the APK and Windows installer (`DevOps-v<version>-windows-x64-setup.exe`) are on the *Releases* page.

The build number (`+N`) in `pubspec.yaml` is only used for local builds; CI uses the workflow run number, so it always increases. A release can also be started manually with *Run workflow* on the *Release* workflow in *Actions*.

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
