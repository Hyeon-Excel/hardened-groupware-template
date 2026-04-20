# PAGE_STRUCTURE.md

# hardened-groupware-template 페이지 구조 기획 문서

## 1. 문서 목적

본 문서는 `hardened-groupware-template`의 화면 구조(Information Architecture)와 페이지별 책임을 정의한다.  
이 문서는 프론트엔드 구현 전에 **어떤 페이지가 존재하는지**, **각 페이지가 어떤 데이터를 다루는지**, **어떤 권한이 필요한지**, **어떤 API와 연결되는지**를 먼저 고정하기 위한 기준 문서다.

본 문서를 통해 다음을 명확히 한다.

- 공개 웹 서비스 페이지 구성
- 내부 그룹웨어 페이지 구성
- 인증 필요 여부
- 역할별 접근 경계
- 페이지별 주요 액션
- 페이지별 필요한 API 범위
- MVP 우선순위
- 에러 대응 화면 구조
- 파일 보안 상태/차단 상태를 확인할 관리자 화면 구조

---

## 2. 페이지 구조 설계 원칙

### 2.1 서비스 경계 분리

- 공개 웹 서비스와 내부 그룹웨어는 다른 서비스 경계로 본다.
- 일반 사용자가 사용하는 화면과 임직원이 사용하는 화면을 혼합하지 않는다.

### 2.2 인증 경계 분리

- 공개 서비스 로그인은 일반 사용자용이다.
- 내부 그룹웨어 로그인은 임직원/관리자용이다.
- 같은 브라우저에서 보여도 인증 체계는 분리된다.

### 2.3 페이지는 기능 단위로 나눈다

- 단순 라우트가 아니라, 데이터 책임이 다른 경우 페이지를 분리한다.
- 목록 / 상세 / 생성 / 수정 흐름이 다르면 별도 화면으로 본다.

### 2.4 MVP 우선순위를 먼저 정한다

- 모든 페이지를 처음부터 완성하지 않는다.
- MVP는 external 화면을 우선으로 Phase 1에 확보하고, Phase 2 분석에 필요한 internal 최소 화면만 병행한다.
- 이후 internal 상세 업무 화면, 관리자 편의성, 통계/부가 기능은 Phase 3 이후로 둔다.

### 2.5 페이지 설계는 API 설계보다 먼저 고정한다

- 화면이 무엇을 보여줘야 하는지 먼저 정하고,
- 그 다음 필요한 API를 뽑는다.

### 2.6 보안 상태는 화면에서도 증명 가능해야 한다

- 파일 보안 검사 결과, 차단, 상태 변경, 접근 거부 같은 보안 동작은 관리자 또는 사용자 화면에서 확인 가능해야 한다.
- 따라서 보안 기능은 백엔드 로직만이 아니라 **모니터링/상태 표시 페이지**까지 포함해 설계한다.

---

## 3. 전체 구조 요약

본 시스템의 화면 구조는 크게 두 그룹으로 나뉜다.

1. **공개 웹 서비스 (External Web)**
2. **내부 그룹웨어 (Internal Groupware)**

추가로, 두 서비스 모두 공통 에러 페이지를 가진다.

---

## 4. 공개 웹 서비스 페이지 구조

상세 페이지 본문 정본은 [PAGE_SPECS_EXTERNAL.md](PAGE_SPECS_EXTERNAL.md) 인덱스와 각 상세 문서에서 관리한다.
본 문서는 전체 구조/권한 경계/라우트 관점만 유지한다.

## 4.1 공개 웹 전체 라우트 개요

```text
/
├─ /login
├─ /signup
├─ /password-reset/request
├─ /password-reset/confirm
├─ /news
├─ /news/:newsId
├─ /notices
├─ /notices/:noticeId
├─ /resources
├─ /support
├─ /support/new
├─ /support/me
├─ /support/:ticketId
├─ /careers
├─ /careers/:careerId
├─ /careers/:careerId/apply
├─ /mypage
├─ /mypage/profile
├─ /mypage/applications
├─ /mypage/download-history
├─ /403
├─ /404
├─ /500
└─ /error
```

---

## 4.2 공개 웹 공통 레이아웃

### 공통 요소

- Header
- Main Navigation
- Footer
- Global Alert / Toast
- 로그인 상태 표시
- 접근 권한에 따른 메뉴 제어
- 공통 에러 페이지 라우팅
- 요청 실패 시 안전한 메시지 처리

### Header 기본 메뉴

- 홈
- 뉴스
- 공지사항
- 자료실
- 고객센터
- 채용
- 로그인 / 회원가입
- 마이페이지 (로그인 시)

### 공개 웹 에러 처리 원칙

- 403: 권한이 없거나 접근이 허용되지 않음
- 404: 존재하지 않는 페이지
- 500: 서버 처리 오류
- error: 예외적 상황의 공통 fallback UI
- 429는 전용 독립 페이지보다 **토스트 또는 인라인 메시지**로 우선 처리한다.

---

## 4.3 공개 웹 페이지별 정의

| 경로                       | 페이지명             | 목적                          | 인증 필요 | 주요 데이터                     | 주요 액션           | 우선순위 |
| -------------------------- | -------------------- | ----------------------------- | --------- | ------------------------------- | ------------------- | -------- |
| `/`                        | 메인 페이지          | 기업 웹 서비스 진입점         | 아니오    | 주요 공지, 대표 뉴스, 채용 배너 | 이동, 탐색          | MVP      |
| `/login`                   | 일반 사용자 로그인   | 공개 서비스 로그인            | 아니오    | 로그인 상태                     | 로그인              | MVP      |
| `/signup`                  | 회원가입             | 일반 사용자 계정 생성         | 아니오    | 계정 기본 정보                  | 회원가입            | MVP      |
| `/password-reset/request`  | 비밀번호 재설정 요청 | 재설정 요청 접수              | 아니오    | 이메일                          | 재설정 요청         | MVP      |
| `/password-reset/confirm`  | 비밀번호 재설정 확인 | 새 비밀번호 설정              | 아니오    | 토큰, 새 비밀번호               | 비밀번호 변경       | MVP      |
| `/news`                    | 뉴스 목록            | 공개 뉴스 리스트 제공         | 아니오    | 뉴스 목록                       | 검색, 페이지 이동   | MVP      |
| `/news/:newsId`            | 뉴스 상세            | 개별 뉴스 내용 조회           | 아니오    | 뉴스 상세                       | 뒤로가기            | MVP      |
| `/notices`                 | 공지사항 목록        | 공지 목록 제공                | 아니오    | 공지 목록                       | 상세 이동           | MVP      |
| `/notices/:noticeId`       | 공지 상세            | 공지 내용 조회                | 아니오    | 공지 상세                       | 뒤로가기            | MVP      |
| `/resources`               | 자료실 목록          | 공개 자료 리스트 제공         | 아니오    | 자료 목록                       | 다운로드            | MVP      |
| `/support`                 | 고객센터 안내        | 고객센터 진입                 | 아니오    | 간단한 FAQ, 문의 안내           | 문의 작성 이동      | 추천     |
| `/support/new`             | 문의 등록            | 고객 문의 작성                | 예        | 문의 입력값, 첨부파일           | 문의 제출           | MVP      |
| `/support/me`              | 내 문의 목록         | 본인 문의 이력 확인           | 예        | 내 문의 목록                    | 상세 이동           | MVP      |
| `/support/:ticketId`       | 문의 상세            | 개별 문의 상태 확인           | 예        | 문의 상세, 첨부 상태            | 상태 확인           | 추천     |
| `/careers`                 | 채용 공고 목록       | 채용 목록 제공                | 아니오    | 채용 공고 목록                  | 상세 이동           | MVP      |
| `/careers/:careerId`       | 채용 공고 상세       | 채용 공고 상세 조회           | 아니오    | 채용 공고 상세                  | 지원하기            | MVP      |
| `/careers/:careerId/apply` | 지원서 제출          | 지원서 작성 및 업로드         | 예        | 지원서 입력값, 첨부파일         | 제출                | MVP      |
| `/mypage`                  | 마이페이지 홈        | 개인 기능 진입점              | 예        | 사용자 요약 정보                | 하위 메뉴 이동      | MVP      |
| `/mypage/profile`          | 내 정보 관리         | 계정 정보 조회/수정           | 예        | 내 프로필 정보                  | 수정                | 추천     |
| `/mypage/applications`     | 내 지원 내역         | 채용 지원 이력 확인           | 예        | 지원 내역 목록                  | 상세 확인           | MVP      |
| `/mypage/download-history` | 다운로드 이력        | 자료 다운로드 기록 확인       | 예        | 다운로드 로그                   | 조회                | 후순위   |
| `/403`                     | 접근 거부 페이지     | 권한 부족 시 안내             | 아니오    | 오류 메시지                     | 홈/이전 페이지 이동 | MVP      |
| `/404`                     | 페이지 없음          | 잘못된 경로 처리              | 아니오    | 오류 메시지                     | 홈 이동             | MVP      |
| `/500`                     | 서버 오류 페이지     | 서버 오류 발생 시 안전한 안내 | 아니오    | 오류 메시지                     | 홈 이동 / 재시도    | 추천     |
| `/error`                   | 공통 에러 페이지     | 예외 상황 fallback UI         | 아니오    | 오류 메시지                     | 홈 이동             | 추천     |

---

## 4.4 공개 웹 MVP 페이지

MVP 대상 라우트는 섹션 4.3 표에서 `우선순위 = MVP` 행을 정본으로 사용한다.
상세 명세 작성 상태는 [PAGE_SPECS_EXTERNAL.md](PAGE_SPECS_EXTERNAL.md) 섹션 4를 참조한다.

---

## 5. 내부 그룹웨어 페이지 구조

## 5.1 내부 그룹웨어 전체 라우트 개요

```text id="n0q4w0"
/internal
├─ /internal/login
├─ /internal/dashboard
├─ /internal/notices
├─ /internal/notices/:noticeId
├─ /internal/employees
├─ /internal/employees/:employeeId
├─ /internal/approvals
├─ /internal/approvals/new
├─ /internal/approvals/:approvalId
├─ /internal/applicants
├─ /internal/applicants/:applicationId
├─ /internal/support-tickets
├─ /internal/support-tickets/:ticketId
├─ /internal/admin
├─ /internal/admin/external-users
├─ /internal/admin/external-users/:userId
├─ /internal/admin/external-resources
├─ /internal/admin/file-security-logs
├─ /internal/admin/audit-logs
├─ /internal/403
├─ /internal/404
├─ /internal/500
└─ /internal/error
```

---

## 5.2 내부 그룹웨어 공통 레이아웃

### 공통 요소

- Sidebar Navigation
- Topbar
- 현재 로그인 사용자 정보
- 권한별 메뉴 제어
- 공통 테이블 / 검색 / 필터 / 상태 배지
- 파일 상태 / 차단 상태 배지 표시 가능 구조
- 공통 에러 페이지 라우팅

### Sidebar 기본 메뉴

- 대시보드
- 사내 공지
- 사원 디렉토리
- 전자결재
- 지원자 검토
- 고객 문의
- 관리자 메뉴 (권한 보유 시)

관리자 메뉴 하위:

- 공개 사용자 관리
- 공개 자료 관리
- 파일 보안 이벤트 로그
- 감사 로그

---

## 5.3 내부 그룹웨어 페이지별 정의

| 경로                                   | 페이지명         | 목적                          | 인증 필요 | 권한          | 주요 데이터                                | 주요 액션                | 우선순위 |
| -------------------------------------- | ---------------- | ----------------------------- | --------- | ------------- | ------------------------------------------ | ------------------------ | -------- |
| `/internal/login`                      | 내부 로그인      | 임직원/관리자 로그인          | 아니오    | 없음          | 로그인 상태                                | 로그인                   | MVP      |
| `/internal/dashboard`                  | 대시보드         | 내부 서비스 홈                | 예        | EMPLOYEE 이상 | 요약 통계, 최근 공지, 결재 대기, 차단 건수 | 이동                     | MVP      |
| `/internal/notices`                    | 사내 공지 목록   | 공지 조회                     | 예        | EMPLOYEE 이상 | 공지 목록                                  | 상세 이동                | MVP      |
| `/internal/notices/:noticeId`          | 사내 공지 상세   | 공지 상세 조회                | 예        | EMPLOYEE 이상 | 공지 상세                                  | 수정/삭제(권한 시)       | MVP      |
| `/internal/employees`                  | 사원 디렉토리    | 조직 구성원 조회              | 예        | EMPLOYEE 이상 | 사원 목록                                  | 검색, 상세 이동          | MVP      |
| `/internal/employees/:employeeId`      | 사원 상세        | 사원 정보 조회                | 예        | EMPLOYEE 이상 | 사원 상세                                  | 조회                     | 추천     |
| `/internal/approvals`                  | 전자결재 목록    | 결재 문서 조회                | 예        | EMPLOYEE 이상 | 결재 목록                                  | 상세 이동, 승인/반려     | MVP      |
| `/internal/approvals/new`              | 전자결재 작성    | 결재 문서 생성                | 예        | EMPLOYEE 이상 | 결재 입력값                                | 제출                     | MVP      |
| `/internal/approvals/:approvalId`      | 전자결재 상세    | 결재 상세 및 처리             | 예        | EMPLOYEE 이상 | 결재 상세                                  | 승인, 반려               | MVP      |
| `/internal/applicants`                 | 지원자 목록      | 지원서 검토 목록              | 예        | MANAGER 이상  | 지원자 목록                                | 상세 이동, 상태 필터     | MVP      |
| `/internal/applicants/:applicationId`  | 지원자 상세      | 지원서 및 첨부 검토           | 예        | MANAGER 이상  | 지원자 상세, 파일 상태                     | 상태 변경, 메모 작성     | MVP      |
| `/internal/support-tickets`            | 문의 목록        | 고객 문의 처리                | 예        | MANAGER 이상  | 문의 목록                                  | 상세 이동, 상태 필터     | MVP      |
| `/internal/support-tickets/:ticketId`  | 문의 상세        | 문의 내용 및 첨부 검토        | 예        | MANAGER 이상  | 문의 상세, 첨부 상태                       | 상태 변경, 답변 등록     | MVP      |
| `/internal/admin`                      | 관리자 홈        | 관리자 기능 진입              | 예        | ADMIN         | 운영 요약 정보                             | 하위 메뉴 이동           | 추천     |
| `/internal/admin/external-users`         | 공개 사용자 목록 | 공개 사용자 조회              | 예        | ADMIN         | 공개 사용자 목록                           | 상세 이동                | 추천     |
| `/internal/admin/external-users/:userId` | 공개 사용자 상세 | 공개 사용자 관리              | 예        | ADMIN         | 공개 사용자 상세                           | 활성/비활성, 초기화 요청 | 추천     |
| `/internal/admin/external-resources`     | 공개 자료 관리   | 공개 자료 상태 관리           | 예        | ADMIN         | 자료 목록                                  | publish/archive/delete   | 추천     |
| `/internal/admin/file-security-logs`      | 파일 보안 이벤트 로그 | 파일 보안 검사 및 차단 결과 시각화 | 예        | ADMIN         | 파일 상태 로그, 차단 사유                  | 필터링, 상세 조회        | 추천     |
| `/internal/admin/audit-logs`           | 감사 로그        | 운영 이력 조회                | 예        | ADMIN         | 감사 로그 목록                             | 조회                     | 후순위   |
| `/internal/403`                        | 접근 거부 페이지 | 내부 권한 부족 안내           | 아니오    | 없음          | 오류 메시지                                | 대시보드 이동            | MVP      |
| `/internal/404`                        | 페이지 없음      | 내부 잘못된 경로 처리         | 아니오    | 없음          | 오류 메시지                                | 대시보드 이동            | MVP      |
| `/internal/500`                        | 서버 오류 페이지 | 내부 서버 오류 안내           | 아니오    | 없음          | 오류 메시지                                | 대시보드 이동 / 재시도   | 추천     |
| `/internal/error`                      | 공통 에러 페이지 | 내부 fallback UI              | 아니오    | 없음          | 오류 메시지                                | 대시보드 이동            | 추천     |

---

## 5.4 내부 그룹웨어 최소 구현 페이지 (Phase 1~2)

초기 분석 페이즈 진입을 위한 최소 구현 범위는 아래 페이지로 한정한다.

- `/internal/login`
- `/internal/dashboard`
- `/internal/notices`
- `/internal/approvals`
- `/internal/approvals/new`
- `/internal/approvals/:approvalId`
- `/internal/applicants`
- `/internal/applicants/:applicationId`
- `/internal/support-tickets`
- `/internal/support-tickets/:ticketId`
- `/internal/403`
- `/internal/404`

그 외 내부 상세 화면과 관리자 운영 화면은 Phase 3 이후에 확장한다.

---

## 6. 페이지별 권한 정책 요약

| 기능 영역                      | PUBLIC_USER       | EMPLOYEE       | MANAGER | ADMIN |
| ------------------------------ | ----------------- | -------------- | ------- | ----- |
| 공개 뉴스 / 공지 / 자료실 조회 | 가능              | -              | -       | -     |
| 공개 문의 등록 / 지원서 제출   | 가능(로그인 필요) | -              | -       | -     |
| 마이페이지 / 내 지원 내역      | 가능              | -              | -       | -     |
| 내부 공지 / 사원 디렉토리      | -                 | 가능           | 가능    | 가능  |
| 전자결재                       | -                 | 가능           | 가능    | 가능  |
| 지원자 검토 / 고객 문의 대응   | -                 | 제한 또는 불가 | 가능    | 가능  |
| 공개 사용자 관리               | -                 | 불가           | 불가    | 가능  |
| 파일 보안 이벤트 로그 확인      | -                 | 불가           | 불가    | 가능  |
| 감사 로그 / 운영 관리          | -                 | 불가           | 제한적  | 가능  |

---

## 7. 페이지와 API 연결 원칙

### 7.1 공개 웹

공개 웹은 `external-api`만 호출한다.

예:

- `/login` → `POST /api/external/auth/login`
- `/news` → `GET /api/external/news`
- `/support/new` → `POST /api/external/support-tickets`
- `/careers/:careerId/apply` → `POST /api/external/careers/{careerId}/applications`
- `/mypage/applications` → `GET /api/external/careers/applications/me`

### 7.2 내부 그룹웨어

내부 그룹웨어는 `internal-api`만 직접 호출한다.

예:

- `/internal/login` → `POST /api/internal/auth/login`
- `/internal/approvals` → `GET /api/internal/approvals`
- `/internal/applicants/:applicationId` → `GET /api/internal/applicants/{applicationId}`
- `/internal/admin/external-resources` → `GET /api/internal/admin/external-resources`
- `/internal/admin/file-security-logs` → `GET /api/internal/admin/file-security-logs`

### 7.3 공개 데이터 관리

내부 그룹웨어 화면에서 공개 데이터를 다룰 때도, 프론트엔드는 `internal-api`만 호출한다.
`internal-api`가 내부적으로 `external-api`의 내부 전용 인터페이스를 호출한다.

예:

- `/internal/admin/external-users/:userId`
  프론트엔드 → `internal-api`
  내부 서비스 → `external-api (External Admin Internal API)`

즉, 내부 프론트가 `external-api`를 직접 호출하지 않는다.

---

## 8. 공통 컴포넌트 기획

## 8.1 공개 웹 공통 컴포넌트

- `AuthForm`
- `NewsCard`
- `NoticeList`
- `ResourceTable`
- `SupportTicketForm`
- `CareerCard`
- `ApplicationForm`
- `FileStatusBadge`
- `Pagination`
- `ErrorFallback`
- `AccessDeniedMessage`

## 8.2 내부 그룹웨어 공통 컴포넌트

- `Sidebar`
- `Topbar`
- `DataTable`
- `SearchFilterBar`
- `ApprovalStatusBadge`
- `ApplicantStatusBadge`
- `SupportTicketStatusBadge`
- `FileSecurityStatusBadge`
- `AuditLogTable`
- `ConfirmModal`
- `ErrorFallback`

---

## 9. 먼저 확정해야 할 화면별 세부 기획 항목

페이지 구현 전에 각 페이지마다 아래 항목을 먼저 정리한다.

1. 페이지 목적
2. 진입 권한
3. 필요한 API
4. 필요한 데이터 필드
5. 목록/상세/생성/수정 여부
6. 첨부파일 존재 여부
7. 파일 상태 확인 필요 여부
8. CSRF 필요한 액션 여부
9. 실패 시 사용자 메시지
10. MVP 포함 여부

---

## 10. 개발 착수 순서

### 10.1

#### 1단계

- 공개 웹 / 내부 그룹웨어 라우트 구조 확정
- 레이아웃 구조 확정
- 페이지 우선순위 확정
- 공통 에러 페이지 구조 확정

### 10.2

#### 2단계

- MVP 페이지별 화면 명세 작성
- 페이지별 필요한 API 매핑
- 공통 컴포넌트 목록 정리
- 관리자 파일 보안 이벤트 로그 화면 설계

### 10.3

#### 3단계

- 프론트엔드 페이지 골격 생성
- API 클라이언트 연결
- 백엔드 엔드포인트 구현 시작

---

## 11. MVP 기준 확정 결론

아래 항목은 추가 논의 없이 MVP 기준으로 확정한다.

1. **메인 페이지 로그인 링크**
   - 우측 상단 헤더(GNB)에 고정 배치한다.

2. **공개 자료실 상세 페이지**
   - 제외한다.
   - 자료 목록에서 클릭 시 owner API 게이트를 거쳐 다운로드하는 구조로 간다.

3. **고객센터 구조**
   - 문의 등록 폼 중심으로 간다.
   - FAQ는 하드코딩된 간단한 아코디언 컴포넌트 수준으로 제한한다.

4. **지원서 첨부파일 수**
   - 1개로 제한한다.
   - 필요 시 단일 압축파일 업로드를 허용한다.

5. **내부 그룹웨어 대시보드 통계**
   - 단순 카운트 카드만 제공한다.
   - 예: 오늘 가입자 수, 결재 대기 건수, 파일 차단 건수

6. **관리자 페이지 구조**
   - 단일 페이지가 아니라 메뉴형으로 분리한다.

---

## 12. 요약

이 문서의 핵심은 다음과 같다.

1. 지금 단계에서는 API 세분화보다 **페이지 구조 확정이 우선**이다.
2. 공개 웹과 내부 그룹웨어의 화면 구조를 먼저 고정해야 한다.
3. 각 페이지는 목적, 권한, 데이터, 액션 기준으로 정의한다.
4. 프론트엔드는 공개/내부 API를 직접 섞어 호출하지 않는다.
5. 내부에서 공개 데이터를 다루는 경우에도 반드시 `internal-api`를 경유한다.
6. 파일 보안 상태/차단 흐름은 관리자 화면에서 시각적으로 확인 가능해야 한다.
7. 공통 에러 페이지를 통해 시스템 구조 노출을 줄이고 안전한 fallback UI를 제공한다.
8. MVP 범위는 이미 확정된 결론을 기준으로 빠르게 구현한다.

---

## 13. 변경 이력

- 2026-04-20: 파일 보안 이벤트 로그 경로/용어(`file-security-logs`)로 정리
- 2026-04-20: 공개 웹 상세 명세 참조 원칙(PAGE_SPECS_EXTERNAL 연계) 추가
- 2026-04-20: 중복 축소를 위해 섹션 4.4 MVP 목록을 섹션 4.3 표 기준 참조 방식으로 변경
