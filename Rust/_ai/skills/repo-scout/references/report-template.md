# Шаблон отчета repo-scout-report.md

```markdown
# Repo Scout Report: {project-name}

> Сгенерировано: {дата} | Скилл: /repo-scout

## 1. Project Profile

| Параметр | Значение |
|----------|----------|
| Project | {название из Cargo.toml package.name} |
| Type | {Library / Binary / Workspace / Mixed} |
| Edition | {2018 / 2021} |
| MSRV | {rust-version из Cargo.toml или "не указан"} |
| Package Manager | Cargo |
| Source Files | {N .rs файлов в src/} |
| Test Files | {N тестовых .rs файлов} |
| Benchmark Files | {N файлов в benches/} |

## 2. Module Structure

| Crate / модуль | Тип | Rust файлов | Описание |
|---------------|-----|:-----------:|----------|
| {crate name} | {lib/bin/test/bench/example} | {N} | {краткое описание} |

## 3. Dependencies Catalog

### Production Dependencies

| # | Crate | Версия | Категория |
|---|-------|--------|-----------|
| 1 | {crate} | {version} | {async-runtime/serialization/web-framework/database/CLI/logging/error-handling/crypto/utilities} |

### Dev Dependencies

| # | Crate | Версия | Категория |
|---|-------|--------|-----------|
| 1 | {crate} | {version} | {testing/utilities} |

### Build Dependencies

| # | Crate | Версия | Назначение |
|---|-------|--------|-----------|
| 1 | {crate} | {version} | {назначение} |

**Итого:** {N} зависимостей ({X} production + {Y} dev + {Z} build)

## 4. Architecture Summary

| Аспект | Значение | Детали |
|--------|----------|--------|
| Async Runtime | {tokio / async-std / smol / нет} | {детали} |
| Web Framework | {axum / actix-web / warp / rocket / нет} | {детали} |
| Serialization | {serde / manual / нет} | {детали} |
| Database | {sqlx / diesel / sea-orm / rusqlite / нет} | {детали} |
| Error Strategy | {thiserror+anyhow / eyre / custom} | {детали} |
| Concurrency | {tokio / rayon / crossbeam / std} | {детали} |
| CLI | {clap / structopt / argh / нет} | {детали} |

## 5. Test Coverage

| Тип | Файлов | Расположение | Фреймворк |
|-----|:------:|-------------|-----------|
| Unit | {N} | src/ (#[cfg(test)]) | std #[test] |
| Integration | {N} | tests/ | {фреймворк} |
| Doc tests | {N} | src/ (/// blocks) | rustdoc |
| Benchmarks | {N} | benches/ | {criterion / divan} |
| Property | {N} | {путь} | {proptest / quickcheck} |

## 6. Infrastructure

| Компонент | Наличие | Детали |
|-----------|:-------:|--------|
| CI/CD | {есть/нет} | {GitHub Actions / GitLab CI / Jenkins} |
| Clippy | {есть/нет} | {clippy.toml: кол-во правил} |
| Rustfmt | {есть/нет} | {rustfmt.toml: детали} |
| cargo-deny | {есть/нет} | {deny.toml: детали} |
| MIRI | {есть/нет} | {использование в CI} |
| Docker | {есть/нет} | {Dockerfile / docker-compose} |
| Code Generation | {есть/нет} | {build.rs / proc macros} |

## 7. AI Setup Status

| Файл | Статус |
|------|--------|
| CLAUDE.md | {есть / нет} |
| _ai/skills/ | {N скиллов / нет} |
| _ai/commands/ | {N команд / нет} |
| .cursor/rules/ | {есть / нет} |

## 8. Readiness Assessment

### Сильные стороны
- {пункт 1}
- {пункт 2}

### Области для улучшения
- {пункт 1}
- {пункт 2}

### Рекомендуемый следующий шаг

{Конкретная рекомендация: /init-project, /rust-review, "настроить CI/CD" и т.д.}
```
