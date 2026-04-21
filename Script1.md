#!/bin/bash

# Скрипт для создания репозитория Git и сохранения списка пакетов с "git"

# Проверка наличия аргумента (ФИО)
=
if [ $# -eq 0 ]; then
    echo "Ошибка: укажите ваше ФИО на английском языке."
    echo "Пример: $0 Ivanov_Ivan_Ivanovich"
    exit 1
fi
=

FULLNAME="$1"
HOME_DIR="$HOME"
TARGET_DIR="$HOME_DIR/$FULLNAME"
PACKAGE_LIST_FILE="$HOME_DIR/git_packages_list.txt"
REPO_FILE_NAME="git_packages_list.txt"
=

# 1. Создание папки для репозитория (если её нет)
mkdir -p "$TARGET_DIR" || { echo "Не удалось создать папку $TARGET_DIR"; exit 1; }
=

# 2. Переход в папку и инициализация Git-репозитория
cd "$TARGET_DIR" || { echo "Не удалось перейти в $TARGET_DIR"; exit 1; }
if [ ! -d ".git" ]; then
    git init
    echo "Git-репозиторий инициализирован в $TARGET_DIR"
fi
=

# 3. Получение списка установленных пакетов, содержащих "git" в имени
#    Используется rpm -qa (подходит для РЕД ОС на базе RPM)
rpm -qa | grep git > "$PACKAGE_LIST_FILE"

# Проверка успешности создания файла
if [ ! -f "$PACKAGE_LIST_FILE" ]; then
    echo "Не удалось создать файл со списком пакетов."
    exit 1
fi
echo "Список пакетов сохранён в $PACKAGE_LIST_FILE"
=

# 4. Копирование файла в репозиторий
cp "$PACKAGE_LIST_FILE" "$TARGET_DIR/$REPO_FILE_NAME"
=

# 5. Добавление файла в индекс Git и коммит
cd "$TARGET_DIR"
git add "$REPO_FILE_NAME"
=

# Проверка, есть ли изменения для коммита
if git diff --cached --quiet; then
    echo "Нет изменений для коммита (файл уже актуален)."
else
    git commit -m "Add list of installed git-related packages"
    echo "Файл зафиксирован в истории репозитория."
=
fi

echo "Готово. Репозиторий: $TARGET_DIR" 
