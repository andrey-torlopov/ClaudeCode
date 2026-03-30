<p align="center">
  <img src="Docs/banner.png" alt="Letopis Logo" width="600"/>
</p>

# Templates

Шаблоны промтов и скиллов для Claude Code.

## Структура

### Rust

Промты, скиллы и конфигурация Claude Code для разработки на Rust.

### Swift

Промты, скиллы и конфигурация Claude Code для разработки на Swift.

## Использование

Скрипты `init_rust.sh` и `init_swift.sh` копируют шаблонные файлы в текущую директорию и переименовывают их (префикс `_` → `.`).

Перейди в папку проекта и запусти нужный скрипт:

```bash
cd ~/MyProject
~/Templates/init_rust.sh
```

### Алиасы

Добавь в `~/.zshrc` алиасы, чтобы не писать полный путь:

```bash
alias initrust='~/Templates/init_rust.sh'
alias initswift='~/Templates/init_swift.sh'
```

После этого в любой папке с проектом достаточно написать `initrust` или `initswift` — все файлы конфигурации Claude Code/Gemini/Codex будут скопированы автоматически.
