# 1. 기반 이미지: 파이썬 3.12 경량 버전
FROM python:3.12-slim

# 2. 작업 디렉터리 /app (없으면 생성, cd와 유사)
WORKDIR /app

# 3. 의존성 목록만 먼저 복사 → 코드가 바뀌어도 pip 레이어 캐시 재사용
COPY requirements.txt .
# 4. 빌드 시 한 번 실행: 라이브러리 설치
RUN pip install --no-cache-dir -r requirements.txt

# 5. 나머지 소스 코드 복사 (자주 바뀌므로 뒤쪽에 배치)
COPY . .

# 6. root가 아닌 일반 사용자로 실행 (보안)
RUN useradd -m appuser
USER appuser

# 7. 환경 변수 기본값을 이미지에 굽기 (docker run -e 로 덮어쓰기 가능)
ENV APP_TITLE="김수환의 방명록" \
    THEME_COLOR="#7C3AED"

# 8. 사용할 포트 문서화 (실제 개방은 -p)
EXPOSE 5000

# 9. 컨테이너 시작 시 실행할 명령
CMD ["python", "app.py"]
