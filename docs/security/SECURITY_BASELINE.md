# SECURITY_BASELINE.md

## 1. 목적

이 문서는 `hardened-groupware-template`의 운영 보안 기본 정책을 정의한다.

적용 범위:

- 세션/쿠키 인증 정책
- 서비스 간 토큰 정책
- HTTP 보안 헤더 정책(Nginx 기준)

---

## 2. 세션/쿠키 정책

### 2.1 세션 수명

- 공개 사용자 세션(`external-api`)
  - Idle timeout: 30분
  - Absolute timeout: 12시간
- 내부 사용자 세션(`internal-api`)
  - Idle timeout: 15분
  - Absolute timeout: 8시간

### 2.2 세션 보안 규칙

- 로그인 성공 시 세션 ID 재발급(Session Fixation 방어)
- 로그아웃 시 서버 세션 무효화 + 쿠키 만료 처리
- 상태 변경 요청은 CSRF 토큰 필수

### 2.3 쿠키 속성

- `HttpOnly=true`
- `Secure=true` (HTTPS 필수)
- `SameSite=Lax` 기본
  - 내부 관리자 경로는 필요 시 `Strict` 적용 검토

### 2.4 동시 세션 정책

- `ADMIN` 계정은 기본 1세션 제한
- 동일 계정 다중 로그인 발생 시 기존 세션 만료 또는 신규 로그인 차단 중 하나를 정책으로 고정

---

## 3. 서비스 간 토큰 정책

- `X-Service-Token`은 환경변수/시크릿 매니저로 관리한다.
- 저장소 커밋 금지
- 회전 주기:
  - 운영: 30일
  - 스테이징/실습: 7~14일
- 토큰 회전 시 구/신 토큰 grace period를 두고 점진 전환한다.

---

## 4. HTTP 보안 헤더 정책

Nginx 응답 헤더 기본값(HTTPS 기준):

- `Strict-Transport-Security: max-age=31536000; includeSubDomains`
- `Content-Security-Policy: default-src 'self'; base-uri 'self'; object-src 'none'; frame-ancestors 'none'; img-src 'self' data:; script-src 'self'; style-src 'self'`
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy: camera=(), microphone=(), geolocation=()`

주의:

- HSTS는 HTTPS 환경에서만 활성화한다.
- CSP는 운영 중 필요한 리소스 도메인만 allowlist 방식으로 추가한다.

### 4.1 Nginx 예시

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Content-Security-Policy "default-src 'self'; base-uri 'self'; object-src 'none'; frame-ancestors 'none'; img-src 'self' data:; script-src 'self'; style-src 'self'" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
```

---

## 5. 비밀번호 해시 정책

- `password_hash`는 Argon2id(권장) 또는 bcrypt를 사용한다.
- 최소 파라미터(권장):
  - Argon2id: memory/time/parallelism을 운영 환경에 맞춰 조정
  - bcrypt: cost 10 이상

---

## 6. IDOR/BOLA 응답 정책

- 공개 사용자 소유 리소스 조회에서 소유권 불일치 시 `403` 대신 `404`를 반환한다.
- 목적: 리소스 존재 여부 노출 최소화
- 예시:
  - `GET /api/external/support-tickets/{ticketId}`

---

## 7. 변경 이력

- 2026-04-16: 초안 작성
- 2026-04-16: IDOR/BOLA 응답 정책(소유권 불일치 시 404) 추가
