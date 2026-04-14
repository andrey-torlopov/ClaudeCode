# Swift Concurrency Rules

## Structured vs Unstructured Concurrency

### Prefer structured concurrency

| Situation | Correct | Wrong |
|----------|-----------|-------------|
| Parallel queries | `async let a = ...; async let b = ...` | `Task { } + Task { }` ​​|
| N parallel tasks | `withTaskGroup { }` | Array `Task { }` ​​|
| Sequential steps | `await step1(); await step2()` | Callback chain |
| Timeout | `withTimeout { }` | `Task.sleep` ​​+ cancel |

### When Task {} is valid

- Launching async work from a sync context (onAppear, viewDidLoad)
- Fire-and-forget operations (logging, analytics)

### Task.detached() - almost never

Use only when you need to **explicitly detach** from the current actor context. In 99% of cases the usual Task {} is enough.

## Sendable

### Types that must be Sendable

- All types passed between actors
- All types in @Sendable closures
- Value types (struct, enum) with Sendable properties - automatically Sendable

### @unchecked Sendable

Allowed ONLY with a justification comment:
```swift
// @unchecked Sendable: thread safety ensured via internal lock
final class ThreadSafeCache: @unchecked Sendable { ... }
```

No comment - WARNING.

## Actor Isolation

### @MainActor

- All UI properties and methods
- All @Published properties in ObservableObject used from UI
- Instead of DispatchQueue.main.async - @MainActor

### Custom Actors

- For shared mutable state
- Instead of DispatchQueue + lock
- Instead of NSLock / os_unfair_lock

### Nonisolated

- For computed properties without side effects
- For methods that do not access the isolated state
- For Hashable/Equatable conformance

## [weak self] patterns in Task

```swift
// Correct: weak self, strengthen before use
Task { [weak self] in
    let data = await fetchData()
    guard let self else { return }
    self.updateUI(data)
}

// Incorrect: boost self immediately
Task { [weak self] in
    guard let self else { return } // <- too early
    let data = await self.fetchData()
    self.updateUI(data)
}
```

## Migration from GCD

| GCD | Swift Concurrency |
|-----|-------------------|
| `DispatchQueue.main.async { }` | `@MainActor func` ​​or `await MainActor.run { }` |
| `DispatchQueue.global().async { }` | `Task { }` |
| `DispatchGroup` | `async let` ​​or `withTaskGroup` |
| `DispatchSemaphore` | `AsyncStream` ​​or actor |
| `DispatchQueue(label:) + sync` | `actor` |
| `NSLock` | `actor` |
| `Thread.sleep` | `Task.sleep(for:)` |
