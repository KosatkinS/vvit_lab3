#!/bin/bash

IP_FILE="nmap_results.txt"
URI_FILE="uris.txt"
LOG_FILE="cam_log.txt"

check_camera() {
  IP="$1"
  URI="$2"
  PORT="$3"

  URL="https://${IP}:${PORT}${URI}"
  echo "Проверка $URL"

  STATUS=$(curl -m 1 -Is "$URL" | head -n 1)

  if [[ "$STATUS" == *"200 OK"* || "$STATUS" == *"401 Authorization Required"* || "$STATUS" == *"501 Not Implemented"* ]]; then
    echo "Найдена камера: $URL - $STATUS" >> "$LOG_FILE"
    echo "Потенциальная камера: $URL - $STATUS"

    #получить информацию о потоке
    ffprobe -hide_banner "$URL" 2>&1 | grep "Video:" >> "$LOG_FILE"
  fi
}


# парсим результаты nmap
grep -E "report for |open " "$IP_FILE" | while read -r line; do
  if [[ "$line" == *"report for"* ]]; then
    IP=$(echo "$line" | awk '{print $5}')
  elif [[ "$line" == *"open"* ]]; then
    PORT=$(echo "$line" | awk -F'/' '{print $1}')
    while IFS= read -r uri; do
      check_camera "$IP" "$uri" "$PORT"
    done < "$URI_FILE"
  fi
done

echo "Сканирование завершено. Результаты в $LOG_FILE"