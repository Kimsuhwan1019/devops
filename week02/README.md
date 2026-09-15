# 2주차 - 실습 환경 구축과 버전 관리 기초

Windows 위에 WSL2 + Ubuntu 리눅스 환경을 구축하고, 리눅스 기본 명령어를 익혔다.
`~/devops` 를 Git 저장소로 만들어 버전 관리를 시작했고,
GitHub CLI 로 원격 저장소를 연결해 실습 결과를 푸시했다.

## 오늘 배운 내용

- 가상화: 서버 / 베어메탈 / 하이퍼바이저 / 컨테이너 비교
  - 컨테이너가 더 가벼운 이유는 호스트 커널을 공유하기 때문
- WSL2 + Ubuntu 환경 구축
- 리눅스 기본 명령어 (디렉터리, 파일, 리다이렉션, 권한, 시스템 정보)
- Git 버전 관리: 커밋, 과거 버전 이동, 변경분 비교, 브랜치
- GitHub CLI 로 원격 저장소 생성 및 푸시

각 항목의 상세 설명은 맨 아래 "개념 정리"에 접어두었다.

## 새로 배운 명령어

```bash
# --- WSL ---
wsl --install -d Ubuntu     # Ubuntu 설치
wsl -l -v                   # 설치된 배포판과 WSL 버전 확인

# --- 디렉터리 / 파일 ---
pwd                         # 현재 디렉터리 경로 출력
ls -l                       # 상세 목록 (권한, 크기, 날짜)
ls -a                       # 숨김 파일까지 표시 (.git 확인용)
mkdir week02                # 디렉터리 생성
rm -r test                  # 디렉터리를 내용째 삭제
cat text.txt                # 파일 내용 출력
echo "Hello" > text.txt     # 덮어쓰기
echo "World" >> text.txt    # 이어쓰기

# --- 시스템 정보 ---
chmod u+x script.sh         # 소유자에게 실행 권한 부여
df -h                       # 디스크 사용량 (사람이 읽기 쉬운 단위)
free -h                     # 메모리 사용량
history                     # 지금까지 입력한 명령어 목록

# --- Git ---
git config --global user.name "이름"    # 커밋에 기록될 이름
git config --list                       # 설정 확인
git init                    # 현재 디렉터리를 저장소로 초기화
git status                  # 변경 상태 확인 (add 여부 판별)
git add .                   # 변경사항을 staging area 에 올림
git commit -m "메시지"       # 하나의 버전으로 기록
git log --oneline           # 커밋 기록을 한 줄씩
git diff <해시1> <해시2>     # 두 커밋의 차이 (+추가 / -삭제)
git switch -d <해시>         # 과거 커밋으로 이동
git switch main             # 최신 브랜치로 복귀
git switch -c hi            # 새 브랜치 생성 후 이동
git branch                  # 브랜치 목록 (* 가 현재 위치)
git log --oneline --all --graph   # 전체 브랜치 흐름을 그래프로

# --- GitHub CLI ---
gh auth login               # GitHub 계정 인증
gh repo create devops --public --source=. --remote=origin --push
                            # 저장소 생성 + 연결 + 첫 푸시를 한 번에
git push                    # 커밋을 GitHub 에 업로드
gh browse --no-browser      # 저장소 주소만 출력
```

## 파일 구성

```
week02/
├── README.md     # 이 문서
├── text.txt      # 커밋 / diff 실습용
└── hello.txt     # 브랜치 실습용 (main 과 hi 의 내용이 다름)
```

저장소 루트는 `~/devops` 이고 주차 폴더는 그 안에 둔다.

## 실행 결과

- `git log` 의 Author 가 `Kimsuhwan1019 <hansnara2000@naver.com>` 로 기록됨 확인
- `git switch -d 7ac3fe0` 로 이동하니 `text.txt` 가 한 줄만 표시,
  `git switch main` 으로 복귀하니 두 줄로 돌아옴
- `main` 과 `hi` 브랜치에서 `hello.txt` 의 내용이 서로 다른 것 확인
- `gh repo create` 실행 후 `Created repository` → `Added remote` → `Pushed commits` 출력
- GitHub 웹에서 `week02/` 안의 파일과 README 렌더링 확인

## 막혔던 부분

- `git init` 은 `week02` 가 아니라 저장소 루트인 `~/devops` 에서 실행해야 한다.
- Git 은 빈 디렉터리를 추적하지 않는다. 안에 파일이 있어야 `git status` 에 잡힌다.
- `git add` 를 빠뜨리면 `commit` 이 되지 않고 `push` 도 `Everything up-to-date` 만 출력된다.
  `git status` 가 `Changes to be committed:` 로 바뀌었는지 확인하는 습관이 필요하다.
- WSL 에 `wslu` 패키지가 없어 `gh auth login` 시 브라우저 자동 실행이 실패한다.
  https://github.com/login/device 에 직접 접속해 일회용 코드를 입력하면 된다.

---

<details>
<summary><b>개념 정리</b> (클릭해서 펼치기)</summary>

### 가상화
- 서버 / 베어메탈 / 하이퍼바이저 / 컨테이너 비교
- 컨테이너가 더 가벼운 이유: 호스트 커널을 공유하기 때문

### WSL2
- Windows 안에서 리눅스 커널을 실행하는 방식
- `wsl -l -v` 의 VERSION 이 2 인지 확인해야 한다

### 리다이렉션
- `>` 덮어쓰기 — 기존 내용이 사라진다
- `>>` 이어쓰기 — 파일 끝에 추가된다

### Git 버전 관리
- `git init` 으로 `~/devops` 를 저장소로 초기화 (`.git` 디렉터리 생성)
- `.git` 안에 커밋 기록, 브랜치 정보, 설정이 저장된다
- `git add` 는 저장이 아니라 **다음 커밋에 포함할 것을 고르는 작업** (staging area)
- `git commit` 으로 하나의 버전(스냅샷)을 기록
- `git switch -d <해시>` 는 detached HEAD 상태. 브랜치가 아니라 특정 커밋을 직접 가리킨다
- `git diff <해시1> <해시2>` 에서 `+` 는 추가된 줄, `-` 는 없어진 줄
- 커밋 해시는 앞 7자리만 써도 Git 이 알아서 찾는다

### 브랜치
- 브랜치 = 특정 커밋을 가리키는 이름
- `git switch -c <이름>` 생성 후 이동, `git branch` 로 목록 확인
- 같은 파일이라도 브랜치마다 내용이 다를 수 있다

### GitHub 연동
- `gh auth login` 으로 CLI 인증 (GitHub.com / HTTPS / 웹 브라우저 방식)
- `gh repo create devops --public --source=. --remote=origin --push`
  - `--source=.` 현재 디렉터리를 연결, `--remote=origin` 원격 이름 지정, `--push` 바로 업로드
- 커밋 이후에는 반드시 `git push` 해야 GitHub 에 반영된다

</details>
