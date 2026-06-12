# Aventus Machine Test — Dynamic Theming & Offline‑First Sync

A production‑grade Flutter app showcasing two pillars of senior mobile engineering:

1. **Dynamic theming** — light/dark/system modes, custom accent colour, and font‑family
   selection, applied with *surgical* rebuilds (only the affected widgets repaint).
2. **Offline‑first data** — posts are fetched from a public API, cached in Hive, served fully
   offline, and **auto‑synchronised** the moment connectivity returns.

Built with **Clean Architecture**, **Riverpod**, **Hive (CE)**, **Dio**, **Connectivity Plus**,
**Freezed**, and code generation via **build_runner**.

---

## Features

- 🎨 **Theme engine** — Material 3 `ColorScheme.fromSeed`, dynamic Google Fonts, three theme modes.
- 💾 **Offline‑first** — the app is fully usable with no network; cached data is the source of truth offline.
- 🔄 **Automatic sync** — reconnecting to the internet triggers a background sync and live UI refresh.
- 📶 **Connectivity awareness** — an animated status banner (Online / Offline / Syncing) and a last‑sync indicator.
- ⚡ **Performance‑first state** — `select()`‑driven granular rebuilds with on‑screen **rebuild counters** that prove it.
- 🧱 **Clean Architecture** — strict domain / data / presentation separation, repository pattern, DI via Riverpod.
- ✅ **Tested** — unit tests for JSON/entity mapping, the offline‑first repository, and the theme controller (incl. `select` granularity).

---

## Architecture

The project follows a feature‑first **Clean Architecture**. Each feature is split into the three
canonical layers; dependencies always point *inward* (presentation → domain ← data).

```
lib/
├── main.dart                      # Bootstrap: Hive init, open boxes, DI overrides, runApp
├── app.dart                       # Root MaterialApp (the only widget that rebuilds on theme change)
│
├── core/                          # Cross-cutting, feature-agnostic building blocks
│   ├── constants/                 # AppConstants (endpoints, box names, keys, timeouts)
│   ├── hive/                      # @GenerateAdapters + generated adapter/registrar
│   ├── network/                   # DioClient factory, ApiException (Dio → domain error mapping)
│   ├── services/                  # ConnectivityService (connectivity_plus wrapper → Stream<bool>)
│   └── theme/                     # AppPalette, AppFonts, AppThemeFactory (ThemeState → ThemeData)
│
├── features/
│   ├── theme/
│   │   ├── domain/                # ThemeState (Freezed entity) + ThemeRepository (interface)
│   │   ├── data/                  # ThemeRepositoryImpl (Hive-backed) + provider
│   │   └── presentation/          # ThemeController (Notifier) + ThemeScreen + control widgets
│   │
│   └── posts/
│       ├── domain/                # Post (Freezed entity) + PostRepository (interface)
│       ├── data/
│       │   ├── models/            # PostModel (JSON + Hive adapter) ↔ Post mapper
│       │   ├── datasources/       # PostRemoteDataSource (Dio) + PostLocalDataSource (Hive)
│       │   ├── repositories/      # PostRepositoryImpl (offline-first orchestration)
│       │   └── sync/              # SyncService (the "how" of synchronising)
│       └── presentation/          # PostsController (AsyncNotifier), SyncController, HomeScreen, widgets
│
└── shared/
    ├── providers/                 # Infrastructure DI providers (boxes, Dio, connectivity)
    └── widgets/                   # RebuildCounter (reusable rebuild-visualiser badge)
```

**Why this shape?**

- **Domain** holds pure entities and repository *interfaces* — no Flutter/IO concerns
  (exception: the theming domain legitimately speaks in `ThemeMode`/`Color`, its native vocabulary).
- **Data** implements those interfaces with concrete data sources and DTOs (`PostModel`).
- **Presentation** depends only on domain abstractions, reached through Riverpod providers.
- Dependency Inversion is enforced via abstract `interface class` repositories resolved by providers.

---

## State Management (Riverpod 3)

| Concern | Provider | Type |
| --- | --- | --- |
| Theme state | `themeControllerProvider` | `NotifierProvider<ThemeController, ThemeState>` |
| Posts list | `postsControllerProvider` | `AsyncNotifierProvider<PostsController, List<Post>>` |
| Sync state | `syncControllerProvider` | `NotifierProvider<SyncController, SyncState>` |
| Connectivity | `connectivityStatusProvider` | `StreamProvider<bool>` |
| Banner status | `bannerStatusProvider` | derived `Provider<BannerStatus>` |
| Infrastructure | `dioProvider`, `settingsBoxProvider`, `postsBoxProvider`, … | `Provider` (boxes injected via overrides) |

**Dependency injection.** The only truly async singletons are the Hive boxes. They're opened in
`main()` and injected into the graph with `ProviderScope(overrides: …)`, so every other dependency
(data sources → repositories → controllers) is wired declaratively and is trivially overridable in tests.

---

## Offline Strategy

The **local cache is authoritative when offline**; the network is an enhancement, never a hard
dependency.

- **Online** → `PostRepositoryImpl` fetches fresh posts, atomically rewrites the Hive cache
  (`clear()` + `putAll`), stamps the sync time, and returns the fresh data.
- **Network error while "online"** → degrade gracefully to the cached snapshot (no error thrown to the UI).
- **Offline** → return the cached snapshot directly; the remote source is never even called.
- **Pull‑to‑refresh** uses the *offline‑first* read, so refreshing while offline keeps the cached list
  instead of throwing.

`PostModel` carries a generated Hive `TypeAdapter` (via `@GenerateAdapters`), so posts are stored as
typed objects — not loosely‑typed maps.

---

## Sync Flow

```
ConnectivityService (connectivity_plus)
        │  Stream<bool> (emits current status first, then changes)
        ▼
connectivityStatusProvider ──watched by──► SyncController.build() { ref.listen(...) }
        │                                          │
        │ offline ─► online transition             │ (first emission skipped: initial load handles it)
        ▼                                          ▼
   SyncController._synchronize()  ──►  SyncService.synchronize()  ──►  PostRepositoryImpl.refreshPosts()
        │                                                                   │ fetch + cache
        │ on success                                                        ▼
        ├─► PostsController.applySynced(posts)   ← pushes fresh data WITHOUT a second network call
        └─► SyncState(success, lastSyncAt, "Synced N posts")
                  │
                  ▼
        bannerStatusProvider / SyncStatusWidget reflect the new status & timestamp
```

- Auto‑sync fires **only** on a genuine offline→online transition (guarded against the first stream
  emission and against overlapping syncs).
- A manual **Sync** button in the AppBar calls `SyncController.syncNow()`.
- After a successful sync the fresh list is pushed straight into `PostsController`, avoiding a
  redundant second fetch.

---

## Performance Optimizations

The brief: *“avoid rebuilding the entire widget tree; only affected widgets should rebuild.”*

1. **`select()` for slice‑level subscriptions.** Each theme control watches exactly one field:
   `ThemeModeSelector` → `themeMode`, `AccentColorPicker` → `primaryColor`, `FontFamilySelector` →
   `fontFamily`. Changing the colour does **not** rebuild the font selector, and vice‑versa.
2. **`const` everywhere it matters.** `HomeScreen`/`ThemeScreen` are `const`‑composed `StatelessWidget`s
   that watch nothing, so they never rebuild; their children independently subscribe to the minimum state.
3. **Isolated `Consumer`s.** The AppBar sync button is its own `ConsumerWidget` watching only `isSyncing`,
   so toggling sync state never rebuilds the whole AppBar/Screen.
4. **Rebuild counters.** `RebuildCounter` badges (and `debugPrint` logs, e.g. `🔁 [color] rebuilt 3 time(s)`)
   make the above *observable*: open **Appearance**, change one setting, and watch only the relevant
   section — plus the deliberately full‑state **Live preview** — tick up.

   The badge is intentionally a *faithful* probe: it depends on **no** `InheritedWidget` (no `Theme.of`) and
   is driven by a `token` equal to the exact slice its host watches. A naïve badge that read the theme would
   rebuild on *every* theme change and tick in lockstep regardless of `select()` — measuring the wrong thing.
   (This was caught by running the app on a device and pinned down with a widget test, not just by reasoning.)

> **Honest note on the root widget.** A `MaterialApp` *must* rebuild to swap its `ThemeData`, so `App`
> rebuilds on a theme change — that is unavoidable and correct. The optimization is that its child is
> `const HomeScreen()`: Flutter reuses that element subtree, so the theme change only repaints widgets
> that actually depend on `Theme.of(context)`, not the whole tree. This is the realistic, senior‑level
> framing rather than a false “nothing above rebuilds” claim.

---

## Packages Used

| Package | Version | Role |
| --- | --- | --- |
| `flutter_riverpod` | 3.3.2 | State management & DI |
| `hive_ce` / `hive_ce_flutter` | 2.19.3 / 2.3.4 | Local NoSQL persistence (maintained Hive Community Edition) |
| `hive_ce_generator` | 1.11.1 | Generates Hive `TypeAdapter`s + registrar |
| `dio` | 5.9.2 | HTTP client |
| `connectivity_plus` | 7.1.1 | Network status detection |
| `google_fonts` | 8.1.0 | Dynamic font families |
| `freezed` / `freezed_annotation` | 3.2.5 / 3.1.0 | Immutable value objects (`ThemeState`, `Post`) |
| `json_serializable` / `json_annotation` | 6.14.0 / 4.12.0 | API (de)serialization for `PostModel` |
| `intl` | 0.20.2 | Last‑sync timestamp formatting |
| `build_runner` | 2.15.0 | Code generation runner |

> **Why Hive CE?** The original `hive`/`hive_generator` is unmaintained and its `hive_generator`
> depends on a `source_gen` range that conflicts with current `json_serializable`. **Hive Community
> Edition** is the drop‑in, actively‑maintained successor with a modern, conflict‑free toolchain.

**API:** `https://jsonplaceholder.typicode.com/posts`

---

## How To Run

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code (Hive adapters, Freezed, JSON)
dart run build_runner build --delete-conflicting-outputs

# 3. Run on a connected device / emulator
flutter run

# Quality gates
flutter analyze   # → No issues found
flutter test      # → All tests pass
```

**Requirements:** Flutter ≥ 3.41 (stable), Dart ≥ 3.11.

### Try the offline & sync flow
1. Launch the app online → posts load and cache; banner shows **Online**.
2. Turn off Wi‑Fi / data → banner flips to **Offline**; the cached list stays fully usable.
3. Turn connectivity back on → banner shows **Syncing…**, posts refresh, and the **last sync** time updates.

### Try the theming / rebuild demo
Open **Appearance** (palette icon), change the mode / accent colour / font, and watch the per‑section
rebuild counters: only the section you touched (and the full‑state preview) increments — proving the
rest of the tree is untouched.

---

## Testing

```bash
flutter test
```

- `post_model_test.dart` — JSON round‑trip + `Post` ⇄ `PostModel` mapping.
- `post_repository_test.dart` — offline‑first behaviour (online fetch+cache, offline cache, graceful
  degradation on network error) using lightweight fakes.
- `theme_controller_test.dart` — load/mutate/persist, the no‑op guard, and a `select()` assertion proving
  the colour subscription is *not* notified by a font change.
