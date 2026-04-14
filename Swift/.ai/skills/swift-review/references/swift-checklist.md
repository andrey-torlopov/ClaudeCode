# Swift Code Review Checklist

## Memory Safety

| # | Check | Severity | Grep pattern |
|---|---------|----------|-------------|
| M-1 | Escaping closure without [weak self] | BLOCKER | `@escaping.*\{[^w]*self\.` |
| M-2 | Delegate property without weak | BLOCKER | `var delegate:` (without weak) |
| M-3 | Force unwrap (!) outside tests and IBOutlet | CRITICAL | `[^?]!` in non-test files |
| M-4 | Implicitly unwrapped optional without justification | WARNING | `var.*:.*!` |
| M-5 | Unowned reference | WARNING | `unowned` |
| M-6 | Closure capture list is missing from escaping | WARNING | escaping closure without `[` |
| M-7 | Strong self in Task without necessity | INFO | `Task.*\{.*self\.` without weak |

### Rules

- In Task: if we use [weak self], we do not strengthen self immediately, but only before the first use
- Delegate, dataSource - always weak
- Timer, NotificationCenter callbacks - always weak self
- DispatchQueue closures - weak self if long-running

## Concurrency

Full rules: `concurrency-rules.md`

| # | Check | Severity |
|---|---------|----------|
| C-1 | Mutable shared state without synchronization | BLOCKER |
| C-2 | DispatchQueue.main instead of @MainActor | CRITICAL |
| C-3 | The type is passed between actors without Sendable | CRITICAL |
| C-4 | Task {} instead of structured concurrency | WARNING |
| C-5 | Task.detached() without explicit need | WARNING |
| C-6 | @unchecked Sendable without justification comment | WARNING |
| C-7 | Completion handler instead of async/await | INFO |
| C-8 | NSLock/Semaphore instead of actor | INFO |

## Swift Conventions

| # | Check | Severity |
|---|---------|----------|
| S-1 | var where let | WARNING |
| S-2 | class where struct is sufficient | WARNING |
| S-3 | Nested if let instead of guard | WARNING |
| S-4 | Any/AnyObject without need | WARNING |
| S-5 | .init instead of an explicit type name | INFO |
| S-6 | Naming not according to Swift API Design Guidelines | INFO |
| S-7 | Boolean without is/has/should prefix | INFO |
| S-8 | enum for single values ​​(preferably struct) | INFO |

## Error Handling

| # | Check | Severity |
|---|---------|----------|
| E-1 | Empty catch {} | CRITICAL |
| E-2 | try? with error loss without logging | WARNING |
| E-3 | Optional for error states instead of throws | WARNING |
| E-4 | fatalError() in production code | BLOCKER |
| E-5 | Raw Result.failure | WARNING |

## Performance

| # | Check | Severity |
|---|---------|----------|
| P-1 | Calculations in body SwiftUI View | WARNING |
| P-2 | Extra allocations in the hot path | INFO |
| P-3 | No lazy for heavy properties | INFO |
| P-4 | Array instead of Set for search/contains | INFO |

## Architecture

| # | Check | Severity |
|---|---------|----------|
| A-1 | File > 500 lines | WARNING |
| A-2 | Class/Structure > 300 lines | WARNING |
| A-3 | Function > 50 lines | INFO |
| A-4 | UI logic in ViewModel/business layer | CRITICAL |
| A-5 | Business logic in View | WARNING |
| A-6 | Hard dependency instead of protocol | INFO |

## SwiftUI Specific

| # | Check | Severity |
|---|---------|----------|
| U-1 | @ObservedObject where @StateObject is needed | CRITICAL |
| U-2 | @State for reference type | CRITICAL |
| U-3 | Heavy calculations in body | WARNING |
| U-4 | Deep nesting View (>5 levels) | INFO |
| U-5 | Lack of @ViewBuilder for conditional Views | INFO |
