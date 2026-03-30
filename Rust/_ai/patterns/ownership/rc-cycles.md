# Rc<RefCell<T>> циклические ссылки

## Applies to
- Двусторонние связи между структурами через `Rc<RefCell<T>>`
- Графовые структуры данных, деревья с parent-ссылками
- Observer/listener паттерны с обратными ссылками
- Аналогичная проблема с `Arc<Mutex<T>>` в многопоточном коде

## Why this is bad
- Rc использует reference counting - цикл означает, что счетчик никогда не достигнет 0
- Память утекает навсегда - Drop не вызывается для объектов в цикле
- В отличие от языков с GC (Java, Go), Rust не имеет cycle collector
- Утечка накапливается - каждая итерация создает новый неосвобождаемый цикл

## Bad Example

```rust
use std::cell::RefCell;
use std::rc::Rc;

struct Node {
    value: String,
    children: Vec<Rc<RefCell<Node>>>,
    parent: Option<Rc<RefCell<Node>>>, // Цикл: parent -> child -> parent
}

fn build_tree() {
    let parent = Rc::new(RefCell::new(Node {
        value: "root".to_owned(),
        children: vec![],
        parent: None,
    }));

    let child = Rc::new(RefCell::new(Node {
        value: "leaf".to_owned(),
        children: vec![],
        parent: Some(Rc::clone(&parent)), // strong ref на parent
    }));

    parent.borrow_mut().children.push(Rc::clone(&child));

    // После выхода из функции:
    // parent refcount = 1 (child.parent) - не 0
    // child refcount = 1 (parent.children) - не 0
    // Ни один Drop не вызовется - утечка памяти
}
```

## Good Example

```rust
use std::cell::RefCell;
use std::rc::{Rc, Weak};

struct Node {
    value: String,
    children: Vec<Rc<RefCell<Node>>>,
    parent: Option<Weak<RefCell<Node>>>, // Weak не увеличивает strong count
}

impl Node {
    fn new(value: &str) -> Rc<RefCell<Node>> {
        Rc::new(RefCell::new(Node {
            value: value.to_owned(),
            children: vec![],
            parent: None,
        }))
    }

    fn add_child(parent: &Rc<RefCell<Node>>, child: &Rc<RefCell<Node>>) {
        child.borrow_mut().parent = Some(Rc::downgrade(parent));
        parent.borrow_mut().children.push(Rc::clone(child));
    }
}

fn build_tree() {
    let parent = Node::new("root");
    let child = Node::new("leaf");

    Node::add_child(&parent, &child);

    // parent refcount = 1 (локальная переменная), weak count = 1 (child.parent)
    // child refcount = 2 (локальная переменная + parent.children)
    // При drop parent: children drop, child refcount = 1
    // При drop child: refcount = 0, Drop вызывается, Weak становится невалидным
}

// Доступ к parent через Weak:
fn get_parent_value(node: &Rc<RefCell<Node>>) -> Option<String> {
    node.borrow()
        .parent
        .as_ref()
        .and_then(|weak| weak.upgrade()) // Option<Rc<...>> - None если parent уже drop
        .map(|parent| parent.borrow().value.clone())
}
```

### Правило для Arc (многопоточная версия)

Та же проблема существует с `Arc<Mutex<T>>`:

```rust
// Плохо: Arc -> Arc цикл
struct Worker {
    manager: Arc<Mutex<Manager>>,
}
struct Manager {
    workers: Vec<Arc<Mutex<Worker>>>,
}

// Хорошо: Arc -> Weak для обратных ссылок
struct Worker {
    manager: Weak<Mutex<Manager>>,
}
struct Manager {
    workers: Vec<Arc<Mutex<Worker>>>,
}
```

## What to look for in code review
- `Rc<RefCell<T>>` в двух struct, которые ссылаются друг на друга
- `Arc<Mutex<T>>` с обратными ссылками
- Отсутствие `Weak` в графовых структурах данных
- `.upgrade()` вызовы без обработки `None` - parent мог быть уже освобожден
- `Rc::strong_count()` в debug логах - косвенный признак подозрения на утечку
