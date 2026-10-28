# Ресурспаки и шейдеры в стандартной установке

Клиент для **Minecraft 1.21.1 · NeoForge 21.1.264**.

- Добавлен **Faithful 32x**, June 2026 для Minecraft 1.21.1.
- Добавлен **Faithful 64x**, Release 6 для Minecraft 1.21 / 1.21.1.
- Добавлен **Bliss 2.1.2**.
- **Complementary Reimagined r5.9.3** уже входит в комплект; сохранён выбор по умолчанию для новой установки.

Faithful 32x и 64x созданы [Faithful Resource Pack](https://faithfulpack.net) и распространяются под [Faithful License](https://faithfulpack.net/license). Версии, ссылки на авторов и лицензии всех четырёх пакетов указаны в `VISUAL-PACKS.md` внутри клиента и в [репозитории](https://github.com/pressftorun/minecraftversion/blob/main/pack/VISUAL-PACKS.md). Оригинальные ZIP не изменены.

## Как установить

Закройте Minecraft и нажмите **«Проверить файлы»** в [Create Launcher](https://github.com/pressftorun/minecraftlauncher/releases/latest). При новой установке все четыре пакета скачиваются вместе с клиентом. Переустановка лаунчера не требуется.

Выберите Faithful 32x или 64x в «Настройки → Наборы ресурсов», а Bliss или Complementary Reimagined — в настройках графики Iris. Ресурспаки автоматически не включаются. Пользовательские `options.txt`, настройки графики, оформление FancyMenu и Drippy Loading Screen сохраняются при обновлении.

Для ручной установки скачайте [client.zip](https://github.com/pressftorun/minecraftversion/releases/latest/download/client.zip) и [client.zip.sha256](https://github.com/pressftorun/minecraftversion/releases/latest/download/client.zip.sha256). `optional-mods.zip` содержит только опциональные моды и не устанавливает ресурспаки и шейдеры.

## Проверка

Архивы пакетов сверены с SHA-512 официальных файлов Modrinth. Выполнены тесты упаковки, проверка содержимого ZIP и SHA-256 манифеста, сохранности настроек и оформления. Отдельный тест графического запуска новых пакетов в игре не проводился.
