#!/bin/bash
cd "$(dirname "$0")" || exit 1
if ! command -v python3 >/dev/null 2>&1; then
    echo "Python3가 설치되어 있지 않습니다." >&2
    if [ "$(uname)" = "Darwin" ]; then
        echo "[Mac] 다음 명령으로 설치하세요." >&2
        echo "  brew install python" >&2
    else
        echo "[Windows(WSL)/Ubuntu] 다음 명령으로 설치하세요." >&2
        echo "  sudo apt update" >&2
        echo "  sudo apt install python3 -y" >&2
    fi
    exit 1
fi
exec python3 chat.py
