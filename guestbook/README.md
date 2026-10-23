# 방명록 (Guestbook)

이름과 메시지를 남기면 목록에 쌓이고, 방문자 수를 세는 간단한 웹 앱입니다.

---

## 이 앱이 하는 일

- 이름과 메시지를 남기는 방명록
- 방문자 수 카운트
- 화면에 hostname 표시

## 이 앱의 두 가지 모드

| 모드 | 조건 | 저장 위치 |
|---|---|---|
| **메모리 모드** | `REDIS_HOST` 환경변수 없음 | 프로세스 메모리 (재시작하면 사라짐) |
| **Redis 모드** | `REDIS_HOST` 환경변수 있음 | Redis (영구 저장) |

---

## Docker로 실행하기

```bash
# 이미지 빌드
docker build -t guestbook:v1 .

# 실행 (메모리 모드)
docker run -d -p 8080:5000 --name guestbook guestbook:v1

# 접속
# → http://localhost:8080

# 로그 보기 / 내부 들어가기 / 정리
docker logs guestbook
docker exec -it guestbook sh
docker stop guestbook && docker rm guestbook
```

**환경변수로 커스터마이징**
```bash
docker run -d -p 8080:5000 \
  -e APP_TITLE="홍길동의 방명록" \
  -e THEME_COLOR="#e11d48" \
  guestbook:v1
```

**ghcr.io에 올리기**
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u 내아이디 --password-stdin
# 또는: gh auth token | docker login ghcr.io -u 내아이디 --password-stdin

docker tag guestbook:v1 ghcr.io/내아이디/guestbook:v1
docker push ghcr.io/내아이디/guestbook:v1
```

**Mac(Apple Silicon)은 멀티 아키텍처로**
```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  -t ghcr.io/내아이디/guestbook:v1 --push .
```

**[심화] 이미지 용량 줄이기**
```bash
docker build -t guestbook:fat .
docker build -f Dockerfile.multistage -t guestbook:slim .
docker images | grep guestbook      # 용량 비교!
```

## docker compose로 실행하기 (웹 + Redis)

```bash
docker compose up -d        # 두 컨테이너가 함께 뜬다
docker compose ps
docker compose logs -f web
# → http://localhost:8080

docker compose down         # 종료 (볼륨은 유지)
docker compose down -v      # 볼륨까지 삭제
```

---

## 파일 구조

```
.
├── app.py
├── requirements.txt
├── templates/index.html
├── Dockerfile
├── Dockerfile.multistage     # [심화] 용량 줄이기
└── .dockerignore
```

## 엔드포인트

| 경로 | 설명 |
|---|---|
| `/` | 방명록 화면 |
| `/add` | 글 등록 (POST) |
| `/api/entries` | JSON 목록 |
| `/healthz` | 헬스체크 (항상 200) |
| `/readyz` | 준비 상태 확인 (Redis 연결 안 되면 503) |

## 설정 (환경변수)

| 변수 | 기본값 | 설명 |
|---|---|---|
| `APP_TITLE` | DevOps 방명록 | 화면 제목 |
| `THEME_COLOR` | #DC143C (크림슨) | 테마 색상 |
| `PORT` | 5000 | 리스닝 포트 |
| `REDIS_HOST` | (없음) | 있으면 Redis 모드 |
| `REDIS_PORT` | 6379 | |
| `REDIS_PASSWORD` | (없음) | |

---

## (추가) web=3 항상 유지하기: keep-web3.sh

07번 교안 48p 호기심 문제(`docker stop`으로 멈춘 web은 자동으로 살아나지 않음)를 해결하기 위해 추가한 감시 스크립트입니다.

### 동작
- 10초마다 실행 중인 web 개수를 세고, 3개보다 적으면 `docker compose up -d --scale web=3`으로 복구합니다.
- healthcheck 상태가 `unhealthy`인 web은 재시작합니다.

### 실행 방법
```bash
cd ~/devops/guestbook
docker compose up -d --scale web=3   # web 3개 + nginx + redis 실행
./keep-web3.sh                        # 감시 시작 (종료: Ctrl+C)
```

### 확인 방법
```bash
docker stop guestbook-web-2                                  # 다른 터미널에서 web 하나 멈추기
docker compose ps --format "table {{.Name}}\t{{.Status}}"    # 10초쯤 뒤 web 3개 모두 Up이면 성공
```

### 한계
- 점검 간격(10초) 동안은 web 2개로 운영됨
- 스크립트가 꺼지면 아무도 지키지 않음
- 컴퓨터 한 대 안에서만 동작함
