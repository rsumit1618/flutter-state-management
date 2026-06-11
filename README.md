# Flutter State Management Interview Lab

This project demonstrates the same Notes feature with **BLoC, GetX, and
Riverpod**. Its primary purpose is to show:

- How each state-management package is implemented
- How their state flow and dependency management differ
- How to choose between them in an interview or production project
- How state-management logic is unit tested
- How Flutter widgets and complete user flows are tested

## Complete Interview Question Bank

Start here for the rewritten, easy-to-remember interview answers:

### [Open Flutter Interview Questions: Easy Answers](docs/flutter_interview_master_qa.md)

The guide contains your **50 priority questions first**, followed by the
**Top 100 additional Flutter interview questions**.

Each section follows this structure:

```text
Memory line -> Questions and answers -> Flow -> Comparison -> Code example
```

## Interview Questions And Answers

### 1. Why does Flutter need state management?

Flutter rebuilds UI from state. Local state such as a selected tab can stay in
one widget, but shared or asynchronous business state needs a predictable owner.
State-management packages help separate rendering from loading, validation,
errors, persistence, and business workflows.

**Project examples:**

- Local state: [`ValueNotifier` concepts example](lib/interview_examples/view/interview_concepts_page.dart)
- Application state: [BLoC](lib/bloc_example/viewmodel/note_bloc.dart),
  [GetX](lib/getx_example/viewmodel/getx_note_controller.dart), and
  [Riverpod](lib/riverpod_example/viewmodel/riverpod_note_view_model.dart)

### 2. What is the difference between BLoC, GetX, and Riverpod?

| Package | State flow | Dependency management | Async/error state | Main tradeoff |
| --- | --- | --- | --- | --- |
| BLoC | View sends events; BLoC emits immutable states | Constructor injection and `BlocProvider` | Explicit fields/events/states | Very predictable, but most boilerplate |
| GetX | View calls controller; `Rx` values notify `Obx` | `Get.put` and `Get.find` | Reactive loading/error fields | Fast and concise, but dependencies can become hidden/global |
| Riverpod | View watches provider; notifier changes state | Provider graph and overrides | `AsyncValue` loading/data/error | Strong DI and async modeling, but requires provider conventions |

**Project implementations:**

- [BLoC event/state implementation](lib/bloc_example/viewmodel/)
- [GetX reactive controller](lib/getx_example/viewmodel/getx_note_controller.dart)
- [Riverpod `AsyncNotifier`](lib/riverpod_example/viewmodel/riverpod_note_view_model.dart)

### 3. Which state-management package is best?

There is no universal best package.

- Choose **BLoC** when explicit workflows, auditability, testing, and strict team
  conventions matter.
- Choose **GetX** for fast delivery when the team actively controls dependency
  scope and controller size.
- Choose **Riverpod** when provider-based dependency injection, composability,
  overrides, and asynchronous state are priorities.

A good interview answer connects the choice to team size, feature complexity,
existing architecture, testing needs, and maintenance cost.

### 4. How does the same feature flow through each package?

```text
BLoC
Tap -> Event -> NoteBloc -> NoteRepository -> State -> BlocBuilder

GetX
Tap -> Controller method -> NoteRepository -> Rx values -> Obx

Riverpod
Tap -> AsyncNotifier method -> NoteRepository -> AsyncValue -> ref.watch
```

The views are available in:

- [BLoC views](lib/bloc_example/view/)
- [GetX views](lib/getx_example/view/)
- [Riverpod views](lib/riverpod_example/view/)

### 5. How is dependency injection implemented?

All three implementations depend on the
[`NoteRepository` abstraction](lib/core/repository/note_repository.dart), not
directly on SQLite.

- BLoC receives the repository through its constructor.
- GetX receives it through the controller constructor; the controller is scoped
  with `Get.put` and deleted when the feature page is disposed.
- Riverpod creates it through a provider that tests can override.

The concrete implementation is
[`NoteRepositoryImpl`](lib/core/repository/note_repository_impl.dart).

### 6. Why use the repository pattern?

The repository hides whether data comes from SQLite, HTTP, cache, or another
source. It also makes the state managers testable with an in-memory fake.

```text
State manager -> NoteRepository -> local/remote data sources
```

See:

- [Repository contract](lib/core/repository/note_repository.dart)
- [Repository implementation](lib/core/repository/note_repository_impl.dart)
- [Data-source contracts](lib/core/data/note_data_sources.dart)
- [Fake repository used by tests](test/helpers/fake_note_repository.dart)

### 7. How are loading, data, and error states represented?

- BLoC uses an immutable [`NoteState`](lib/bloc_example/viewmodel/note_state.dart).
- GetX uses `RxBool`, `RxList`, and `RxnString` in its
  [controller](lib/getx_example/viewmodel/getx_note_controller.dart).
- Riverpod uses `AsyncValue<NotesSnapshot>` through an
  [`AsyncNotifier`](lib/riverpod_example/viewmodel/riverpod_note_view_model.dart).

This is a common interview comparison because it exposes the mental model and
boilerplate of each package.

### 8. How is state-management code tested?

State managers receive a fake repository, then tests trigger a public event or
method and verify the resulting state.

- [BLoC unit tests](test/bloc/note_bloc_test.dart)
- [GetX unit tests](test/getx/getx_note_controller_test.dart)
- [Riverpod unit tests](test/riverpod/riverpod_note_view_model_test.dart)

Read the complete [Testing Guide](test/README.md) for clear unit, widget, and
integration test definitions and examples.

### 9. What is the difference between unit, widget, and integration tests?

- **Unit test:** verifies one model, repository, BLoC, controller, or notifier in
  isolation.
- **Widget test:** renders widgets in Flutter's test runtime and verifies UI
  interaction.
- **Integration test:** runs a complete user flow with plugins on a device or
  emulator.

See the [Testing Guide](test/README.md) and
[BLoC SQLite integration flow](integration_test/app_flow_test.dart).

### 10. Is this Clean Architecture, MVVM, or DDD?

This is a **layered, MVVM-inspired architecture with dependency inversion**.
It is not full Domain-Driven Design because it does not define aggregates,
bounded contexts, value objects, or domain services.

```text
View
  |
  v
Bloc / GetX Controller / Riverpod AsyncNotifier
  |
  v
NoteRepository contract
  |
  v
NoteRepositoryImpl
  |
  +--> AppDatabase (SQLite)
  `--> ApiService (simulated remote source)
```

### 11. What is the difference between local and application state?

Local or ephemeral state is owned by a small widget subtree, such as an
animation, counter, text-field visibility, or selected tab. Application state
is shared, persistent, asynchronous, or governed by business rules.

The [interview concepts screen](lib/interview_examples/view/interview_concepts_page.dart)
uses `ValueNotifier` for local state. Notes use BLoC, GetX, or Riverpod.

### 12. What are Future, Stream, and async/await?

A `Future` completes once. A `Stream` emits zero or more events. `async/await`
does not automatically create a new thread; it makes asynchronous code easier
to compose without blocking while waiting for I/O.

Examples:

- [`FutureBuilder` and `StreamBuilder`](lib/interview_examples/view/interview_concepts_page.dart)
- Parallel local/remote loading with
  [`Future.wait`](lib/core/repository/note_repository_impl.dart)

### 13. What lifecycle questions can an interviewer ask?

Typical questions include:

- What is the order of `initState`, `didChangeDependencies`, `build`,
  `didUpdateWidget`, and `dispose`?
- Why should a `Future` not be recreated on every `build`?
- Why must controllers, streams, and observers be disposed?
- What does `context.mounted` protect after an `await`?

The [concepts screen](lib/interview_examples/view/interview_concepts_page.dart)
registers `WidgetsBindingObserver`, caches a `Future` in `initState`, and
disposes a `ValueNotifier` and `StreamController`.

### 14. Why are keys important?

Keys preserve widget identity when siblings move and give tests stable finders.
This project uses keys such as `open_bloc_example`, `bloc_note_title_field`,
and `bloc_save_note_button` in the
[integration test](integration_test/app_flow_test.dart).

### 15. What SQLite questions are demonstrated?

The project demonstrates:

- A single shared database instance
- Parameterized `whereArgs`
- CRUD operations
- Mapping rows to typed models
- Separating SQL from widgets and state managers

See [`AppDatabase`](lib/core/database/app_database.dart).

For production interviews, also prepare schema migrations, indexes,
transactions, encryption, and offline synchronization. Those are discussed in
the [easy-answer interview guide](docs/flutter_interview_master_qa.md#a31-what-is-caching-and-offline-support) but are not all
implemented in this small sample.

## More Questions An Interviewer Can Ask

| Interview question | Answer/example in this project |
| --- | --- |
| What are Widget, Element, and RenderObject? | [Easy answer](docs/flutter_interview_master_qa.md#a38-widget-tree-vs-element-tree-vs-renderobject-tree) |
| How does `BuildContext` work? | [Easy answer](docs/flutter_interview_master_qa.md#b21-what-is-buildcontext) |
| How do provider overrides improve tests? | [Riverpod test](test/riverpod/riverpod_note_view_model_test.dart) |
| How do you handle mutation success and failure in BLoC? | [`BlocConsumer` form](lib/bloc_example/view/bloc_add_note_page.dart) |
| How should GetX controllers be scoped? | [GetX list page lifecycle](lib/getx_example/view/getx_notes_list_page.dart) |
| What does `autoDispose` do in Riverpod? | [Riverpod provider](lib/riverpod_example/viewmodel/riverpod_note_view_model.dart) |
| Why use immutable state? | [`NoteState`](lib/bloc_example/viewmodel/note_state.dart) and [`NoteModel`](lib/core/models/note_model.dart) |
| How do you avoid duplicate API calls from `build`? | [Cached future example](lib/interview_examples/view/interview_concepts_page.dart) |
| How do you build responsive Flutter UI? | [`LayoutBuilder` example](lib/interview_examples/view/interview_concepts_page.dart) |
| How do you test failure states? | [BLoC](test/bloc/note_bloc_test.dart), [GetX](test/getx/getx_note_controller_test.dart), [Riverpod](test/riverpod/riverpod_note_view_model_test.dart) |
| How would you add a real REST API? | Implement [`NoteRemoteDataSource`](lib/core/data/note_data_sources.dart) |
| How would you improve performance? | [Jank and performance answer](docs/flutter_interview_master_qa.md#b45-what-causes-flutter-jank) |
| What are isolates used for? | [Isolate answer](docs/flutter_interview_master_qa.md#a34-what-is-an-isolate) |
| What are platform channels? | [MethodChannel vs EventChannel](docs/flutter_interview_master_qa.md#a21-methodchannel-vs-eventchannel) |
| How do you secure tokens and secrets? | [Secure storage answer](docs/flutter_interview_master_qa.md#b87-what-is-secure-storage) |

## Project Structure

```text
lib/
|-- main.dart
|-- main_bloc.dart
|-- main_getx.dart
|-- main_riverpod.dart
|-- core/
|   |-- api/
|   |-- data/
|   |-- database/
|   |-- models/
|   |-- repository/
|   `-- widgets/
|-- bloc_example/
|-- getx_example/
|-- riverpod_example/
`-- interview_examples/

test/
|-- README.md
|-- bloc/
|-- core/
|-- getx/
|-- riverpod/
|-- helpers/
`-- widget_test.dart

integration_test/
`-- app_flow_test.dart
```

## Run The Project

```bash
flutter pub get
flutter run
```

Run one implementation:

```bash
flutter run -t lib/main_bloc.dart
flutter run -t lib/main_getx.dart
flutter run -t lib/main_riverpod.dart
```

## Run Tests

```bash
# Unit and widget tests
flutter test

# Integration test: requires an emulator or physical device
flutter test integration_test/app_flow_test.dart

# Static analysis
flutter analyze
```

The GitHub Actions workflow at
[`.github/workflows/flutter_ci.yml`](.github/workflows/flutter_ci.yml) runs
formatting, static analysis, unit/widget tests, and Android integration tests.

## Documentation

- [Complete Interview Master Q&A](docs/flutter_interview_master_qa.md)
- [Testing Guide: unit vs widget vs integration](test/README.md)
- [Official Flutter testing documentation](https://docs.flutter.dev/testing/overview)
- [Official Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide)
