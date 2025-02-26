#!/usr/bin/env bash

# Параметри
if [ -z "${USER_DOCKER_HOST}" ]; then
    USER_DOCKER_HOST="docker" # IP-адреса або доменне ім'я віддаленого хоста
fi

LOCAL_PORT_START=0 # Початковий порт для пересилання на локальній машині
SCAN_INTERVAL=30 # Інтервал сканування в секундах

# Асоціативний масив для зберігання інформації про тунелі
# unset TUNNELS_ORIG
declare -Ag TUNNELS=()

# socat TCP4-LISTEN:5432,fork TCP4:docker:5432
# socat TCP4-LISTEN:$LOCAL_PORT,fork TCP4:$USER_DOCKER_HOST:$REMOTE_PORT

# Функція для перевірки та встановлення тунелю
function check_and_forward_port() {
  # declare -n TUNNELS=$1
  local REMOTE_PORT=$1
  # echo "REMOTE_PORT $REMOTE_PORT"

  local LOCAL_PORT=$((LOCAL_PORT_START + REMOTE_PORT))
  local FORWARDCMD="socat TCP4-LISTEN:$LOCAL_PORT,fork TCP4:$USER_DOCKER_HOST:$REMOTE_PORT"

  # Перевірка, чи тунель вже встановлено
  if ! pgrep -f "$FORWARDCMD"; then
    # Перевірка, чи порт вже використовується
    if lsof -i :$LOCAL_PORT >/dev/null 2>&1; then
      echo "Порт $LOCAL_PORT вже використовується. Пропускаємо."
      return
    fi

    # Встановлюємо тунель
    $FORWARDCMD &
    echo "Форвардинг порту $REMOTE_PORT на локальний порт $LOCAL_PORT"

    # Зберігаємо інформацію про тунель
    TUNNELS[$REMOTE_PORT]=$LOCAL_PORT
  fi
  # echo "Перевірки11 ${!TUNNELS[@]}"
}

# Функція для закриття недоступних тунелів
function close_unused_tunnels() {
  # declare -n TUNNELS=$1
  # echo "Перевірки33 ${!TUNNELS[@]}"
  for REMOTE_PORT in "${!TUNNELS[@]}"
  do
    local LOCAL_PORT=${TUNNELS[$REMOTE_PORT]}
    local FORWARDCMD="socat TCP4-LISTEN:$LOCAL_PORT,fork TCP4:$USER_DOCKER_HOST:$REMOTE_PORT"

    # echo "Перевірка $REMOTE_PORT"

    if nmap -sT -p $REMOTE_PORT $USER_DOCKER_HOST | grep -q "$REMOTE_PORT/tcp closed"; then
      if pgrep -f "$FORWARDCMD"; then
        pkill -f "$FORWARDCMD"
      fi
      echo "Закрито форвардинг порту $REMOTE_PORT"
      # Видаляємо інформацію про тунель
      unset TUNNELS[$REMOTE_PORT]
    fi
  done
}

# Функція для закриття всіх тунелів
function close_all_tunnels() {
  # declare -n TUNNELS=$1
  for REMOTE_PORT in "${!TUNNELS[@]}"; do
    local LOCAL_PORT=${TUNNELS[$REMOTE_PORT]}
    local FORWARDCMD="socat TCP4-LISTEN:$LOCAL_PORT,fork TCP4:$USER_DOCKER_HOST:$REMOTE_PORT"

    if pgrep -f "$FORWARDCMD"; then
      pkill -f "$FORWARDCMD"
      echo "Закрито форвардинг порту $REMOTE_PORT"
    fi
  done
}

function start_scan() {
  # Обробник сигналу Ctrl+C
  trap "close_all_tunnels; exit" INT

  # Головний цикл
  while true; do
    # Скануємо відкриті порти на віддаленому хості
    ddd=$(nmap -sT -p- $USER_DOCKER_HOST | grep -o '[0-9]\+/tcp[ ]\+open' | cut -d'/' -f1)
    for line in $ddd; do
      REMOTE_PORT=$(echo $line)
      check_and_forward_port "$REMOTE_PORT"
    done
    close_unused_tunnels

    sleep $SCAN_INTERVAL
  done
}

start_scan;
