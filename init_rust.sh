#!/usr/bin/env bash
set -euo pipefail

# 1) Копируем содержимое Swift-шаблона в текущую папку
cp -a ~/Dev/Templates/Rust/. .

# 2) Переименовываем каталог и файлы на верхнем уровне
mv _ai .ai
mv _aiignore .aiignore
mv _markdownlint.yaml .markdownlint.yaml
mv _gitignore .gitignore
