#!/bin/sh
set -e

REPO="Lobanov338/openwrt-telegram-monitor"
BASE_URL="https://raw.githubusercontent.com/${REPO}/main"

echo "== OpenWrt Telegram Monitor =="

if [ "$(id -u)" != "0" ]; then
    echo "Запусти от root."
    exit 1
fi

echo "[1/6] Устанавливаю зависимости..."
opkg update
opkg install curl ca-bundle ca-certificates jsonfilter

mkdir -p /etc/telegram-monitor
mkdir -p /usr/lib/telegram-monitor

echo
echo "Введите BOT TOKEN:"
read -r BOT_TOKEN

echo
echo "Введите CHAT ID:"
read -r CHAT_ID

cat >/etc/telegram-monitor/config <<EOF
BOT_TOKEN="$BOT_TOKEN"
CHAT_ID="$CHAT_ID"
EOF

echo "[2/6] Загружаю файлы..."

FILES="
monitor.sh
lib/router.sh
lib/network.sh
lib/devices.sh
lib/telegram.sh
init.d/telegram-monitor
"

for FILE in $FILES; do
    mkdir -p "/usr/lib/telegram-monitor/$(dirname "$FILE")"

    curl -fsSL \
        "$BASE_URL/$FILE" \
        -o "/usr/lib/telegram-monitor/$FILE"
done

chmod +x /usr/lib/telegram-monitor/monitor.sh
chmod +x /usr/lib/telegram-monitor/init.d/telegram-monitor

cp /usr/lib/telegram-monitor/init.d/telegram-monitor \
   /etc/init.d/telegram-monitor

chmod +x /etc/init.d/telegram-monitor

echo "[3/6] Запускаю сервис..."

/etc/init.d/telegram-monitor enable
/etc/init.d/telegram-monitor restart

echo
echo "==================================="
echo "Установка завершена."
echo
echo "Отправь боту:"
echo "/start"
echo "==================================="
