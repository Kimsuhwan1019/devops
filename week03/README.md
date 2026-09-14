# 3주차 - 셸 스크립팅

## 오늘 배운 내용

### Qwen + Ollama 로컬 AI 서비스
- Qwen: 답변을 만드는 모델 / Ollama: 모델을 실행·관리하는 로컬 서버
- `ollama pull qwen3:0.6b` 로 모델 다운로드 (약 522MB)
- `b` = Billion, 파라미터 개수. 0.6b = 약 6억 개
- 구조: 브라우저(8000) -> chat.py -> Ollama 서버(11434) -> qwen3:0.6b

### 셸 스크립트
- `#!` (shebang): 어떤 인터프리터로 실행할지 OS에 알려주는 첫 줄
- `chmod u+x` 로 실행 권한을 줘야 `./script.sh` 실행 가능
- `cd "$(dirname "$0")" || exit 1` 로 스크립트 자기 위치로 이동
  - `$0` 스크립트 경로, `dirname` 디렉터리 부분만 추출, `$( )` 명령어 치환
- `exec` 는 현재 bash 프로세스를 대체 (PID 유지)

### 종료 상태
- 성공 = 0, 실패 = 0 이외 (숫자 불리언과 반대이므로 주의)
- `||` 는 앞 명령이 실패했을 때 뒤를 실행
- `$?` 로 직전 명령의 종료 상태 확인

### 환경 변수
- `chat.py` 는 `os.environ.get()` 으로 MODEL, WEB_PORT, APP_NAME 을 읽음
- 스크립트 안에서 `export WEB_PORT="8080"` 하면 코드 수정 없이 포트 변경
- `export` 는 해당 스크립트 안에서만 유효, 원래 터미널은 바뀌지 않음

### 조건문
- `if 명령어; then ... fi` — 참/거짓이 아니라 명령의 종료 상태로 판단
- `command -v python3` 로 설치 여부 확인
- `>/dev/null 2>&1` 로 출력과 오류를 모두 버림 (순서 중요)
- `echo "..." >&2` 는 오류 메시지로 출력, `exit 1` 은 실패 상태로 종료 (둘은 별개)

## 파일 구성

```
week03/qwen-web/
├── chat.py                  # 교수님 제공, 파이썬 표준 라이브러리만 사용
├── start.sh                 # 실행 스크립트 (python3 설치 여부 점검 포함)
├── start_with_export.sh     # MODEL 환경 변수 지정
├── start_with_export_2.sh   # WEB_PORT=8080 으로 변경
└── run_py.sh                # shebang 실습용
```

## 실행 방법

```bash
cd ~/devops/week03/qwen-web
./start.sh
# 브라우저에서 http://localhost:8000
```

## 실행 결과

- `안녕?` -> `안녕하세요!` 정상 응답
- 터미널 로그: `종료 사유: stop | 생성 토큰: 5 | thinking 출력 있음: False`
- `start_with_export_2.sh` 실행 시 http://localhost:8080 으로 접속 확인

## 막혔던 부분

- `python` 은 Ubuntu에 없다. `python3` 를 써야 한다.
- 탐색기 드래그로 파일을 복사하면 `chat.py:Zone.Identifier` 가 함께 생긴다. 삭제 필요.
- `chmod` 없이 `./start.sh` 하면 `Permission denied`. 파일 내용이 맞아도 실행 권한이 없으면 실행되지 않는다.
- heredoc 에서 `<< 'EOF'` 의 따옴표를 빼면 `$0`, `$(dirname ...)` 이 현재 값으로 치환되어 스크립트가 망가진다.
