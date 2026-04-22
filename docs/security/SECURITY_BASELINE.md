# SECURITY_BASELINE.md

## 1. 목적

이 문서는 `hardened-groupware-template`의 보안 운영 기준을 **v0(MVP) 기본값**과 **v1(하드닝 목표) 기준**으로 나누어 정의한다.

적용 범위:

- 세션/쿠키 인증 정책
- 서비스 간 토큰 정책
- HTTP 보안 헤더 정책(Nginx 기준)
- 비밀번호 해시 정책
- 인가(IDOR/BOLA) 응답 정책
- 파일 다운로드 게이트 정책 요약

### 1.1 v0 / v1 기준선의 의미

본 프로젝트는 AI 보조 개발 산출물의 현실적인 보안 리스크를 확인하고 전후(before/after) 차이를 측정하는 것을 목적으로 한다. 따라서 v0는 **프레임워크 기본값 수준**을 유지하고, v1에서만 명시적 하드닝을 적용한다.

| 구분 | v0 (MVP) | v1 (하드닝) |
| --- | --- | --- |
| 성격 | 평범한 개발자 관점의 기본 설정 | 분석 결과 기반 명시적 보안 조치 |
| 목적 | 분석 페이즈에서 공격면을 충분히 남김 | 전후 재검증에서 개선된 목표 상태 |
| 적용 주체 | Spring Security / Spring Boot / Nginx 기본값 | 명시적 설정·코드·Nginx directive |

정합성 원칙:

- v0 기준선을 임의로 강화하지 않는다(분석 대상 왜곡 방지).
- v1 기준선을 v0에 선반영하지 않는다.
- 모호한 항목은 기본적으로 v0 측으로 해석한다.
- 관련 정본: [PLANNING.md](../architecture/PLANNING.md) 섹션 7, [ARCHITECTURE.md](../architecture/ARCHITECTURE.md) 섹션 3.6, [ROADMAP.md](../architecture/ROADMAP.md) Phase 3.

---

## 2. 세션/쿠키 정책

### 2.1 v0 기본값 (Spring Security 기본 동작)

- 세션 저장소: 서블릿 컨테이너 기본 HTTP 세션(in-memory).
- 세션 수명: `server.servlet.session.timeout` 기본값(일반적으로 idle 30분, absolute 제한 없음).
- 세션 고정 방지: Spring Security 기본 `migrateSession` 동작에 의존(명시적 재발급 코드 없음).
- 로그아웃: Spring Security 기본 `/logout` 핸들러에 의존.
- CSRF: API 계약 정본([API.md](../api/API.md) 섹션 4.3)을 따르며, v0에서는 Spring Security 기본 동작 수준으로 운영한다.
- 쿠키 속성(개발 HTTP 환경): `HttpOnly`는 서블릿 기본, `Secure`·`SameSite`는 명시 설정 없음.

### 2.2 v1 하드닝 목표값

- **세션 수명**
  - 공개 사용자 세션(`external-api`): idle 30분 / absolute 12시간
  - 내부 사용자 세션(`internal-api`): idle 15분 / absolute 8시간
- **세션 보안 규칙**
  - 로그인 성공 시 세션 ID 재발급 명시(Session Fixation 방어)
  - 로그아웃 시 서버 세션 무효화 + 쿠키 만료 처리 명시
  - 상태 변경 CSRF 규칙은 [API.md](../api/API.md) 섹션 4.3 정본을 따른다.
  - 사용자 로그인은 세션/쿠키만 사용하며 JWT(access/refresh)는 발급하지 않는다.
- **쿠키 속성**
  - `HttpOnly=true`
  - `Secure=true` (HTTPS 필수)
  - `SameSite=Lax` 기본 / 내부 관리자 경로는 `Strict` 검토
- **동시 세션 정책**
  - `ADMIN` 계정은 기본 1세션 제한
  - 동일 계정 다중 로그인 발생 시 기존 세션 만료 또는 신규 로그인 차단 중 하나를 정책으로 고정

---

## 3. 서비스 간 토큰 정책

### 3.1 v0 기본값

- external 단독 v0 구간에서는 internal 연동 경로 자체가 없어 서비스 간 토큰은 **미적용**.
- 시크릿 관리도 최소 수준(Spring 기본 프로퍼티 / `.env`)으로, 회전·grace period 운영 없음.

### 3.2 v1 하드닝 목표값

- `X-Service-Token`은 환경변수/시크릿 매니저로 관리한다.
- 저장소 커밋 금지.
- 회전 주기
  - 운영: 30일
  - 스테이징/실습: 7~14일
- 토큰 회전 시 구/신 토큰 grace period를 두고 점진 전환한다.
- internal 연동이 실제로 시작되는 시점부터 본 정책을 필수 적용한다.

---

## 4. HTTP 보안 헤더 정책

### 4.1 v0 기본값

- Nginx 수준에서 **명시적 보안 헤더 추가 없음**. 프레임워크/프록시 기본 응답만.
- HSTS / CSP / X-Frame-Options / Referrer-Policy / Permissions-Policy 모두 미설정.
- 목적: 보안 헤더 누락으로 인한 실제 공격면(clickjacking, MIME sniffing, XSS 영향 확대)을 분석 페이즈에서 관찰 가능하게 유지.

### 4.2 v1 하드닝 목표값

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

#### 4.2.1 Nginx 예시 (v1)

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

### 5.1 v0 기본값

- Spring Security 기본 `PasswordEncoder`(`DelegatingPasswordEncoder`) 사용. 기본 bcrypt 수준이며 별도 파라미터 튜닝은 하지 않는다.

### 5.2 v1 하드닝 목표값

- `password_hash`는 Argon2id(권장) 또는 bcrypt를 사용한다.
- 최소 파라미터(권장)
  - Argon2id: memory/time/parallelism을 운영 환경에 맞춰 조정
  - bcrypt: cost 10 이상

---

## 6. IDOR/BOLA 응답 정책

### 6.1 v0 기본값

- 소유권 불일치 시 `403` 또는 `404`가 반환될 수 있다(구현·프레임워크 기본 예외 처리에 의존).
- 리소스 존재 여부 노출이 실제 공격 시 어떻게 활용되는지를 분석 페이즈에서 관찰한다.

### 6.2 v1 하드닝 목표값

- 공개 사용자 소유 리소스 조회에서 소유권 불일치 시 `403` 대신 `404`를 반환한다.
- 목적: 리소스 존재 여부 노출 최소화.
- 예시: `GET /api/external/support-tickets/{ticketId}`

---

## 7. 파일 다운로드 게이트 정책 (요약)

세부 설계/상태 전이 정본은 [ARCHITECTURE.md](../architecture/ARCHITECTURE.md) 섹션 5를 따른다.
본 섹션은 운영 기준선만 요약한다.

### 7.1 v0

- `scan_status='APPROVED'`, `scan_result_code='V0_SCAN_DISABLED'` 고정.
- 실스캔은 비활성화한다.

### 7.2 v1

- fail-closed: `PENDING/SCANNING/REJECTED/FAILED`는 다운로드 거부.
- 다운로드는 owner API 게이트만 허용(직접 접근 금지, presigned URL도 owner API가 발급/검증 주체).
- 공개 파일 상태/문의 응답의 사유 필드는 일반화 코드만 노출하고, 내부 탐지 상세 사유는 내부 API/운영 로그에서만 허용한다.
- 공개 API의 `scanResultCode`는 `V0_SCAN_DISABLED`, `PUBLIC_SCAN_RESULT_UNAVAILABLE`, `null`만 허용한다.

---

## 8. v0 → v1 전환 체크리스트

- [ ] 세션 timeout 값 명시 설정(idle/absolute)
- [ ] 세션 고정 방지(로그인 시 세션 ID 재발급) 명시 활성화
- [ ] 쿠키 속성 `Secure/HttpOnly/SameSite` 명시
- [ ] Nginx 보안 헤더 6종 적용
- [ ] 비밀번호 해시 파라미터 상향
- [ ] IDOR 응답을 404로 통일
- [ ] 파일 다운로드 게이트를 `APPROVED`만 허용으로 전환
- [ ] 서비스 간 토큰 회전 정책 수립(internal 연동 존재 시)

---

## 9. 변경 이력

- 2026-04-16: 초안 작성
- 2026-04-16: IDOR/BOLA 응답 정책(소유권 불일치 시 404) 추가
- 2026-04-20: 적용 단계(v0 예외, v1/내부 연동 기본 적용) 명시
- 2026-04-20: 전면 개편 — 프로젝트 v0/v1 phase 모델에 맞춰 기준선을 "v0 기본값 / v1 하드닝 목표값"으로 분리. v0는 프레임워크 기본 동작을 그대로 두고, v1에서만 명시적 하드닝을 적용하도록 정합화. [PLANNING.md](../architecture/PLANNING.md) 섹션 7, [ARCHITECTURE.md](../architecture/ARCHITECTURE.md) 섹션 3.6, [ROADMAP.md](../architecture/ROADMAP.md) Phase 3과 일관화.
