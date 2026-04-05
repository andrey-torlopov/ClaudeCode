# No Artifact Versioning

## Why this is bad

- Перезапись артефакта с тем же именем означает невозможность воспроизвести предыдущий деплой
- Без чексуммы нельзя проверить целостность артефакта - подмена остается незамеченной
- Мутабельные теги (`:latest`, `:stable`) не дают понять какой код в production прямо сейчас
- Аудит и compliance требуют трассируемости: git commit -> build -> artifact -> deploy

## Bad Example

```bash
# BAD: перезапись одного и того же артефакта
docker build -t myapp:latest .
docker push myapp:latest

# BAD: имя файла без версии
aws s3 cp app.tar.gz s3://releases/app.tar.gz
```

```yaml
# BAD: мутабельный тег в деплойменте
spec:
  containers:
    - name: app
      image: registry.example.com/myapp:latest
      imagePullPolicy: Always
```

## Good Example

```bash
# GOOD: иммутабельный тег + digest + чексумма
VERSION="1.5.2"
GIT_SHA=$(git rev-parse --short HEAD)
IMAGE="registry.example.com/myapp:${VERSION}-${GIT_SHA}"

docker build -t "${IMAGE}" .
docker push "${IMAGE}"

DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "${IMAGE}")
echo "${DIGEST}" > artifact-digest.txt
```

```yaml
# GOOD: CI/CD пайплайн с полной трассируемостью артефактов
name: Release
on:
  push:
    tags: ["v*"]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build and push
        run: |
          IMAGE="registry.example.com/myapp:${{ github.ref_name }}"
          docker build -t "${IMAGE}" .
          docker push "${IMAGE}"

      - name: Generate checksums
        run: |
          docker save myapp:${{ github.ref_name }} | sha256sum > checksums.txt

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: checksums.txt
          generate_release_notes: true
```

## What to look for in review

- `docker push <image>:latest` как единственный тег при релизе
- Артефакты без версии в имени файла (`app.tar.gz` вместо `app-1.5.2.tar.gz`)
- Отсутствие `sha256sum` / чексумм рядом с артефактами
- `imagePullPolicy: Always` с мутабельным тегом вместо digest
- Нет GitHub Release / changelog при выпуске новой версии
