#!/bin/bash

# Скрипт поиска пакетов в репозиториях, начинающихся на "mysql"
# Выводит только имена пакетов, выделяя mysql-community-server

set -e

# Цвета: красный текст на жёлтом фоне
COLOR_START='\033[31;43m'
COLOR_END='\033[0m'

# Функция для получения списка пакетов, начинающихся на mysql
get_mysql_packages() {
    # Пробуем использовать repoquery (из dnf-utils / yum-utils)
    if command -v repoquery &>/dev/null; then
        repoquery --available --queryformat "%{name}" 2>/dev/null | grep '^mysql'
    elif command -v dnf &>/dev/null; then
        # Альтернатива: парсим вывод dnf list available
        dnf list available --quiet 2>/dev/null | awk '/^mysql/ {print $1}' | sed 's/\.[^.]*$//'
    else
        echo "Не найдены команды repoquery или dnf" >&2
        exit 1
    fi
}

# Получаем список пакетов
packages=$(get_mysql_packages)

if [ -z "$packages" ]; then
    echo "Пакеты, начинающиеся на 'mysql', не найдены в репозиториях."
    exit 0
fi

# Выводим каждый пакет, выделяя mysql-community-server
while IFS= read -r pkg; do
    if [ "$pkg" = "mysql-community-server" ]; then
        echo -e "${COLOR_START}${pkg}${COLOR_END}"
    else
        echo "$pkg"
    fi
done <<< "$packages"

# Сохраняем скрипт в истории Git-репозитория (если он внутри репозитория)
SCRIPT_PATH=$(realpath "$0")
if git rev-parse --git-dir >/dev/null 2>&1; then
    git add "$SCRIPT_PATH" 2>/dev/null
    git commit -m "Add script to list mysql* packages from repositories" 2>/dev/null \
        && echo "Скрипт добавлен в историю Git." \
        || echo "Нет изменений для коммита (скрипт уже в репозитории)."
else
    echo "Скрипт не находится в Git-репозитории. Для сохранения результата выполните вручную:"
    echo "  git add $SCRIPT_PATH"
    echo "  git commit -m 'Add script to list mysql* packages'"
fi
