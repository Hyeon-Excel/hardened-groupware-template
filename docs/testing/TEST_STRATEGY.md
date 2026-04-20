# TEST_STRATEGY.md

## 1. 목적

이 문서는 구현 단계에서 테스트 범위와 우선순위를 일관되게 유지하기 위한 기준이다.

적용 범위:

- `external-web`, `internal-web`
- `external-api`, `internal-api`

---

## 2. 테스트 피라미드 기준

- 단위 테스트(Unit): 60%
- 통합 테스트(Integration): 30%
- E2E 테스트: 10%

원칙:

- 비즈니스 규칙은 단위 테스트로 빠르게 검증
- 인증/인가/DB/서비스 경계는 통합 테스트로 검증
- 핵심 사용자 플로우만 E2E 최소 집합 유지

---

## 3. 백엔드 테스트 전략

대상:

- `external-api`
- `internal-api`

### 3.1 단위 테스트

- 서비스 계층 규칙
- 권한 정책/검증 유틸
- 파일 상태 전이 규칙(`scan_status`)

### 3.2 통합 테스트

- API 엔드포인트 + 인증/인가 필터 체인
- DB 리포지토리 쿼리
- `internal-api -> external-api` 브리지 호출(mock/stub 가능)
- `uploaded_file` 상태 게이트 및 다운로드 허용 조건

### 3.3 보안 회귀 테스트(자동화 필수)

- CSRF 미포함 상태 변경 요청 차단
- 세션 없는 보호 API 접근 차단(401)
- 권한 부족 접근 차단(403)
- 서비스 토큰 누락/불일치 차단(401/403)
- IDOR 방어: 타 사용자 리소스 조회 시 404
- 파일 게이트: `APPROVED` 외 상태 다운로드 차단

---

## 4. 프론트엔드 테스트 전략

대상:

- `external-web`
- `internal-web`

### 4.1 컴포넌트 테스트

- 폼 검증
- 상태 배지(`FileStatusBadge`, `ApprovalStatusBadge`)
- 에러/로딩/빈 상태 렌더링

### 4.2 페이지/플로우 E2E

최소 필수 플로우:

- 외부 로그인 → 마이페이지 접근
- 문의 등록 → 내 문의 목록/상태 확인
- 지원서 제출 → 내 지원 내역 상태 확인
- 내부 로그인 → 결재 처리
- 관리자 파일 보안 이벤트 로그 조회

---

## 5. v0 / v1 테스트 차등

### 5.1 v0

- `scan_status=APPROVED`
- `scan_result_code='V0_SCAN_DISABLED'`
- 업로드 접수 응답에서 `status=APPROVED`, `scanResultCode=V0_SCAN_DISABLED` 확인
- 파일 상태 조회 API에서 v0 기본값이 동일하게 반환되는지 확인
- `APPROVED` 상태 파일의 다운로드 허용 경로 검증

### 5.2 v1

- `PENDING -> SCANNING -> APPROVED/REJECTED/FAILED` 전이 검증
- fail-closed(`PENDING/SCANNING/FAILED/REJECTED` 거부) 검증
- 동시성 락(`FOR UPDATE SKIP LOCKED` 등) 검증
- 재동기화 잡 정합성 검증

---

## 6. 커버리지 및 품질 게이트

- 백엔드 단위+통합 커버리지 목표: 70% 이상
- 보안 핵심 모듈(인증/인가/파일 게이트/브리지): 80% 이상 권장
- PR 병합 최소 조건:
  - 관련 테스트 통과
  - 신규 보안 규칙 변경 시 보안 회귀 테스트 1개 이상 추가

---

## 7. CI 실행 기준

- PR: 단위 + 핵심 통합 + API 계약 가드
- main/develop: 전체 통합 + E2E 스모크
- 보안 하드닝 PR: 보안 회귀 테스트 포함 필수

---

## 8. 변경 이력

- 2026-04-16: 초안 작성
- 2026-04-20: 단일 스토리지 + 파일 상태 머신(v0/v1) 기준으로 개편
