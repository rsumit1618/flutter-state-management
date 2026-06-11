# Flutter Interview Guide

Reviewed on June 11, 2026.

Navigation:

- [Complete interview master Q&A](flutter_interview_master_qa.md)
- [Main state-management Q&A](../README.md#interview-questions-and-answers)
- [State-management package comparison](../README.md#2-what-is-the-difference-between-bloc-getx-and-riverpod)
- [Testing guide](../test/README.md)
- [Implemented interview examples](../lib/interview_examples/view/interview_concepts_page.dart)

There is no authoritative public list of current Capgemini Flutter interview
questions. Public candidate reports are incomplete and vary by country,
experience level, account, and client. Prepare for an enterprise mobile
interview rather than memorizing an unverified question bank.

The most useful focus areas are Dart, Flutter rendering and lifecycle, state
management, architecture, REST/JSON, persistence, testing, performance,
platform integration, Git, Agile delivery, and scenario-based debugging.

## 1. StatelessWidget vs StatefulWidget

`StatelessWidget` has no mutable state owned by the widget. `StatefulWidget`
creates a separate `State` object whose values can change across rebuilds.

Important lifecycle order:

```text
createState
initState
didChangeDependencies
build
didUpdateWidget (when configuration changes)
deactivate
dispose
```

Do not make API calls repeatedly inside `build`. Cache a `Future` in
`initState`, as demonstrated in
[`InterviewConceptsPage`](../lib/interview_examples/view/interview_concepts_page.dart).

## 2. What is BuildContext?

`BuildContext` identifies a widget's location in the element tree. Flutter uses
it to find inherited dependencies such as `Theme`, `MediaQuery`, providers,
and `Navigator`.

After an `await`, verify that the widget is still mounted before using its
context:

```dart
await repository.save();
if (!context.mounted) return;
Navigator.pop(context);
```

## 3. Why are keys important?

Keys help Flutter match old and new widgets when the tree changes.

- `ValueKey`: identity based on a value
- `ObjectKey`: identity based on an object
- `UniqueKey`: always unique
- `GlobalKey`: accesses state/context across the tree; use sparingly

This project also uses keys as stable selectors in widget and integration tests.
See the [integration flow](../integration_test/app_flow_test.dart).

## 4. Future vs Stream

A `Future` produces one completion or error. A `Stream` can produce multiple
events over time.

```dart
Future<User> loadUser() => api.getUser();
Stream<List<Message>> watchMessages() => database.messageStream();
```

Use `FutureBuilder` and `StreamBuilder` for small UI-bound operations. For
shared business state, keep asynchronous work in a controller, BLoC, notifier,
or view model.

Project example:
[`FutureBuilder` and `StreamBuilder`](../lib/interview_examples/view/interview_concepts_page.dart).

## 5. async/await and parallel work

`async` does not automatically create a background thread. It allows other
event-loop work to continue while waiting for asynchronous operations.

Independent futures can run together:

```dart
final results = await Future.wait([
  repository.loadLocalNotes(),
  repository.loadRemoteNotes(),
]);
```

Project example:
[`Future.wait` in the repository](../lib/core/repository/note_repository_impl.dart).

CPU-heavy work can block frames. Use `Isolate.run` or `compute` for expensive
parsing or computation. Isolates do not share mutable memory.

## 6. setState vs app state management

Use `setState`, `ValueNotifier`, or another local mechanism for short-lived
state owned by one widget. Use application state management when data is shared,
has business rules, survives navigation, or requires testable async workflows.

The concepts screen uses `ValueNotifier` for local state. The Notes features use
BLoC, GetX, or Riverpod for application state.

Project examples:
[BLoC](../lib/bloc_example/viewmodel/note_bloc.dart),
[GetX](../lib/getx_example/viewmodel/getx_note_controller.dart), and
[Riverpod](../lib/riverpod_example/viewmodel/riverpod_note_view_model.dart).

## 7. BLoC vs GetX vs Riverpod

A strong interview answer explains tradeoffs:

```text
BLoC:
Predictable event/state flow and strong team conventions, but more code.

GetX:
Fast reactive development and built-in dependency tools, but global lookup and
large controllers can hide dependencies.

Riverpod:
Strong dependency injection, provider overrides, and async modeling, but teams
need conventions for provider ownership and lifecycle.
```

Do not answer that one package is always best.

See the complete
[state-management comparison and implementation links](../README.md#2-what-is-the-difference-between-bloc-getx-and-riverpod).

## 8. Repository pattern

A repository hides data-source details from business/UI state.

```dart
abstract interface class NoteRepository {
  Future<NotesSnapshot> loadNotes();
  Future<void> addNote({
    required String title,
    required String description,
  });
}
```

Benefits:

- State managers do not know SQL or HTTP details
- Fakes can replace production dependencies in unit tests
- Data-source changes have a smaller blast radius
- Caching and offline strategies have one owner

Project example:
[`NoteRepository`](../lib/core/repository/note_repository.dart) and
[`NoteRepositoryImpl`](../lib/core/repository/note_repository_impl.dart).

## 9. SOLID in Flutter

- Single Responsibility: widgets render, repositories coordinate data
- Open/Closed: add implementations behind contracts
- Liskov Substitution: fakes can replace repository implementations
- Interface Segregation: keep contracts focused
- Dependency Inversion: state managers depend on `NoteRepository`

This project demonstrates these principles without claiming full DDD.

## 10. Riverpod AsyncValue

`AsyncValue<T>` represents loading, data, and error states without separate
nullable fields.

```dart
final notes = ref.watch(notesProvider);

return notes.when(
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => Text('$error'),
  data: (value) => NotesList(value),
);
```

Provider overrides make tests deterministic without changing production code.

Project example:
[Riverpod provider override unit test](../test/riverpod/riverpod_note_view_model_test.dart).

## 11. Error handling

Handle errors at the layer that can add useful context. Avoid empty catch
blocks. A production app may map low-level exceptions into typed failures:

```dart
sealed class AppFailure {
  const AppFailure();
}

final class NetworkFailure extends AppFailure {
  final String message;
  const NetworkFailure(this.message);
}
```

Also discuss retries, timeouts, offline state, logging, and user-safe messages.

## 12. Unit vs widget vs integration tests

- Unit: fast tests for a function, class, BLoC, controller, or notifier
- Widget: verifies rendering and interaction in Flutter's test environment
- Integration: verifies a complete flow on a device/emulator

Use many unit/widget tests and a smaller number of critical integration tests.
Avoid real network calls in deterministic unit tests.

See the complete [Testing Guide](../test/README.md).

## 13. Widget performance

Common interview points:

- Use `const` where it avoids unnecessary object creation
- Keep `build` pure and inexpensive
- Use lazy lists such as `ListView.builder` for large collections
- Rebuild the smallest practical subtree
- Avoid expensive opacity, clipping, and intrinsic layout in hot paths
- Profile with DevTools instead of guessing
- Move CPU-heavy work off the UI isolate

`const` is useful, but it does not prevent every rebuild; it allows Flutter to
reuse an immutable widget instance.

## 14. Flutter rendering pipeline

Know the distinction:

```text
Widget: immutable configuration
Element: mounted instance and tree relationship
RenderObject: layout, painting, and hit testing
```

Typical frame stages include build, layout, paint, compositing, and rasterization.

## 15. REST and JSON

Be ready to explain:

- HTTP verbs and status codes
- Authentication headers and token refresh
- Timeouts, cancellation, retry policy, and pagination
- JSON serialization
- DTO-to-domain mapping
- Caching and offline behavior
- Never logging secrets or storing tokens as plain text

The current `ApiService` is simulated. A production implementation would use an
HTTP client behind `NoteRemoteDataSource`.

## 16. SQLite questions

Prepare:

- Why indexes improve reads but add write/storage cost
- Transactions for atomic multi-step operations
- Schema versioning and `onUpgrade`
- Parameterized queries to avoid injection
- Avoiding database work directly in widgets

## 17. Navigation

For small apps, `Navigator` is enough. For deep links, web URLs, nested
navigation, and redirect rules, a declarative router such as `go_router` is
often easier to scale.

Navigation is a UI concern; business logic should expose outcomes rather than
depending heavily on a global navigation context.

## 18. Platform channels

Platform channels allow Dart to call Kotlin/Java or Swift/Objective-C code when
a plugin does not expose the required native API. Know `MethodChannel`,
`EventChannel`, serialization limits, and thread/error handling.

## 19. Security

Interview-ready points:

- Store secrets in secure platform storage, not source code
- Use HTTPS and validate backend authorization
- Do not treat obfuscation as encryption
- Minimize logs containing personal data or tokens
- Validate input on both client and server
- Keep dependencies and native permissions minimal

## 20. Capgemini-oriented scenario practice

Practice explaining these aloud:

1. A screen rebuilds repeatedly and calls the API each time. Diagnose and fix it.
2. Two API requests finish out of order. Prevent stale data from winning.
3. A token expires while several requests are active. Design refresh handling.
4. The app must work offline and synchronize later. Describe the data flow.
5. A list drops frames with thousands of items. Explain how you would profile it.
6. Compare BLoC, GetX, and Riverpod for a large distributed team.
7. Design unit, widget, and integration coverage for a payment or login flow.
8. A feature works on Android but not iOS. Describe your debugging process.
9. Explain a difficult production issue using situation, action, and result.
10. Describe code review, branching, Agile ceremonies, and CI/CD experience.

## Official References

- Flutter testing overview: https://docs.flutter.dev/testing/overview
- Flutter architecture guide: https://docs.flutter.dev/app-architecture/guide
- Dart concurrency and isolates: https://dart.dev/language/concurrency
- Flutter performance practices: https://docs.flutter.dev/perf/best-practices
