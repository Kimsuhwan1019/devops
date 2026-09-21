# 4주차 - 자동화와 협업, 네트워크

백업 스크립트를 Git 브랜치·PR·Conflict 해결까지 거쳐 완성하고,
파이썬 내장 웹 서버로 포트 충돌 상황을 재현하고 해결했다.

## 오늘 배운 내용
- 셸 스크립트로 파일 검색·로그 필터링·조건 분기 자동화
- 백업 스크립트 작성 후 압축·복원 결과를 `diff`로 검증
- 브랜치 → PR → `--squash` merge → 브랜치 삭제, Git 협업 전체 흐름
- 두 브랜치에서 같은 줄을 다르게 고쳐 Conflict를 만들고 nano로 직접 해결
- GitHub Ruleset으로 main 브랜치 직접 push 차단
- IP/포트/DNS 개념과 `curl`/`jq`/`ss`로 서버 상태 조회
- 웹 서버 포트 충돌을 재현하고 두 가지 방법으로 해결

상세는 맨 아래 개념 정리에.

## 새로 배운 명령어
```bash
# --- 셸 스크립팅 ---
find . -type f -name "*.sh"           # 파일 이름으로 찾기
grep -R -n "패턴" 경로                 # 재귀 검색 + 줄 번호
tar -czf 백업.tar.gz 대상폴더          # 압축
diff -rq 원본 복원본                   # 디렉터리 두 개 비교
# --- 프로세스 ---
kill <PID> / kill -9 <PID>            # 정상 종료 / 강제 종료
# --- Git 협업 ---
git switch -c 브랜치명                 # 브랜치 생성 + 이동
gh pr create --base main              # PR 생성
gh pr merge --squash --delete-branch  # 스쿼시 병합 + 브랜치 삭제
# --- 네트워크 ---
curl -I 주소                           # 응답 헤더만 확인
ss -tlnp | grep 포트번호               # 포트 사용 중인지 확인
python3 -m http.server 8080           # 현재 폴더를 웹 서버로 띄우기
```

## 실행 방법
```bash
cd ~/devops/week04 && ./backup.sh test                  # 백업 실행
cd ~/devops/week04/site && python3 -m http.server 8080  # 웹 서버 (종료: Ctrl+C)
```

## 파일 구성
```
week04/
├── backup.sh        # 백업 + 로그 기록 + conflict 해결 반영
├── site/index.html  # 웹 서버 실습용
└── test/             # check.sh, greet.sh, var.sh, diary.txt, server.log, errors.txt
```

## 실행 결과
- `./backup.sh test` → 백업 성공, `diff -rq` + `echo $?` → `0`으로 원본·복원본 동일 확인
- `curl -I http://localhost:8080` → `HTTP/1.0 200 OK`
- 같은 포트로 서버 2개 실행 → `OSError: [Errno 98] Address already in use` 재현
- main에 Ruleset 설정 후 직접 push → `GH013: Repository rule violations`로 거부 확인

## 막혔던 부분
- 파워셸에서 `wsl` 입력 시 위치가 윈도우 `system32`로 잡힘 → `cd ~`로 해결
- `find /`로 드라이브 전체 검색은 WSL에서 매우 느림 → 범위를 좁히거나 경로를 먼저 확인
- nano에서 마우스로 충돌 마커를 못 지움 → `Ctrl+K`로 줄 단위 삭제해야 함
- `gh pr create` 후 브라우저 자동 열기 실패 → 링크를 직접 복사해 브라우저에 붙여넣음

---

<details>
<summary><b>개념 정리</b> (클릭해서 펼치기)</summary>

### 자동화 기초 (03번 교안 6~16p)
- `find`, `grep -R -n`으로 파일과 로그를 검색하고 재귀적으로 줄 번호까지 확인
- 파이프(`|`)와 리다이렉션(`>`)으로 명령 결과를 다른 명령에 넘기거나 파일로 저장
- `var.sh`: `$(date +%Y%m%d)` 같은 명령 치환으로 동적인 파일명 생성
- `greet.sh`: `$#`(인자 개수)와 `exit 1`/`echo $?`로 종료 코드 다루기
- `check.sh`: `[ -f ]`/`[ -d ]`로 파일·디렉터리 존재 여부 분기

### 프로세스와 백업 (17~25p)
- `ps aux`로 실행 중인 프로세스 확인, `kill`(정상 종료)과 `kill -9`(강제 종료)의 차이
- `backup.sh`: `cd "$(dirname "$0")"`로 스크립트 위치 기준 실행 보장, `$$`(PID)로 백업 파일명 충돌 방지
- `tar -czf`로 압축 → `tar -tzf`로 내용 확인 → 복원 후 `diff -rq`로 원본과 동일한지 검증
- `.gitignore`로 백업 산출물(`backups/`, `restore-check/`)은 저장소에서 제외

### Git 협업 - 브랜치, PR, Merge (26~32p)
- `git switch -c`로 기능 브랜치 생성 → 작업 → `git push -u origin 브랜치명`
- `gh pr create`로 PR 생성, `gh pr merge --squash --delete-branch`로 병합과 동시에 브랜치 정리

### Conflict와 Merge (33~40p)
- main과 다른 브랜치에서 같은 줄을 각각 수정하면 병합 시 `CONFLICT` 발생
- 충돌 마커(`<<<<<<<`, `=======`, `>>>>>>>`)를 직접 확인하고 원하는 버전만 남기는 방식으로 해결
- 해결 후 다시 커밋·푸시하면 정상적으로 병합 가능

### Merge 옵션과 브랜치 보호 (41~46p)
- `merge`/`squash`/`rebase` 세 가지 병합 방식의 차이
- GitHub Ruleset으로 main 브랜치에 "PR을 거치지 않은 직접 push"를 차단 — 이후 모든 변경은 PR을 통해서만 반영됨

### 네트워크 기본 개념 (04번 교안 1~15p)
- IP 주소(장치 식별), 공인 IP·사설 IP, NAT(사설 IP↔공인 IP 매핑)
- 포트(하나의 컴퓨터 안에서 서비스를 구분하는 번호, 0~65535), 대표 포트(22 SSH, 80 HTTP, 443 HTTPS 등)
- DNS: 도메인 이름을 IP 주소로 변환

### 서버와의 통신 확인 (16~20p)
- `curl`로 HTTP 요청 확인(`-I` 헤더만, `-s` 조용히, `-o` 파일로 저장)
- `jq`로 JSON 응답을 보기 좋게 출력하거나 원하는 값만 추출
- `ss -tlnp`로 현재 LISTEN 중인 포트와 프로세스 확인

### 서버 실행과 포트 충돌 (21~28p)
- `python3 -m http.server`로 현재 폴더를 즉석 웹 서버로 실행
- 같은 포트를 두 번 사용하면 `Address already in use` 에러 → 다른 포트 사용 또는 기존 프로세스 종료로 해결
- `pkill -f`로 이름 패턴에 맞는 프로세스 한 번에 정리

### 방화벽과 정리 (29~30p)
- 서버가 포트를 열어도 방화벽이 막으면 외부 접근 불가
- 오늘 배운 도구 정리: `ip addr`(IP 확인), `ping`(응답 확인), `dig`(DNS 조회), `curl`(HTTP), `ss`(포트)

</details>
