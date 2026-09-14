# 3주차 - 셸 스크립팅

로컬에서 동작하는 AI 챗 웹앱을 셸 스크립트 한 줄로 실행할 수 있게 만들었다.
`Qwen` 모델을 `Ollama` 로 띄우고, 파이썬 웹앱(`chat.py`)을 `start.sh` 로 감싸
경로를 외우지 않아도 실행되도록 자동화했다.

```
브라우저(8000) -> chat.py -> Ollama 서버(11434) -> qwen3:0.6b
```

## 오늘 배운 내용

- 자동화의 필요성 (반복 작업의 시간 누적과 사람의 실수)
- Qwen + Ollama 로 로컬 AI 서비스 실행
- 셸 스크립트 작성: shebang, 실행 권한, 작업 경로 설정
- 종료 상태로 성공/실패 판단 (성공 = 0, 실패 = 0 이외)
- 환경 변수(`export`)로 코드 수정 없이 실행 설정 변경
- 조건문으로 실행 환경 점검 및 오류 안내

각 항목의 상세 설명은 맨 아래 "개념 정리"에 접어두었다.

## 새로 배운 명령어

```bash
# --- Ollama ---
ollama pull qwen3:0.6b      # 모델 다운로드
ollama list                 # 받은 모델 목록 확인
ollama serve                # Ollama 서버 실행 (설치 시 자동 등록됨)

# --- 스크립트 실행 ---
chmod u+x start.sh          # 실행 권한 부여 (없으면 Permission denied)
./start.sh                  # 현재 폴더의 스크립트 실행
uname                       # OS 이름 출력 (Linux / Darwin)
command -v python3          # 명령어 설치 여부 확인 (있으면 경로 출력)

# --- 스크립트 안에서 쓰는 것 ---
dirname "$0"                # 스크립트 자신의 디렉터리 경로
exec python3 chat.py        # 현재 프로세스를 python3 로 교체
export WEB_PORT="8080"      # 환경 변수 지정 (이 스크립트 안에서만 유효)
cat > 파일명 << 'EOF'        # 여러 줄을 파일로 저장 (EOF 줄에서 입력 종료)

# --- 리다이렉션 ---
>/dev/null 2>&1             # 출력과 오류를 모두 버림
echo "메시지" >&2            # 오류 메시지로 출력
echo $?                     # 직전 명령의 종료 상태 (0=성공)
```

## 실행 방법

```bash
cd ~/devops/week03/qwen-web
./start.sh
# 브라우저에서 http://localhost:8000
```

포트를 바꿔서 실행하려면:

```bash
./start_with_export_2.sh
# 브라우저에서 http://localhost:8080
```

종료는 `Ctrl + C`. 웹 앱만 종료되고 Ollama 서버는 계속 동작한다.

## 파일 구성

```
week03/qwen-web/
├── chat.py                  # 교수님 제공, 파이썬 표준 라이브러리만 사용
├── start.sh                 # 실행 스크립트 (python3 설치 여부 점검 포함)
├── start_with_export.sh     # MODEL 환경 변수 지정
├── start_with_export_2.sh   # WEB_PORT=8080 으로 변경
└── run_py.sh                # shebang 실습용
```

모델은 Ollama 가 따로 보관하므로 이 폴더에 두거나 푸시하지 않는다.

## 실행 결과

- `안녕?` -> `안녕하세요!` 정상 응답
- 터미널 로그: `종료 사유: stop | 생성 토큰: 5 | thinking 출력 있음: False`
  - `stop` 은 모델이 스스로 끝낸 것. `length` 면 512토큰 한도에 걸려 잘린 것
- `start_with_export_2.sh` 실행 시 http://localhost:8080 으로 접속 확인
- python3 가 없는 상황을 흉내내어 실행했을 때 안내 메시지 출력 + 종료 상태 1 확인
- `Ctrl + C` 로 종료해도 Ollama 서버(11434)는 계속 살아 있음을 확인

## 막혔던 부분

- `python` 은 Ubuntu에 없다. `python3` 를 써야 한다.
- 탐색기 드래그로 파일을 복사하면 `chat.py:Zone.Identifier` 가 함께 생긴다. 삭제 필요.
- `chmod` 없이 `./start.sh` 하면 `Permission denied`.
  파일 내용이 맞아도 실행 권한이 없으면 실행되지 않는다.
- heredoc 에서 `<< 'EOF'` 의 따옴표를 빼면 `$0`, `$(dirname ...)` 이
  현재 값으로 치환되어 스크립트가 망가진다.
- nano 로 긴 파일을 갈아엎을 때는 `> README.md` 로 비우고 다시 여는 게 편하다.

---

<details>
<summary><b>개념 정리</b> (클릭해서 펼치기)</summary>

### 왜 셸 스크립트인가
- 반복 작업을 손으로 하면 시간이 누적된다 (하루 10분 = 1년 약 61시간)
- 사람은 반드시 실수한다 (오타, 순서 바뀜, 단계 생략)
- 기계는 수백만 번을 시켜도 같은 절차로 실행한다

### Qwen + Ollama
- Qwen: 답변을 만드는 모델 / Ollama: 모델을 실행·관리하는 로컬 서버
- `ollama pull qwen3:0.6b` 로 모델 다운로드 (약 522MB)
- `b` = Billion, 파라미터 개수. 0.6b = 약 6억 개
  - 클수록 성능은 대체로 좋지만 연산량이 커져 느리고 메모리를 더 쓴다
- 구조: 브라우저(8000) -> chat.py -> Ollama 서버(11434) -> qwen3:0.6b

### 셸 스크립트
- `#!` (shebang): 어떤 인터프리터로 실행할지 OS에 알려주는 첫 줄
  - `#` 하나만 있으면 그냥 주석. `#!` 두 글자가 붙어야 shebang
  - `#!/usr/bin/env python3` 는 PATH 에서 찾기, `#!/usr/bin/python3` 는 경로 고정
- `chmod u+x` 로 실행 권한을 줘야 `./script.sh` 실행 가능
- `cd "$(dirname "$0")" || exit 1` 로 스크립트 자기 위치로 이동
  - `$0` 스크립트 경로, `dirname` 디렉터리 부분만 추출, `$( )` 명령어 치환
  - 덕분에 어느 디렉터리에서 실행해도 동작한다
- `exec` 는 현재 bash 프로세스를 대체 (PID 유지) -> 뒤에 있는 줄이 실행되지 않는다
- 인자 참고: `$1` `$2` 전달된 인자, `$#` 인자 개수, `$@` 모든 인자

### 종료 상태
- 성공 = 0, 실패 = 0 이외 (숫자 불리언과 반대이므로 주의)
- `||` 는 앞 명령이 실패했을 때 뒤를 실행
- `$?` 로 직전 명령의 종료 상태 확인

### 환경 변수
- `chat.py` 는 `os.environ.get()` 으로 MODEL, WEB_PORT, APP_NAME 을 읽음
  - 환경 변수가 있으면 그 값을, 없으면 기본값을 쓴다 -> 코드 수정 없이 설정 변경 가능
- `export` 는 해당 스크립트 안에서만 유효, 원래 터미널은 바뀌지 않음
- heredoc `cat > 파일 << 'EOF'` 로 여러 줄을 파일에 저장
  - 종료 표시(`EOF`)는 `END`, `FINISH` 등으로 바꿔도 된다
  - `'EOF'` 따옴표가 있으면 변수를 문자 그대로 저장
  - 따옴표가 없으면 현재 값으로 치환되어 저장된다

### 조건문
- `if 명령어; then ... fi` — 참/거짓이 아니라 명령의 종료 상태로 판단
- `command -v python3` 로 설치 여부 확인 (있으면 경로 출력 + 0, 없으면 출력 없음 + 실패)
- `!` 로 조건을 반전 -> "찾을 수 없다면"
- `>/dev/null` 로 출력을 버림 (`/dev/null` 은 리눅스의 쓰레기통)
- `2>&1` 은 표준 오류를 표준 출력이 가는 곳으로 보냄. 순서에 따라 결과가 다르다
  - `>/dev/null 2>&1` 출력·오류 모두 버림
  - `2>&1 >/dev/null` 오류는 화면에 남음
- `echo "..." >&2` 는 오류 메시지로 출력, `exit 1` 은 실패 상태로 종료 (둘은 별개)
- `uname` 으로 OS 구분 (macOS 는 `Darwin`) 하여 설치 방법을 다르게 안내

### 표준 스트림

| 번호 | 이름 |
|---|---|
| 0 | 표준 입력 (stdin) |
| 1 | 표준 출력 (stdout) |
| 2 | 표준 오류 (stderr) |

</details>
