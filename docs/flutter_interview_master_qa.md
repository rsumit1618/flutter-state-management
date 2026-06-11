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
Flutter architecture has 3 main layers: **Framework**, **Engine**, and **Embedder**.

1. **Framework layer**  
   Written in **Dart**.  
   It gives us widgets, UI, gestures, animations, and rendering logic.

2. **Engine layer**  
   Written mostly in **C++**.  
   It runs Dart code and handles text, graphics, painting, and rendering.

3. **Embedder layer**  
   Connects Flutter to the native platform like Android, iOS, Web, or Desktop.  
   It handles window, input, app lifecycle, and platform-specific features.

**Flow:**

```text
App -> Framework -> Engine -> Embedder -> OS/GPU

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
SOLID is a set of 5 rules that helps us write clean, reusable, and testable object-oriented code.

| Principle | Simple meaning | Example |
|---|---|---|
| **S - Single Responsibility** | One class should do one job | Widget shows UI, repository gets data |
| **O - Open/Closed** | Add new features without changing old code | Add a new repository class |
| **L - Liskov Substitution** | Child class should work in place of parent class | Fake repository works instead of real repository |
| **I - Interface Segregation** | Keep interfaces small | Separate read and write methods |
| **D - Dependency Inversion** | Depend on interfaces, not direct classes | Controller uses repository interface |

```dart
abstract interface class UserRepository {
  Future<User> getUser();
}

class UserController {
  final UserRepository repository;

  UserController(this.repository);
}


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

# Part B: Top Flutter Interview Questions - Simplified

## Dart Language: B1-B20

### B1. What is Dart?

**Interview answer:**  
Dart is an object-oriented programming language used to build Flutter apps.

It supports:
- Type safety
- Async programming
- Null safety
- Generics
- Isolates
- JIT for development
- AOT for release builds

---

### B2. What is the difference between `var`, `dynamic`, and `Object?`?

**Interview answer:**  
`var`, `dynamic`, and `Object?` are used to store values, but they work differently.

| Type | Simple meaning |
|---|---|
| `var` | Dart guesses the type and keeps it fixed |
| `dynamic` | Type checking is mostly skipped |
| `Object?` | Can store any value, but needs type check before specific use |

```dart
var name = 'Sumit'; // String
dynamic raw = apiValue;
Object? value = raw;
```

---

### B3. What is type inference?

**Interview answer:**  
Type inference means Dart automatically understands the type from the assigned value.

```dart
var name = 'Sumit'; // Dart understands it as String
var age = 25;       // Dart understands it as int
```

---

### B4. What are named and positional parameters?

**Interview answer:**  
Positional parameters depend on order. Named parameters use names, so they are easier to read.

```dart
void save(String id, {required String title}) {}
```

```dart
save('1', title: 'My Note');
```

---

### B5. What are optional parameters and default values?

**Interview answer:**  
Optional parameters are not required when calling a function.

Named optional parameters use `{}`.  
Positional optional parameters use `[]`.

```dart
void greet({String name = 'Guest'}) {
  print('Hello $name');
}
```

---

### B6. What is a closure?

**Interview answer:**  
A closure is a function that remembers variables from its surrounding scope.

```dart
Function counter() {
  int count = 0;

  return () {
    count++;
    print(count);
  };
}
```

Here, the inner function remembers `count`.

---

### B7. What is a typedef?

**Interview answer:**  
A `typedef` gives a simple name to a function type or type signature.

```dart
typedef UserLoader = Future<User> Function(String id);
```

It makes code cleaner and easier to understand.

---

### B8. What are generics?

**Interview answer:**  
Generics help us write reusable and type-safe code.

```dart
List<String> names = ['Sumit', 'Amit'];
List<int> numbers = [1, 2, 3];
```

Same `List`, but different data types.

```dart
class Result<T> {
  final T data;

  Result(this.data);
}
```

Here, `T` can be `String`, `int`, `User`, etc.

---

### B9. What is an extension method?

**Interview answer:**  
An extension method adds new methods to an existing class without changing that class.

```dart
extension StringExtension on String {
  bool get isLong => length > 10;
}
```

```dart
print('Flutter Developer'.isLong);
```

---

### B10. What is an enum in Dart?

**Interview answer:**  
An enum is used when we have a fixed set of values.

```dart
enum Status {
  loading,
  success,
  error,
}
```

It makes code cleaner than using plain strings.

---

### B11. What are records?

**Interview answer:**  
Records are used to return or store multiple values together without creating a class.

```dart
(String, int) userSummary() {
  return ('Sumit', 5);
}
```

---

### B12. What are patterns?

**Interview answer:**  
Patterns are used to extract values from records, lists, objects, or switch cases.

```dart
final (name, count) = userSummary();
```

Here, values are directly extracted into `name` and `count`.

---

### B13. What is the cascade operator?

**Interview answer:**  
The cascade operator `..` lets us perform multiple operations on the same object.

```dart
final controller = TextEditingController()
  ..text = 'Initial'
  ..selection = const TextSelection.collapsed(offset: 7);
```

It avoids writing the object name again and again.

---

### B14. What are spread and collection-if/for?

**Interview answer:**  
Spread `...` adds items of one collection into another collection.  
Collection `if` and `for` help build lists conditionally.

```dart
final numbers = [1, 2, 3];

final allNumbers = [0, ...numbers, 4];
```

```dart
final isAdmin = true;

final menu = [
  'Home',
  if (isAdmin) 'Admin Panel',
];
```

---

### B15. How does equality work in Dart?

**Interview answer:**  
`identical()` checks whether two variables point to the same object.  
`==` checks equality and can be customized.

If we override `==`, we should also override `hashCode`.

---

### B16. How do exceptions work?

**Interview answer:**  
Exceptions handle runtime errors using `try`, `catch`, `on`, and `finally`.

```dart
try {
  final data = await apiCall();
} catch (e) {
  print('Something went wrong');
} finally {
  print('Cleanup');
}
```

---

### B17. What is `Future.wait`?

**Interview answer:**  
`Future.wait` runs multiple futures together and waits for all results.

```dart
final results = await Future.wait([
  fetchUser(),
  fetchPosts(),
]);
```

It is useful when tasks are independent.

---

### B18. What is the Dart event loop?

**Interview answer:**  
The Dart event loop manages sync code, microtasks, and event tasks.

Simple order:

```text
Synchronous code -> Microtask queue -> Event queue
```

Heavy synchronous work can block UI frames.

---

### B19. Microtask queue vs event queue?

**Interview answer:**  
Microtasks run before event queue tasks.

| Queue | Used for |
|---|---|
| Microtask queue | Very high priority async work |
| Event queue | Timers, I/O, user events, frames |

Too many microtasks can delay UI updates.

---

### B20. What is a Stream subscription?

**Interview answer:**  
A stream subscription listens to stream data.

It can:
- Pause
- Resume
- Cancel

```dart
final subscription = stream.listen((data) {
  print(data);
});

subscription.cancel();
```

Always cancel owned subscriptions when not needed.

---

## Flutter Fundamentals: B21-B45

### B21. What is `BuildContext`?

**Interview answer:**  
`BuildContext` tells where a widget is located in the widget tree.

It is used to access things like:

```text
Theme
Navigator
MediaQuery
Provider
InheritedWidget
```

---

### B22. Why should `BuildContext` not be stored globally?

**Interview answer:**  
`BuildContext` belongs to a specific widget location.

If the widget is removed, the context can become invalid.  
So we should use it only when needed, not store it globally.

---

### B23. What are keys in Flutter?

**Interview answer:**  
Keys help Flutter identify widgets when the widget tree changes.

Common keys:

| Key | Use |
|---|---|
| `ValueKey` | Based on a value |
| `ObjectKey` | Based on an object |
| `UniqueKey` | Always unique |
| `GlobalKey` | Access state/context globally in tree |

---

### B24. When should `GlobalKey` be used?

**Interview answer:**  
`GlobalKey` should be used only when we need to access a specific widget state from outside.

Example:

```dart
final formKey = GlobalKey<FormState>();
```

Common use case: form validation.

Use it carefully because it is heavier than normal keys.

---

### B25. What is the Flutter constraint rule?

**Interview answer:**  
Flutter layout follows this rule:

```text
Constraints go down,
Sizes go up,
Parent sets position.
```

Meaning:
- Parent gives size limits
- Child chooses size
- Parent places the child

---

### B26. `Expanded` vs `Flexible`

**Interview answer:**  
Both are used inside `Row`, `Column`, or `Flex`.

| Widget | Meaning |
|---|---|
| `Expanded` | Child must fill available space |
| `Flexible` | Child can take available space but may use less |

```dart
Row(
  children: [
    Expanded(child: Text('Takes full space')),
    Flexible(child: Text('Can be smaller')),
  ],
)
```

---

### B27. `MediaQuery` vs `LayoutBuilder`

**Interview answer:**  

| Widget | Use |
|---|---|
| `MediaQuery` | Gives screen size and device info |
| `LayoutBuilder` | Gives parent constraints |

Use `MediaQuery` for screen-level size.  
Use `LayoutBuilder` for widget-level responsive layout.

---

### B28. What is `Builder`?

**Interview answer:**  
`Builder` creates a new `BuildContext`.

It is useful when we need a context below a newly created widget.

```dart
Scaffold(
  body: Builder(
    builder: (context) {
      return ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hello')),
          );
        },
        child: const Text('Show'),
      );
    },
  ),
)
```

---

### B29. What is `FutureBuilder`?

**Interview answer:**  
`FutureBuilder` builds UI based on a `Future`.

It handles:
- Loading state
- Success data
- Error state

```dart
FutureBuilder(
  future: fetchUser(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Error');
    }

    return Text('Data loaded');
  },
)
```

Create/cache the future outside `build` if it should not restart again and again.

---

### B30. What is `StreamBuilder`?

**Interview answer:**  
`StreamBuilder` builds UI from continuous stream data.

It is useful for:
- Live data
- Chat messages
- Firebase updates
- Timer updates

```dart
StreamBuilder(
  stream: messageStream,
  builder: (context, snapshot) {
    return Text('${snapshot.data}');
  },
)
```

---

### B31. Hot reload vs hot restart

**Interview answer:**  

| Feature | Meaning |
|---|---|
| Hot reload | Updates code and keeps current state |
| Hot restart | Restarts app and clears runtime state |

Hot reload is faster during development.  
Hot restart is used when app state or initialization must reset.

---

### B32. What is `RepaintBoundary`?

**Interview answer:**  
`RepaintBoundary` separates painting of a widget subtree.

It helps when one part of UI repaints often and we want to avoid repainting other parts.

Use it after profiling, because unnecessary boundaries can also add cost.

---

### B33. What is the gesture arena?

**Interview answer:**  
The gesture arena decides which gesture wins when multiple gestures happen together.

Example:

```text
Tap vs horizontal drag vs vertical drag
```

Flutter checks all recognizers and chooses the winner.

---

### B34. What are slivers?

**Interview answer:**  
Slivers are scrollable building blocks in Flutter.

Examples:

```text
SliverList
SliverGrid
SliverAppBar
```

They are used inside `CustomScrollView`.

---

### B35. What is a Hero animation?

**Interview answer:**  
Hero animation moves a shared widget smoothly from one screen to another.

```dart
Hero(
  tag: 'profile-image',
  child: Image.network(url),
)
```

The same `tag` is used on both screens.

---

### B36. Implicit vs explicit animation

**Interview answer:**  

| Animation type | Meaning |
|---|---|
| Implicit animation | Flutter handles animation automatically |
| Explicit animation | Developer controls animation using `AnimationController` |

Example implicit animation:

```dart
AnimatedContainer(
  duration: Duration(seconds: 1),
  width: 200,
  height: 200,
)
```

Use explicit animation when more control is needed.

---

### B37. Why dispose an `AnimationController`?

**Interview answer:**  
`AnimationController` uses a ticker resource.

If we do not dispose it, it can cause memory leaks or ticker warnings.

```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

---

### B38. What is a Form and `GlobalKey<FormState>`?

**Interview answer:**  
`Form` groups multiple input fields.

`GlobalKey<FormState>` is used to validate, save, or reset the form.

```dart
final formKey = GlobalKey<FormState>();

formKey.currentState?.validate();
```

---

### B39. `TextField` vs `TextFormField`

**Interview answer:**  

| Widget | Use |
|---|---|
| `TextField` | Basic text input |
| `TextFormField` | Text input with form validation |

Use `TextFormField` when working inside a `Form`.

---

### B40. What are `FocusNode` and `FocusScope`?

**Interview answer:**  
`FocusNode` controls focus for a specific input field.  
`FocusScope` manages focus between multiple fields.

```dart
FocusScope.of(context).nextFocus();
```

Dispose owned `FocusNode`s.

---

### B41. What is localization?

**Interview answer:**  
Localization means supporting multiple languages and region-specific formats.

Example:
- English
- Hindi
- Gujarati

It also handles date, number, and currency formats.

---

### B42. What is theming?

**Interview answer:**  
Theming means defining common colors, fonts, and styles in one place.

```dart
MaterialApp(
  theme: ThemeData(
    primarySwatch: Colors.blue,
  ),
)
```

It helps maintain consistent UI and supports light/dark mode.

---

### B43. What are semantics and accessibility?

**Interview answer:**  
Semantics help screen readers understand UI elements.

Accessibility means making the app usable for everyone.

We should check:
- Labels
- Contrast
- Text scaling
- Touch target size
- Focus order

---

### B44. What is a platform view?

**Interview answer:**  
A platform view embeds a native Android or iOS view inside Flutter.

Example:
- Native map
- WebView
- Native camera view

It is useful but may have performance and gesture tradeoffs.

---

### B45. What causes Flutter jank?

**Interview answer:**  
Jank happens when UI frames are slow and the app feels laggy.

Common reasons:
- Heavy work on UI thread
- Expensive build/layout/paint
- Large images
- Too many animations
- Blocking platform calls

Use DevTools in profile mode to find the cause.

---

## State Management: B46-B50

### B46. Why use state management?

**Interview answer:**  
State management helps separate UI from business logic.

It gives a clear owner for data and makes code easier to test and maintain.

Example:

```text
UI shows data
Controller/BLoC handles logic
Repository loads data
```

---

### B47. Local state vs application state

**Interview answer:**  

| Type | Meaning | Example |
|---|---|---|
| Local state | Used only in one small widget area | Checkbox, selected tab |
| Application state | Shared across screens or business logic | Logged-in user, cart, theme |

Use local state for small UI changes.  
Use state management for shared or important data.

---

### B48. What is BLoC?

**Interview answer:**  
BLoC means Business Logic Component.

It takes events and gives states.

```text
Event -> BLoC -> State -> UI
```

Example:

```text
LoginButtonPressed -> LoginBloc -> Loading/Success/Error
```

BLoC is useful for complex flows.

---

### B49. What is Cubit?

**Interview answer:**  
Cubit is a simpler version of BLoC.

It does not use event classes.  
We directly call methods, and Cubit emits states.

```text
Method call -> Cubit -> State -> UI
```

Example:

```text
login() -> LoginCubit -> Loading/Success/Error
```

Cubit is good for simple logic.

---

### B50. BLoC vs Cubit

**Interview answer:**  

| BLoC | Cubit |
|---|---|
| Uses events and states | Uses methods and states |
| More structured | Less boilerplate |
| Better for complex logic | Better for simple logic |
| Easier to track user actions | Easier to write quickly |

Simple memory trick:

```text
BLoC = Event based
Cubit = Method based
```

Use BLoC for complex flows.  
Use Cubit for simple state changes.

## State Management: B51-B65

### B51. `BlocBuilder`, `BlocListener`, and `BlocConsumer`

**Interview answer:**  

| Widget | Use |
|---|---|
| `BlocBuilder` | Builds UI when state changes |
| `BlocListener` | Performs one-time actions |
| `BlocConsumer` | Combines builder and listener |

Example:

```text
BlocBuilder  -> Show UI
BlocListener -> Show snackbar / navigate
BlocConsumer -> Do both
```

---

### B52. What is GetX state management?

**Interview answer:**  
GetX is a simple state management solution.

A controller holds data, and `Obx` rebuilds UI when reactive values change.

```dart
class CounterController extends GetxController {
  var count = 0.obs;

  void increment() {
    count++;
  }
}
```

```dart
Obx(() => Text('${controller.count}'));
```

---

### B53. What are `Get.put` and `Get.find`?

**Interview answer:**  

| Method | Meaning |
|---|---|
| `Get.put()` | Registers a controller or dependency |
| `Get.find()` | Finds the registered dependency |

```dart
Get.put(CounterController());

final controller = Get.find<CounterController>();
```

Use them carefully to avoid hidden global objects.

---

### B54. What is Riverpod?

**Interview answer:**  
Riverpod is a state management and dependency injection solution.

It uses providers to store and share state.

Unlike Provider, Riverpod does not depend on `BuildContext`.

---

### B55. What is `ProviderScope`?

**Interview answer:**  
`ProviderScope` is required to use Riverpod in a Flutter app.

It stores provider state for the widget tree.

```dart
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

---

### B56. `ref.watch`, `ref.read`, and `ref.listen`

**Interview answer:**  

| Method | Use |
|---|---|
| `ref.watch` | Watches value and rebuilds UI |
| `ref.read` | Reads value once |
| `ref.listen` | Listens for changes and performs side effects |

Memory trick:

```text
watch = rebuild
read = one-time access
listen = side effect
```

---

### B57. What is `StateProvider`?

**Interview answer:**  
`StateProvider` is used for simple state.

Example:
- Selected tab
- Counter
- Filter value
- Toggle value

```dart
final counterProvider = StateProvider<int>((ref) => 0);
```

Use a notifier when logic becomes complex.

---

### B58. What is `FutureProvider`?

**Interview answer:**  
`FutureProvider` is used for async data that comes once.

Example:
- API call
- Load user profile
- Read config

```dart
final userProvider = FutureProvider<User>((ref) async {
  return fetchUser();
});
```

It gives loading, data, and error states.

---

### B59. What is `StreamProvider`?

**Interview answer:**  
`StreamProvider` is used for continuous async data.

Example:
- Chat messages
- Firebase updates
- Live location
- Timer

```dart
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return messageStream();
});
```

---

### B60. What is `NotifierProvider`?

**Interview answer:**  
`NotifierProvider` is used when state has methods and logic.

It is good for synchronous state changes.

Example:

```text
State + methods = NotifierProvider
```

Use it when simple `StateProvider` is not enough.

---

### B61. What is `AsyncNotifierProvider`?

**Interview answer:**  
`AsyncNotifierProvider` is used when state is asynchronous and also has methods.

It handles:

```text
Loading
Data
Error
```

Example use cases:
- Load notes
- Add note
- Delete note
- Refresh list

---

### B62. What is `AsyncValue`?

**Interview answer:**  
`AsyncValue` represents async state in Riverpod.

It has three common states:

```text
loading
data
error
```

Example:

```dart
userAsync.when(
  loading: () => CircularProgressIndicator(),
  data: (user) => Text(user.name),
  error: (error, stack) => Text('Error'),
);
```

---

### B63. What does `autoDispose` do?

**Interview answer:**  
`autoDispose` automatically removes provider state when it is no longer used.

It is useful for screen-specific state.

Example:

```dart
final userProvider = FutureProvider.autoDispose<User>((ref) async {
  return fetchUser();
});
```

Do not use it for state that must stay alive, like unsaved form drafts.

---

### B64. How are Riverpod providers tested?

**Interview answer:**  
Riverpod providers are tested using `ProviderContainer`.

We can override real dependencies with fake ones.

```dart
final container = ProviderContainer(
  overrides: [
    repositoryProvider.overrideWithValue(FakeRepository()),
  ],
);
```

Then we call the provider and check the state.

---

### B65. How do you choose BLoC, GetX, or Riverpod?

**Interview answer:**  
Choose based on project needs, team experience, testing, and long-term maintenance.

| Option | Good for |
|---|---|
| BLoC | Large apps, complex flows, event-based logic |
| GetX | Fast development and simple reactive state |
| Riverpod | Testable, scalable, provider-based architecture |

Do not choose only because of trends.

---

## Architecture And Data: B66-B80

### B66. What is Clean Architecture?

**Interview answer:**  
Clean Architecture separates code into layers.

```text
Presentation -> Domain -> Data
```

| Layer | Work |
|---|---|
| Presentation | UI and state management |
| Domain | Business rules |
| Data | API, database, local storage |

Main idea: business logic should not depend on UI or database.

---

### B67. What is an entity?

**Interview answer:**  
An entity is a core business object.

It should not depend on API or database format.

Example:

```dart
class User {
  final String id;
  final String name;

  User(this.id, this.name);
}
```

---

### B68. What is a DTO?

**Interview answer:**  
DTO means Data Transfer Object.

It is used to send or receive data from API/database.

Example:

```text
API JSON -> DTO -> Entity
```

DTO matches external data format.  
Entity is used inside business logic.

---

### B69. What is a repository?

**Interview answer:**  
A repository hides where data comes from.

Data can come from:
- API
- SQLite
- SharedPreferences
- Cache

```dart
abstract class UserRepository {
  Future<User> getUser();
}
```

The UI does not need to know the data source.

---

### B70. What is a use case?

**Interview answer:**  
A use case represents one business action.

Example:
- Login user
- Get notes
- Add product to cart
- Delete account

```text
UI -> UseCase -> Repository
```

---

### B71. Repository vs use case

**Interview answer:**  

| Repository | Use case |
|---|---|
| Handles data access | Handles business action |
| Knows how to get data | Knows what action to perform |

Simple memory trick:

```text
Repository = How to get data
Use case = What action to do
```

---

### B72. What is dependency injection?

**Interview answer:**  
Dependency injection means passing dependencies from outside instead of creating them inside a class.

```dart
class UserController {
  final UserRepository repository;

  UserController(this.repository);
}
```

This makes code easier to test and replace.

---

### B73. What is dependency inversion?

**Interview answer:**  
Dependency inversion means high-level classes depend on abstractions, not concrete classes.

```dart
abstract class UserRepository {
  Future<User> getUser();
}

class UserController {
  final UserRepository repository;

  UserController(this.repository);
}
```

Here, `UserController` depends on the interface, not a specific repository class.

---

### B74. What is immutable state?

**Interview answer:**  
Immutable state means we do not directly change the old object.

Instead, we create a new object with updated values.

```text
Old state -> New state
```

This makes state predictable and easier to debug.

---

### B75. What is `copyWith`?

**Interview answer:**  
`copyWith` creates a new object by changing only selected fields.

```dart
final updatedUser = user.copyWith(name: 'Rahul');
```

It is commonly used with immutable state.

---

### B76. What is Freezed?

**Interview answer:**  
Freezed is a Dart package that generates immutable classes.

It can generate:
- `copyWith`
- Value equality
- Union/sealed classes
- JSON support

It reduces boilerplate code.

---

### B77. What is JSON serialization?

**Interview answer:**  
JSON serialization means converting Dart objects to JSON and JSON to Dart objects.

```text
Dart object -> JSON
JSON -> Dart object
```

Example:

```dart
final json = user.toJson();
final user = User.fromJson(json);
```

---

### B78. SQLite vs SharedPreferences

**Interview answer:**  

| SQLite | SharedPreferences |
|---|---|
| Stores structured data | Stores small key-value data |
| Good for lists/records | Good for settings |
| Supports queries | No complex queries |

Example:

```text
SQLite -> notes, users, orders
SharedPreferences -> theme, token flag, language
```

Do not store sensitive secrets in plain SharedPreferences.

---

### B79. What is a database migration?

**Interview answer:**  
Database migration means updating database structure from one version to another without losing user data.

Example:

```text
Version 1: notes table has title
Version 2: notes table adds description
```

Migration safely updates old users' databases.

---

### B80. What is a database transaction?

**Interview answer:**  
A transaction groups multiple database operations together.

Either all operations succeed, or all fail.

```text
All success -> Save changes
Any failure -> Rollback
```

Use it when multiple operations must stay consistent.

---

## Networking And Security: B81-B90

### B81. What do common HTTP status groups mean?

**Interview answer:**  

| Status | Meaning |
|---|---|
| `2xx` | Success |
| `4xx` | Client-side error |
| `5xx` | Server-side error |

Example:

```text
200 = OK
404 = Not found
500 = Server error
```

---

### B82. `200` vs `201` vs `202`

**Interview answer:**  

| Code | Meaning |
|---|---|
| `200` | Request completed successfully |
| `201` | New resource created |
| `202` | Request accepted, processing later |

Example:

```text
200 -> Get profile success
201 -> User created
202 -> Upload accepted for processing
```

---

### B83. `401` vs `403`

**Interview answer:**  

| Code | Meaning |
|---|---|
| `401` | Not authenticated |
| `403` | Authenticated but not allowed |

Memory trick:

```text
401 = Who are you?
403 = You are known, but not allowed.
```

---

### B84. What is pagination?

**Interview answer:**  
Pagination means loading data in small parts instead of loading everything at once.

Example:

```text
Load first 20 items
Then next 20 items
Then next 20 items
```

It improves speed, memory usage, and UI performance.

---

### B85. What are debounce and throttle?

**Interview answer:**  

| Concept | Meaning | Example |
|---|---|---|
| Debounce | Wait until user stops action | Search box |
| Throttle | Run at fixed interval | Scroll event |

Memory trick:

```text
Debounce = Wait
Throttle = Limit
```

---

### B86. How do you cancel stale API requests?

**Interview answer:**  
Stale API requests are old requests that are no longer needed.

Ways to handle them:
- Cancel previous request
- Use request tokens
- Ignore old response if it does not match current query

Example:

```text
User searches "fl"
Then quickly searches "flutter"
Ignore result of old "fl" request
```

---

### B87. What is secure storage?

**Interview answer:**  
Secure storage stores small sensitive data using platform security.

Examples:
- iOS Keychain
- Android Keystore

Use it for:
- Access token
- Refresh token
- Small secrets

But it does not make a rooted or compromised device fully secure.

---

### B88. Authentication vs authorization

**Interview answer:**  

| Term | Meaning |
|---|---|
| Authentication | Who are you? |
| Authorization | What can you access? |

Example:

```text
Login = Authentication
Admin access = Authorization
```

---

### B89. Symmetric vs asymmetric encryption

**Interview answer:**  

| Type | Meaning |
|---|---|
| Symmetric encryption | Same key is used to encrypt and decrypt |
| Asymmetric encryption | Public key and private key are used |

Simple idea:

```text
Symmetric = one shared key
Asymmetric = public/private key pair
```

---

### B90. Hashing vs encryption

**Interview answer:**  

| Hashing | Encryption |
|---|---|
| One-way | Reversible with key |
| Cannot get original value back | Can decrypt original value |
| Used for passwords/integrity | Used for secure data transfer/storage |

Memory trick:

```text
Hashing = one-way
Encryption = can decrypt
```

---

## Testing, Delivery, And Production: B91-B100

### B91. Unit vs widget vs integration test

**Interview answer:**  

| Test type | Checks |
|---|---|
| Unit test | Logic only |
| Widget test | UI widget behavior |
| Integration test | Complete app flow |

Example:

```text
Unit -> validate email function
Widget -> login button shows error
Integration -> full login flow
```

---

### B92. Mock vs fake

**Interview answer:**  

| Mock | Fake |
|---|---|
| Checks method calls/interactions | Simple working implementation |
| Usually generated/configured | Hand-written test class |

Example:

```text
Mock -> verify getUser() was called
Fake -> returns test user data
```

---

### B93. What is a golden test?

**Interview answer:**  
A golden test checks UI screenshot output.

It compares the current UI with an approved image.

```text
Current UI image == Golden image
```

It helps catch visual changes.

---

### B94. What is CI/CD?

**Interview answer:**  

| Term | Meaning |
|---|---|
| CI | Automatically test code changes |
| CD | Automatically prepare or release builds |

Example:

```text
Push code -> Run tests -> Build app -> Deploy/release
```

---

### B95. How do you reduce app size?

**Interview answer:**  
Ways to reduce Flutter app size:

- Remove unused packages
- Remove unused assets
- Compress images
- Use app bundles
- Enable shrinking/minification
- Split debug symbols
- Analyze app size

---

### B96. How do you find memory leaks?

**Interview answer:**  
Use Flutter DevTools memory tools.

Common causes:
- Not disposing controllers
- Not cancelling streams
- Active timers
- Stored `BuildContext`
- Large caches
- Growing lists

Always dispose owned resources.

---

### B97. Foreground, background, and terminated notification handling

**Interview answer:**  

| App state | Handling |
|---|---|
| Foreground | App is open, update UI or show local notification |
| Background | App is not visible, do limited background work |
| Terminated | App is closed, handle notification tap on startup |

Deep link navigation should happen after app initialization.

---

### B98. What is a deep link?

**Interview answer:**  
A deep link opens a specific screen in the app using a link.

Example:

```text
myapp://notes/10
```

It can directly open note details, product details, or profile screen.

Always validate route data and user permission.

---

### B99. How should payment integration be secured?

**Interview answer:**  
Payment security should mainly be handled by the backend.

Flow:

```text
App -> Backend creates order
App -> Opens payment gateway
Gateway -> Sends result/webhook to backend
Backend -> Verifies payment
App -> Shows final status
```

Never keep secret keys inside the Flutter app.

---

### B100. How do you answer “describe a production issue”?

**Interview answer:**  
Use the STAR method.

```text
Situation -> Task -> Action -> Result
```

Include:
- What happened
- How you found the issue
- Root cause
- Fix
- Testing/verification
- Final result
- Prevention for future

Example:

```text
Situation: App was crashing on login for some users.
Task: Find and fix the crash.
Action: Checked logs, found null user data issue, added null handling and test.
Result: Crash was fixed and login became stable.
```

Do not fake experience. If it was not real, say “I would handle it like this”.

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
