#!/bin/bash
# keep-web3.sh : web 컨테이너를 항상 3개로 유지하는 감시 스크립트

cd "$(dirname "$0")" || exit 1   # 스크립트가 있는 폴더(compose.yaml 위치)로 이동, 실패하면 종료
WANT=3                            # 유지할 web 개수 (목표)
INTERVAL=10                       # 점검 간격(초)

while true; do

  # ① 센다: 실행 중인 web 컨테이너 ID를 한 줄씩 출력 → wc -l로 줄 수(=개수)를 센다
  RUNNING=$(docker compose ps --status running -q web | wc -l)   # --status running (교안 외)

  # ② 비교: 실행 중인 개수가 목표보다 적은가? (-lt = less than)
  if [ "$RUNNING" -lt "$WANT" ]; then
    # ③ 복구: 언제 몇 개였는지 기록하고, 3개로 다시 맞춘다 (7번 교안 48p에서 사람이 치던 명령)
    echo "$(date '+%F %T') web ${RUNNING}개 -> ${WANT}개로 복구"
    docker compose up -d --scale web="$WANT"
  fi

  # ③-2 고장 확인: 켜져 있지만 응답 못 하는(unhealthy) web을 찾아 재시작
  for id in $(docker compose ps -q web); do                              # web 컨테이너를 하나씩 꺼내서
    STATE=$(docker inspect --format '{{.State.Health.Status}}' "$id")    # healthcheck 상태 확인 (교안 외)
    if [ "$STATE" = "unhealthy" ]; then                                  # 고장이면
      echo "$(date '+%F %T') unhealthy 재시작: $id"                      # 기록을 남기고
      docker restart "$id"                                               # 그 컨테이너만 재시작
    fi
  done

  # ④ 대기: 10초 쉬고 ①로 돌아간다
  sleep "$INTERVAL"
done
