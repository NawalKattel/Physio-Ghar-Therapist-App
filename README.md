# PhysioGhar — Therapist App

A functional Flutter prototype of the **PhysioGhar Therapist App**, built for the PhysioGhar Flutter Developer technical assignment. Therapists can manage their weekly availability, respond to booking requests, run sessions, keep patient notes, edit their profile and report issues.

---

## Download the APK

**[⬇ physioghar-therapist.apk](apk/physioghar-therapist.apk)** — a release build, in the [`apk/`](apk) folder of this repo (77 MB, runs on any Android device or emulator).

On GitHub, open the file and press **Download**; or from a clone:

```bash
adb install apk/physioghar-therapist.apk
```

To install by hand on a phone:

1. Copy the `.apk` across, or open the link on the phone itself.
2. Tap the file and allow installing from this source when asked.
3. Open **PhysioGhar Therapist** and log in with the demo account below.

To rebuild it:

```bash
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk apk/physioghar-therapist.apk
```

This is a universal APK: one file that runs on every processor type, including emulators, which is why it's 77 MB. A per-processor build is about a third of the size but won't run on an x86_64 emulator:

```bash
flutter build apk --split-per-abi   # app-arm64-v8a-release.apk ≈ 25 MB, for modern phones
```

---

## How to run the project

**Prerequisites:** the Flutter SDK (version below) and an Android emulator or device. iOS works too, with a minimum of iOS 15.

```bash
git clone https://github.com/NawalKattel/Physio-Ghar-Therapist-App.git
cd Physio-Ghar-Therapist-App
flutter pub get
flutter run
```

**Demo login.** Authentication is mocked. On the Log in screen tap **Use** in the demo box, or type:

| Email | Password |
|---|---|
| `aarati.joshi@example.com` | `physio123` |

You can also create an account on the **Create account** screen; it lasts while the app is running.

**Checks**

```bash
flutter analyze     # no issues
flutter test        # 34 tests, all passing
```

**Data.** Everything comes from a bundled JSON file — no backend and no network calls. Changes you make are saved on the device, so they survive a restart. To start over from the original data, clear the app's storage or reinstall it.

> Fonts are fetched at runtime by `google_fonts`, so the first launch needs an internet connection. Offline, the app falls back to the system font.

---

## Flutter / Dart version

| Tool | Version |
|---|---|
| Flutter | 3.44.6 (stable) |
| Dart | 3.12.2 |
| Android | Runs on Android; target SDK from Flutter's defaults |
| iOS | Deployment target 15.0 |

---

## Packages used

| Package | Version | Why |
|---|---|---|
| [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) | 3.4.3 | State management, as the brief requires |
| [`go_router`](https://pub.dev/packages/go_router) | 17.5.0 | Routing: bottom-nav tabs that keep their own history, full-screen detail routes, and the login guard |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | 8.2.1 | Fraunces, Inter and IBM Plex Mono from the design system, plus Noto Sans Devanagari for Nepali |
| [`intl`](https://pub.dev/packages/intl) | 0.20.2 | Date and time formatting |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | 2.5.5 | Saves state on the device, so it survives a restart |
| [`flutter_lints`](https://pub.dev/packages/flutter_lints) (dev) | 6.0.0 | Lint rules |

No code generation, and no other packages.

---

## State-management approach

**Riverpod 3**, written by hand with `Notifier`, `NotifierProvider`, `Provider` and `Provider.family`.

| Kind | Examples |
|---|---|
| **Source-of-truth notifiers** — hold state, expose actions | `sessionsProvider` (accept, decline, complete, reschedule), `slotsProvider` (block, unblock, add), `notesProvider` (add, edit), `therapistProvider` (availability, profile), `complaintsProvider`, `authProvider`, `languageProvider` |
| **Derived providers** — read-only, computed | `bookingsForTabProvider(tab)`, `daySlotsProvider(day)`, `dashboardSummaryProvider`, `patientSessionsProvider(id)`, `pendingRequestCountProvider` |
| **Action notifier** — simulates network delay, tracks which item is busy | `bookingActionsProvider` |
| **Initial load** | `appDataProvider`, a `FutureProvider` driving the skeleton, error and retry states |

`SessionsNotifier` is the only place a session's status changes, and it rejects anything outside this flow:

```
request ──accept──▶ upcoming ──complete (remarks)──▶ completed
   └──decline──▶ cancelled        └──reschedule──▶ upcoming (new time)
```

### Why Riverpod

- **The brief requires it,** and it suits the problem. Most state is shared: accepting a booking has to update the dashboard counts, the Schedule's slots and the bottom-nav badge at once. One notifier owns each piece of state, and derived providers recompute on their own.
- **Derived state instead of copies.** Filtered lists, counts, today's sessions and the OPEN / BOOKED / BLOCKED slot states are computed from the source data rather than stored twice, so no two screens can disagree.
- **Testable.** Providers are overridden in tests: `clockProvider` fixes "now" and the repository is swapped for an in-memory one, which is how all 34 tests stay deterministic.
- **No `BuildContext`** needed to read or change state, so the view models stay free of UI code.

---

## Project structure

Feature-based **MVVM**. Each feature owns its `model/`, `view_model/` and `view/`; `core/` holds app-wide infrastructure.

```
lib/
├── main.dart                     ProviderScope + MaterialApp.router
├── core/
│   ├── localization/             EN / NE strings and language provider
│   ├── repository/               app_repository (interface), mock_app_repository,
│   │                             mock_repository, physio_ghar.json,
│   │                             app_data_provider, local_store, app_snapshot, persistence
│   ├── router/                   routes, auth guard, bottom-nav shell
│   ├── theme/                    colour, text and spacing tokens
│   ├── utils/                    formatters, validators
│   └── widgets/                  shared UI kit (appButton, appCard, appTextField,
│                                 showAppBottomSheet, emptyState, sessionCard, …)
└── features/
    ├── auth/        model/ account       view_model/ auth                view/ login, register
    ├── dashboard/                        view_model/ dashboard           view/ dashboard
    ├── schedule/    model/ slot          view_model/ schedule            view/ schedule, slot tile, sheets
    ├── bookings/    model/ session       view_model/ sessions, bookings  view/ bookings, session detail, sheets
    ├── patients/    model/ patient, note view_model/ patients, notes     view/ list, record, note editor
    ├── account/     model/ therapist     view_model/ therapist, account  view/ account, profile, edit profile
    ├── complaints/  model/ complaint     view_model/ complaints          view/ list, form, success
    ├── shell/                                                            view/ bottom navigation
    └── welcome/                                                          view/ welcome
```

- **Model:** plain data classes with `fromJson` and `copyWith`; no Flutter code.
- **View model:** Riverpod providers holding state, actions and derived data.
- **View:** screens watching view models and calling their actions. Screens are `ConsumerWidget`/`ConsumerStatefulWidget`; shared widgets and screen sections are functions returning a `Widget`.
- **Imports** are always `package:physio_ghar/...`.

`test/` mirrors this: `test/view_model/` for unit tests, plus widget tests for full flows.

**34 tests** cover the session status rules, slot validation, notes, the profile, complaints, auth and the validators, along with three end-to-end widget flows at 390×844 (log in, accept a request, submit a complaint). They run against the bundled data with a fixed clock and in-memory storage, so they're deterministic.

---

## How mock data is handled

**The app talks to a repository, not to a data source.** `AppRepository` declares everything the app can ask for — sign in, load, accept, complete, reschedule, block a slot, save a note, submit a complaint. `MockAppRepository` implements it against the bundled JSON: it applies the rules, waits a moment so loading states show, and throws `RepositoryException` with a code (`INVALID_CREDENTIALS`, `SESSION_INVALID_STATUS`) when something isn't allowed. View models call the repository and write what it returns into state.

Swapping in a real backend means writing one more implementation of that interface — sign in, load, and one call per action; nothing in the view models changes.

### The bundled data

- **One local JSON file,** [`lib/core/repository/physio_ghar.json`](lib/core/repository/physio_ghar.json), bundled as an asset: the therapist profile, 7 patients, 13 sessions across every status, notes, a weekly slot template, one complaint and the demo login. It includes the brief's examples (Sita Sharma's 10:00 AM home visit, Ram Thapa's 2:00 PM clinic session, and the example session note).
- **`MockRepository` stands in for an API.** It reads the JSON after a 600ms delay, so the loading states are visible, and builds typed models. `appDataProvider` loads it once; everything after that happens in Riverpod state, so the app behaves as if a backend were there.
- **Dates are relative, so the data never goes stale.** Sessions and notes store `dayOffset` plus a `time` (`"dayOffset": 0, "time": "10:00"`), resolved against today when loaded, so "today" always has sessions. Slots are expanded from the weekly template (9:00–17:00 hourly, Saturday off, some times blocked) into the current week.
- **Actions have their own short delays** (300–600ms) so buttons can show a loading state: accepting, completing and rescheduling, saving a note or profile, submitting a complaint, and logging in.
- **Changes are saved on the device** with `shared_preferences`. `AppSnapshot` writes everything the therapist can change — sessions, slots, notes, complaints and the profile — as JSON whenever it changes, and the chosen language alongside it. On launch the saved state is used if present; otherwise the bundled JSON seeds a first run. A snapshot that can't be read is discarded and the bundled data is used instead.

---

## Important architectural decisions

1. **One repository interface.** The data source sits behind `AppRepository`, so a real backend can replace the mock without touching a view model.
2. **State is saved as one snapshot.** `AppSnapshot` serialises the changeable state to a single `shared_preferences` entry, written whenever a view model changes. It's the simplest thing that works at this size; a bigger data set would need per-record writes and debouncing.
3. **BOOKED is derived, not stored.** A slot holds only OPEN or BLOCKED; `daySlotsProvider` marks it BOOKED when a session starts at that time. Accepting or rescheduling updates the Schedule with no syncing code, and a booked slot can't be blocked.
4. **One place changes a session's status.** Screens call intent methods (`accept`, `complete`) and never set a status directly, so the allowed flow is enforced in one file.
5. **Completing a session writes a patient note** from the remarks, so session history and patient records can't drift apart.
6. **Navigation:** `go_router` with `StatefulShellRoute.indexedStack`, so each tab keeps its scroll position and history. Patient records open inside their tab; session details and editors open full screen over the bottom bar.
7. **Auth guard in the router.** `redirect` reads `authProvider` and re-runs on login and logout, so screens never navigate after auth changes themselves.
8. **Widgets as functions.** Shared UI (`appButton`, `appCard`, `sessionCard`) is functions returning widgets; only widgets needing a lifecycle (forms, tab controllers, animations) are classes. The trade-off: no `const`, and they don't show by name in DevTools — not noticeable at this size.
9. **Lightweight localisation.** A hand-written `AppStrings` class with English and Nepali copies and a `languageProvider`, instead of `gen-l10n`. Names, places and ages translate through lookup tables with a fallback to the original text.
10. **Design tokens only.** Colours, spacing, radii and text styles come from `core/theme`; widgets hard-code nothing.
11. **Accessibility.** Status never depends on colour alone (every pill and slot has a label and icon), tappable cards have screen-reader labels, tap targets are at least 44×44, and Amber buttons use Ink text because white fails contrast.

---

## Assumptions

- **Changes are kept on the device,** so sessions, slots, notes, complaints, the profile and the chosen language all survive a restart. Reinstalling, or clearing the app's data, starts again from the bundled mock data.
- **Auth is mocked, and login is not remembered.** Accounts live in memory and passwords are compared as plain text, so credentials are never written to the device and you log in again on each launch. Accounts created in the app last only for that run; the demo account always works. Creating an account copies the new name, email and phone onto the single therapist profile.
- **The Schedule shows the current week only,** as the brief describes, and rescheduling is limited to open slots from today through Sunday.
- **Slots are one hour long,** and a session occupies the slot matching its start time. Requests don't hold a slot until accepted.
- **Past slots can still be blocked or unblocked;** only *adding* a slot in the past is rejected.
- **Sessions can be completed before their scheduled time,** to keep the demo easy to walk through.
- **Call and message are simulated** with a confirmation message.
- **Only selected text is translated** (bottom navigation, Account screen, and names, ages and places), as the brief allows.
- **Avatars show initials,** so no image upload is needed.
- **Complaints are reported by the therapist** to the PhysioGhar admin; patients report through their own app, which is out of scope.

---

## What I'd improve with more time

- **A local database** (Drift or Isar) instead of one JSON snapshot, once the data outgrows rewriting it on every change.
- **Connect a real backend** by adding an Dio `AppRepository` implementation, leaving the view models untouched.
- **More widget tests:** completing a session end to end, blocking a slot on screen, and adding a note then reopening the patient.
- **Full localisation** with `gen-l10n` and ARB files, covering every screen, dates and plurals.
- **Bundle the fonts** so they work offline on first launch.
- **Tablet layouts:** two-pane patient and booking screens instead of one centred column.
- **Schedule:** move between weeks, recurring availability, and slots of varying length.
