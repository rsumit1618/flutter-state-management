# Flutter Interview Questions: Easy Answers

This is the main interview revision document for this repository.

It contains:

1. **Your 50 priority questions first**, rewritten and technically corrected.
2. **The Top 100 additional Flutter interview questions** after them.
3. Short spoken answers, memory lines, comparisons, flows, and code examples.

Navigation:

- [Project and state-management implementation](../README.md)
- [Testing guide](../test/README.md)
- [Working Flutter concepts screen](../lib/interview_examples/view/interview_concepts_page.dart)

## How To Remember An Answer

Use **D-F-E**:

```text
D = Definition: What is it?
F = Flow: How does it work?
E = Example: Where would I use it?
```

Keep the first answer under 30 seconds. Add details only when the interviewer
asks a follow-up.

---

# Part A: Your 50 Priority Questions

## A1. What are `main()` and `runApp()`?

**Interview answer:**  
`main()` is the Dart entry point. `runApp()` attaches the root widget and starts
the Flutter UI.

**Remember:** `main = start Dart`, `runApp = start UI`.

```dart
void main() {
  runApp(const MyApp());
}
```

Project example: [main.dart](../lib/main.dart).

---

## A2. What is the difference between `StatelessWidget` and `StatefulWidget`?

**Interview answer:**  
A `StatelessWidget` has no mutable `State` object. A `StatefulWidget` creates a
`State` object whose values may change during the widget's lifetime.

| StatelessWidget | StatefulWidget |
| --- | --- |
| Immutable configuration | Immutable widget plus mutable `State` |
| Good for display-only UI | Good for local changing UI |
| Example: `Text`, `Icon` | Example: `TextField`, `Checkbox` |

Do not say that `StatelessWidget` automatically makes an app fast. Performance
depends more on rebuild scope, layout, painting, and expensive work.

For large features, keep business state in BLoC, GetX, Riverpod, or another
state layer instead of putting everything in the widget.

**Lifecycle memory:**

```text
createState
-> initState
-> didChangeDependencies
-> build
-> didUpdateWidget (when parent configuration changes)
-> deactivate
-> dispose
```

Project example:
[InterviewConceptsPage](../lib/interview_examples/view/interview_concepts_page.dart).

---

## A3. What are tree shaking, R8, and ProGuard?

**Interview answer:**  
Tree shaking removes unreachable Dart code from release builds. On Android, R8
performs code shrinking, optimization, and obfuscation. R8 has largely replaced
ProGuard as the Android shrinker, though ProGuard rule syntax is still used.

**Remember:**

```text
Tree shaking -> Dart unused code
R8           -> Android bytecode shrink/optimize/obfuscate
Resource shrinker -> unused Android resources
```

Obfuscation makes reverse engineering harder, but it is not encryption and does
not make embedded secrets safe.

---

## A4. What is Agile?

**Interview answer:**  
Agile is an iterative development approach where a team delivers software in
small increments, gets feedback, and adapts priorities continuously.

**Remember:** `Plan small -> build -> review -> improve`.

Common Scrum activities include sprint planning, daily stand-up, refinement,
review, and retrospective. Agile is the mindset; Scrum is one framework.

---

## A5. What is a sealed class?

**Interview answer:**  
A sealed class defines a closed family of subtypes. Dart knows the possible
subclasses, which helps exhaustive `switch` handling.

```dart
sealed class ApiState {}

final class Loading extends ApiState {}
final class Success extends ApiState {
  final String data;
  Success(this.data);
}
final class Failure extends ApiState {
  final String message;
  Failure(this.message);
}
```

```dart
String label(ApiState state) => switch (state) {
  Loading() => 'Loading',
  Success(:final data) => data,
  Failure(:final message) => message,
};
```

In Dart, direct subtypes of a sealed class must be declared in the same
**library**, not necessarily the same physical file when `part` files are used.

---

## A6. What is an abstract class?

**Interview answer:**  
An abstract class cannot be instantiated directly. It can define a contract,
shared implementation, fields, and constructors for subclasses.

```dart
abstract interface class UserRepository {
  Future<String> getUser();
}
```

Repositories depend on contracts so API, database, and fake implementations can
be replaced without changing the consumer.

Project example:
[NoteRepository](../lib/core/repository/note_repository.dart).

---

## A7. `ListView`, `builder`, `separated`, and `custom`: what is the difference?

**Interview answer:**  
Use the normal `ListView(children:)` for a small known list.
`ListView.builder` lazily builds large or dynamic lists.
`ListView.separated` lazily builds items plus separators.
`ListView.custom` gives advanced control through a sliver child delegate.

| Constructor | Best use |
| --- | --- |
| `ListView(children:)` | Small static list |
| `ListView.builder` | Large/dynamic list |
| `ListView.separated` | Lazy list with dividers/gaps |
| `ListView.custom` | Custom child creation/delegates |

There is no standard Flutter widget named `CustomizableListView`.

---

## A8. What is `SingleChildScrollView`?

**Interview answer:**  
`SingleChildScrollView` makes one child scrollable. It is suitable for small
content such as a form inside a `Column`.

It lays out the whole child, so do not use it for thousands of records. Use a
lazy list instead.

```dart
SingleChildScrollView(
  child: Column(children: formFields),
);
```

**Remember:** `small page = SingleChildScrollView`, `large list = builder`.

---

## A9. What is a mixin?

**Interview answer:**  
A mixin reuses behavior across multiple classes without creating an
“is-a” inheritance relationship. A class can apply multiple mixins with `with`.

```dart
mixin Logger {
  void log(String message) => print('LOG: $message');
}

mixin Validator {
  bool isValid(String value) => value.trim().isNotEmpty;
}

class UserService with Logger, Validator {
  void createUser(String name) {
    log(isValid(name) ? 'User created' : 'Invalid user');
  }
}
```

Use composition or a service when behavior needs independent state,
dependencies, or runtime replacement.

---

## A10. What is `git cherry-pick`?

**Interview answer:**  
`git cherry-pick` applies one or more specific commits from another branch onto
the current branch.

```bash
git switch release
git cherry-pick a1b2c3d
```

It creates a new commit with the same change but a different commit identity.
Use it for an isolated fix, not as the normal way to combine whole branches.

---

## A11. What is the difference between Git merge and rebase?

| Merge | Rebase |
| --- | --- |
| Combines histories | Replays commits on a new base |
| May create merge commit | Produces linear history |
| Does not rewrite existing commits | Rewrites commit identities |
| Safe for shared branches | Avoid rebasing already shared commits |

**Interview answer:**  
I use merge when preserving shared history is important. I use rebase to update
my private feature branch and keep its history linear before merging.

---

## A12. What is the difference between `final`, `const`, and `factory`?

| Keyword | Meaning |
| --- | --- |
| `final` | Assigned once; value may be known at runtime |
| `const` | Compile-time constant |
| `factory` | Constructor that controls what instance is returned |

```dart
final now = DateTime.now(); // Runtime value, assigned once.
const timeout = Duration(seconds: 10); // Compile-time constant.

class User {
  final int id;
  User(this.id);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['id'] as int);
  }
}
```

A factory may return a cached instance, subtype, or parsed object. A generative
constructor always creates a new instance.

---

## A13. What is a payload?

**Interview answer:**  
A payload is the meaningful data carried by a request, response, message, or
event. In an HTTP API it usually means the body.

```json
{
  "title": "Flutter",
  "description": "Interview notes"
}
```

Headers and status code describe the message; the payload carries its data.

---

## A14. What is a push-notification payload?

**Interview answer:**  
It is the notification and custom data sent to the app. Display fields may
contain title/body; data fields may contain a safe route or entity ID.

```json
{
  "notification": {"title": "Payment", "body": "Payment completed"},
  "data": {"type": "payment", "paymentId": "p_123"}
}
```

Validate payload values and authorization before navigation. Do not trust a push
payload as proof of payment or permission.

---

## A15. What is `CustomScrollView`?

**Interview answer:**  
`CustomScrollView` combines multiple slivers into one scrollable area, such as a
collapsing app bar, list, grid, and spacing.

```dart
CustomScrollView(
  slivers: [
    const SliverAppBar(
      pinned: true,
      expandedHeight: 160,
      flexibleSpace: FlexibleSpaceBar(title: Text('Notes')),
    ),
    SliverList.builder(
      itemCount: 20,
      itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
    ),
  ],
);
```

---

## A16. `NestedScrollView` vs `CustomScrollView`

**Interview answer:**  
`CustomScrollView` creates one sliver-based scroll view. `NestedScrollView`
coordinates an outer scroll view with inner scroll views, commonly a collapsing
header with tab lists.

| CustomScrollView | NestedScrollView |
| --- | --- |
| One scroll position | Coordinates outer and inner positions |
| Slivers compose the page | Useful with `TabBarView` inner lists |
| Simpler and preferred when enough | More complex overlap/scroll behavior |

---

## A17. What is cryptography?

**Interview answer:**  
Cryptography protects information using mathematical techniques for
confidentiality, integrity, authentication, and non-repudiation.

**Remember:** `hide data, detect changes, prove identity`.

Do not invent cryptographic algorithms; use maintained libraries and platform
security APIs.

---

## A18. What are the main types of cryptography?

| Type | Keys | Example use |
| --- | --- | --- |
| Symmetric encryption | Same secret key | AES data encryption |
| Asymmetric encryption | Public/private pair | Key exchange, signatures |
| Hashing | No decryption key | Integrity, password verification |

Hashing is one-way and is not encryption. Passwords should use a dedicated
password-hashing algorithm such as Argon2, bcrypt, or scrypt on the server.

---

## A19. What is SSL pinning, and what happens when a pin expires?

**Interview answer:**  
SSL/TLS pinning makes the app accept only an expected certificate or public key
in addition to normal trust checks. It reduces some man-in-the-middle risks.

If the pinned certificate/key changes or expires without a valid backup pin and
rotation plan, HTTPS calls fail even when the server has a generally valid new
certificate.

**Production answer:** ship backup pins, overlap rotation, monitor expiry, and
have an emergency update strategy. Pinning is not a replacement for backend
authorization.

---

## A20. What is JWT?

**Interview answer:**  
JWT is a compact token format containing encoded claims and usually a digital
signature. A server may issue it after authentication and verify it on API
requests.

```text
header.payload.signature
```

JWT payloads are normally encoded, **not encrypted**, so do not place secrets in
claims. Use short expiry, validate issuer/audience/signature, store tokens
securely, and enforce authorization on the server.

---

## A21. `MethodChannel` vs `EventChannel`

| MethodChannel | EventChannel |
| --- | --- |
| One request and response | Continuous native events |
| Returns `Future` | Returns `Stream` |
| Get battery level | Listen to sensor/connectivity |

**Remember:** `method = ask once`, `event = listen continuously`.

Catch `PlatformException` and map native errors to app failures.

---

## A22. What is `WidgetsBindingObserver`?

**Interview answer:**  
It lets an object observe app and system lifecycle events such as foreground,
background, locale, metrics, accessibility, and platform brightness changes.

```dart
class PageState extends State<Page> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

Project example:
[InterviewConceptsPage](../lib/interview_examples/view/interview_concepts_page.dart).

---

## A23. What is `mounted`?

**Interview answer:**  
`mounted` tells whether a `State` object is currently attached to the widget
tree. After asynchronous work, check it before using `context` or `setState`.

```dart
await saveNote();
if (!mounted) return;
Navigator.pop(context);
```

```text
initState -> mounted true
dispose   -> mounted false
```

---

## A24. What types of navigation are available in Flutter?

**Interview answer:**  
Flutter supports imperative navigation with `Navigator` and declarative routing
with a Router API/package such as `go_router`.

| Style | Example |
| --- | --- |
| Anonymous route | `Navigator.push(MaterialPageRoute(...))` |
| Named route | `Navigator.pushNamed('/details')` |
| Generated route | `onGenerateRoute` creates routes |
| Declarative router | Route configuration represents app state/URL |

Use a declarative router for deep links, web URLs, redirects, and larger apps.

---

## A25. What is required to publish to Play Store and App Store?

### Google Play

- Play Console developer account
- Unique application ID and signed Android App Bundle (`.aab`)
- Release signing key managed safely
- Store listing, screenshots, icon, category, countries
- Privacy policy, data-safety form, content rating, audience declarations
- Permission and policy compliance

### Apple App Store

- Apple Developer membership
- macOS/Xcode for signing and upload
- Bundle ID, certificates/signing, provisioning configuration
- Archive/upload through Xcode or CI
- App Store Connect listing, screenshots, privacy details, review information

Requirements change, so verify current store policies before each release.

---

## A26. What is sound null safety?

**Interview answer:**  
Sound null safety makes types non-nullable by default and catches unsafe null
access at compile time when all code is null safe.

```dart
String name = 'Sumit'; // Cannot be null.
String? nickname;      // May be null.
final length = nickname?.length;
```

**Remember:** `? allows null`, `?. accesses safely`, `?? supplies fallback`.

---

## A27. What are `late` and `!`?

**Interview answer:**  
`late` delays initialization of a non-nullable variable. `!` asserts that a
nullable value is non-null at runtime.

```dart
late final TextEditingController controller;

void initState() {
  controller = TextEditingController();
}

String? token;
final value = token!; // Throws if token is null.
```

Prefer proper flow checks over `!`. `late` also throws if read before
initialization.

---

## A28. What is the difference between JIT and AOT?

| JIT | AOT |
| --- | --- |
| Compiles during execution | Compiles before execution |
| Development/debug | Release mobile builds |
| Enables hot reload | Faster startup and predictable runtime |

**Remember:** `JIT = speed of coding`, `AOT = speed of released app`.

Flutter web has different compilation/runtime paths, so avoid claiming every
Flutter release uses the same native AOT mechanism.

---

## A29. `InheritedWidget` vs Provider

**Interview answer:**  
`InheritedWidget` is Flutter's low-level mechanism for sharing data with
descendants and rebuilding dependents. Provider offers a simpler API for
creation, lookup, updates, and disposal using inherited mechanisms.

| InheritedWidget | Provider |
| --- | --- |
| Framework primitive | Higher-level package |
| Manual boilerplate | Easier common patterns |
| Full custom control | Better convenience/scalability |

Riverpod uses a provider graph and `Ref`, so it does not require
`BuildContext` for dependency reads.

---

## A30. How would you design a scalable mobile architecture?

**Interview answer:**  
I separate presentation, domain, and data responsibilities, depend on
abstractions, and keep framework/network/database details outside business
rules.

```text
Presentation
  Widget -> BLoC/Notifier/Controller
Domain
  UseCase -> Repository contract -> Entity
Data
  Repository implementation -> Remote/Local data source -> DTO
```

Add typed failures, dependency injection, environment configuration, tests,
logging, caching, pagination, and security based on actual complexity.

Project note: this sample is layered and MVVM-inspired rather than full Clean
Architecture. See [README](../README.md#10-is-this-clean-architecture-mvvm-or-ddd).

---

## A31. What is caching and offline support?

**Interview answer:**  
Caching stores previously fetched data to improve speed, reduce network usage,
and optionally support offline access.

```text
UI asks repository
-> return fresh cache if valid
-> otherwise fetch remote
-> save local copy
-> return data
```

| Storage | Use |
| --- | --- |
| Memory | Fast temporary cache |
| SharedPreferences | Small non-sensitive settings |
| SQLite/Hive/files | Structured or larger persistent data |
| Secure storage | Small credentials, not general cache |

Define source of truth, expiry, invalidation, conflict resolution, and sync
rules. “Store everything locally” is not a cache strategy.

---

## A32. What is an interceptor and why is it used?

**Interview answer:**  
An interceptor is middleware around HTTP requests, responses, and errors. It
centralizes common networking logic.

Common uses:

- Add authorization and common headers
- Log safe request/response metadata
- Convert errors consistently
- Refresh expired access tokens
- Retry temporary failures
- Add correlation IDs

For simultaneous `401` responses, use one synchronized refresh operation and
queue/replay eligible requests once. Never log tokens or sensitive payloads.

---

## A33. What are Flutter build modes?

| Mode | Use | Characteristics |
| --- | --- | --- |
| Debug | Development | Assertions, service extensions, hot reload |
| Profile | Performance analysis | Near-release behavior plus profiling |
| Release | Production | Optimized, assertions/service extensions removed |

**Remember:** `debug = develop`, `profile = measure`, `release = ship`.

Measure performance in profile mode on a physical device, not debug mode.

---

## A34. What is an isolate?

**Interview answer:**  
An isolate is an independent Dart execution context with its own memory and
event loop. Isolates communicate by message passing.

Use an isolate for CPU-heavy work that would block frames, such as large JSON
parsing, image processing, or expensive calculations.

```dart
final result = await Isolate.run(() => calculateLargeReport(data));
```

For simple Flutter-compatible functions, `compute` is also convenient.

---

## A35. Isolate vs thread, and why use isolates?

| Isolate | Typical shared-memory thread |
| --- | --- |
| Separate Dart heap | Shared process memory |
| Message passing | Shared-state synchronization |
| Avoids shared-Dart-memory data races | Locks/races/deadlocks are concerns |
| Heavier communication/copy cost | Cheap shared access but riskier |

Do not say Dart or Flutter has no threads. The engine and platform use threads;
Dart application concurrency is exposed primarily through isolates.

**Remember:** `thread shares`, `isolate sends`.

---

## A36. Write factorial using recursion

```dart
int factorial(int number) {
  if (number < 0) {
    throw ArgumentError('Factorial is undefined for negative numbers');
  }
  if (number <= 1) return 1;
  return number * factorial(number - 1);
}
```

Time complexity is `O(n)` and recursive space is `O(n)`. Large values overflow
fixed-width integers in many languages and deep recursion can overflow the
stack.

---

## A37. Write factorial using iteration

```dart
int factorial(int number) {
  if (number < 0) {
    throw ArgumentError('Factorial is undefined for negative numbers');
  }

  var result = 1;
  for (var value = 2; value <= number; value++) {
    result *= value;
  }
  return result;
}
```

This is iteration, not an “array solution.” Time is `O(n)` and extra space is
`O(1)`.

---

## A38. Widget tree vs Element tree vs RenderObject tree

**Interview answer:**  
Widgets describe configuration, elements preserve mounted identity and
lifecycle, and render objects perform layout, painting, and hit testing.

```text
Widget       = what UI should be
Element      = mounted manager/connection
RenderObject = size, position, paint, hit test
```

Widgets are recreated frequently. Elements and render objects are reused when
Flutter can match runtime type and key.

---

## A39. What actually happens when `setState()` is called?

**Interview answer:**  
`setState` runs its callback synchronously, marks that element dirty, and
schedules a rebuild of that widget's subtree. Flutter then updates only changed
parts through element reconciliation and the rendering pipeline.

It does **not** recreate or repaint the entire app.

```dart
setState(() {
  count++;
});
```

Keep the callback synchronous and change only the relevant local state.

---

## A40. What is Flutter architecture?

**Interview answer:**  
Flutter has a Dart framework, a C++ engine, and platform embedders.

```text
App
-> Framework: widgets, gestures, animation, rendering abstractions
-> Engine: Dart runtime, text, compositing, graphics/rasterization
-> Embedder: window, input, lifecycle, native platform integration
-> OS/GPU
```

Do not say Flutter always renders only with Skia. Modern Flutter uses Impeller
by default on major mobile targets, while Skia remains relevant on other
platforms/backends.

---

## A41. What is Google OAuth 2.0?

**Interview answer:**  
OAuth 2.0 is an authorization framework. Google Sign-In commonly combines OAuth
2.0 with OpenID Connect so the app can authenticate a user and obtain
authorization tokens without receiving the user's Google password.

```text
App requests sign-in
-> Google user consent/authentication
-> app receives authorization result/tokens
-> backend verifies ID token
-> backend creates its own session
```

An access token authorizes Google API access. An ID token is a signed identity
token. Verify important tokens on the backend.

---

## A42. How do you call and manage a REST API?

**Interview answer:**  
I keep HTTP in the data layer and expose it through a repository contract. The
state manager controls loading, success, and failure for the UI.

```text
Widget
-> State manager
-> Use case (when needed)
-> Repository contract
-> Repository implementation
-> Remote data source
-> HTTP client
```

Handle timeouts, typed errors, parsing, authentication, cancellation,
pagination, caching, retries, and secure logs at the correct layer.

Project boundary:
[NoteRemoteDataSource](../lib/core/data/note_data_sources.dart).

---

## A43. What is Dio?

**Interview answer:**  
Dio is a Dart HTTP client with request options, interceptors, cancellation,
timeouts, uploads/downloads, and progress callbacks.

```dart
final dio = Dio(
  BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 10),
  ),
);

final response = await dio.get<Map<String, dynamic>>('/users/1');
```

The `http` package is also valid for simpler needs. Choose based on required
features.

---

## A44. What is Retrofit in Flutter?

**Interview answer:**  
Retrofit for Dart is a code generator that creates typed API client
implementations from annotated interfaces, commonly on top of Dio.

```dart
@RestApi(baseUrl: 'https://api.example.com')
abstract class ApiClient {
  factory ApiClient(Dio dio) = _ApiClient;

  @GET('/users')
  Future<List<UserDto>> getUsers();
}
```

| Dio | Retrofit |
| --- | --- |
| HTTP engine/client | Declarative generated API layer |
| Manual request code | Annotated endpoint methods |
| Maximum direct control | Less repetitive endpoint code |

---

## A45. How do you create Flutter flavors?

**Interview answer:**  
Flavors let one codebase produce separate dev, staging, and production apps.
Android uses Gradle product flavors; iOS uses Xcode schemes/configurations.

```text
dev     -> dev API, dev app ID/name
staging -> test services
prod    -> production services
```

Run with:

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

Keep secrets in CI/backend secret management, not in flavor constants.

---

## A46. How do you handle retry, token refresh, and API failure?

**Interview answer:**  
Retry only temporary and safe failures. For `401`, refresh the token once,
replay the original request once, and log out if refresh fails.

```text
Timeout/502/503
-> exponential backoff + jitter
-> limited attempts

401
-> one synchronized refresh
-> save new token
-> replay request once
-> refresh fails: clear session
```

Do not blindly retry non-idempotent payment/order requests. Use idempotency keys
where supported and prevent infinite retry loops with a retry marker.

---

## A47. `ListView` vs `ListView.builder`

**Interview answer:**  
`ListView(children:)` builds the supplied child widgets, so it suits small,
known lists. `ListView.builder` creates items lazily and suits large or dynamic
data.

For transaction history, combine `ListView.builder` with pagination, stable
keys, cached data, and lightweight row widgets.

**Remember:** `small/static = ListView`, `large/dynamic = builder`.

---

## A48. What are SOLID principles?

**Interview answer:**  
SOLID is a set of five design principles that makes object-oriented code easier
to change, test, and extend.

| Principle | Easy meaning | Flutter example |
| --- | --- | --- |
| SRP | One reason to change | Widget renders; repository loads data |
| OCP | Extend without editing stable code | Add repository implementation |
| LSP | Subtype safely replaces contract | Fake repository replaces real one |
| ISP | Small focused interfaces | Separate reader/writer contracts |
| DIP | Depend on abstractions | Controller depends on repository interface |

```dart
abstract interface class UserRepository {
  Future<User> getUser();
}

class UserController {
  final UserRepository repository;
  UserController(this.repository);
}
```

Project example:
[NoteRepository and implementation](../lib/core/repository/).

---

## A49. What is `WidgetsFlutterBinding.ensureInitialized()`?

**Interview answer:**  
It ensures Flutter framework bindings exist before code uses plugins or
framework services prior to `runApp`.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabaseOrFirebase();
  runApp(const App());
}
```

You do not need to call it just because `main` is async; call it when pre-UI
initialization requires the binding.

---

## A50. `didChangeDependencies()` vs `didUpdateWidget()`

| didChangeDependencies | didUpdateWidget |
| --- | --- |
| Inherited dependency changed | Parent passed new widget configuration |
| Theme, locale, inherited/provider dependency | Constructor property changed |
| Safe place for context-dependent setup | Compare `oldWidget` and `widget` |

```dart
@override
void didUpdateWidget(covariant UserPage oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.userId != widget.userId) {
    loadUser(widget.userId);
  }
}
```

**Remember:** `dependency from context -> didChangeDependencies`; `new property
from parent -> didUpdateWidget`.

---

# Part B: Top 100 Additional Flutter Interview Questions

These questions avoid repeating Part A. Answers are intentionally compact for
rapid revision.

## Dart Language: B1-B20

### B1. What is Dart?

**Answer:** Dart is a type-safe, object-oriented language optimized for client
applications. It supports JIT development, ahead-of-time compilation, async
programming, sound null safety, generics, patterns, and isolates.

### B2. What is the difference between `var`, `dynamic`, and `Object?`?

**Answer:** `var` infers a static type. `dynamic` disables most static checking
for that value. `Object?` accepts any value but requires type checks before
specific operations.

```dart
var name = 'Sumit'; // String
dynamic raw = apiValue;
Object? value = raw;
```

### B3. What is type inference?

**Answer:** The compiler determines a variable or generic type from its value
and context while retaining static checking.

### B4. What are named and positional parameters?

**Answer:** Positional parameters depend on order. Named parameters improve
clarity and can be marked `required`.

```dart
void save(String id, {required String title}) {}
```

### B5. What are optional parameters and default values?

**Answer:** Optional positional parameters use `[]`; optional named parameters
use `{}`. Non-nullable optional parameters need a default or must be required.

### B6. What is a closure?

**Answer:** A closure is a function that captures variables from its surrounding
scope even after that scope returns.

### B7. What is a typedef?

**Answer:** A typedef gives a readable name to a function or type signature.

```dart
typedef UserLoader = Future<User> Function(String id);
```

### B8. What are generics?

**Answer:** Generics make classes/functions reusable while preserving type
safety, such as `List<User>` or `Result<T>`.

### B9. What is an extension method?

**Answer:** An extension adds statically resolved methods/getters to an existing
type without modifying or inheriting from it.

### B10. What is an enum in modern Dart?

**Answer:** An enum represents a fixed set of values and may contain fields,
methods, and implemented interfaces.

### B11. What are records?

**Answer:** Records are immutable typed groups of values without declaring a
class.

```dart
(String, int) userSummary() => ('Sumit', 5);
```

### B12. What are patterns?

**Answer:** Patterns destructure and match values in declarations, switches,
and conditions.

```dart
final (name, count) = userSummary();
```

### B13. What is the cascade operator?

**Answer:** `..` performs multiple operations on the same object and returns
that object.

```dart
final controller = TextEditingController()
  ..text = 'Initial'
  ..selection = const TextSelection.collapsed(offset: 7);
```

### B14. What are spread and collection-if/for?

**Answer:** `...` inserts collection items; collection `if` and `for` build
collections declaratively.

### B15. How does equality work in Dart?

**Answer:** `identical` checks object identity. `==` can be overridden for value
equality; when overriding it, also provide a consistent `hashCode`.

### B16. How do exceptions work?

**Answer:** Use `try`, `on`, `catch`, and `finally`. Catch specific errors where
you can recover or add context; do not silently swallow failures.

### B17. What is `Future.wait`?

**Answer:** It waits for multiple independent futures concurrently and returns
their results in order.

Project example:
[repository loading](../lib/core/repository/note_repository_impl.dart).

### B18. What is the Dart event loop?

**Answer:** It processes synchronous work, microtasks, and event-queue tasks on
an isolate. Long synchronous work blocks frames even when called from an async
function.

### B19. Microtask queue vs event queue?

**Answer:** Microtasks run before the next event. Overusing microtasks can starve
timers, I/O events, and frame work.

### B20. What is a Stream subscription?

**Answer:** `listen` returns a subscription that can pause, resume, or cancel
delivery. Cancel owned subscriptions in cleanup.

---

## Flutter Fundamentals: B21-B45

### B21. What is `BuildContext`?

**Answer:** It is an element's location in the widget tree and is used to find
ancestors such as Theme, Navigator, MediaQuery, and inherited dependencies.

### B22. Why should `BuildContext` not be stored globally?

**Answer:** Context belongs to a mounted tree location and can become invalid or
retain UI objects. Pass it briefly or use scoped navigation/dependency APIs.

### B23. What are keys?

**Answer:** Keys help Flutter match widgets with elements when siblings move or
change. Common types are `ValueKey`, `ObjectKey`, `UniqueKey`, and `GlobalKey`.

### B24. When should `GlobalKey` be used?

**Answer:** Use it sparingly when access to a specific state/context/form across
the tree is necessary. It is heavier and can create tight coupling.

### B25. What is the Flutter constraint rule?

**Answer:** `Constraints go down, sizes go up, parents set positions`.

### B26. `Expanded` vs `Flexible`

**Answer:** Both work inside Flex layouts. `Expanded` forces the child to fill
its allocated space; `Flexible` allows it to use less space.

### B27. `MediaQuery` vs `LayoutBuilder`

**Answer:** `MediaQuery` describes the screen/window and accessibility settings.
`LayoutBuilder` provides the constraints of the immediate parent.

### B28. What is `Builder`?

**Answer:** It creates a new `BuildContext` below its position, useful when a
callback needs to see an ancestor added in the same build method.

### B29. What is `FutureBuilder`?

**Answer:** It builds UI from a future snapshot. Create/cache the future outside
`build` when it must not restart on rebuild.

### B30. What is `StreamBuilder`?

**Answer:** It rebuilds from stream snapshots and is suitable for widget-owned
continuous data.

Project examples:
[concepts screen](../lib/interview_examples/view/interview_concepts_page.dart).

### B31. Hot reload vs hot restart

**Answer:** Hot reload injects code and preserves most state. Hot restart
restarts the Dart isolate and loses runtime state without reinstalling the app.

### B32. What is `RepaintBoundary`?

**Answer:** It can isolate painting into a separate layer so one subtree does
not repaint with another. Use it after profiling; unnecessary boundaries also
have cost.

### B33. What is the gesture arena?

**Answer:** Multiple gesture recognizers compete for a pointer sequence. Flutter
resolves which recognizer wins, such as horizontal drag versus tap.

### B34. What are slivers?

**Answer:** Slivers are scrollable layout building blocks consumed by a
viewport, including `SliverList`, `SliverGrid`, and `SliverAppBar`.

### B35. What is a Hero animation?

**Answer:** It animates a shared tagged widget between routes. Hero tags must be
unique within a route subtree.

### B36. Implicit vs explicit animation

**Answer:** Implicit widgets animate property changes automatically. Explicit
animations use `AnimationController` for lifecycle and timing control.

### B37. Why dispose an `AnimationController`?

**Answer:** It owns a ticker/resource. Not disposing can leak work and trigger
ticker warnings.

### B38. What is a Form and `GlobalKey<FormState>`?

**Answer:** `Form` groups field validation/saving. Its key can call
`validate`, `save`, and `reset` on that specific form state.

### B39. `TextField` vs `TextFormField`

**Answer:** `TextField` is basic editable input. `TextFormField` integrates with
`Form` validation and saving.

### B40. What are FocusNode and FocusScope?

**Answer:** They control keyboard focus, traversal, and focus events. Dispose
owned focus nodes.

### B41. What is localization?

**Answer:** Localization provides translated strings and locale-specific
formats. Flutter uses generated localizations/delegates and locale resolution.

### B42. What is theming?

**Answer:** `ThemeData` centralizes colors, typography, and component styles so
UI remains consistent and supports light/dark modes.

### B43. What are semantics and accessibility?

**Answer:** Semantics describe meaning/actions to assistive technologies. Test
screen readers, contrast, scaling, focus order, labels, and touch targets.

### B44. What is a platform view?

**Answer:** It embeds a native Android/iOS view in Flutter, such as a native map.
It can have composition, gesture, and performance tradeoffs.

### B45. What causes Flutter jank?

**Answer:** Frames exceed their time budget due to heavy UI-isolate work,
expensive layout/paint/rasterization, large images, excess allocation, or
blocking platform calls. Measure in profile mode with DevTools.

---

## State Management: B46-B65

### B46. Why use state management?

**Answer:** It gives state a clear owner and separates UI rendering from async
work, persistence, validation, and business rules.

### B47. Local state vs application state

**Answer:** Local state belongs to a small widget subtree. Application state is
shared, persistent, asynchronous, or business-critical.

### B48. What is BLoC?

**Answer:** BLoC receives events and emits states through a predictable
event-to-state flow.

### B49. What is Cubit?

**Answer:** Cubit exposes methods that directly emit states without event
classes, reducing boilerplate for simpler workflows.

### B50. BLoC vs Cubit

**Answer:** Use BLoC when explicit events, auditability, event transformations,
or complex sources matter. Use Cubit for straightforward method-to-state logic.

### B51. `BlocBuilder`, `BlocListener`, and `BlocConsumer`

**Answer:** Builder renders state, Listener performs one-time side effects, and
Consumer combines both.

Project example:
[BLoC views](../lib/bloc_example/view/).

### B52. What is GetX state management?

**Answer:** A GetX controller owns reactive `Rx` values, and `Obx` rebuilds when
the values read inside it change.

### B53. What are `Get.put` and `Get.find`?

**Answer:** `Get.put` registers a dependency and `Get.find` retrieves it. Scope
and delete controllers deliberately to avoid hidden long-lived globals.

### B54. What is Riverpod?

**Answer:** Riverpod is provider-based state and dependency management using a
provider graph and `Ref` rather than `BuildContext`.

### B55. What is `ProviderScope`?

**Answer:** It stores Riverpod provider state for a Flutter subtree and enables
provider overrides.

### B56. `ref.watch`, `ref.read`, and `ref.listen`

**Answer:** `watch` subscribes/rebuilds, `read` gets a value once, and `listen`
runs side effects when a provider changes.

### B57. What is `StateProvider`?

**Answer:** It manages a simple mutable value such as a filter or selected
index. Prefer a notifier when logic grows.

### B58. What is `FutureProvider`?

**Answer:** It exposes read-only future data as `AsyncValue`.

### B59. What is `StreamProvider`?

**Answer:** It exposes stream values as `AsyncValue`.

### B60. What is `NotifierProvider`?

**Answer:** It exposes synchronous state plus methods owned by a Riverpod
`Notifier`.

### B61. What is `AsyncNotifierProvider`?

**Answer:** It exposes asynchronous loading/data/error state plus mutation
methods through `AsyncNotifier`.

Project example:
[RiverpodNoteViewModel](../lib/riverpod_example/viewmodel/riverpod_note_view_model.dart).

### B62. What is `AsyncValue`?

**Answer:** It represents loading, data, and error without separate nullable
flags.

### B63. What does `autoDispose` do?

**Answer:** It disposes provider state when no longer listened to, unless kept
alive. Use it for screen-scoped state; avoid it for drafts that must survive.

### B64. How are Riverpod providers tested?

**Answer:** Create `ProviderContainer`, override dependencies with fakes, invoke
the notifier, and inspect provider state.

Project test:
[riverpod_note_view_model_test.dart](../test/riverpod/riverpod_note_view_model_test.dart).

### B65. How do you choose BLoC, GetX, or Riverpod?

**Answer:** Choose based on team conventions, workflow complexity, dependency
management, testing, existing architecture, and maintenance cost, not trends.

See the [state-management comparison](../README.md#2-what-is-the-difference-between-bloc-getx-and-riverpod).

---

## Architecture And Data: B66-B80

### B66. What is Clean Architecture?

**Answer:** It separates presentation, domain, and data so business rules do not
depend on UI, HTTP, or database frameworks.

### B67. What is an entity?

**Answer:** An entity represents business identity and rules independent of
transport/storage format.

### B68. What is a DTO?

**Answer:** A Data Transfer Object matches an API or storage shape and is mapped
to/from domain objects.

### B69. What is a repository?

**Answer:** A repository is a domain-facing abstraction that hides data-source
details.

### B70. What is a use case?

**Answer:** A use case represents one business action and coordinates rules and
repositories.

### B71. Repository vs use case

**Answer:** A repository answers “how can data be accessed?” A use case answers
“what business action should happen?”

### B72. What is dependency injection?

**Answer:** Dependencies are supplied from outside instead of constructed
internally, improving replacement, configuration, and testing.

### B73. What is dependency inversion?

**Answer:** High-level code depends on abstractions, while concrete data
implementations satisfy those abstractions.

Project example:
[repository contract](../lib/core/repository/note_repository.dart).

### B74. What is immutable state?

**Answer:** Existing state is not mutated; a new state object represents each
change. This improves predictability, equality, and debugging.

### B75. What is `copyWith`?

**Answer:** It creates a new immutable object while replacing selected fields.

Project example:
[NoteModel](../lib/core/models/note_model.dart).

### B76. What is Freezed?

**Answer:** Freezed generates immutable classes, value equality, `copyWith`,
sealed unions, and optional JSON integration.

### B77. What is JSON serialization?

**Answer:** It converts between Dart objects and JSON-compatible maps. Generated
serialization reduces repetitive and unsafe manual casts.

### B78. SQLite vs SharedPreferences

**Answer:** SQLite handles structured/queryable records and transactions.
SharedPreferences handles small non-sensitive primitive settings.

### B79. What is a database migration?

**Answer:** It upgrades an existing schema/data from an old version to a new
version without losing user data. Test every supported upgrade path.

### B80. What is a database transaction?

**Answer:** It groups operations atomically: all succeed or all roll back. Use
it for multi-step consistency.

---

## Networking And Security: B81-B90

### B81. What do common HTTP status groups mean?

**Answer:** `2xx` success, `4xx` client/auth/request problems, and `5xx`
server/upstream failures.

### B82. `200` vs `201` vs `202`

**Answer:** `200` completed successfully, `201` created a resource, `202`
accepted for later processing.

### B83. `401` vs `403`

**Answer:** `401` means valid authentication is missing. `403` means identity is
known but permission is denied.

### B84. What is pagination?

**Answer:** Pagination loads data in pages/cursors instead of all records,
reducing response time, memory, and UI work.

### B85. What are debounce and throttle?

**Answer:** Debounce waits for quiet time before running, useful for search.
Throttle limits execution frequency, useful for scrolling or repeated events.

### B86. How do you cancel stale API requests?

**Answer:** Use the client's cancellation mechanism, cancel previous searches,
or ignore results whose request/version no longer matches current state.

### B87. What is secure storage?

**Answer:** It stores small secrets using platform-protected facilities such as
Keychain or Keystore-backed encryption. It does not make an untrusted device
fully secure.

### B88. Authentication vs authorization

**Answer:** Authentication asks “who are you?” Authorization asks “what may you
do?”

### B89. Symmetric vs asymmetric encryption

**Answer:** Symmetric encryption uses one shared secret and is fast. Asymmetric
cryptography uses public/private keys and supports key exchange/signatures.

### B90. Hashing vs encryption

**Answer:** Encryption is reversible with a key. Hashing is one-way and used for
integrity or password-verification schemes.

---

## Testing, Delivery, And Production: B91-B100

### B91. Unit vs widget vs integration test

**Answer:** Unit tests isolate logic, widget tests render/interact with Flutter
UI in the test runtime, and integration tests verify complete flows on a target.

See the [testing guide](../test/README.md).

### B92. Mock vs fake

**Answer:** A mock verifies configured interactions. A fake is a lightweight
working implementation with controllable behavior.

Project fake:
[FakeNoteRepository](../test/helpers/fake_note_repository.dart).

### B93. What is a golden test?

**Answer:** It compares rendered pixels with an approved reference image to
detect visual regressions. Control fonts, sizes, platform differences, and
intentional updates.

### B94. What is CI/CD?

**Answer:** Continuous Integration automatically validates changes. Continuous
Delivery/Deployment prepares or releases validated builds through repeatable
pipelines.

Project example:
[Flutter CI](../.github/workflows/flutter_ci.yml).

### B95. How do you reduce app size?

**Answer:** Analyze size, remove unused dependencies/assets, enable appropriate
shrinking, use app bundles/split debug symbols, compress resources, and avoid
shipping unnecessary architectures/features.

### B96. How do you find memory leaks?

**Answer:** Use DevTools memory snapshots/allocation tracking and check retained
controllers, subscriptions, timers, contexts, caches, and growing collections.

### B97. Foreground, background, and terminated notification handling

**Answer:** Foreground messages update UI/show local notifications; background
handlers do limited work; terminated taps are read during startup before safe
deep-link navigation.

### B98. What is a deep link?

**Answer:** A deep link opens a specific app location from a URI. Validate route
arguments and authorization before displaying protected content.

### B99. How should payment integration be secured?

**Answer:** The backend creates orders and owns secrets. The app opens the
gateway UI, while the backend verifies signatures/webhooks and returns the
authoritative idempotent payment status.

### B100. How do you answer “describe a production issue”?

**Answer:** Use STAR:

```text
Situation -> Task -> Action -> Result
```

Explain symptoms, evidence, root cause, fix, verification, measurable result,
and prevention. Do not invent production experience; describe a design as “I
would” when it was not personally implemented.

---

# Five-Minute Revision

```text
main starts Dart; runApp starts UI.
Widget configures; Element manages; RenderObject lays out and paints.
setState rebuilds one subtree, not the whole app.
Future gives one result; Stream gives many.
MethodChannel asks once; EventChannel listens.
JIT helps development; AOT optimizes release.
Thread shares memory; isolate sends messages.
Authentication = who; authorization = permission.
BLoC: Event -> State.
GetX: Controller -> Rx -> Obx.
Riverpod: Provider -> AsyncNotifier -> AsyncValue.
Repository hides data source; use case represents business action.
Unit tests logic; widget tests UI; integration tests complete flow.
```

Return to the [root project guide](../README.md).
