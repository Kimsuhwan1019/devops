# 7주차 캡처 목록

`week07/README.md`의 "실행 결과"에 쓰인 캡처입니다. 번호 순서가 실습 순서입니다.
교안: `DevOps_07_도커_컴포즈.pdf`

| 파일 | 교안 | 실행한 명령 | 확인할 것 |
|---|---|---|---|
| `01-compose-up.png` | 22~23p | `docker compose up -d`, `ps`, `logs web` | `up 4/4`, `Redis 연결 성공: redis:6379`, 브라우저 저장소 Redis, Pod/Host 013533a48696 |
| `02-restart-web.png` | 24p | `docker compose restart web`, `ps` | web만 `Up 12 seconds`(redis는 3분), 글 3개 유지, Pod/Host 그대로 |
| `03-down-up.png` | 25~26p | `docker compose down`, `docker volume ls`, `up -d` | 볼륨 남음, `up 3/3`, 글 3개 유지, Pod/Host가 d7f3beeeef83으로 바뀜 |
| `04-down-v-up.png` | 27p | `docker compose down -v`, `docker volume ls`, `up -d` | Volume `Removed` → `Created`, 글 0개, 방문 1회 |
| `05-network.png` | 29~30p | 호스트에서 6379 접속, `exec web`으로 이름 해석·연결 | `Connection refused` / `172.18.0.2` / `TCP 연결 성공` |
| `06-healthy.png` | 40p | `docker compose ps`, `docker inspect --format ...` | redis, web 모두 `(healthy)`, `healthy` |
| `07-scale-nginx.png` | 47p | `docker ps --format`, `/healthz` 6번 요청 | web 3개의 ID가 번갈아 응답, 브라우저 Pod/Host가 web-1 ID와 일치 |
| `08-watch.png` | 51p | `docker compose watch --no-up` + index.html 수정 | 저장 후 자동 rebuild, 버튼 문구 `방명록 남기기~!` 반영 |

## 참고

- 01~04는 같은 흐름을 이어서 찍었습니다. Pod/Host가 `restart`에서는 그대로이고, `down` 후 `up`에서는 바뀝니다.
- 08의 watch 로그를 보면 rebuild 때 web-2, web-3이 `Removed`되어 web이 1개로 줄었습니다. `docker compose up -d --scale web=3`으로 복구했습니다(`week07/README.md` 막혔던 부분 참고).
