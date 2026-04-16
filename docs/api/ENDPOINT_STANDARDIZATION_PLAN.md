# ENDPOINT_STANDARDIZATION_PLAN.md

## 1. 목적

이 문서는 공개 API 경로 체계를 단일 규칙으로 정리하고, 중복/혼선 가능성이 있는 엔드포인트를 canonical 기준으로 통합하기 위한 계획서다.

---

## 2. 현재 이슈

### 2.1 동일 의미의 중복 경로

중복 후보:

- `GET /api/external/careers/applications/me`
- `GET /api/external/me/applications`

두 경로 모두 "내 지원 내역 조회"로 해석 가능해 클라이언트/서버 구현이 분기될 수 있다.

### 2.2 문서-계약 불일치

- API 목록 문서와 OpenAPI 간 경로 불일치가 존재
- 표준 경로를 먼저 확정하지 않으면 동기화 시 중복 스펙이 누적될 수 있음

---

## 3. 표준 경로 규칙

### 3.1 기본 원칙

1. 리소스 중심으로 설계한다.
2. 사용자 소유 목록 조회는 도메인 리소스 기준에서 `.../me` 형태를 우선한다.
3. `/me`는 사용자 프로필/계정 자체 조회·수정에만 사용한다.
4. 동일 의미 API를 2개 이상 유지하지 않는다.

### 3.2 적용 규칙

- 프로필/계정 정보:
  - `GET /api/external/me`
  - `PATCH /api/external/me`
- 도메인별 사용자 소유 목록:
  - `GET /api/external/support-tickets/me`
  - `GET /api/external/careers/applications/me`
- 운영/관리 리소스:
  - `/api/internal/...`
  - `/api/external/internal/...` (service-to-service)

---

## 4. Canonical 결정

| 기능              | Canonical                                 | Deprecate 후보                    | 비고                                             |
| ----------------- | ----------------------------------------- | --------------------------------- | ------------------------------------------------ |
| 내 지원 내역 조회 | `GET /api/external/careers/applications/me` | `GET /api/external/me/applications` | 페이지 명세와 OpenAPI가 canonical 경로를 사용 중 |

보완 결정:

- `GET /api/external/me/download-history`는 계정 하위 이력 성격이므로 유지 가능
- 향후 리소스 정합성을 더 높이고 싶다면 `GET /api/external/downloads/me`로 이관 검토

---

## 5. 마이그레이션 계획

### Phase A. 계약 확정

- OpenAPI에서 canonical 경로를 기본 계약으로 유지
- deprecated 경로가 필요하면 `deprecated: true`와 sunset 설명 추가

### Phase B. 서버 호환 구간

- deprecated 경로를 canonical 핸들러로 위임
- 응답 헤더에 deprecation 힌트 추가(예: `Deprecation`, `Sunset`)

### Phase C. 클라이언트 정리

- 프론트/내부 클라이언트에서 canonical 경로만 사용
- API SDK 생성 시 deprecated API 제외

### Phase D. 제거

- 합의된 sunset 날짜 이후 deprecated 경로 제거
- 제거 시 릴리즈 노트 및 변경 가이드 동시 배포

---

## 6. 구현 체크리스트

- [ ] canonical/deprecated 매핑 테이블 승인
- [ ] OpenAPI에 deprecated 표기 반영
- [ ] 서버 라우팅 alias 적용(필요 시)
- [ ] 클라이언트 호출 경로 교체
- [ ] API.md에서 중복 경로 정리
- [ ] 제거 일정 공지 및 문서화

---

## 7. 완료 기준

1. 동일 기능에 대한 공개 API 경로가 1개(canonical)로 수렴한다.
2. OpenAPI, API.md, 페이지 명세의 연결 API가 동일하다.
3. deprecated 경로 제거 일정이 문서화되어 있다.
