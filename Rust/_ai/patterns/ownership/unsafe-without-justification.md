# unsafe без обоснования

## Applies to
- Любой `unsafe` блок или `unsafe fn` в кодовой базе
- FFI вызовы, raw pointer операции, реализации unsafe trait

## Why this is bad
- unsafe снимает гарантии компилятора - каждый блок должен быть обоснован
- Без комментария `// SAFETY:` невозможно верифицировать корректность при code review
- Clippy lint `clippy::undocumented_unsafe_blocks` ловит это автоматически
- Баги в unsafe - undefined behavior, а не паника; отлаживать на порядок сложнее

## Bad Example

```rust
fn read_value(ptr: *const u32) -> u32 {
    unsafe { *ptr }
}

fn extend_lifetime<'a, T>(value: &T) -> &'a T {
    unsafe { std::mem::transmute(value) }
}

unsafe impl Send for MyWrapper {}

fn call_c_function(data: *mut u8, len: usize) {
    unsafe {
        libc::memset(data, 0, len);
    }
}
```

## Good Example

```rust
fn read_value(ptr: *const u32) -> u32 {
    // SAFETY: Вызывающий код гарантирует, что ptr не null и выровнен.
    // Время жизни данных обеспечивается владением буфером в CallerStruct.
    unsafe { *ptr }
}

fn extend_lifetime<'a, T>(value: &T) -> &'a T {
    // SAFETY: Вызывается только внутри with_extended_ref(), где
    // время жизни T гарантированно превышает 'a за счет arena аллокатора.
    unsafe { std::mem::transmute(value) }
}

// SAFETY: MyWrapper содержит только AtomicU64, который сам Send.
// Обертка не добавляет interior mutability.
unsafe impl Send for MyWrapper {}

fn call_c_function(data: *mut u8, len: usize) {
    // SAFETY: data указывает на валидный буфер размером >= len байт.
    // Буфер выделен через Vec::with_capacity(len) и не освобождается
    // до завершения вызова.
    unsafe {
        libc::memset(data, 0, len);
    }
}
```

### Структура SAFETY комментария

Хороший `// SAFETY:` отвечает на вопросы:
1. Почему инвариант выполняется? (не "что делает код", а "почему это безопасно")
2. Кто гарантирует? (вызывающий код, конструктор, тип-обертка)
3. Что сломается при нарушении? (null deref, data race, UB)

## What to look for in code review
- `unsafe {` без `// SAFETY:` комментария на строке выше
- `unsafe impl` без объяснения, почему trait может быть реализован безопасно
- `// SAFETY: trust me` или `// SAFETY: safe` - не считается обоснованием
- `unsafe fn` без документации инвариантов в doc-комментарии
- Несколько операций внутри одного unsafe блока - каждая должна быть обоснована
