# Testing Guide

This folder documents and contains the automated testing strategy for the
project.

## Test Types

### Unit Tests

Unit tests verify one class or small unit of behavior without rendering the
full application UI or using a real device.

| Test file | What it verifies |
| --- | --- |
| [note_model_test.dart](core/note_model_test.dart) | Model mapping and immutable `copyWith` behavior |
| [note_repository_impl_test.dart](core/note_repository_impl_test.dart) | Repository coordination, source ownership, and fake data sources |
| [note_bloc_test.dart](bloc/note_bloc_test.dart) | BLoC event-to-state behavior and failures |
| [getx_note_controller_test.dart](getx/getx_note_controller_test.dart) | GetX reactive controller behavior and failures |
| [riverpod_note_view_model_test.dart](riverpod/riverpod_note_view_model_test.dart) | Riverpod provider overrides, `AsyncNotifier`, and `AsyncError` |

The unit tests use
[fake_note_repository.dart](helpers/fake_note_repository.dart) to replace the
real SQLite/API repository. This keeps them fast and deterministic.

### Widget Tests

Widget tests render widgets in Flutter's test environment. They verify visible
content, navigation, and user interaction without installing the application
on a device.

| Test file | What it verifies |
| --- | --- |
| [widget_test.dart](widget_test.dart) | Main menu content, navigation to the concepts page, and `ValueNotifier` UI updates |

Widget tests use `testWidgets`, `WidgetTester`, finders, `pumpWidget`, and
`pumpAndSettle`.

### Integration Tests

Integration tests exercise a complete user flow with the real application and
plugins on an emulator or physical device.

| Test file | What it verifies |
| --- | --- |
| [app_flow_test.dart](../integration_test/app_flow_test.dart) | Opens the BLoC feature, enters note data, saves it through SQLite, and verifies the result |

Although integration tests also use `testWidgets`, they become integration
tests because they initialize `IntegrationTestWidgetsFlutterBinding` and run
from the `integration_test/` folder on a real Flutter target.

## Why Use All Three?

```text
Unit tests        -> Fast feedback for business/state logic
Widget tests      -> UI rendering and interaction confidence
Integration tests -> Confidence that complete app and plugin flows work
```

A practical test pyramid has many unit tests, focused widget tests, and fewer
integration tests for critical journeys.

## Commands

Run unit and widget tests:

```bash
flutter test
```

Run the device-level integration test:

```bash
flutter test integration_test/app_flow_test.dart
```

Run static analysis:

```bash
flutter analyze
```

## Interview Questions Covered

### What is the difference between a unit, widget, and integration test?

A unit test isolates logic, a widget test renders a Flutter widget tree in the
test runtime, and an integration test validates a complete flow on a target
device or emulator.

### Why use fakes?

Fakes remove network/database variability and let tests control success and
failure states. They also demonstrate dependency inversion because production
classes depend on `NoteRepository`, not a concrete database.

### What should be mocked?

Mock or fake boundaries such as repositories, HTTP clients, databases, clocks,
and platform services. Do not mock simple value objects or implementation
details unless isolation requires it.

### Why are keys used in tests?

Keys provide stable selectors for widgets whose labels or positions might
change. This project uses keys such as `open_bloc_example` and
`bloc_save_note_button` in the integration flow.

Return to the [main project guide](../README.md).
