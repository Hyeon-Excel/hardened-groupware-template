# API_CONTRACT_SYNC_CHECKLIST.md

## 1. 목적

이 문서는 [docs/api/API.md](../api/API.md)에 정의된 API 목록과 [docs/api/openapi.yaml](../api/openapi.yaml) 간 계약 불일치를 추적하고, OpenAPI-first 원칙에 맞춰 동기화하기 위한 실행 체크리스트다.

---

## 2. 기준 시점

- 작성일: 2026-04-15
- 최근 업데이트: 2026-04-21 (internal 권한/세션 스키마 반영에 따른 계약 수치 재검증)
- 비교 기준:
  - API 목록 문서: [docs/api/API.md](../api/API.md)
  - 계약 스펙: [docs/api/openapi.yaml](../api/openapi.yaml)
- 비교 단위: HTTP Method + Path
- 참고: `?page=...` 형태의 예시 호출 라인은 실제 Path가 아니므로 누락 계산에서 제외

---

## 3. 요약 결과

- API.md method+path: 66개
- OpenAPI method+path: 66개
- 실제 누락(예시 쿼리 제외): 0개

진행 이력:

- 초기: 34개 누락
- 중간(P0 반영 후): 26개 누락
- 현재: 0개 누락

---

## 4. 우선순위

분류 기준:

- P0: 현재 페이지 명세 또는 1차 구현 대상과 직접 연결되는 API
- P1: 내부 운영/관리 흐름에서 바로 필요한 API
- P2: 2차 구현 대상 또는 확장 기능

### 4.1 P0 (즉시 반영)

- [x] `GET /api/external/notices`
- [x] `GET /api/external/notices/{noticeId}`
- [x] `GET /api/external/resources`
- [x] `GET /api/external/resources/{resourceId}`
- [x] `GET /api/external/resources/{resourceId}/download`
- [x] `GET /api/external/support-tickets/{ticketId}`
- [x] `GET /api/external/me`
- [x] `PATCH /api/external/me`

### 4.2 P1 (다음 스프린트)

- [x] `GET /api/internal/notices/{noticeId}`
- [x] `PATCH /api/internal/notices/{noticeId}`
- [x] `DELETE /api/internal/notices/{noticeId}`
- [x] `GET /api/internal/approvals/{approvalId}`
- [x] `PATCH /api/internal/approvals/{approvalId}/approve`
- [x] `PATCH /api/internal/approvals/{approvalId}/reject`
- [x] `GET /api/internal/employees/{employeeId}`
- [x] `GET /api/internal/support-tickets`
- [x] `GET /api/internal/support-tickets/{ticketId}`
- [x] `PATCH /api/internal/support-tickets/{ticketId}/status`
- [x] `POST /api/internal/support-tickets/{ticketId}/reply`
- [x] `GET /api/internal/applicants`
- [x] `POST /api/internal/applicants/{applicationId}/notes`

### 4.3 P2 (2차 구현/확장)

- [x] `GET /api/internal/admin/dashboard`
- [x] `GET /api/internal/admin/audit-logs`
- [x] `GET /api/internal/admin/external-users`
- [x] `GET /api/internal/admin/external-resources`
- [x] `GET /api/internal/admin/file-security-logs`
- [x] `GET /api/external/internal/resources`
- [x] `DELETE /api/external/internal/resources/{resourceId}`
- [x] `PATCH /api/external/internal/resources/{resourceId}/publish`
- [x] `PATCH /api/external/internal/resources/{resourceId}/archive`
- [x] `GET /api/external/internal/support-tickets`
- [x] `PATCH /api/external/internal/support-tickets/{ticketId}/status`
- [x] `GET /api/external/internal/users/{userId}`
- [x] `GET /api/external/me/download-history`
- [x] `/api/external/me/applications`는 canonical 정책에 따라 신규 사용 중지

---

## 5. 실행 체크리스트

### 5.1 계약 동기화

- [x] 누락 Path를 [docs/api/openapi.yaml](../api/openapi.yaml)에 추가
- [x] 각 Path에 `operationId`, `tags`, `security`, `responses` 최소 필드 반영
- [x] `components/schemas`에서 재사용 타입 정의 후 참조

### 5.2 문서 동기화

- [x] [docs/api/API.md](../api/API.md)의 API 목록과 OpenAPI 목록을 일치시킴
- [ ] 1차/2차 구현 분류를 OpenAPI description 또는 별도 태그로 명시
- [x] 예시 호출(`?page=...`)은 엔드포인트 목록과 분리

### 5.3 품질 게이트

- [x] CI에서 OpenAPI lint 검증 추가 ([.github/workflows/api-contract-guard.yml](../../.github/workflows/api-contract-guard.yml))
- [x] API.md와 OpenAPI 경로 차이를 검사하는 drift check 스크립트 추가 ([scripts/check_api_contract_drift.py](../../scripts/check_api_contract_drift.py))
- [x] PR 체크리스트에 "OpenAPI 동기화 완료" 항목 추가 ([docs/rules/PR_CHECKLIST.md](../rules/PR_CHECKLIST.md))

---

## 6. 완료 기준

아래 조건을 모두 만족하면 본 체크리스트를 완료로 본다.

1. `missing in OpenAPI` 목록이 0건이다.
2. 표준화 대상 엔드포인트의 canonical/deprecated 정책이 문서화되어 있다.
3. 신규 API 추가 시 API.md와 OpenAPI 동시 업데이트가 CI에서 강제된다.
