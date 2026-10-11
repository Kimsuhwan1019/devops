# 6주차 실습 캡처

진행 순서대로 정리했다. 본문은 [week06/README.md](../README.md)에 있다.

| 순서 | 파일 | 내용 |
|---|---|---|
| 1 | [dockerfile.png](dockerfile.png) | 줄별 주석을 단 Dockerfile(`cat`)과 index.html 문구 3곳 수정 확인(`grep`) |
| 2 | [build.png](build.png) | `docker build -t guestbook:v2 .` 로그 `[1/6]`~`[6/6]`, 생성된 이미지 확인 |
| 3 | [run.png](run.png) | `docker run`, `docker ps`(8081→5000), `docker logs`(김수환의 방명록 시작) |
| 4 | [browser.png](browser.png) | localhost:8081 — 보라색 테마, 바꾼 문구, 글 3개 작성 |
| 5 | [push-denied.png](push-denied.png) | 첫 push 실패: `permission_denied: ... expected scopes` (토큰에 write:packages 없음) |
| 6 | [push.png](push.png) | `gh auth refresh` 후 재로그인 → push 성공, digest = 로컬 이미지 ID |
| 7 | [packages.png](packages.png) | GitHub Packages의 `guestbook v2`, Public 전환 완료 |
| 8 | [pull-run.png](pull-run.png) | `rmi` → `pull`(Downloaded newer image) → `-e THEME_COLOR="#C6A15B"`로 실행 |
| 9 | [gold.png](gold.png) | 금색으로 바뀐 화면 — ENV보다 `-e`가 우선, 새 컨테이너라 글 목록은 비어 있음 |
| 10 | [cache.png](cache.png) | 문구 한 글자 수정 후 재빌드 3.0s, `[2/6]`~`[4/6]` CACHED |
