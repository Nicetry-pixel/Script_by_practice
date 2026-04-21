#!/bin/bash

# Скрипт для замены $releasever на корректную версию ОС в файлах репозиториев MySQL
# Файлы: mysql-community.repo, mysql-community-source.repo, mysql-community-debuginfo.repo

set -e  # прерывать выполнение при ошибке

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "Пожалуйста, запустите скрипт с правами root (sudo)."
    exit 1
fi

# Определение версии ОС (первая цифра из /etc/redhat-release)
if [ -f /etc/redhat-release ]; then
    OS_VERSION=$(grep -oP '(?<=release )\d+' /etc/redhat-release | head -1)
else
    echo "Не удалось найти /etc/redhat-release. Определение версии ОС невозможно."
    exit 1
fi

if [ -z "$OS_VERSION" ]; then
    echo "Не удалось извлечь номер версии из /etc/redhat-release."
    exit 1
fi

echo "Определена версия ОС: $OS_VERSION"

# Список файлов репозиториев MySQL
REPO_FILES=(
    "/etc/yum.repos.d/mysql-community.repo"
    "/etc/yum.repos.d/mysql-community-source.repo"
    "/etc/yum.repos.d/mysql-community-debuginfo.repo"
)

CHANGED=0
for file in "${REPO_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "Обработка $file"
        # Создание резервной копии
        cp "$file" "${file}.bak"
        # Замена $releasever на актуальную версию
        sed -i "s/\$releasever/$OS_VERSION/g" "$file"
        echo "  - Заменён \$releasever на $OS_VERSION"
        CHANGED=1
    else
        echo "Файл $file не найден, пропускаем."
    fi
done

if [ $CHANGED -eq 1 ]; then
    echo "Готово. Резервные копии сохранены с расширением .bak"
else
    echo "Ни один из файлов репозиториев MySQL не был изменён."
fi

# Сохранение самого скрипта в истории Git-репозитория (если он находится внутри репозитория)
SCRIPT_PATH=$(realpath "$0")
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Скрипт уже внутри Git-репозитория
    git add "$SCRIPT_PATH" > /dev/null 2>&1
    git commit -m "Add script to fix MySQL repo releasever (version $OS_VERSION)" > /dev/null 2>&1 || echo "Нет изменений для коммита (скрипт уже добавлен)."
    echo "Скрипт добавлен в историю Git-репозитория."
else
    echo "Скрипт не находится в Git-репозитории. Чтобы сохранить результат в истории, выполните вручную:"
    echo "  git add $SCRIPT_PATH"
    echo "  git commit -m 'Add script to fix MySQL repo releasever'"
fi
