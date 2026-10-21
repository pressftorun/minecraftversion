# Create Server — клиент

[![Client release](https://github.com/pressftorun/minecraftversion/actions/workflows/release.yml/badge.svg)](https://github.com/pressftorun/minecraftversion/actions/workflows/release.yml)
[![Release](https://img.shields.io/github/v/release/pressftorun/minecraftversion)](https://github.com/pressftorun/minecraftversion/releases/latest)
[![License: MIT](https://img.shields.io/badge/Original_code-MIT-blue.svg)](LICENSE)

Minecraft **1.21.1**, NeoForge **21.1.264**, **57 модов**.
Сервер: `46.146.228.125:25565`. [BlueMap](http://46.146.228.125:8100/).

[Установить](#скачать-и-установить) · [Изменения](CHANGELOG.md) · [Внести изменения](CONTRIBUTING.md) · [Безопасность](SECURITY.md)

Готовая клиентская сборка для сервера Create: моды, настройки и оформление игры. Сам лаунчер разрабатывается отдельно в [minecraftlauncher](https://github.com/pressftorun/minecraftlauncher).

## Скачать и установить

Скачайте [Create Launcher](https://github.com/pressftorun/minecraftlauncher/releases/latest), распакуйте и нажмите «Установить и играть».
Лаунчер автоматически скачает актуальный `client.zip`, проверит SHA-256 и установит клиент, Java и моды в свою папку.
Для обновления закройте Minecraft и нажмите «Проверить файлы».

Для ручной установки `client.zip` и `client.zip.sha256` доступны в [Releases](https://github.com/pressftorun/minecraftversion/releases).

В сборке есть меню и экран загрузки с иконкой блока травы, а также исходные настройки клиента.
Миры, аккаунты, токены и пользовательский список серверов не публикуются.
Minecraft, Java и загрузчик скачиваются лаунчером отдельно и не входят в репозиторий.

## Структура репозитория

| Путь | Назначение |
| --- | --- |
| `pack/mods/` | JAR-файлы модов клиента |
| `pack/config/` | Настройки модов и ресурсы оформления |
| `pack/manifest.json` | Версии игры/загрузчика и SHA-256 файлов |
| `release_client.ps1` | Подготовка манифеста, ZIP и контрольной суммы |
| `release/` | Локальный результат упаковки; исключён из Git |
| `RELEASE.md` | Описание публикуемого релиза |
| `.github/workflows/release.yml` | Упаковка и публикация в GitHub Actions |

## Обновление сборки

Изменяйте моды и конфиги в `pack/`, затем выполните `pwsh ./release_client.ps1`.
Архив и SHA-256 появятся в `release/`. Скрипт обновляет `pack/manifest.json` и проверяет, что NeoLogin не попал в клиент. Сам скрипт ничего не публикует; GitHub Actions собирает и публикует пакет после обновления `main`.
Игроку для распаковки сборки Python или PowerShell не нужны.

Не копируйте в `pack/` всю пользовательскую установку. После изменения файлов заново выполните упаковку, чтобы обновить хеши. Полные инструкции: [внесение изменений](CONTRIBUTING.md) и [выпуск релиза](docs/RELEASING.md).

## Сообщить о проблеме

Ошибка установки, интерфейса или профиля — [issues лаунчера](https://github.com/pressftorun/minecraftlauncher/issues/new/choose). Ошибка модов, игрового меню или настроек пакета — [issues клиента](https://github.com/pressftorun/minecraftversion/issues/new/choose).

Укажите версию сборки, ОС, дополнительные моды и шаги воспроизведения. Перед отправкой журнала удалите личные сведения. Для уязвимостей используйте [SECURITY.md](SECURITY.md).

## Лицензии и авторство

[MIT](LICENSE) распространяется на оригинальные скрипты и созданное для проекта оформление.
Сторонние моды и шейдеры сохраняют лицензии авторов, вложенные в их JAR/ZIP; см. [NOTICE.md](NOTICE.md).
Оформление и скрипты разработаны при помощи OpenAI Codex.

## Исправление от 22.10.2026

Из клиентского пакета удалён NeoLogin 1.1.2. Это серверный мод: установленный на клиенте, он отменяет взаимодействие с блоками даже после успешного `/login` на отдельном сервере. В одиночном мире проблема могла не проявляться из-за общего состояния встроенного сервера.

NeoLogin должен оставаться на выделенном сервере. Клиентский лаунчер при «Проверить файлы» удаляет прежний неизменённый JAR из состава пакета. После обновления перезапустите игру и войдите на сервер обычной командой `/login`.
