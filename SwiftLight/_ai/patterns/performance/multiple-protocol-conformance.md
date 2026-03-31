# Multiple Protocol Conformance

**Applies to:** Performance, UIKit/SwiftUI cells, reusable components

## Why this is bad

Множество мелких протоколов = множество проверок конформансов в рантайме:
- Каждый протокол проверяется через `swift_conform_protocol`
- В ячейках/компонентах с большим reuse count затраты множатся
- Замена множества протоколов на один дала ускорение в 2.5-3x в Т-Банке

## Bad Example

```swift
// ❌ BAD: Много мелких протоколов для конфигурации ячейки
protocol TitleConfigurable {
    var title: String { get }
}

protocol SubtitleConfigurable {
    var subtitle: String? { get }
}

protocol ImageConfigurable {
    var imageURL: URL? { get }
}

protocol ActionConfigurable {
    var action: (() -> Void)? { get }
}

// Каждый каст к протоколу - отдельный swift_conform_protocol
func configure(cell: UITableViewCell, with model: Any) {
    if let titled = model as? TitleConfigurable {
        cell.textLabel?.text = titled.title
    }
    if let subtitled = model as? SubtitleConfigurable {
        cell.detailTextLabel?.text = subtitled.subtitle
    }
    if let imaged = model as? ImageConfigurable {
        loadImage(imaged.imageURL)
    }
    if let actionable = model as? ActionConfigurable {
        cell.accessoryType = actionable.action != nil ? .disclosureIndicator : .none
    }
}
```

## Good Example

```swift
// ✅ GOOD: Один протокол с опциональными свойствами
protocol CellConfigurable {
    var title: String { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
    var action: (() -> Void)? { get }
}

// Один каст вместо четырех
func configure(cell: UITableViewCell, with model: CellConfigurable) {
    cell.textLabel?.text = model.title
    cell.detailTextLabel?.text = model.subtitle
    if let url = model.imageURL { loadImage(url) }
    cell.accessoryType = model.action != nil ? .disclosureIndicator : .none
}

// ✅ GOOD: Альтернатива - struct конфигурация без кастов
struct CellConfiguration {
    let title: String
    var subtitle: String?
    var imageURL: URL?
    var action: (() -> Void)?
}

func configure(cell: UITableViewCell, with config: CellConfiguration) {
    cell.textLabel?.text = config.title
    cell.detailTextLabel?.text = config.subtitle
    if let url = config.imageURL { loadImage(url) }
    cell.accessoryType = config.action != nil ? .disclosureIndicator : .none
}
```

## What to look for in code review

- Множественные `as?` к разным протоколам для одного объекта
- Декомпозиция на 3+ мелких протоколов для конфигурации UI-компонентов
- Протокольные касты внутри `cellForRow` / `tableView(_:willDisplay:)` и аналогов
- Паттерн "проверяем каждый протокол по очереди" в горячем пути
