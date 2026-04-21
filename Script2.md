=
#!/bin/bash
=
# Скрипт для поиска пакетов по заданной подстроке,
# вывода результата с подсветкой через lolcat и сохранения в Git-репозитории.
=
# Проверка количества аргументов
if [ $# -ne 2 ]; then
    echo "Использование: $0 <ФИО_англ> <подстрока_поиска>"
    echo "Пример: $0 Ivanov_Ivan_Ivanovich git"
    exit 1
fi
=
FULLNAME="$1"
SEARCH_STRING="$2"
HOME_DIR="$HOME"
REPO_DIR="$HOME_DIR/$FULLNAME"
RESULT_FILE_HOME="$HOME_DIR/packages_${SEARCH_STRING}.txt"
RESULT_FILE_REPO="$REPO_DIR/packages_${SEARCH_STRING}.txt"
=
# Проверка наличия lolcat
if ! command -v lolcat &> /dev/null; then
    echo "Утилита lolcat не найдена. Установите её: sudo dnf install lolcat"
    exit 1
fi
=
# 1. Создание папки для репозитория (если её нет)
mkdir -p "$REPO_DIR" || { echo "Не удалось создать папку $REPO_DIR"; exit 1; }
=
# 2. Переход в папку и инициализация Git-репозитория
cd "$REPO_DIR" || { echo "Не удалось перейти в $REPO_DIR"; exit 1; }
if [ ! -d ".git" ]; then
    git init
    echo "Git-репозиторий инициализирован в $REPO_DIR"
fi
=
# 3. Получение списка установленных пакетов, содержащих подстроку
rpm -qa | grep "$SEARCH_STRING" > "$RESULT_FILE_HOME"
=
# Проверка успешности создания файла
if [ ! -f "$RESULT_FILE_HOME" ]; then
    echo "Не удалось создать файл со списком пакетов."
    exit 1
fi
=
# 4. Копирование файла в репозиторий
cp "$RESULT_FILE_HOME" "$RESULT_FILE_REPO"
=
# 5. Добавление файла в индекс Git и коммит (если есть изменения)
git add "$(basename "$RESULT_FILE_REPO")"
if git diff --cached --quiet; then
    echo "Нет изменений для коммита (файл уже актуален)."
else
    git commit -m "Add list of packages containing '${SEARCH_STRING}'"
    echo "Файл зафиксирован в истории репозитория."
fi
=
# 6. Вывод результата в stdout с подсветкой совпадений и через lolcat
if [ -s "$RESULT_FILE_HOME" ]; then
    echo -e "\nСписок пакетов, содержащих подстроку '${SEARCH_STRING}':\n"
    # Подсветка совпадений: заменяем искомую подстроку на красный цвет, затем передаём в lolcat
    # Экранируем специальные символы в SEARCH_STRING для безопасного использования в sed
    ESCAPED_STRING=$(printf '%s\n' "$SEARCH_STRING" | sed 's/[][\.*^$(){}?+|/]/\\&/g')
    sed "s/${ESCAPED_STRING}/\\\033[1;31m&\\\033[0m/g" "$RESULT_FILE_HOME" | lolcat
else
    echo "Пакеты, содержащие подстроку '${SEARCH_STRING}', не найдены." | lolcat
fi
=

echo -e "\nГотово. Репозиторий: $REPO_DIR"
echo "Список пакетов также сохранён в $RESULT_FILE_HOME"
