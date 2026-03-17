#!/usr/bin/env bash
set -euo pipefail

# 1) Копируем содержимое Swift-шаблона в текущую папку
cp -a ~/Dev/Templates/Swift/. .

# 2) Переименовываем каталог и файлы на верхнем уровне
mv _claude .claude
mv _claudeignore .claudeignore
mv _markdownlint.yaml .markdownlint.yaml
