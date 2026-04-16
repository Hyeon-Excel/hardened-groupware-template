# API.md

# hardened-groupware-template API 설계 문서

## 1. 문서 목적

본 문서는 `hardened-groupware-template`의 API 경계, 네이밍 규칙, 인증 방식, 응답 형식, 엔드포인트 구조를 정의한다.  
이 문서는 프론트엔드와 백엔드, 그리고 내부 서비스 간 호출이 동일한 계약을 따르도록 하기 위한 기준 문서다.

본 문서는 다음 내용을 다룬다.

- 공개 서비스 API
- 내부 그룹웨어 API
- 공개 서비스 내부 관리 API
- 인증 방식
- CSRF 처리 규칙
- 공통 응답 포맷
- 비동기 파일 업로드 및 상태 조회 API
- 서비스 간 호출 규칙
- 상태 코드 및 에러 규칙

---

## 2. API 분류

본 시스템의 API는 다음 세 종류로 나뉜다.

### 2.1 External User API

일반 사용자가 공개 웹서비스를 통해 호출하는 API

예:

- 회원가입
- 로그인
- 뉴스 조회
- 고객센터 문의 등록
- 채용 지원
- 마이페이지 조회

기본 prefix:

- `/api/external`

---

### 2.2 Internal Groupware API

임직원과 관리자가 내부 그룹웨어를 통해 호출하는 API

예:

- 임직원 로그인
- 사내 공지 조회
- 전자결재
- 사원 디렉토리
- 지원자 검토
- 관리자 기능

기본 prefix:

- `/api/internal`

---

### 2.3 External Admin Internal API

내부 서비스가 공개 서비스 데이터를 관리하기 위해 호출하는 내부 전용 API

예:

- 공개 회원 상태 변경
- 공개 게시글 삭제
- 공개 자료 상태 변경
- 공개 문의 상태 처리

기본 prefix:

- `/api/external/internal`

주의:

- 외부 브라우저에서 직접 호출하는 API가 아니다.
- `internal-api` 또는 내부망에서만 접근 가능해야 한다.

---

## 3. API 기본 규칙

### 3.1 네이밍 규칙

- URI는 소문자와 하이픈을 사용한다.
- 복수형 자원명을 사용한다.
- 동사보다 자원을 중심으로 설계한다.
- 상태 변경이 필요한 경우 명시적인 action path를 허용한다.

예:

- `/api/external/news`
- `/api/external/support-tickets`
- `/api/internal/employees`
- `/api/internal/approvals`
- `/api/external/internal/users/{userId}/deactivate`

---

### 3.2 HTTP Method 규칙

- `GET`: 조회
- `POST`: 생성
- `PUT`: 전체 수정
- `PATCH`: 부분 수정 / 상태 변경
- `DELETE`: 삭제

---

### 3.3 데이터 형식

- 기본 요청/응답 형식은 `application/json`
- 파일 업로드는 `multipart/form-data`
- 파일 다운로드는 `application/octet-stream` 또는 실제 MIME 타입

---

### 3.4 비동기 처리 규칙

비동기 후처리가 필요한 요청은 `202 Accepted`를 사용할 수 있다.

대표 예:

- 파일 업로드 접수
- 파일 검역 작업 등록
- 후처리 작업 큐 등록

즉, 요청이 접수되었더라도 최종 완료를 의미하지 않을 수 있다.

---

## 4. 인증 및 호출 규칙

## 4.1 일반 사용자 인증

대상:

- `external-api`

방식:

- 세션 / 쿠키 기반 인증
- 세션 만료/쿠키 보안 속성 기준은 `docs/security/SECURITY_BASELINE.md`를 따른다.

적용 예:

- 로그인 후 마이페이지 접근
- 지원 내역 조회
- 문의 내역 확인

---

## 4.2 내부 사용자 인증

대상:

- `internal-api`

방식:

- 세션 / 쿠키 기반 인증
- 세션 만료/쿠키 보안 속성 기준은 `docs/security/SECURITY_BASELINE.md`를 따른다.

적용 예:

- 전자결재
- 사내 공지 관리
- 관리자 기능

---

## 4.3 CSRF 방어 규칙

본 시스템은 세션/쿠키 기반 인증을 사용하므로, 모든 상태 변경 요청은 CSRF 방어 규칙을 따른다.

적용 대상:

- `POST`
- `PUT`
- `PATCH`
- `DELETE`

기본 규칙:

- 클라이언트는 상태 변경 요청 시 `X-CSRF-TOKEN` 헤더를 포함해야 한다.
- 서버는 세션과 연계된 CSRF 토큰을 검증해야 한다.
- 공개 서비스와 내부 그룹웨어는 각자의 인증 경계에 따라 별도의 CSRF 토큰을 가진다.

CSRF 토큰 발급/조회 엔드포인트:

- `GET /api/external/csrf`
- `GET /api/internal/csrf`

응답 예시:

```json
{
  "success": true,
  "code": "CSRF_TOKEN_ISSUED",
  "message": "CSRF 토큰이 발급되었습니다.",
  "data": {
    "csrfToken": "token-value"
  },
  "timestamp": "2026-04-15T12:00:00Z"
}
```

주의:

- 로그인 성공 후에도 클라이언트는 필요 시 CSRF 토큰을 다시 조회할 수 있어야 한다.
- 서비스 간 호출(`internal-api -> external-api`)에는 사용자 CSRF 토큰이 아니라 내부 서비스 인증을 사용한다.

---

## 4.4 서비스 간 인증

대상:

- `internal-api -> external-api`

방식:

- 내부 서비스 전용 인증 토큰 또는 서비스 계정 헤더
- 토큰 회전/보관 정책은 `docs/security/SECURITY_BASELINE.md`를 따른다.

예시 헤더:

- `X-Service-Name: internal-api`
- `X-Service-Token: <internal-service-token>`

주의:

- 사용자 세션 쿠키를 서비스 간 인증에 사용하지 않는다.
- 브라우저 요청과 서비스 간 요청을 혼동하지 않는다.

---

## 5. 공통 응답 포맷

모든 JSON 응답은 다음 포맷을 기본으로 한다.

```json
{
  "success": true,
  "code": "OK",
  "message": "요청이 성공했습니다.",
  "data": {},
  "timestamp": "2026-04-15T12:00:00Z"
}
```

### 5.1 성공 응답 예시

```json id="mnamad"
{
  "success": true,
  "code": "PUBLIC_NEWS_LIST_OK",
  "message": "뉴스 목록 조회에 성공했습니다.",
  "data": {
    "items": [],
    "page": {
      "page": 1,
      "size": 10,
      "total": 0
    }
  },
  "timestamp": "2026-04-15T12:00:00Z"
}
```

### 5.2 실패 응답 예시

```json id="bhqxze"
{
  "success": false,
  "code": "AUTH_INVALID_CREDENTIALS",
  "message": "아이디 또는 비밀번호가 올바르지 않습니다.",
  "data": null,
  "timestamp": "2026-04-15T12:00:00Z"
}
```

---

## 6. 상태 코드 규칙

- `200 OK`: 정상 조회 / 수정 성공
- `201 Created`: 생성 성공
- `202 Accepted`: 비동기 처리 요청 접수 성공
- `204 No Content`: 삭제 성공
- `400 Bad Request`: 요청값 검증 실패
- `401 Unauthorized`: 인증 필요 / 인증 실패
- `403 Forbidden`: 권한 부족
- `404 Not Found`: 대상 자원 없음
- `409 Conflict`: 상태 충돌 / 중복
- `422 Unprocessable Entity`: 비즈니스 규칙 위반
- `429 Too Many Requests`: 호출 횟수 제한 초과
- `500 Internal Server Error`: 서버 오류

`429` 응답은 공개 API에 대한 무차별 대입 공격, 과도한 업로드 시도, 과도한 조회 요청 등에 대해 사용한다.

### 6.1 리소스 소유권(IDOR) 응답 정책

공개 사용자 소유 리소스 조회 API에서 소유권이 맞지 않으면 `403` 대신 `404`를 반환한다.

적용 이유:

- 리소스 존재 여부 자체를 외부 사용자에게 노출하지 않기 위함
- IDOR/BOLA 탐색 가능성 축소

대표 적용 대상:

- `GET /api/external/support-tickets/{ticketId}`
- `GET /api/external/files/{fileId}/status` (소유권 확인이 필요한 경우)

---

## 7. External User API 설계

## 7.1 인증

- `POST /api/external/auth/signup`
- `POST /api/external/auth/login`
- `POST /api/external/auth/logout`
- `POST /api/external/auth/password-reset/request`
- `POST /api/external/auth/password-reset/confirm`
- `GET /api/external/csrf`

---

## 7.2 뉴스 / 공지

- `GET /api/external/news`
- `GET /api/external/news/{newsId}`
- `GET /api/external/notices`
- `GET /api/external/notices/{noticeId}`

---

## 7.3 고객센터

- `POST /api/external/support-tickets`
- `GET /api/external/support-tickets/me`
- `GET /api/external/support-tickets/{ticketId}`

주의:

- `GET /api/external/support-tickets/{ticketId}`는 본인 소유가 아닌 리소스 접근 시 `404`를 반환한다.

---

## 7.4 자료실

- `GET /api/external/resources`
- `GET /api/external/resources/{resourceId}`
- `GET /api/external/resources/{resourceId}/download`

---

## 7.5 채용

- `GET /api/external/careers`
- `GET /api/external/careers/{careerId}`
- `POST /api/external/careers/{careerId}/applications`
- `GET /api/external/careers/applications/me`

---

## 7.6 마이페이지

- `GET /api/external/me`
- `PATCH /api/external/me`
- `GET /api/external/me/download-history`

경로 표준화 적용 (2026-04-16):

- 내 지원 내역 조회의 canonical 경로는 `GET /api/external/careers/applications/me`를 사용한다.
- `/api/external/me/applications` 경로는 중복 의미 alias이므로 신규 사용을 중지한다.

---

## 8. Internal Groupware API 설계

## 8.1 인증

- `POST /api/internal/auth/login`
- `POST /api/internal/auth/logout`
- `GET /api/internal/auth/me`
- `GET /api/internal/csrf`

---

## 8.2 사내 공지

- `GET /api/internal/notices`
- `GET /api/internal/notices/{noticeId}`
- `POST /api/internal/notices`
- `PATCH /api/internal/notices/{noticeId}`
- `DELETE /api/internal/notices/{noticeId}`

---

## 8.3 사원 디렉토리

- `GET /api/internal/employees`
- `GET /api/internal/employees/{employeeId}`

---

## 8.4 전자결재

- `GET /api/internal/approvals`
- `GET /api/internal/approvals/{approvalId}`
- `POST /api/internal/approvals`
- `PATCH /api/internal/approvals/{approvalId}/approve`
- `PATCH /api/internal/approvals/{approvalId}/reject`

---

## 8.5 지원자 검토

- `GET /api/internal/applicants`
- `GET /api/internal/applicants/{applicationId}`
- `PATCH /api/internal/applicants/{applicationId}/status`
- `POST /api/internal/applicants/{applicationId}/notes`

---

## 8.6 고객 문의 대응

- `GET /api/internal/support-tickets`
- `GET /api/internal/support-tickets/{ticketId}`
- `PATCH /api/internal/support-tickets/{ticketId}/status`
- `POST /api/internal/support-tickets/{ticketId}/reply`

---

## 8.7 관리자 기능

- `GET /api/internal/admin/dashboard`
- `GET /api/internal/admin/audit-logs`
- `GET /api/internal/admin/external-users`
- `GET /api/internal/admin/external-resources`
- `GET /api/internal/admin/quarantine-logs`

주의:

- 내부 관리자 화면은 공개 데이터를 직접 수정하지 않는다.
- 수정은 반드시 External Admin Internal API를 호출하는 내부 서비스 로직을 통해 처리한다.

---

## 9. External Admin Internal API 설계

## 9.1 공개 사용자 관리

- `GET /api/external/internal/users`
- `GET /api/external/internal/users/{userId}`
- `PATCH /api/external/internal/users/{userId}/deactivate`
- `PATCH /api/external/internal/users/{userId}/activate`
- `POST /api/external/internal/users/{userId}/password-reset`

---

## 9.2 공개 게시글 / 자료 관리

- `GET /api/external/internal/resources`
- `PATCH /api/external/internal/resources/{resourceId}/publish`
- `PATCH /api/external/internal/resources/{resourceId}/archive`
- `DELETE /api/external/internal/resources/{resourceId}`

---

## 9.3 공개 문의 상태 관리

- `GET /api/external/internal/support-tickets`
- `PATCH /api/external/internal/support-tickets/{ticketId}/status`

---

## 10. 파일 업로드 / 다운로드 API 규칙

## 10.1 업로드 규칙

업로드는 `multipart/form-data`를 사용한다.

예:

- `POST /api/external/careers/{careerId}/applications`
- `POST /api/external/support-tickets`

업로드 처리 원칙:

1. `external-api`가 업로드 수신
2. 파일을 `quarantine_storage`에 저장
3. `file_scan_jobs` 작업 생성
4. `file-worker`가 후속 검사 수행

즉, 업로드 성공 응답은 **최종 승인**이 아니라 **업로드 접수 성공**일 수 있다.

권장 상태 코드:

- `202 Accepted`

업로드 접수 응답 예시:

```json id="jlwmx2"
{
  "success": true,
  "code": "FILE_UPLOAD_ACCEPTED",
  "message": "파일 업로드가 접수되었습니다. 검역 결과를 기다려주세요.",
  "data": {
    "fileId": "file_12345",
    "jobId": "job_67890",
    "status": "PENDING"
  },
  "timestamp": "2026-04-15T12:00:00Z"
}
```

---

## 10.2 파일 상태 확인 API

비동기 검역을 사용하는 모든 업로드 파일은 상태 확인 API를 통해 현재 처리 상태를 조회할 수 있어야 한다.

공개 사용자용:

- `GET /api/external/files/{fileId}/status`

내부 관리자/검토용:

- `GET /api/internal/files/{fileId}/status`

상태값 예시:

- `PENDING`
- `SCANNING`
- `APPROVED`
- `REJECTED`
- `QUARANTINED`

응답 예시:

```json id="sb4v9l"
{
  "success": true,
  "code": "FILE_STATUS_OK",
  "message": "파일 상태 조회에 성공했습니다.",
  "data": {
    "fileId": "file_12345",
    "jobId": "job_67890",
    "status": "APPROVED",
    "reason": null
  },
  "timestamp": "2026-04-15T12:00:00Z"
}
```

실패/차단 예시:

```json id="3x1rha"
{
  "success": true,
  "code": "FILE_STATUS_OK",
  "message": "파일 상태 조회에 성공했습니다.",
  "data": {
    "fileId": "file_12345",
    "jobId": "job_67890",
    "status": "REJECTED",
    "reason": "FILE_POLICY_VIOLATION"
  },
  "timestamp": "2026-04-15T12:00:00Z"
}
```

---

## 10.3 다운로드 규칙

다운로드는 승인 저장소의 파일만 제공한다.

예:

- `GET /api/external/resources/{resourceId}/download`

다운로드 대상:

- `approved_external_storage`에 존재하는 파일만 허용

금지:

- `quarantine_storage` 직접 다운로드
- `internal_review_storage` 외부 공개

---

## 11. 페이징 / 정렬 / 검색 규칙

목록 조회 API는 다음 query parameter를 공통 사용한다.

- `page`
- `size`
- `sort`
- `keyword`

예:

- `GET /api/external/news?page=1&size=10&sort=createdAt,desc`
- `GET /api/internal/employees?page=1&size=20&keyword=kim`

응답 예시:

```json id="6rwf3n"
{
  "success": true,
  "code": "LIST_OK",
  "message": "목록 조회에 성공했습니다.",
  "data": {
    "items": [],
    "page": {
      "page": 1,
      "size": 10,
      "total": 100
    }
  },
  "timestamp": "2026-04-15T12:00:00Z"
}
```

---

## 12. 에러 코드 네이밍 규칙

형식:

- `DOMAIN_REASON`

예:

- `AUTH_INVALID_CREDENTIALS`
- `PUBLIC_USER_NOT_FOUND`
- `INTERNAL_APPROVAL_FORBIDDEN`
- `FILE_EXTENSION_NOT_ALLOWED`
- `FILE_SCAN_FAILED`
- `FILE_POLICY_VIOLATION`
- `RATE_LIMIT_EXCEEDED`
- `SERVICE_TOKEN_INVALID`

---

## 13. OpenAPI 관리 원칙

- API 계약은 구현 전에 먼저 정의한다.
- OpenAPI 문서는 `docs/api/openapi.yaml`을 기준으로 관리한다.
- External / Internal / External Internal API를 하나의 스펙 안에서 태그로 구분한다.
- 구현 변경 시 OpenAPI를 먼저 수정하고, 그다음 서버/클라이언트를 수정한다.

태그 예시:

- `External Auth`
- `External News`
- `External Support`
- `External Careers`
- `External Files`
- `Internal Auth`
- `Internal Approvals`
- `Internal Employees`
- `Internal Files`
- `External Internal Admin`

---

## 14. 폴더 구조 대응

이 문서는 아래 구조와 직접 연결된다.

- `apps/external-web/src/api/`
- `apps/external-api/src/main/java/.../auth/`
- `apps/external-api/src/main/java/.../query/`
- `apps/external-api/src/main/java/.../admininternal/`
- `apps/external-api/src/main/java/.../files/`
- `apps/internal-web/src/api/`
- `apps/internal-api/src/main/java/.../externalbridge/`
- `docs/api/openapi.yaml`

---

## 15. 초기 구현 우선순위

### 15.1 1차 구현 대상

- External Auth
- External CSRF
- External News / Notices
- External Support
- External Careers
- External File Status
- Internal Auth
- Internal CSRF
- Internal Notices
- Internal Employees
- Internal Approvals
- External Internal User Management

### 15.2 2차 구현 대상

- 다운로드 이력
- 관리자 대시보드
- 감사 로그
- 문의 답변 상세 흐름
- 파일 상태 추적 상세 API
- Rate limiting 상태 및 정책 고도화

---

## 16. 요약

이 API 문서의 핵심은 다음과 같다.

1. API는 **External / Internal / External Internal** 세 경계로 구분한다.
2. 인증은 **세션 기반 사용자 인증**과 **서비스 간 인증**을 분리한다.
3. 모든 상태 변경 요청은 **CSRF 토큰 검증**을 전제로 한다.
4. 내부 그룹웨어는 공개 데이터를 직접 수정하지 않고, `external-api`의 내부 관리 인터페이스를 호출한다.
5. 파일 업로드는 검역 저장소와 비동기 검사 흐름을 전제로 하며, 상태 조회 API를 제공한다.
6. 공개 API에는 **429 Too Many Requests**를 포함한 호출 제한 정책을 반영한다.
7. 모든 구현은 OpenAPI 계약을 먼저 고정한 뒤 진행한다.
