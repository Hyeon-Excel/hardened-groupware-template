# INTERNAL_ACCESS_CONTROL_POLICY.md

> Status: final
> Scope: internal-web, internal-api, internal_db
> Related: `docs/architecture/PAGE_STRUCTURE.md`, `docs/security/SECURITY_BASELINE.md`, `docs/api/API.md`

## 1. 목적

이 문서는 내부 그룹웨어의 계정, 조직, 권한 규칙을 실제 구현 기준으로 고정한다.

적용 목표:

- 부서/직급 기반 권한 분리를 코드와 화면에서 동일하게 적용
- 내부 계정 보안(초기 비밀번호 변경, 주기적 변경) 강제
- 직원 디렉터리/메시지 검색/게시판 권한을 일관된 정책으로 운영

---

## 2. 권한 모델

권한은 아래 3축을 동시에 적용한다.

1. 시스템 직급 권한(`org_role`)
2. 소속 부서(`department_code`)
3. 기능 권한(`permission`)

요청 허용 조건:

```text
ALLOW only if:
  auth ok
  AND account status is ACTIVE or PENDING_PASSWORD_CHANGE
  AND password policy gate passed
  AND org_role/department_scope/permission all matched
else DENY
```

---

## 3. 조직/계정 정의

### 3.1 시스템 직급(`org_role`)

| 코드 | 설명 | 기본 범위 |
| --- | --- | --- |
| `ADMIN` | 시스템 관리자 | 전체 |
| `EXECUTIVE` | 임원진 | 전사 조회, 제한적 승인 |
| `DEPT_HEAD` | 부서장 | 부서 전체 |
| `TEAM_LEAD` | 팀장 | 팀/담당 범위 |
| `TEAM_MEMBER` | 팀원 | 본인/할당 범위 |

### 3.2 부서(`department_code`)

| 코드 | 설명 |
| --- | --- |
| `COMMON` | 공통 부서(일반 업무) |
| `HR` | 인사팀 |
| `MAINTENANCE` | 유지보수팀 |

필요 시 `SECURITY`, `FINANCE` 등 부서를 추가할 수 있다.

### 3.3 계정 상태(`account_status`)

| 상태 | 의미 | 로그인 |
| --- | --- | --- |
| `PENDING_PASSWORD_CHANGE` | 초기 계정, 비밀번호 변경 전 | 제한 허용 |
| `ACTIVE` | 정상 사용 상태 | 허용 |
| `LOCKED` | 로그인 실패 잠금 | 거부 |
| `DISABLED` | 비활성화 | 거부 |

`PENDING_PASSWORD_CHANGE` 상태에서는 비밀번호 변경 화면 외 모든 내부 페이지 접근을 차단한다.

---

## 4. 내부 계정 보안 규칙

### 4.1 초기 로그인 강제 변경

- 초기 계정 생성 시 상태는 `PENDING_PASSWORD_CHANGE`로 시작한다.
- 첫 로그인 성공 직후 `/internal/mypage/password-change`로 강제 리다이렉트한다.
- 비밀번호 변경 완료 전 허용 경로:

| 유형 | 경로 |
| --- | --- |
| 화면 | `/internal/mypage/password-change` |
| API | `/api/internal/me/password` |
| API | `/api/internal/auth/logout` |

### 4.2 90일 주기 변경

- 비밀번호는 90일마다 변경한다.
- 기준 시점은 `password_changed_at`이다.
- 만료 시 로그인은 허용하되 즉시 비밀번호 변경 화면으로 이동시킨다.

### 4.3 비밀번호 복잡도

비밀번호 정책:

- 최소 8자
- 영문자 포함
- 숫자 포함
- 특수문자 포함

검증 정규식(기준):

```regex
^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$
```

### 4.4 서버 측 강제

- 비밀번호 정책 검사는 반드시 서버(`internal-api`)에서 수행한다.
- 프론트엔드 유효성 검사는 UX 보조용으로만 사용한다.

---

## 5. 직원 식별자 및 이메일 규칙

### 5.1 이메일 자동 생성

- 사번(`employee_no`) 기준으로 회사 이메일을 자동 생성한다.
- 형식: `{employee_no}@secuworks.com`

예:

- 사번 `E240015` -> `e240015@secuworks.com` (소문자 정규화)

### 5.2 무결성 규칙

- `employee_no`는 내부에서 유일해야 한다.
- 생성된 이메일도 유일해야 한다.
- 수동 수정은 `ADMIN`만 허용한다.

---

## 6. 직원 디렉터리 및 메시지 검색 규칙

### 6.1 직원 디렉터리

필수 기능:

- 부서별 그룹 목록
- 이름/사번/이메일 검색
- 직원 선택 시 기본 정보 표시(이름, 부서, 직책, 이메일)

권한:

- `TEAM_MEMBER` 이상 조회 가능
- `ADMIN`은 전사 조회 가능

### 6.2 메시지 수신자 검색

- 메시지/쪽지 수신자 검색은 직원 디렉터리 인덱스를 재사용한다.
- 검색 결과에는 `ACTIVE` 계정만 노출한다.
- 결과 항목은 `employeeId`, `name`, `departmentCode`, `departmentName`, `email`을 기본으로 반환한다.
- 참고: 직원 디렉터리 일반 조회는 운영 목적에 따라 `accountStatus` 필터로 `LOCKED`/`DISABLED` 계정을 조회할 수 있다.
  단, 메시지 수신자 검색 컨텍스트에서는 항상 `ACTIVE`로 제한한다.

---

## 7. 내부 메뉴 및 부서 권한 규칙

### 7.1 공통 메뉴(전체 내부 계정)

`ACTIVE` 내부 계정은 아래 메뉴를 기본 접근한다.

- 대시보드
- 게시판(공지사항/자유게시판)
- 직원 디렉터리
- 전자결재

### 7.2 부서 전용 메뉴

| 기능 | 접근 부서 | 비고 |
| --- | --- | --- |
| 지원자 검토 | `HR` | 채용 관련 화면/처리 |
| 고객 문의 대응 | `MAINTENANCE` | 고객 문의 답변/상태 변경 |

`ADMIN`은 부서 제한 없이 모든 메뉴 접근 가능하다.

### 7.3 직급별 접근 수준

| 메뉴/기능 | TEAM_MEMBER | TEAM_LEAD | DEPT_HEAD | EXECUTIVE | ADMIN |
| --- | --- | --- | --- | --- | --- |
| 대시보드 | 개인/기본 카드 | 팀 범위 카드 | 부서 범위 카드 | 전사 요약(읽기) | 전체 운영 카드 |
| 게시판 읽기 | 가능 | 가능 | 가능 | 가능 | 가능 |
| 공지사항 작성/고정 | 불가 | 제한 | 가능 | 가능 | 가능 |
| 자유게시판 작성 | 가능 | 가능 | 가능 | 가능 | 가능 |
| 직원 디렉터리 조회 | 가능 | 가능 | 가능 | 가능 | 가능 |
| 전자결재 기안 | 가능 | 가능 | 가능 | 가능 | 가능 |
| 전자결재 승인 | 할당 건만 | 팀 할당 | 부서 할당 | 전사 중요안(정책 기반) | 전체 |
| 지원자 검토 | 부서 조건 충족 시 가능 | 부서 조건 충족 시 가능 | 부서 조건 충족 시 가능 | 읽기 전용(선택) | 가능 |
| 고객 문의 대응 | 부서 조건 충족 시 가능 | 부서 조건 충족 시 가능 | 부서 조건 충족 시 가능 | 읽기 전용(선택) | 가능 |
| 사용자/권한 관리 | 불가 | 불가 | 불가 | 불가 | 가능 |

---

## 8. 게시판 정책 (공지사항 -> 게시판 확장)

내부 게시판은 2개 타입으로 운영한다.

- `NOTICE`: 운영 공지
- `FREE`: 자유게시판

권한 정책:

| 타입 | 읽기 | 작성 | 수정/삭제 | 비고 |
| --- | --- | --- | --- | --- |
| `NOTICE` | 내부 `ACTIVE` 전원 | `DEPT_HEAD`, `EXECUTIVE`, `ADMIN` | `DEPT_HEAD`, `EXECUTIVE`, `ADMIN` | 상단 고정은 `ADMIN` 전용 |
| `FREE` | 내부 `ACTIVE` 전원 | 내부 `ACTIVE` 전원 | 작성자 본인 또는 `TEAM_LEAD` 이상 | 운영 정책에 따라 신고/숨김 가능 |

---

## 9. 페이지 접근 제어 규칙

### 9.1 기본 규칙

- 내부 모든 라우트는 인증 필수다.
- 권한 부족은 `/internal/403`으로 보낸다.
- 리소스 소유/범위 위반은 404 또는 403 정책을 API 정본(`docs/api/API.md`)에 맞춰 적용한다.

### 9.2 대시보드 차등 노출

대시보드는 동일 경로(`/internal/dashboard`)를 사용하고 카드 구성만 권한별로 다르게 노출한다.

- `TEAM_MEMBER`: 개인 할 일/내 결재/내 처리 건
- `TEAM_LEAD`: 팀 대기 건/팀 SLA
- `DEPT_HEAD`: 부서 KPI/부서 병목
- `EXECUTIVE`: 전사 요약 KPI(읽기 중심)
- `ADMIN`: 보안 이벤트/계정 상태/운영 경고 포함 전체 뷰

---

## 10. 구현 기준 (DB/API)

### 10.1 `internal_employees` 필수 필드

아래 필드를 기준으로 마이그레이션을 수행한다.

- `employee_no` (UNIQUE)
- `email` (UNIQUE, `{employee_no}@secuworks.com`)
- `org_role` (`ADMIN|EXECUTIVE|DEPT_HEAD|TEAM_LEAD|TEAM_MEMBER`)
- `department_code`
- `account_status`
- `must_change_password` (BOOLEAN)
- `password_changed_at` (DATETIME)

### 10.2 내부 API 공통 가드

모든 내부 API에서 아래 순서를 공통 적용한다.

1. 세션 인증 확인
2. 계정 상태 확인 (`ACTIVE` 또는 비밀번호 변경 전용 상태)
3. 비밀번호 변경 강제 게이트 확인
4. 메뉴 권한 확인 (`org_role + department_code + permission`)
5. 객체 범위 확인(본인/팀/부서/전사)

---

## 11. 감사 로그 필수 이벤트

필수 기록 이벤트:

- 초기 비밀번호 변경 완료
- 90일 만료 후 비밀번호 변경 완료
- 권한 없는 메뉴 접근 시도(차단)
- 부서 전용 메뉴 접근 시도(허용/차단)
- 게시판 공지 작성/수정/삭제
- 지원자 검토 상태 변경
- 고객 문의 상태 변경

---

## 12. 테스트 수용 기준

아래 항목이 모두 통과되어야 권한 규칙 구현 완료로 본다.

- 초기 계정 로그인 시 비밀번호 변경 화면 강제 이동
- 비밀번호 변경 전 내부 주요 페이지 접근 차단
- 90일 만료 계정 강제 비밀번호 변경
- HR 계정은 `지원자 검토` 접근 가능, `고객 문의 대응` 접근 불가
- MAINTENANCE 계정은 `고객 문의 대응` 접근 가능, `지원자 검토` 접근 불가
- ADMIN 계정은 모든 내부 메뉴 접근 가능
- 메시지 수신자 검색 결과는 `ACTIVE` 계정만 노출
- 직원 디렉터리 조회는 `accountStatus` 필터에 따라 `LOCKED`/`DISABLED` 계정을 조회할 수 있음
- 동일 권한이라도 객체 범위 위반 시 차단 동작

---

## 13. 변경 이력

- 2026-04-21: 내부 조직/권한 세분화 구현 기준 문서 최초 확정
