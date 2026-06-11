# Flutter Interview Master Questions And Answers

This guide answers every topic from the supplied interview list in a form that
is designed to be spoken aloud and remembered.

The source list contains **356 questions across 22 sections**. Repeated
questions are intentionally grouped under headings such as `3-5` so one answer
covers the related “what,” “why,” and “when” forms without repeating the same
paragraph.

Navigation:

- [Main project and state-management comparison](../README.md)
- [Testing guide](../test/README.md)
- [Short Flutter interview guide](flutter_interview_guide.md)
- [Working concepts screen](../lib/interview_examples/view/interview_concepts_page.dart)

## How To Answer In An Interview

Use **D-F-E-T**:

```text
D = Definition: What is it?
F = Flow: How does it work?
E = Example: Where did I use it?
T = Tradeoff: When would I not use it?
```

Example:

```text
Riverpod is a provider-based state and dependency-management library.
The UI watches a provider, an AsyncNotifier calls a repository, and AsyncValue
represents loading, data, or error. I used it in this Notes project with
provider overrides for tests. Its tradeoff is that teams need clear provider
ownership and lifecycle conventions.
```

## Implementation Legend

| Label | Meaning |
| --- | --- |
| **Implemented** | Working code exists in this repository |
| **Demonstrated** | A small runnable example exists |
| **Documented** | Interview answer and code sample exist, but the dependency is not added |
| **Production extension** | Important production topic intentionally outside this small sample |

## Original Question Coverage

| Section | Questions |
| --- | ---: |
| Platform Channels | 8 |
| Widgets and Widget Tree | 20 |
| StatefulWidget Lifecycle | 20 |
| InheritedWidget and State Sharing | 8 |
| Flutter Architecture | 10 |
| Clean Architecture | 18 |
| Riverpod and Provider | 25 |
| BLoC and Cubit | 15 |
| Freezed and Immutable Classes | 14 |
| API Integration and Networking | 27 |
| HTTP Status Codes | 25 |
| Security, SSL Pinning, and Encryption | 26 |
| SQLite Database | 15 |
| Futures, Streams, and Async Programming | 18 |
| Callbacks and Listeners | 14 |
| App Store and Play Store Country Availability | 8 |
| Payment Gateway Integration | 15 |
| Push Notifications | 15 |
| App Performance | 15 |
| Main Function and App Startup | 8 |
| MCP Server, AI Agent, and Agentic AI | 12 |
| Practical Scenario-Based Flutter Questions | 20 |
| **Total** | **356** |

---

# 1. Platform Channels

**Memory line:** `MethodChannel = request/response; EventChannel = continuous events.`

## Questions And Answers

### 1. What is a MethodChannel?

A `MethodChannel` is an asynchronous named bridge used to invoke a method
between Dart and platform code such as Kotlin or Swift.

### 2. Why do we use MethodChannel?

Use it when Flutter or an existing plugin does not expose a native capability,
for example a vendor SDK, device API, or platform-specific security feature.

### 3. How does Flutter communicate with Android or iOS?

```text
Dart invokes method
  -> Flutter engine serializes arguments
  -> Kotlin/Swift channel handler runs
  -> native result/error returns
  -> Dart Future completes
```

```dart
const channel = MethodChannel('com.example/device');

Future<String> deviceName() async {
  try {
    return await channel.invokeMethod<String>('deviceName') ?? 'Unknown';
  } on PlatformException catch (error) {
    throw Exception('Native call failed: ${error.code}');
  }
}
```

### 4. What is an EventChannel?

An `EventChannel` exposes a stream of platform events to Dart.

### 5. MethodChannel vs EventChannel?

| MethodChannel | EventChannel |
| --- | --- |
| One request, one response | Multiple events over time |
| Returns a `Future` | Returns a `Stream` |
| Battery level on demand | Accelerometer or connectivity updates |

### 6. When should MethodChannel be used instead of EventChannel?

Use `MethodChannel` when the operation is command-like or one-shot. Use
`EventChannel` when the platform continuously pushes values.

### 7. Where is EventChannel more suitable?

Sensor data, call-state updates, download progress, Bluetooth events, or native
location updates are better represented as streams.

### 8. How are native errors handled?

Native code returns a structured error. Dart catches `PlatformException` and
maps its code/message/details into an application failure. Do not display raw
native stack traces to users.

**Status:** Documented. This project currently uses plugins such as `sqflite`,
which internally use platform integration.

---

# 2. Widgets And Widget Trees

**Memory line:** `Widget configures; Element connects; RenderObject lays out and paints.`

## Questions And Answers

### 1. What is a Widget?

A widget is an immutable description of part of the UI.

### 2. StatelessWidget vs StatefulWidget?

| StatelessWidget | StatefulWidget |
| --- | --- |
| No mutable `State` object | Creates a mutable `State` object |
| Output depends on inputs/inherited data | Output can change during its lifetime |
| Example: `Text`, `Icon` | Example: `TextField`, `Checkbox` |

### 3-6. Examples and classifications

- `Text`, `Icon`, `Padding`, and `Row` are stateless widgets.
- `TextField`, `Checkbox`, `Form`, and `AnimatedContainer` are stateful widgets.
- `Text()` is a `StatelessWidget`.
- `TextField()` is a `StatefulWidget` because it manages editable interaction,
  focus, selection, and connection to an editing controller.

### 7. What is the Widget Tree?

It is the hierarchy of immutable widget configurations returned by `build`.

### 8. Widget Tree vs Element Tree vs Render Tree?

| Tree | Responsibility | Lifetime |
| --- | --- | --- |
| Widget | Immutable configuration | Often recreated |
| Element | Mounted identity and parent/child relationship | Reused when possible |
| RenderObject | Constraints, size, painting, hit testing | Reused when possible |

### 9-10. How are widgets converted into mobile UI?

Flutter inflates widgets into elements. RenderObject elements create/update
render objects. Render objects perform layout and painting, and the engine
composites/rasterizes the frame.

### 11. What happens when a widget rebuilds?

Flutter creates new widget descriptions and asks existing elements to update.
If runtime type and key match, the element/render object can be reused; otherwise
that subtree is replaced.

### 12. Container vs Stack?

`Container` styles or sizes one child. `Stack` overlays multiple children and
can position them with `Positioned`.

### 13. When should Stack be used?

Use it for badges, overlays, floating labels, image captions, or layered UI.
Avoid it when normal `Row`, `Column`, or constraint-based layout is sufficient.

### 14. What is LayoutBuilder?

`LayoutBuilder` builds based on the constraints supplied by its parent.

```dart
LayoutBuilder(
  builder: (context, constraints) {
    return constraints.maxWidth >= 600
        ? const WideLayout()
        : const CompactLayout();
  },
);
```

**Implemented:** [responsive example](../lib/interview_examples/view/interview_concepts_page.dart).

### 15. What is Builder?

`Builder` creates a new `BuildContext` below its location. It is useful when an
operation needs a context that can see a newly inserted ancestor.

### 16. LayoutBuilder vs Builder?

`Builder` provides a new context. `LayoutBuilder` provides a context plus parent
layout constraints and may rebuild when constraints change.

### 17-18. What is FutureBuilder and when should it be used?

`FutureBuilder` converts a `Future` snapshot into UI. Use it for small,
widget-owned one-shot asynchronous work. Cache the future outside `build` if it
must not restart on every rebuild.

### 19-20. What is an event listener and event handling?

An event listener is a callback registered for user, stream, controller, or
system events.

```dart
FilledButton(
  onPressed: () => debugPrint('Tapped'),
  child: const Text('Save'),
);
```

**Demonstrated:** [FutureBuilder, StreamBuilder and listeners](../lib/interview_examples/view/interview_concepts_page.dart).

---

# 3. StatefulWidget Lifecycle

**Memory order:** `create -> init -> dependencies -> build -> update -> deactivate -> dispose`.

## Questions And Answers

### 1-3. What is setState, why use it, and what happens?

`setState` synchronously changes state and marks the element dirty. Flutter
schedules a rebuild; it does not immediately repaint the whole application.

```dart
setState(() {
  count++;
});
```

Use it for local state owned by one widget, not as a replacement for shared
business-state architecture.

### 4. Explain the lifecycle

```text
createState
  -> initState (once)
  -> didChangeDependencies
  -> build (many times)
  -> didUpdateWidget (new configuration)
  -> build
  -> deactivate
  -> dispose (once)
```

### 5. What is createState?

`StatefulWidget.createState` creates the mutable `State` object.

### 6-7. What is initState and when is it called?

`initState` runs once after the state is inserted into the tree. Initialize
controllers, observers, subscriptions, and cached futures here. Do not call
`dependOnInheritedWidgetOfExactType` here.

### 8-9. What is build and when is it called?

`build` returns the current widget configuration. It can run after `setState`,
dependency changes, parent rebuilds, widget updates, or hot reload, so keep it
fast and free of side effects.

### 10-11. What is didChangeDependencies?

It runs after `initState` and when an inherited dependency used by the state
changes, such as theme, locale, or provider data.

### 12-13. What is didUpdateWidget?

It runs when the parent supplies a new widget of the same type/key. Compare old
and new properties and replace subscriptions when necessary.

### 14-15. What is dispose and why is it important?

`dispose` is the final cleanup hook. Remove observers and dispose controllers,
focus nodes, animation controllers, and streams to prevent leaks and callbacks
to dead state.

### 16-17. What is mounted and why check it?

`mounted` indicates whether the state is still in the tree. After `await`, check
it before using `context` or calling `setState`.

```dart
await save();
if (!mounted) return;
Navigator.pop(context);
```

### 18-20. What is WidgetsBindingObserver and lifecycle detection?

It listens to application/system lifecycle changes.

```dart
class PageState extends State<Page> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // resumed, inactive, paused, hidden, detached
  }
}
```

Register in `initState` and remove in `dispose`.

**Implemented:** [lifecycle example](../lib/interview_examples/view/interview_concepts_page.dart).

---

# 4. InheritedWidget And State Sharing

**Memory line:** `InheritedWidget efficiently exposes data downward through context.`

## Questions And Answers

### 1-3. What is InheritedWidget, why and when use it?

`InheritedWidget` is a framework primitive for efficiently sharing immutable
data with descendant widgets and rebuilding dependents when that data changes.
Use it when building a small custom dependency API; otherwise a package often
reduces boilerplate.

### 4. How does it pass data?

An ancestor inserts an `InheritedWidget`. A descendant looks it up through
`BuildContext`; Flutter records the dependency and rebuilds the descendant when
`updateShouldNotify` returns true.

### 5. InheritedWidget vs Provider?

| InheritedWidget | Provider |
| --- | --- |
| Low-level Flutter primitive | Higher-level package built around inherited mechanisms |
| Manual lookup/update API | Creation, disposal, lookup, and common patterns |
| More control and boilerplate | Easier application use |

### 6. How does dependOnInheritedWidgetOfExactType work?

It searches the nearest ancestor of the requested type and registers the
calling element as a dependent.

### 7. Example

```dart
class AppConfig extends InheritedWidget {
  final String apiBaseUrl;

  const AppConfig({
    super.key,
    required this.apiBaseUrl,
    required super.child,
  });

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }

  @override
  bool updateShouldNotify(AppConfig oldWidget) {
    return apiBaseUrl != oldWidget.apiBaseUrl;
  }
}
```

### 8. What problem does it solve?

It avoids manually passing the same data through every intermediate widget
while keeping dependency tracking efficient.

---

# 5. Flutter Architecture

**Memory line:** `Framework (Dart) -> Engine (C++) -> Embedder (platform).`

## Questions And Answers

### 1-2. Explain Flutter architecture and layers

```text
Application
  -> Flutter framework: widgets, gestures, animation, rendering abstractions
  -> Flutter engine: Dart runtime, text, graphics, compositing, rasterization
  -> Platform embedder: window, lifecycle, input, surfaces, platform integration
  -> Operating system and GPU
```

### 3. Role of the framework

The Dart framework supplies Material/Cupertino widgets, layout, gestures,
animation, painting, semantics, and foundation APIs.

### 4. Role of the engine

The C++ engine hosts the Dart runtime, frame scheduling, text layout,
compositing, graphics backends, and communication with the embedder.

### 5. What is Skia?

Skia is a graphics library historically central to Flutter rasterization and
still relevant on some platforms/backends. Modern Flutter uses **Impeller by
default on major mobile targets**, so saying “Flutter always renders with Skia”
is outdated.

### 6. What is the Dart runtime?

It executes Dart code. Development uses JIT capabilities for fast iteration and
hot reload; release mobile builds generally use ahead-of-time compiled native
code.

### 7-8. Cross-platform vs native rendering

Flutter usually owns its rendering pipeline and draws consistent pixels rather
than mapping every widget to an OEM UI control. Native frameworks primarily use
platform UI components. Flutter can still embed native platform views.

### 9. Gestures, layout, painting, rendering

```text
Pointer event -> gesture arena -> callback
Constraints down -> sizes up -> positions set
RenderObjects paint -> layers composed -> engine rasterizes frame
```

### 10. How does execution start from main?

The Dart isolate invokes `main`, initialization runs, `runApp` attaches the root
widget, and Flutter builds/schedules the first frame.

**Implemented:** [application entry point](../lib/main.dart).

---

# 6. Clean Architecture

**Memory flow:** `UI -> UseCase -> Repository contract -> Repository implementation -> Data source`.

## Questions And Answers

### 1-3. What is Clean Architecture and its layers?

Clean Architecture separates policy from details. A common Flutter form is:

| Layer | Owns |
| --- | --- |
| Presentation | Widgets, state managers, UI models |
| Domain | Entities, repository contracts, use cases, business rules |
| Data | DTOs, repository implementations, API/database data sources |

Dependencies point inward toward business rules.

### 4. Explain presentation, domain, and data

- Presentation converts user actions into calls and state into widgets.
- Domain describes business meaning independent of Flutter/HTTP/SQLite.
- Data implements persistence/network details and mapping.

### 5. What is an Entity?

An entity is a business object defined by domain identity and rules, not by JSON
or database shape.

### 6. What is a Model?

“Model” is broad. In architecture discussions, specify whether it is a domain
entity, API DTO, database row model, or UI model.

### 7. What is a Repository?

A repository is a domain-facing abstraction that hides data-source details.

### 8. What is a UseCase?

A use case represents one application action, such as `CreateNote`,
`TransferMoney`, or `Login`, and coordinates relevant business rules.

### 9. Repository vs UseCase?

| UseCase | Repository |
| --- | --- |
| Describes an action/business workflow | Describes data access capability |
| Calls one or more repositories | Calls data sources |
| May validate business rules | Hides API/database implementation |

### 10-13. UI-to-API data flow

```text
UI event
 -> state manager
 -> use case
 -> repository interface
 -> repository implementation
 -> remote data source
 -> HTTP client
 -> map DTO to entity
 -> result/failure returns to UI
```

### 14. Where should business logic be written?

Domain rules belong in entities/use cases/domain services. UI behavior belongs
in presentation. SQL, HTTP, and serialization belong in data.

### 15. Where should API mapping logic be written?

Map JSON in a DTO/data mapper inside the data layer, then return domain objects
to higher layers.

### 16. Advantages

Testability, replaceable infrastructure, clearer ownership, smaller change
impact, and independent business rules.

### 17. How are API errors handled?

Catch low-level client exceptions in the data layer, map them to typed failures,
and let presentation convert failures into user-safe state/messages.

### 18. How are layers tested?

- Domain: pure unit tests
- Data: repository/data-source tests with fake clients or test databases
- Presentation: state-manager unit tests and widget tests
- Critical flows: integration tests

**Project note:** This repository is layered and MVVM-inspired, not full Clean
Architecture because it intentionally omits use-case classes and separate
domain/data models. It does implement
[`NoteRepository`](../lib/core/repository/note_repository.dart) dependency
inversion and has [layered tests](../test/README.md).

---

# 7. Riverpod And Provider

**Memory line:** `watch rebuilds; read acts once; listen performs a side effect.`

## Questions And Answers

### 1. What is Provider?

Provider is a Flutter package that exposes objects through the widget tree using
`BuildContext` and inherited-widget mechanisms.

### 2. What is Riverpod?

Riverpod is a reactive state and dependency-management library where providers
form a graph outside the widget tree and are consumed through `Ref`.

### 3-5. Provider vs Riverpod and advantages

| Provider | Riverpod |
| --- | --- |
| Reads through `BuildContext` | Reads through `Ref` |
| Primarily widget-tree scoped | Provider graph is independently testable |
| Runtime lookup mistakes are possible | Dependencies are explicit providers |
| Overrides usually involve widget setup | `ProviderContainer` supports direct overrides |

Riverpod is not automatically “better”; it is often preferred for compile-time
provider references, test overrides, async state, and context-free dependency
access. Provider remains simple and effective for many apps.

### 6. How does Riverpod remove BuildContext dependency?

Provider callbacks and consumers receive `Ref`, so repositories/notifiers can
read providers without a widget context.

### 7-8. How do you update data and implement Riverpod?

```text
1. Wrap app in ProviderScope
2. Define dependency providers
3. Define a Notifier/AsyncNotifier provider
4. ref.watch state in UI
5. ref.read(provider.notifier).method() for actions
6. Render loading/data/error
```

```dart
final counterProvider = NotifierProvider<Counter, int>(Counter.new);

class Counter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}
```

### 9. What is ProviderScope?

`ProviderScope` stores provider state and enables overrides for the Flutter
subtree. It is normally placed above the app.

### 10-13. watch vs read vs listen

| API | Use |
| --- | --- |
| `ref.watch(provider)` | Subscribe and rebuild/recompute when value changes |
| `ref.read(provider)` | Read once, commonly inside event callbacks |
| `ref.listen(provider, ...)` | Run a side effect such as navigation/snackbar |

Do not use `read` to avoid rebuilds when the UI actually depends on the value.

### 14. What is StateProvider?

A provider for simple mutable values such as a filter or selected index. For
business logic, prefer a notifier.

### 15. What is FutureProvider?

It exposes a future as `AsyncValue<T>`, useful for read-only async data.

### 16. What is StreamProvider?

It exposes stream events as `AsyncValue<T>`, useful for real-time data.

### 17. What is StateNotifierProvider?

It exposes a `StateNotifier`. It is common in older Riverpod code and still
supported in Riverpod 2, but modern Riverpod generally favors `Notifier` and
`AsyncNotifier` for new code.

### 18. What is NotifierProvider?

It exposes synchronous state and methods owned by a `Notifier`.

### 19. What is AsyncNotifierProvider?

It exposes asynchronous state through `AsyncValue`, with a notifier that can
load and mutate data.

### 20. Notifier vs StateNotifier?

| Notifier | StateNotifier |
| --- | --- |
| Riverpod-native lifecycle and `ref` | Independent package/class pattern |
| Dependencies read in `build`/methods | Dependencies usually constructor-injected |
| Recommended for modern Riverpod | Common in existing Riverpod 1/2 code |

### 21-22. API call and loading/success/error

```dart
class Users extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() => ref.read(apiProvider).fetchUsers();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(apiProvider).fetchUsers(),
    );
  }
}
```

```dart
return ref.watch(usersProvider).when(
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => Text('$error'),
  data: (users) => UsersList(users),
);
```

### 23. How do you refresh?

Call a notifier method, invalidate the provider with `ref.invalidate`, or
refresh/read its future depending on ownership and required behavior.

### 24. How do you retain registration form data?

Put form state in a notifier that outlives the page route, scope its provider
above the flow, and do not use `autoDispose` unless keeping it alive
intentionally. Clear it after successful submission/cancellation.

### 25. Riverpod with RxDart?

A repository can expose RxDart streams and Riverpod can consume them with
`StreamProvider`. Do not add RxDart only to duplicate Riverpod state; use it
when stream operators such as debounce, combineLatest, or switching are needed.

**Implemented:** [ProviderScope](../lib/main.dart),
[AsyncNotifier](../lib/riverpod_example/viewmodel/riverpod_note_view_model.dart),
[AsyncValue UI](../lib/riverpod_example/view/riverpod_notes_list_page.dart), and
[provider override test](../test/riverpod/riverpod_note_view_model_test.dart).

---

# 8. BLoC And Cubit

**Memory line:** `BLoC: Event in, State out. Cubit: Method in, State out.`

## Questions And Answers

### 1-4. What is BLoC, Event, and State?

BLoC separates user/system inputs from output state.

```text
UI -> AddNoteEvent -> NoteBloc -> repository -> NoteState -> UI
```

An event describes what happened. A state is the immutable UI-relevant result.

### 5. How does UI update?

`BlocBuilder` subscribes to the bloc stream and rebuilds when a new state is
emitted.

### 6. What is BlocBuilder?

It rebuilds UI from state and should remain free of navigation/snackbar side
effects.

### 7. What is BlocListener?

It reacts once to state changes for side effects such as navigation, dialogs,
analytics, or snackbars.

### 8. What is BlocConsumer?

It combines `BlocBuilder` and `BlocListener` when the same subtree needs both.

### 9. What is Cubit?

Cubit is a simpler state container where public methods directly emit states;
there is no event class/handler layer.

### 10. BLoC vs Cubit?

| BLoC | Cubit |
| --- | --- |
| Events are explicit inputs | Methods are inputs |
| Better event trace/audit vocabulary | Less boilerplate |
| Supports event transformers | Straightforward state changes |

### 11-13. When to use each?

Use BLoC for complex workflows, many event sources, auditability, debounce or
concurrency rules, and strict team conventions. Use Cubit for simpler screens
where named methods communicate intent clearly. Choose BLoC over Cubit when the
event history itself has business meaning.

### 14. Login flow example

```text
LoginSubmitted
 -> LoginLoading
 -> repository.login
 -> LoginSuccess(user) OR LoginFailure(message)
 -> listener navigates or shows error
```

### 15. Loading, success, and failure

Emit loading before the repository call, success with required data, and a
typed/user-safe failure on exception. Preserve previous data when the UX needs
refresh-in-place instead of blank loading.

**Implemented:** [events](../lib/bloc_example/viewmodel/note_event.dart),
[state](../lib/bloc_example/viewmodel/note_state.dart),
[BLoC](../lib/bloc_example/viewmodel/note_bloc.dart), and
[`BlocConsumer`](../lib/bloc_example/view/bloc_add_note_page.dart).

---

# 9. Freezed And Immutable Classes

**Memory line:** `Freezed generates immutable value classes, copyWith, equality, unions, and JSON helpers.`

## Questions And Answers

### 1-4. What is Freezed, why, when, and benefits?

Freezed is a code generator for immutable Dart classes and sealed unions. Use it
for value models or state where equality, `copyWith`, exhaustive variants, and
JSON generation reduce error-prone boilerplate.

### 5. What is immutability?

An immutable object's observable fields do not change after construction.
Updates create a new object.

### 6-7. Can it be updated and how does copyWith work?

Do not mutate it. Create a changed copy:

```dart
final updated = user.copyWith(name: 'Sumit');
```

### 8-10. API mapping and JSON serialization

Freezed works with `json_serializable` to generate `fromJson`/`toJson`. Keep API
DTO concerns separate from domain entities in a strict architecture.

### 11-12. Example

```dart
@freezed
class User with _$User {
  const factory User({
    required int id,
    required String name,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
}

final changed = user.copyWith(name: 'New name');
```

### 13. Normal class vs Freezed?

| Manual immutable class | Freezed |
| --- | --- |
| No build generation | Requires generator/build step |
| Full manual control | Generates equality/copy/union/JSON glue |
| More boilerplate | Less boilerplate |

### 14. How does Freezed help state management?

Value equality and immutable copies make state transitions predictable.
Sealed states can model loading/data/error exhaustively.

**Project equivalent:** This sample intentionally uses a manual immutable
[`NoteModel`](../lib/core/models/note_model.dart) and
[`NoteState`](../lib/bloc_example/viewmodel/note_state.dart) so interviewers can
see what Freezed would generate.

---

# 10. API Integration And Networking

**Memory flow:** `UI -> state manager -> repository -> client -> map -> state`.

## Questions And Answers

### 1-5. How do you integrate an API and update UI?

```text
1. Define remote data-source contract
2. Configure HTTP client
3. Call endpoint and validate status/body
4. Parse DTO
5. Repository maps/returns domain data
6. State manager emits loading, data, or failure
7. UI renders state
```

Never call HTTP directly from `build`.

### 6-8. What is Dio and why use it over http?

Dio is a Dart HTTP client with interceptors, cancellation, timeout
configuration, uploads/downloads, progress, and rich options. The `http`
package is smaller and often enough for simple calls. Choose based on needs,
not popularity.

### 9-11. What is Retrofit and Dio vs Retrofit?

Retrofit for Dart is a declarative API-client generator built on Dio.

| Dio | Retrofit |
| --- | --- |
| Executes/configures HTTP | Generates typed endpoint methods |
| Imperative requests | Annotation-based interface |
| Can work alone | Flutter Retrofit commonly depends on Dio |

### 12-14. What is an interceptor and how are headers added?

An interceptor observes/modifies requests, responses, and errors globally.

```dart
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await tokenStore.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ),
);
```

### 15-16. Token expiry and retry

On `401`, allow one synchronized refresh request, store the new token, clone and
retry queued requests once. Prevent infinite loops and multiple simultaneous
refresh calls. If refresh fails, clear the session and navigate to login.

### 17. API timeout

Configure connect/send/receive timeouts, map timeout exceptions to a retryable
failure, and offer retry where the operation is idempotent.

### 18-20. Session timeout and logout

Session timeout is server/client policy that invalidates an inactive or expired
session. Clear secure tokens and sensitive cached state, reset protected
providers/controllers, and route to authentication.

### 21-23. Token, access token, refresh token

- Token: credential/value representing authorization or identity context.
- Access token: short-lived credential sent to APIs.
- Refresh token: longer-lived credential used only to request a new access
  token.

### 24. Secure token storage

Use Keychain on Apple platforms and Keystore-backed encrypted storage on
Android through a maintained secure-storage plugin. Never commit tokens or
secret keys.

### 25. What to do on 401?

Distinguish expired access token from invalid credentials. Try the synchronized
refresh flow once; otherwise end the session.

### 26-27. Global errors and UI messages

Map transport/client exceptions to typed failures in the data layer. Log
technical context securely, while UI displays actionable messages such as
“Check your connection” rather than raw exceptions.

**Implemented boundary:** [`NoteRemoteDataSource`](../lib/core/data/note_data_sources.dart)
and [`ApiService`](../lib/core/api/api_service.dart). The service is simulated,
so Dio/Retrofit/token handling are documented production extensions.

---

# 11. HTTP Status Codes

**Memory groups:** `2xx success, 4xx client/request, 5xx server/upstream`.

## Status Table

| Code | Meaning | Typical client action |
| --- | --- | --- |
| 200 | OK | Parse successful response |
| 201 | Created | Parse created resource/location |
| 202 | Accepted, processing later | Show pending/poll/status tracking |
| 400 | Bad Request | Correct malformed request |
| 401 | Unauthenticated/invalid credentials | Refresh token or login |
| 403 | Authenticated but forbidden | Explain lack of permission |
| 404 | Resource not found | Empty/not-found state |
| 408 | Request timeout | Retry idempotent request |
| 409 | Conflict | Resolve version/duplicate conflict |
| 422 | Semantically invalid input | Show field validation errors |
| 429 | Rate limited | Respect `Retry-After`, back off |
| 500 | Internal server error | Generic error, retry cautiously |
| 501 | Not implemented | Client/server contract mismatch |
| 502 | Bad gateway | Temporary upstream failure |
| 503 | Service unavailable | Maintenance/overload, retry later |
| 504 | Gateway timeout | Upstream timeout, retry cautiously |

### 200 vs 201 vs 202

- `200`: operation completed successfully.
- `201`: resource was created.
- `202`: request accepted but processing is not complete.

### 401 vs 403

`401` means valid authentication is missing. `403` means identity is known but
the action is not permitted.

### How should 400, 401, and 500 be handled?

- `400/422`: map server validation to fields/general message.
- `401`: refresh once or log out.
- `500`: do not blame user; show retry/support path and log correlation ID.

### User-friendly error handler

```dart
String messageForStatus(int? status) {
  return switch (status) {
    400 || 422 => 'Please check the entered information.',
    401 => 'Your session expired. Please sign in again.',
    403 => 'You do not have permission for this action.',
    404 => 'The requested item was not found.',
    408 || 504 => 'The request timed out. Please retry.',
    409 => 'This change conflicts with newer data.',
    429 => 'Too many requests. Please wait and retry.',
    >= 500 => 'The service is temporarily unavailable.',
    _ => 'Something went wrong. Please try again.',
  };
}
```

Do not decide success only from status code if the API contract also defines
business errors in the body.

---

# 12. Security, SSL Pinning, And Encryption

**Memory line:** `TLS protects transit; encryption protects data; authn identifies; authz permits.`

## Questions And Answers

### 1-2. What are SSL and an SSL certificate?

The modern protocol is TLS, though “SSL” is commonly used informally. TLS
encrypts and authenticates network connections. A server certificate binds a
public key to an identity through a trusted certificate authority.

### 3-5. What is SSL pinning and how does it prevent MITM?

Pinning makes the app accept only an expected certificate/public key in
addition to normal trust validation. A malicious certificate trusted by the OS
is rejected if it does not match the pin.

### 6-9. Types of pinning

| Type | Pins | Tradeoff |
| --- | --- | --- |
| Certificate pinning | Whole certificate/its hash | Breaks when certificate changes |
| Public-key/SPKI pinning | Public key hash | Easier certificate renewal with same key |
| Hash pinning | Hash of certificate or key | Compact representation, same rotation concern |

### 10-11. Which is preferred in fintech and why?

There is no universal “best.” Many high-security apps prefer public-key/SPKI
pins with backup pins because certificate renewal is easier, but the correct
choice depends on threat model, compliance, backend control, and rotation
strategy. Pinning reduces some MITM risk but does not replace secure server
authorization.

### 12-13. Risks and rotation

Risks include outages after certificate/key rotation, recovery difficulty,
proxies in enterprise environments, and bypass on compromised devices. Ship
primary and backup pins, monitor expiry, overlap rotations, and keep an
emergency update strategy.

### 14-18. Encryption, AES, symmetric encryption, and keys

Encryption transforms plaintext using a key. AES is a standardized symmetric
block cipher; the same secret key is used for encryption and decryption. Use an
authenticated mode such as AES-GCM, not raw AES/ECB.

### 19-20. AES-128 vs AES-256

They use 128-bit and 256-bit keys. Both are strong when implemented correctly;
AES-256 offers a larger security margin at small possible performance cost.

### 21. AES example

Conceptual example using an authenticated cryptography library:

```dart
final algorithm = AesGcm.with256bits();
final secretKey = await algorithm.newSecretKey();
final nonce = algorithm.newNonce();

final box = await algorithm.encrypt(
  utf8.encode('sensitive value'),
  secretKey: secretKey,
  nonce: nonce,
);
```

Store nonce, ciphertext, and authentication tag; never invent cryptographic
algorithms.

### 22-23. Where should keys be stored?

Do not hardcode keys: application binaries can be inspected. Use platform
secure hardware-backed storage where possible, backend key management, key
wrapping, and short-lived server-delivered material based on the threat model.

### 24-26. Authentication vs authorization

| Authentication | Authorization |
| --- | --- |
| Who are you? | What may you do? |
| Login, token validation, biometrics | Roles, scopes, ownership, policy |
| Happens first | Evaluated after identity is known |

**Status:** Documented production extension. This sample contains no secrets,
payments, or authentication.

---

# 13. SQLite Database

**Memory line:** `Open -> version -> create/migrate -> CRUD -> close when truly finished.`

## Questions And Answers

### 1-3. What is SQLite, why use it, and which package?

SQLite is an embedded relational database stored in a local file. Use it for
structured, queryable, offline data and relationships. `sqflite` is a common
Flutter plugin.

### 4-6. Implementation steps, database, and table creation

```text
1. Add sqflite and path
2. Resolve database path
3. openDatabase with version
4. Create tables in onCreate
5. Add onUpgrade migrations
6. Expose parameterized CRUD methods
```

```dart
final db = await openDatabase(
  join(await getDatabasesPath(), 'app.db'),
  version: 1,
  onCreate: (db, version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
      )
    ''');
  },
);
```

### 7-11. CRUD operations

```dart
await db.insert('notes', {'title': 'Learn SQLite'});

final rows = await db.query(
  'notes',
  where: 'id = ?',
  whereArgs: [id],
);

await db.update(
  'notes',
  {'title': 'Updated'},
  where: 'id = ?',
  whereArgs: [id],
);

await db.delete('notes', where: 'id = ?', whereArgs: [id]);
```

CRUD means Create, Read, Update, Delete.

### 12. Database migration

Increase the version and apply ordered schema changes in `onUpgrade`.

```dart
onUpgrade: (db, oldVersion, newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE notes ADD COLUMN created_at TEXT');
  }
},
```

Test migration from every supported old version and use transactions for
multi-step changes.

### 13. How do you close the database?

Call `db.close()` when the application/database service is permanently done.
For a process-wide singleton mobile database, repeatedly closing it during
screen disposal is usually incorrect.

### 14-15. SQLite vs SharedPreferences

| SQLite | SharedPreferences |
| --- | --- |
| Structured rows, queries, relations | Small primitive key-value settings |
| Notes, offline records, cache indexes | Theme, onboarding flag, simple preference |
| Transactions and migrations | No relational querying |

Do not store secrets in plain preferences.

**Implemented:** [`AppDatabase`](../lib/core/database/app_database.dart) and
repository-driven [SQLite CRUD flow](../lib/core/repository/note_repository_impl.dart).
Migration is a documented next extension because the current schema is version 1.

---

# 14. Futures, Streams, And Async Programming

**Memory line:** `Future = one result; Stream = many results; await = readable suspension.`

## Questions And Answers

### 1-3. Future, Stream, and difference

| Future | Stream |
| --- | --- |
| One value or error | Zero or more values/errors |
| API response, file read | Sensor, socket, database watch |
| Await once | Listen over time |

### 4-6. async, await, async function

`async` makes a function return a `Future` and permits `await`. `await`
suspends that async function until completion without blocking the isolate's
event loop.

```dart
Future<User> loadUser() async {
  final response = await api.fetchUser();
  return User.fromJson(response);
}
```

### 7-10. FutureBuilder and StreamBuilder

`FutureBuilder` renders snapshots from one future. `StreamBuilder` renders
snapshots from multiple stream events. Use them for widget-owned async work;
use a state manager for shared workflows, caching, and business logic.

### 11. Future example

```dart
Future<String> loadTitle() async {
  await Future<void>.delayed(const Duration(milliseconds: 200));
  return 'Loaded';
}
```

### 12. Stream example

```dart
Stream<int> ticks() async* {
  for (var value = 1; value <= 3; value++) {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield value;
  }
}
```

### 13-15. RxDart and BehaviorSubject

RxDart adds reactive stream operators and subjects to Dart streams.
`BehaviorSubject` stores/emits the latest value to new listeners. Use it when
stream composition requires operators such as debounce or combineLatest, not
as a default replacement for every state tool.

### 16. Keep registration data with RxDart

Own a form-state `BehaviorSubject` in a flow-scoped controller/service, update
it on field changes, expose a stream, and clear it only after completion or
explicit cancellation.

### 17-18. Dispose streams and what happens if not

Cancel subscriptions and close owned controllers/subjects. Otherwise callbacks,
resources, and object references can remain alive, causing memory leaks,
duplicate events, or “add after close/disposed widget” errors.

**Demonstrated:** [FutureBuilder, StreamBuilder, cached Future, and stream disposal](../lib/interview_examples/view/interview_concepts_page.dart).

---

# 15. Callbacks And Listeners

**Memory line:** `VoidCallback sends a signal; ValueChanged<T> sends a value.`

## Questions And Answers

### 1-4. What is VoidCallback and why use it?

`VoidCallback` is `void Function()`. It lets a child notify a parent without
knowing the parent's implementation.

```dart
class SaveButton extends StatelessWidget {
  final VoidCallback onSave;

  const SaveButton({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return FilledButton(onPressed: onSave, child: const Text('Save'));
  }
}
```

### 5-6. What is ValueChanged<T>?

It is `void Function(T value)`, used when the callback must provide a new value.

```dart
DropdownButton<String>(
  value: selected,
  onChanged: (value) {
    if (value != null) onCountryChanged(value);
  },
  items: items,
);
```

### 7-8. ValueNotifier and ValueListenableBuilder

`ValueNotifier<T>` stores one value and notifies listeners when it changes.
`ValueListenableBuilder` rebuilds only its builder subtree.

### 9. ValueNotifier vs setState

| ValueNotifier | setState |
| --- | --- |
| Observable value can be passed/shared | State stays inside one `State` object |
| Builder can target small subtree | Rebuilds the state's widget subtree |
| Must dispose when owned | No separate notifier disposal |

### 10-11. How does it update UI and example?

Assigning a different value calls listeners; the builder receives the new value.

```dart
final count = ValueNotifier<int>(0);

ValueListenableBuilder<int>(
  valueListenable: count,
  builder: (_, value, __) => Text('$value'),
);
```

### 12-14. Event listener, button clicks, text-field listeners

Flutter receives pointer/keyboard/platform events and invokes registered
callbacks. A button calls `onPressed`. For text, use `onChanged` or a
`TextEditingController` listener; remove/dispose owned listeners/controllers.

**Implemented:** [`AppButton` callback](../lib/core/widgets/app_button.dart) and
[`ValueNotifier` example](../lib/interview_examples/view/interview_concepts_page.dart).

---

# 16. App Store And Play Store Country Availability

**Memory line:** `Store restriction controls discovery/download; app restriction controls runtime features.`

## Questions And Answers

### 1-3. How do you restrict countries?

- Google Play Console: configure production or testing track
  **Countries/regions**.
- App Store Connect: configure app availability for selected countries or
  regions.

Store interfaces change, so confirm the latest console steps before release.

### 4. Can users from other countries install?

New store discovery/download is restricted according to store-account region
rules, not simply current GPS location. Existing installs and travelers may
still retain/use the app, and internal/testing distribution can follow
different rules.

### 5. Country-based rollout

Use store country targeting, staged/phased rollout, monitoring, remote config,
backend allowlists, localization, legal review, and rollback plans.

### 6. Country-based feature restriction inside the app

The backend should return eligibility based on authoritative account/regulatory
data. Remote Config can control UX, but sensitive authorization must be
server-enforced.

### 7. Store-level vs app-level restriction

| Store level | App/backend level |
| --- | --- |
| Controls listing/download eligibility | Controls behavior after install |
| Account/store region based | Business/account/regulatory rules |
| Cannot fully protect an API | Backend authorization can enforce access |

### 8. How do you test?

Use closed/internal tracks, test accounts with target regions, TestFlight,
backend test fixtures, remote-config conditions, VPN only as a secondary check,
and verify store rules rather than assuming IP equals country.

**Status:** Documented deployment topic.

---

# 17. Payment Gateway Integration

**Memory flow:** `Backend creates order -> app opens SDK -> backend verifies -> app displays status.`

## Questions And Answers

### 1-3. How do you integrate a payment gateway?

```text
1. App asks backend to create payment/order
2. Backend uses secret credential and returns public checkout data
3. App opens gateway SDK/UI
4. Gateway returns success/failure/cancel signal
5. App sends payment reference to backend
6. Backend verifies signature/status with gateway
7. Backend records final idempotent result
8. App reads and displays backend-confirmed status
```

Name only gateways you have genuinely used. Otherwise say which SDK flow you
understand and that provider-specific APIs differ.

### 4-5. Why backend order creation and no secret key in Flutter?

Mobile binaries are untrusted and inspectable. Secret keys on the client allow
attackers to create/refund/modify transactions. Backend ownership enforces
amount, currency, user, inventory, and authorization.

### 6-8. Success, failure, and backend verification

Treat client callbacks as UX signals, not final truth. Show processing, ask the
backend for verified status, and handle delayed webhooks. Failure should remain
retryable where safe.

### 9. What is signature verification?

The backend recomputes/verifies a cryptographic signature using the provider
secret/public key to prove that payment data came from the gateway and was not
modified.

### 10-11. Cancellation and status UI

Cancellation is not necessarily failure; no charge may have occurred. Model
states such as `created`, `processing`, `paid`, `failed`, `cancelled`,
`refunded`, and `unknown`.

### 12. Secure payment flow

TLS, backend secrets, signature verification, webhook validation, amount checks,
idempotency keys, minimal PCI scope, secure logging, and no trust in client
amount/status.

### 13. Testing

Use gateway sandbox, test cards/accounts, success/failure/cancel/timeout cases,
duplicate callbacks, webhook replay, network loss after payment, and backend
contract/integration tests.

### 14. Common errors

Invalid order, expired session, declined payment, insufficient funds, SDK
configuration, user cancellation, timeout, signature mismatch, duplicate
request, and webhook delay.

### 15. Duplicate payment requests

Generate a server-side idempotency key/order ID, enforce uniqueness, disable
duplicate taps for UX, and return the existing result for repeated requests.

**Status:** Documented production extension. No payment SDK is added.

---

# 18. Push Notifications

**Memory flow:** `Permission -> token -> backend -> FCM/APNs -> handler -> route.`

## Questions And Answers

### 1-4. What are push notifications, FCM, and integration steps?

Push notifications are server-originated messages delivered through platform
services. Firebase Cloud Messaging (FCM) provides cross-platform messaging and
uses APNs for Apple delivery.

```text
Configure Firebase/platform files
 -> request permission
 -> obtain token
 -> send token to authenticated backend
 -> handle foreground/background/terminated messages
 -> route from payload safely
```

### 5-6. Get token and send to backend

Call the messaging SDK for the registration token, listen for token refresh,
and associate it with the authenticated user/device on the backend. Remove
stale tokens on logout or delivery feedback.

### 7. Foreground notifications

The app receives a callback. Decide whether to update UI directly or show a
local notification; system notification banners may not appear automatically
in the foreground.

### 8. Background notifications

Use the platform-supported background handler. Keep it top-level where
required, initialize only necessary services, and finish quickly.

### 9. Terminated-state notifications

Read the initial notification/message when the app launches and route after
startup/navigation is ready.

### 10. Navigate after tap

Parse a validated route/entity ID from payload, authenticate/authorize, then
navigate through the router. Do not trust arbitrary URLs or actions.

### 11. Permissions

Request at a contextually appropriate time, explain value first, handle denied
and permanently denied states, and provide settings guidance.

### 12-13. Android and iOS configuration

- Android: Firebase configuration, manifest/service setup, notification
  channel, Android 13+ permission, icons.
- iOS: Firebase config, push capability, background modes if required, APNs key
  or certificate, notification permission.

### 14. What is APNs?

Apple Push Notification service is Apple's delivery service for Apple devices.
FCM forwards Apple-targeted messages through APNs.

### 15. Notification message vs data message

| Notification payload | Data payload |
| --- | --- |
| SDK/OS can display automatically in background | App controls processing |
| Convenient display | Flexible routing/silent update |
| Behavior varies by app state/platform | Subject to background restrictions |

**Status:** Documented production extension. No Firebase dependency is added.

---

# 19. App Performance

**Memory line:** `Measure first; optimize build, layout, paint, raster, memory, and I/O.`

## Questions And Answers

### 1-3. How do you measure performance and which tools?

Use profile mode on a representative physical device. Flutter DevTools provides
performance timelines, CPU profiler, memory view, network view, inspector, and
app-size tooling. Also use platform profilers and production monitoring.

### 4. What is frame rendering time?

It is the time to produce a frame. At 60 Hz the budget is about 16.7 ms; at
120 Hz it is about 8.3 ms. Missing the budget causes visible jank.

### 5. What causes jank?

Expensive synchronous work on the UI isolate, large rebuild/layout/paint areas,
shader/image work, excessive allocations/GC, complex clipping/opacity, and
blocking platform operations.

### 6. Reduce unnecessary rebuilds

Keep state close to consumers, split widgets, use `const`, selectors/buildWhen,
`ValueListenableBuilder`, `Consumer`, or `Obx` narrowly, and avoid watching
state above a large tree.

### 7-8. Optimize large lists and why ListView.builder?

Use lazy builders, stable keys, pagination, fixed/prototype extent where valid,
cached thumbnails, and avoid expensive work per item. `ListView.builder`
creates visible items on demand instead of all children at once.

### 9. How does const help?

A const widget is canonical/immutable and can be reused when configuration is
unchanged. It reduces object recreation and helps Flutter skip some update
work, but it does not magically stop every ancestor rebuild.

### 10. Optimize images

Request/display correct dimensions, compress assets, use modern formats where
supported, set cache dimensions, paginate galleries, preload selectively, and
avoid decoding huge images for tiny views.

### 11. Reduce startup time

Delay noncritical initialization, minimize synchronous work before `runApp`,
lazy-load services/features, reduce plugin/dependency overhead, optimize first
screen assets, and measure cold/warm startup separately.

### 12. Identify memory leaks

Use DevTools memory snapshots and allocation tracking. Check undisposed
controllers/subscriptions/timers, retained contexts, image caches, and growing
collections.

### 13. Improve API performance

Parallelize independent calls, paginate, cache with expiry, compress payloads,
avoid duplicate requests, debounce search, cancel stale calls, use ETags where
supported, and measure backend/network latency.

### 14. Cache data

Choose memory cache for speed, local database/files for persistence, and define
expiry/invalidation/source-of-truth rules. Cache is a consistency decision, not
only a storage decision.

### 15. Improve complex-screen build performance

Profile the exact frame, split state ownership, use lazy layout, avoid intrinsic
measurement in hot paths, isolate repaint regions when useful, reduce nested
scroll complexity, and move CPU-heavy work to an isolate.

**Demonstrated:** targeted builders and responsive layout in the
[concepts screen](../lib/interview_examples/view/interview_concepts_page.dart),
plus parallel data loading with
[`Future.wait`](../lib/core/repository/note_repository_impl.dart).

---

# 20. Main Function And App Startup

**Memory line:** `main initializes; runApp mounts the root widget.`

## Questions And Answers

### 1. What is main?

`main()` is the Dart entry function for the application isolate.

### 2. What is runApp?

`runApp(rootWidget)` attaches the root widget to Flutter's rendering pipeline
and schedules the UI.

### 3. main vs runApp

`main` is a Dart function and can perform setup. `runApp` is the Flutter call
that starts the widget tree.

### 4. Can main be async?

Yes.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeServices();
  runApp(const App());
}
```

Keep pre-UI work minimal to protect startup time.

### 5. Why WidgetsFlutterBinding.ensureInitialized?

It initializes the Flutter binding before using plugin/channel/framework
services prior to `runApp`.

### 6. What happens before runApp?

The Dart isolate starts, imports/static initialization occur, `main` executes,
and any awaited startup setup completes.

### 7. What is the first widget?

The widget passed to `runApp`, such as `ProviderScope`, `MaterialApp`, or a
custom root.

### 8. Initialize Firebase before startup

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}
```

**Implemented:** [`main`](../lib/main.dart) starts with `ProviderScope` and
`MainMenuApp`.

---

# 21. MCP Server, AI Agent, And Agentic AI

**Memory line:** `MCP standardizes tool/data connection; an agent decides and acts through tools.`

## Questions And Answers

### 1-2. What is an MCP server and what problem does it solve?

The Model Context Protocol (MCP) is an open protocol for connecting AI
applications to external tools and context. An MCP server exposes capabilities
such as tools, resources, and prompts through a standard interface, reducing
custom one-off integrations.

### 3. MCP usage example

An IDE assistant connects to a GitHub MCP server to read issues and create a
pull request, or to a database MCP server to inspect schema through controlled
tools.

### 4. How can MCP help app development?

It can give development agents standardized access to design files, repository
issues, documentation, test systems, logs, or internal APIs with explicit
permissions.

### 5. What is an AI agent?

An AI agent is a system that receives a goal, reasons/plans within constraints,
uses tools, observes results, and continues until it produces an outcome or
needs human input.

### 6-7. What is Agentic AI and how is it different?

“Agentic AI” describes systems/behavior with autonomy, planning, tool use,
memory, and multi-step execution. An “AI agent” is a concrete component or
application exhibiting some of those properties. The terms overlap and are not
strictly standardized.

### 8. AI agent example

A support agent reads an order through an approved tool, checks refund policy,
asks for confirmation, submits a refund, and records the result.

### 9. Integrating an agent with Flutter

```text
Flutter UI
 -> authenticated backend
 -> agent runtime/model
 -> approved server-side tools
 -> streamed status/result
 -> Flutter renders progress and asks confirmation for risky actions
```

Keep privileged tools and model credentials on the backend, not in the app.

### 10. Chatbot vs agent

| Chatbot | Agent |
| --- | --- |
| Primarily responds with text | Can plan and execute actions |
| Often one request/response | Multi-step tool loop |
| Limited external effects | May change external systems |

### 11. How does an agent call tools?

The model selects a tool with structured arguments, the host validates policy
and executes it, the result returns to the model, and the loop continues. MCP
is one standard way to expose tools/context; provider-specific function calling
is another.

### 12. Safety concerns

Prompt injection, excessive permissions, secret leakage, unsafe tool arguments,
untrusted tool output, hallucinated actions, privacy, cost loops, and missing
human approval. Use least privilege, allowlists, schema validation, sandboxing,
audit logs, rate limits, confirmations, and output sanitization.

**Status:** Documented. This Flutter sample does not connect to an AI backend.

---

# 22. Practical Scenario-Based Answers

Use **S-A-R** for experience questions:

```text
Situation -> Action -> Result
```

Do not claim technologies you have not used. Replace “I implemented” with “I
would implement” when describing a design rather than real experience.

## 1. How did you implement API integration?

“I kept HTTP behind a remote data-source interface. The repository mapped
transport data into application models, and the state manager exposed loading,
data, and failure. This prevented widgets from depending on the client.”

Project reference:
[`NoteRemoteDataSource`](../lib/core/data/note_data_sources.dart).

## 2. How did you update UI after an API response?

“The state manager awaited the repository, then emitted/assigned a new immutable
state. BLoC rebuilt through `BlocBuilder`, GetX notified `Obx`, and Riverpod
updated `AsyncValue` watched by the consumer.”

## 3. How did you manage token expiry?

“A Dio interceptor detected 401, entered one synchronized refresh operation,
queued/retried eligible requests once, and logged out if refresh failed.”

## 4. How did you handle session timeout?

“I treated server expiry as authoritative, cleared secure credentials and
protected state, cancelled sensitive work, and routed to login with a clear
message.”

## 5. How did you store login data securely?

“I stored short-lived tokens in platform secure storage, kept non-sensitive
profile/cache data separately, avoided secrets in source/preferences/logs, and
relied on backend authorization.”

## 6. How did you keep registration form data when navigating back?

“I moved draft form state into a flow-scoped notifier/provider above the pages,
restored controllers from that state, and cleared it after completion or
explicit cancellation.”

## 7. How did you handle internet errors?

“I mapped socket/timeout failures to a network failure, preserved cached data
where possible, showed an offline/retry state, and retried only safe operations.”

## 8. How did you handle server errors?

“I separated validation, authorization, rate-limit, and 5xx failures; logged
technical context with a correlation ID and showed user-safe actionable text.”

## 9. How did you implement payments?

“The backend created the order and owned secret keys. The app opened the
provider SDK, then displayed only the status verified by backend signature/API
or webhook processing.”

## 10. How did you implement push notifications?

“I requested permission contextually, registered/refreshed the FCM token with
the backend, handled foreground/background/terminated states, and validated the
payload before deep-link navigation.”

## 11. How did you improve performance?

“I measured in profile mode, identified the expensive frame in DevTools, then
reduced rebuild scope/lazy-loaded lists/optimized images or moved CPU work off
the UI isolate. I compared metrics before and after.”

## 12-13. How did you manage app lifecycle/background/foreground?

“I used `WidgetsBindingObserver` for lifecycle transitions, paused/resumed
appropriate resources, refreshed stale data on resume, and never assumed
background execution is unlimited.”

Project reference:
[lifecycle demonstration](../lib/interview_examples/view/interview_concepts_page.dart).

## 14-15. How did you secure API communication and use SSL pinning?

“I used TLS, secure token storage, backend authorization, safe logs, timeout and
certificate validation. Where the threat model justified pinning, I used
maintained certificate/public-key pinning with backup pins and a rotation plan.”

## 16. How did you manage local database CRUD?

“Widgets called the state manager, which called a repository. The repository
used parameterized SQLite methods and returned typed models. SQL never lived in
the UI.”

Project reference:
[`AppDatabase`](../lib/core/database/app_database.dart).

## 17. How did you structure the project?

“I separated shared model/data/repository/widgets from package-specific
presentation. All state managers depend on one repository contract, making the
comparison fair and tests deterministic.”

## 18. How did you use Clean Architecture?

For this repository, answer accurately:

“This sample is layered and MVVM-inspired with dependency inversion; it is not
full Clean Architecture because it intentionally omits use-case classes and
separate domain/DTO models. In a larger app I would add those only when business
complexity justifies them.”

## 19. How did you test API and state-management logic?

“I replaced the repository with an in-memory fake, triggered events/methods, and
verified loading/data/error. Widget tests verify UI interaction, while an
integration test verifies the BLoC-to-SQLite flow on a device.”

Project reference: [testing guide](../test/README.md).

## 20. How did you handle dev, staging, and production?

“I used build flavors/schemes and typed environment configuration for API URL,
logging, app IDs, and service files. Secrets remained in CI/backend secret
management, not Dart constants. CI built and tested each relevant environment.”

---

# Rapid Revision Tables

## State Management

| Question | BLoC | GetX | Riverpod |
| --- | --- | --- | --- |
| Input | Event | Controller method | Notifier method |
| State | Immutable state object | Rx values | State / AsyncValue |
| UI subscription | BlocBuilder | Obx | ref.watch |
| Side effects | BlocListener | Worker/controller/UI callback | ref.listen |
| DI | Constructor/RepositoryProvider | Get.put/Get.find | Provider graph |
| Test strategy | Add event, expect states | Call method, inspect Rx | Override provider in container |

## Async

| Concept | Remember |
| --- | --- |
| Future | One result |
| Stream | Many results |
| async | Function returns Future |
| await | Suspend function, not isolate |
| FutureBuilder | Future snapshot to UI |
| StreamBuilder | Stream snapshots to UI |

## Architecture

| Concept | Responsibility |
| --- | --- |
| View | Render and collect user input |
| State manager | UI state and workflow coordination |
| Use case | One business action |
| Repository | Data-access abstraction |
| Data source | HTTP, database, platform implementation |
| DTO | Transport/storage shape |
| Entity | Business meaning and rules |

## Security

| Concept | Remember |
| --- | --- |
| Authentication | Who are you? |
| Authorization | What may you do? |
| TLS | Protect data in transit |
| Encryption | Protect data with a key |
| Hashing | One-way digest |
| Pinning | Restrict accepted server certificate/key |

---

# Official References

- [Flutter platform channels](https://docs.flutter.dev/platform-integration/platform-channels)
- [Flutter architectural overview](https://docs.flutter.dev/resources/architectural-overview)
- [Flutter application architecture](https://docs.flutter.dev/app-architecture/guide)
- [Flutter testing overview](https://docs.flutter.dev/testing/overview)
- [Flutter performance best practices](https://docs.flutter.dev/perf/best-practices)
- [Riverpod refs: watch, read, listen](https://riverpod.dev/docs/concepts2/refs)
- [Flutter BLoC concepts](https://bloclibrary.dev/flutter-bloc-concepts/)
- [Dio package documentation](https://pub.dev/packages/dio)
- [Freezed package documentation](https://pub.dev/packages/freezed)
- [sqflite package documentation](https://pub.dev/packages/sqflite)
- [Firebase Cloud Messaging for Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages)
- [Google Play country targeting](https://support.google.com/googleplay/android-developer/answer/7550024)
- [Model Context Protocol introduction](https://modelcontextprotocol.io/docs/getting-started/intro)

Return to the [root project guide](../README.md).
