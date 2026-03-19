# Справочник Rust-паттернов для repo-scout

## Project Files

| Файл | Назначение |
|------|-----------|
| `Cargo.toml` | Зависимости, metadata, features, workspace |
| `Cargo.lock` | Зафиксированные версии зависимостей |
| `build.rs` | Build script (code generation, linking) |
| `.cargo/config.toml` | Cargo configuration (target, linker, aliases) |
| `rustfmt.toml` | Конфигурация rustfmt |
| `clippy.toml` | Конфигурация clippy |
| `rust-toolchain.toml` | Rust version pinning (channel, components) |
| `deny.toml` | Конфигурация cargo-deny (licenses, advisories) |

## Architecture Detection Patterns

### Web Framework

| Паттерн в коде | Технология |
|----------------|-----------|
| `use axum` | axum |
| `use actix_web` | actix-web |
| `use warp` | warp |
| `use rocket` | rocket |

### Serialization

| Паттерн в коде | Технология |
|----------------|-----------|
| `use serde` | serde |
| `#[derive(Serialize, Deserialize)]` | serde derive |
| `use bincode` | bincode |
| `use postcard` | postcard |

### Async Runtime

| Паттерн в коде | Технология |
|----------------|-----------|
| `#[tokio::main]` | tokio |
| `use async_std` | async-std |
| `use smol` | smol |

### Database

| Паттерн в коде | Технология |
|----------------|-----------|
| `use sqlx` | sqlx |
| `use diesel` | diesel |
| `use sea_orm` | sea-orm |
| `use rusqlite` | rusqlite |

### CLI

| Паттерн в коде | Технология |
|----------------|-----------|
| `use clap` | clap |
| `#[derive(Parser)]` | clap derive |
| `use structopt` | structopt (legacy) |
| `use argh` | argh |

### Error Handling

| Паттерн в коде | Технология |
|----------------|-----------|
| `use thiserror` | thiserror (library errors) |
| `use anyhow` | anyhow (application errors) |
| `use eyre` | eyre |
| `use color_eyre` | color-eyre (pretty errors) |

### Logging / Tracing

| Паттерн в коде | Технология |
|----------------|-----------|
| `use tracing` | tracing |
| `use log` | log facade |
| `use env_logger` | env_logger |
| `use slog` | slog |

### Concurrency

| Паттерн в коде | Технология |
|----------------|-----------|
| `use tokio` | tokio (async runtime) |
| `use rayon` | rayon (data parallelism) |
| `use crossbeam` | crossbeam (lock-free structures) |
| `Arc<Mutex<` | std mutex |
| `use parking_lot` | parking_lot (fast locks) |

## Test Patterns

| Тип | Паттерн / расположение |
|-----|----------------------|
| Unit | `#[test]`, `#[cfg(test)]` модули внутри `src/` |
| Integration | `tests/` директория |
| Benchmark | `benches/`, `criterion` |
| Property | `proptest!`, `#[proptest]` |
| Doc tests | `///` с code blocks (тройной backtick) |
| Async tests | `#[tokio::test]`, `#[async_std::test]` |
| Parametrized | `#[rstest]`, `#[case]` |

## Infrastructure Markers

### CI/CD

| Файл / паттерн | Технология |
|----------------|-----------|
| `.github/workflows/*.yml` | GitHub Actions |
| `.gitlab-ci.yml` | GitLab CI |
| `Jenkinsfile` | Jenkins |
| `.circleci/config.yml` | CircleCI |

### Containerization

| Файл / паттерн | Технология |
|----------------|-----------|
| `Dockerfile` | Docker |
| `.dockerignore` | Docker ignore |
| `docker-compose*.yml` | Docker Compose |

### Quality Tools

| Файл / паттерн | Технология |
|----------------|-----------|
| `clippy.toml` | Clippy (linter) |
| `rustfmt.toml` | rustfmt (formatter) |
| `deny.toml` | cargo-deny (dependency audit) |
| `rust-toolchain.toml` | Rust toolchain pinning |

## AI Setup Files

| Файл / паттерн | Технология |
|----------------|-----------|
| `CLAUDE.md` | Claude Code |
| `.ai/skills/*/SKILL.md` | Claude Code Skills |
| `.ai/commands/*.md` | Claude Code Commands |
| `.ai/agents/*.md` | Claude Code Agents |
| `AGENTS.md` | Zed / Cline / Continue.dev |
| `.cursor/rules/*.mdc` | Cursor IDE |
| `.github/copilot-instructions.md` | GitHub Copilot |

## Dependency Categories

| Категория | Примеры crate-ов |
|-----------|------------------|
| async-runtime | tokio, async-std, smol |
| serialization | serde, serde_json, bincode, postcard, toml, ron |
| web-framework | axum, actix-web, warp, rocket, poem |
| database | sqlx, diesel, sea-orm, rusqlite, mongodb |
| CLI | clap, structopt, argh, dialoguer, indicatif |
| testing | criterion, proptest, rstest, mockall, wiremock, fake |
| logging | tracing, tracing-subscriber, log, env_logger, slog |
| error-handling | thiserror, anyhow, eyre, color-eyre, miette |
| crypto | ring, rustls, openssl, aes, sha2, argon2 |
| http-client | reqwest, hyper, ureq, surf |
| utilities | once_cell, lazy_static, itertools, regex, chrono, uuid |
