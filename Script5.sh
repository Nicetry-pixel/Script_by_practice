#!/bin/bash

# Скрипт для извлечения временного пароля root MySQL из лог-файла
# и вывода его через cowsay с драконом.

LOG_FILE="/var/log/mysqld.log"

# Проверка существования лог-файла
if [ ! -f "$LOG_FILE" ]; then
    echo "Ошибка: Файл $LOG_FILE не найден." >&2
    exit 1
fi

# Поиск строки с временным паролем
# Типичный формат: "A temporary password is generated for root@localhost: AbcD!2345"
PASSWORD_LINE=$(grep -i "temporary password" "$LOG_FILE" | tail -1)

if [ -z "$PASSWORD_LINE" ]; then
    echo "Ошибка: Временный пароль root MySQL не найден в $LOG_FILE" >&2
    echo "Возможно, пароль уже был изменён или MySQL не был запущен впервые." >&2
    exit 1
fi

# Извлечение пароля (после последнего двоеточия и пробела)
PASSWORD=$(echo "$PASSWORD_LINE" | sed 's/.*: //')

# Проверка наличия cowsay
if ! command -v cowsay &>/dev/null; then
    echo "Утилита cowsay не установлена. Вывод без неё:"
    echo "Временный пароль root MySQL: $PASSWORD"
else
    # Вывод пароля через cowsay с драконом
    echo "$PASSWORD" | cowsay -f dragon
fi

# Сохранение скрипта в истории Git-репозитория (если он внутри репозитория)
SCRIPT_PATH=$(realpath "$0")
if git rev-parse --git-dir >/dev/null 2>&1; then
    git add "$SCRIPT_PATH" 2>/dev/null
    git commit -m "Add script to show temporary MySQL root password with cowsay" 2>/dev/null \
        && echo "Скрипт добавлен в историю Git." \
        || echo "Нет изменений для коммита (скрипт уже в репозитории)."
else
    echo "Скрипт не находится в Git-репозитории. Для сохранения результата выполните вручную:"
    echo "  git add $SCRIPT_PATH"
    echo "  git commit -m 'Add script to show temporary MySQL root password with cowsay'"
fi
