# 2주차 - 실습 환경 구축과 버전 관리 기초

## 오늘 배운 내용

### 가상화
- 서버 / 베어메탈 / 하이퍼바이저 / 컨테이너 비교
- 컨테이너가 더 가벼운 이유: 호스트 커널 공유

### WSL2 + Ubuntu 환경 구축
- `wsl --install -d Ubuntu` 로 설치
- `wsl -l -v` 로 버전 2 확인

### 리눅스 기본 명령어
- 디렉터리: `pwd`, `ls`, `mkdir`, `rmdir`, `cd`
- 파일: `touch`, `cat`, `echo`, `cp`, `mv`, `rm`
- 리다이렉션: `>` (덮어쓰기), `>>` (이어쓰기)
- 권한: `chmod`
- 정보 확인: `df -h`, `free -h`, `history`

### Git 버전 관리
- `git init` 으로 `~/devops` 를 저장소로 초기화
- `git add` 는 저장이 아니라 staging area 에 올리는 작업
- `git commit` 으로 하나의 버전(스냅샷) 기록
- `git switch -d <해시>` 로 과거 버전 확인, `git switch main` 으로 복귀
- `git diff <해시1> <해시2>` 로 변경분 비교 (`+` 추가 / `-` 삭제)
- 브랜치: `git switch -c`, `git branch`, `git log --oneline --all --graph`

### GitHub 연동
- `gh auth login` 으로 CLI 인증
- `gh repo create devops --public --source=. --remote=origin --push`
- 커밋 후에는 반드시 `git push`

## 주요 명령어

```bash
git init
git status
git add .
git commit -m "메시지"
git log --oneline
git diff <해시1> <해시2>
git switch -c <브랜치>
git push
```

## 막혔던 부분

- `git init` 은 `week02` 가 아니라 저장소 루트인 `~/devops` 에서 실행해야 한다.
- `git add` 를 빠뜨리면 `commit` 이 되지 않고 `push` 도 `Everything up-to-date` 만 출력된다.
  `git status` 가 `Changes to be committed:` 로 바뀌었는지 확인하는 습관이 필요하다.
- WSL 에 `wslu` 패키지가 없어 브라우저 자동 실행이 실패한다.
  `https://github.com/login/device` 에 직접 접속해 코드를 입력하면 된다.
