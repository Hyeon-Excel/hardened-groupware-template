# ARCHITECTURE.md

# hardened-groupware-template 아키텍처 문서

## 1. 문서 목적

본 문서는 `hardened-groupware-template`의 시스템 구조, 서비스 경계, 데이터 소유권, 파일 처리 흐름, 저장소 계층, 초기 개발 단위를 정의한다.  
이 문서는 프로젝트 기획안과 로드맵을 실제 개발 구조로 연결하는 기준 문서이며, 팀원과 코딩 에이전트가 동일한 구조를 전제로 작업할 수 있도록 한다.

본 문서는 다음 질문에 답한다.

- 시스템은 어떤 계층으로 나뉘는가
- 공개 서비스와 내부 그룹웨어는 어떻게 분리되는가
- 어떤 데이터가 어디에 저장되는가
- 파일은 어떤 저장소 흐름을 따르는가
- 서비스 간 호출은 어떤 방식으로 수행되는가
- 세션은 어떤 전략으로 관리되는가
- 어떤 폴더 구조로 개발을 시작해야 하는가
- 각 앱과 모듈은 무엇을 담당하는가

---

## 2. 아키텍처 개요

본 시스템은 다음 세 구역으로 구성된다.

1. **DMZ / External Ingress Zone**
2. **Application / WAS Zone**
3. **Data Zone**

또한 서비스는 기능 기준으로 다음 네 개의 애플리케이션으로 분리한다.

- `external-web`
- `external-api`
- `internal-web`
- `internal-api`

추가로 파일 검역을 위한 비동기 워커를 별도 프로세스로 둔다.

- `file-worker`

즉, 사용자와 가장 가까운 프론트엔드와 실제 비즈니스 로직을 처리하는 API 서버를 분리하고, 공개 서비스와 내부 그룹웨어도 별도의 서비스 경계로 분리한다. 파일 처리 역시 업로드 수신과 검역/승인 절차를 분리해 설계한다.

---

## 3. 설계 원칙

### 3.1 DMZ는 프록시 역할만 수행한다

DMZ는 외부 사용자의 요청을 최초로 받는 경계 구간이다.  
DMZ는 정적 프론트엔드 자산 서빙과 Reverse Proxy만 수행하며, 실제 비즈니스 로직과 데이터 접근은 WAS 계층에서 처리한다.

### 3.2 External WAS와 Internal WAS를 분리한다

공개 서비스와 내부 그룹웨어는 별도의 API 서버로 운영한다.

- `external-api`: 일반 사용자용 공개 서비스 처리
- `internal-api`: 임직원 및 관리자용 그룹웨어 처리

### 3.3 공개 데이터는 External API가 소유한다

내부 그룹웨어는 공개 서비스 데이터를 직접 DB에서 수정하지 않는다.  
공개 데이터의 변경은 반드시 `external-api`의 내부 전용 관리 인터페이스를 통해 수행한다.

### 3.4 외부 업로드 파일은 신뢰하지 않는다

외부에서 업로드된 파일은 곧바로 공개 다운로드 경로나 내부 검토 경로로 들어가면 안 된다.  
반드시 검역 저장소와 검사 절차를 거친 후 승인된 저장소로 이동해야 한다.

### 3.5 사용자 인증과 서비스 간 인증을 분리한다

- 사용자 인증: 세션 / 쿠키 기반
- 서비스 간 호출: 내부 전용 인증 토큰 또는 서비스 계정

### 3.6 단일 실행과 확장 전략을 구분한다

초기 실습 환경은 단일 실행 기준으로 단순화하되, 향후 확장 전략은 문서로 열어둔다.  
즉, 현재 구현은 과도하게 복잡하게 만들지 않되, 아키텍처 문서에는 확장 가능성을 명시한다.

---

## 4. 논리 계층 구조

## 4.1 DMZ / External Ingress Zone

구성 요소:

- `Nginx (external-proxy)`
- `external-web` 정적 자산

역할:

- 일반 사용자 요청 수신
- React 정적 자산 서빙
- `/api/external/*` 요청을 `external-api`로 전달

DMZ는 다음을 하지 않는다.

- `external_db` 직접 접근
- `internal_db` 접근
- 내부 그룹웨어 기능 실행
- 파일 검역 수행

---

## 4.2 Application / WAS Zone

### 4.2.1 external-api

공개 서비스 비즈니스 로직을 담당한다.

담당 기능:

- 일반 사용자 회원가입
- 일반 사용자 로그인 / 로그아웃
- 아이디 / 비밀번호 찾기
- 뉴스 / 공지 / 고객센터
- 공개 자료실
- 채용 공고 / 지원서 제출
- 마이페이지 / 지원 내역 조회
- 공개 서비스 내부 관리 API
- 파일 업로드 수신 및 검역 저장소 전달

보유 인터페이스:

- **External User API**
- **External Query API**
- **External Admin Internal API**

### 4.2.2 internal-web

내부 그룹웨어 UI를 담당한다.

담당 기능:

- 임직원용 화면
- 관리자용 화면
- 사내 공지, 전자결재, 사원 디렉토리, 문의 대응, 지원자 검토 화면

### 4.2.3 internal-api

내부 그룹웨어 비즈니스 로직을 담당한다.

담당 기능:

- 임직원 로그인 / 세션 관리
- RBAC
- 전자결재
- 사원 디렉토리
- 사내 공지
- 고객 문의 대응
- 지원자 검토
- 관리자 기능
- 공개 서비스 연계 모듈

제약:

- `external_db` 직접 write 금지
- 공개 데이터 수정은 `external-api` 내부 관리 인터페이스 경유

### 4.2.4 file-worker

파일 검역 및 승인 저장소 분기를 담당하는 비동기 보조 프로세스다.

구현 스택(초기 기준):

- Node.js 20
- TypeScript

선정 이유:

- 파일 I/O 중심 작업과 비동기 polling 워크로드에 적합
- `external-api`, `internal-api`(Java)와 언어 경계를 분리해 보조 프로세스 책임을 명확히 구분

담당 기능:

- `quarantine_storage`의 신규 파일 검사
- 확장자 / MIME 타입 / 매직바이트 검사
- 파일 크기 및 정책 검사
- 악성 여부 검사
- 검사 결과 기록
- 승인 파일 이동
- 실패 파일 격리 또는 삭제 처리

논리적 위치:

- **Application / WAS Zone의 보안 보조 프로세스**

이유:

- 파일 검역은 단순 저장소 기능이 아니라 정책 실행과 결과 분기를 포함하는 애플리케이션 로직이기 때문
- `external-api`가 업로드를 수신하고, `file-worker`가 후속 검사를 수행하는 구조가 가장 자연스럽기 때문

동작 방식:

- 초기 구현은 **DB-backed polling**을 기본으로 한다.
- `external-api`는 업로드 완료 후 `file_scan_jobs` 작업 레코드를 생성한다.
- `file-worker`는 일정 주기로 작업 테이블을 polling 하여 신규 파일을 검사한다.
- 검사 결과에 따라 `approved_external_storage` 또는 `internal_review_storage`로 파일을 이동한다.

초기 범위에서는 Message Queue를 도입하지 않는다.

---

## 4.3 Data Zone

구성 요소:

- `external_db`
- `internal_db`
- `quarantine_storage`
- `approved_external_storage`
- `internal_review_storage`

### 4.3.1 external_db

공개 서비스 데이터 저장소

예시 데이터:

- 일반 사용자 계정
- 공지 / 뉴스 메타데이터
- 고객 문의
- 채용 공고
- 지원서 메타데이터
- 공개 자료 메타데이터
- 파일 검역 작업 메타데이터
- 파일 상태 메타데이터

소유자:

- `external-api`

### 4.3.2 internal_db

내부 그룹웨어 데이터 저장소

예시 데이터:

- 임직원 계정
- 관리자 계정
- 사내 공지
- 전자결재
- 내부 업무 데이터
- 관리자 검토 메모
- 감사 로그 메타데이터

소유자:

- `internal-api`

### 4.3.3 quarantine_storage

외부 업로드 원본 파일 저장소

특징:

- 신뢰하지 않는 파일 저장
- 웹 루트 밖 저장
- 직접 열람/실행 금지
- 검역 / 검사 전용 구간

### 4.3.4 approved_external_storage

검역 통과 후 공개 배포 가능한 파일 저장소

예시:

- 브로셔
- 공개 자료실 파일

특징:

- 공개 서비스 다운로드 가능
- 원본이 아닌 승인된 파일만 저장

### 4.3.5 internal_review_storage

검역 통과 후 내부 검토 가능한 파일 저장소

예시:

- 이력서
- 문의 첨부
- 내부 검토용 문서

특징:

- 내부 그룹웨어에서만 접근
- 검증 통과본만 저장
- 외부 원본과 분리

### 4.3.6 Cross-DB 참조 무결성 보강 테이블

`external_db`와 `internal_db`는 물리적으로 분리되어 있으므로 DB 레벨의 cross-DB FK를 사용하지 않는다.
대신 `internal_db`에 외부 엔티티 참조 미러 테이블을 둬서 내부 FK 무결성을 복구한다.

핵심 테이블:

- `external_application_refs`
- `external_support_ticket_refs`

적용 원칙:

1. `internal-api`는 외부 엔티티를 사용하기 전에 `external-api` 내부 API로 존재성/상태를 검증한다.
2. 검증된 식별자를 참조 미러 테이블에 upsert 한다.
3. 내부 업무 테이블은 미러 테이블을 FK로 참조한다.
   - `applicant_notes.application_id -> external_application_refs.application_id`
   - `support_ticket_replies.ticket_id -> external_support_ticket_refs.ticket_id`
4. 재동기화 배치로 참조 정합성을 주기적으로 점검한다.

---

## 5. 파일 처리 흐름

외부 파일은 아래 흐름을 따른다.

1. 외부 사용자가 파일 업로드
2. `external-api`가 파일을 `quarantine_storage`에 저장
3. `external-api`가 `file_scan_jobs` 레코드를 생성
4. `file-worker`가 작업을 polling 하여 파일 검사 수행
5. 검사 실패 시 격리, 삭제 또는 관리자 검토 대기
6. 검사 통과 시 파일 용도에 따라 분기
   - 공개용 → `approved_external_storage`
   - 내부 검토용 → `internal_review_storage`

중요 원칙:

- 외부 원본 파일은 내부 그룹웨어가 직접 열람하지 않는다.
- 공개 배포 파일도 검증 통과 후에만 공개 저장소로 이동한다.
- `file-worker`는 `file_scan_jobs` 큐성 레코드만 직접 처리하며, 공개 서비스 도메인 비즈니스 데이터를 직접 수정하지 않는다.

---

## 6. 인증 및 권한 구조

## 6.1 일반 사용자 인증

- 담당 앱: `external-api`
- 방식: 세션 / 쿠키
- 대상: 공개 웹 서비스 사용자

## 6.2 내부 사용자 인증

- 담당 앱: `internal-api`
- 방식: 세션 / 쿠키
- 대상: 임직원, 관리자

## 6.3 역할 예시

공개 서비스:

- `PUBLIC_USER`

내부 그룹웨어:

- `EMPLOYEE`
- `MANAGER`
- `ADMIN`

## 6.4 서비스 간 인증

- 대상: `internal-api -> external-api`
- 방식: 내부 서비스 전용 인증 토큰 또는 서비스 계정
- 목적: 공개 데이터 조회/관리

---

## 7. 세션 저장 전략

## 7.1 현재 범위

현재 프로젝트 범위에서는 **단일 WAS 실행 기준의 세션 저장 전략**을 사용한다.

즉:

- `external-api`는 공개 사용자 세션을 자체적으로 관리
- `internal-api`는 내부 사용자 세션을 자체적으로 관리
- 각 서비스의 세션은 분리된다

이 전략은 다음 전제를 가진다.

- 초기 실습 환경은 고가용성 클러스터를 목표로 하지 않음
- 세션 공유보다는 서비스 경계와 보안 검증에 초점을 맞춤

## 7.2 확장 전략

향후 다중 인스턴스, 수평 확장, 세션 공유가 필요할 경우 아래 중 하나를 도입할 수 있다.

- Redis 기반 세션 저장소
- JDBC 기반 세션 저장소

초기 구현에서는 Redis를 필수 구성 요소로 포함하지 않는다.  
단, `ARCHITECTURE.md`와 `ROADMAP.md` 수준에서는 **세션 외부화가 가능한 구조로 확장 가능함**을 전제로 한다.

## 7.3 세션 보안 정책 기준

세션/쿠키 기반 인증은 아래 정책을 기본값으로 한다.
세부 운영 기준은 `docs/security/SECURITY_BASELINE.md`를 따른다.

- Idle timeout:
  - 공개 사용자 세션: 30분
  - 내부 사용자 세션: 15분
- Absolute timeout:
  - 공개 사용자 세션: 12시간
  - 내부 사용자 세션: 8시간
- 로그인 성공 시 세션 ID 재발급(Session Fixation 방어)
- 로그아웃 시 서버 세션 무효화 + 쿠키 즉시 만료
- 쿠키 속성:
  - `HttpOnly`
  - `Secure` (HTTPS 환경)
  - `SameSite=Lax` (내부 관리자 경로는 필요 시 `Strict` 검토)
- 동시 세션 제한:
  - 내부 관리자(`ADMIN`) 계정은 기본 1세션 제한 권장

---

## 8. 서비스 간 통신 원칙

본 시스템에서 교차 구간 호출은 **`internal-api -> external-api` 방향으로만 제한적으로 허용**한다.

## 8.1 통신 방식

서비스 간 통신은 **REST 기반 HTTP/JSON 통신**을 기본으로 한다.

초기 구현 기준:

- 내부망 또는 내부 Docker 네트워크를 통한 호출
- `external-api`의 내부 전용 경로만 호출
- OpenAPI-first 기준에 따라 계약 정의

즉, 내부 서비스는 `external-api`를 하나의 외부 서비스처럼 호출하되, 그 대상은 **내부 전용 인터페이스**로 제한한다.

## 8.2 호출 대상

허용되는 호출:

- `internal-api -> External Query API`
- `internal-api -> External Admin Internal API`

## 8.3 인증 방식

호출 인증은 **사용자 세션이 아니라 서비스 간 인증 토큰 또는 서비스 계정**으로 수행한다.

즉:

- 브라우저 세션으로 서비스 간 호출하지 않음
- 사용자 JWT를 서비스 간 인증에 재사용하지 않음
- 내부 전용 토큰 또는 고정 서비스 계정을 사용

## 8.4 HTTP 클라이언트 전략

초기 구현에서는 Java의 표준적인 REST 클라이언트 계층을 사용한다.

권장 구현 방향:

- `WebClient` 또는 동등한 비동기/동기 REST 클라이언트 사용
- 호출 대상 base URL은 설정 파일로 분리
- 타임아웃, 재시도, 예외 처리 규칙은 공통 모듈에서 관리

## 8.5 서비스 토큰 회전 및 비밀 관리

- `X-Service-Token`은 고정 장기 토큰을 지양하고 주기적 회전을 기본으로 한다.
- 세부 운영 기준은 `docs/security/SECURITY_BASELINE.md`를 따른다.
- 권장 회전 주기:
  - 운영: 30일
  - 스테이징/실습: 7~14일
- 토큰 저장 위치는 환경변수/시크릿 매니저로 제한하고 소스 저장소에 커밋하지 않는다.
- 토큰 회전 시 구/신 토큰 단기 공존 기간(grace period)을 두고 단계적으로 전환한다.

## 8.6 장애 대응 및 통신 실패 전략

- `internal-api -> external-api` 호출은 짧은 타임아웃을 기본으로 한다.
  - connect timeout 1~3초
  - read timeout 3~5초
- 멱등성 있는 조회성 요청은 제한적 재시도를 허용한다.
- 임계치 초과 시 circuit breaker를 열어 연쇄 장애를 방지한다.
- 호출 실패 시 내부 관리자 화면에는 안전한 일반 오류 메시지를 반환하고, 상세 사유는 서버 로그/감사 로그에만 기록한다.

## 8.7 금지되는 호출

- `internal-api -> external_db` 직접 write
- `external-api -> internal_db` 접근
- 외부 사용자 -> `internal-api` 직접 접근
- 검역 전 파일 -> `internal_review_storage` 직접 이동

---

## 9. 저장소 구조와 아키텍처 대응

프로젝트 저장소는 아래 모노레포 구조를 기준으로 한다.

```text
hardened-groupware-template/
├─ apps/
│  ├─ external-web/
│  │  ├─ src/
│  │  │  ├─ app/
│  │  │  ├─ pages/
│  │  │  │  ├─ auth/
│  │  │  │  ├─ news/
│  │  │  │  ├─ support/
│  │  │  │  ├─ resources/
│  │  │  │  ├─ careers/
│  │  │  │  └─ mypage/
│  │  │  ├─ components/
│  │  │  ├─ layouts/
│  │  │  ├─ api/
│  │  │  ├─ hooks/
│  │  │  ├─ types/
│  │  │  └─ utils/
│  │  ├─ external/
│  │  ├─ package.json
│  │  └─ vite.config.ts
│  │
│  ├─ external-api/
│  │  ├─ src/main/java/com/hardenedgroupware/externalapi/
│  │  │  ├─ config/
│  │  │  ├─ auth/
│  │  │  ├─ common/
│  │  │  ├─ news/
│  │  │  ├─ support/
│  │  │  ├─ resources/
│  │  │  ├─ careers/
│  │  │  ├─ mypage/
│  │  │  ├─ files/
│  │  │  ├─ query/
│  │  │  └─ admininternal/
│  │  ├─ src/main/resources/
│  │  │  ├─ application.yml
│  │  │  └─ db/
│  │  └─ build.gradle
│  │
│  ├─ internal-web/
│  │  ├─ src/
│  │  │  ├─ app/
│  │  │  ├─ pages/
│  │  │  │  ├─ auth/
│  │  │  │  ├─ notices/
│  │  │  │  ├─ employees/
│  │  │  │  ├─ approvals/
│  │  │  │  ├─ applicants/
│  │  │  │  ├─ support-admin/
│  │  │  │  └─ admin/
│  │  │  ├─ components/
│  │  │  ├─ layouts/
│  │  │  ├─ api/
│  │  │  ├─ hooks/
│  │  │  ├─ types/
│  │  │  └─ utils/
│  │  ├─ external/
│  │  ├─ package.json
│  │  └─ vite.config.ts
│  │
│  ├─ internal-api/
│  │  ├─ src/main/java/com/hardenedgroupware/internalapi/
│  │  │  ├─ config/
│  │  │  ├─ auth/
│  │  │  ├─ common/
│  │  │  ├─ notices/
│  │  │  ├─ employees/
│  │  │  ├─ approvals/
│  │  │  ├─ applicants/
│  │  │  ├─ supportadmin/
│  │  │  ├─ admin/
│  │  │  └─ externalbridge/
│  │  ├─ src/main/resources/
│  │  │  ├─ application.yml
│  │  │  └─ db/
│  │  └─ build.gradle
│  │
│  └─ file-worker/
│     ├─ src/
│     │  ├─ scanner/
│     │  ├─ policy/
│     │  ├─ mover/
│     │  ├─ jobs/
│     │  └─ utils/
│     ├─ package.json
│     └─ README.md
│
├─ database/
│  ├─ external/
│  │  ├─ schema/
│  │  └─ seed/
│  └─ internal/
│     ├─ schema/
│     └─ seed/
│
├─ infra/
│  ├─ nginx/
│  │  ├─ external/
│  │  │  └─ default.conf
│  │  └─ internal/
│  │     └─ default.conf
│  ├─ docker/
│  │  ├─ external/
│  │  ├─ internal/
│  │  └─ data/
│  ├─ vmware/
│  │  ├─ network/
│  │  └─ notes/
│  └─ scripts/
│     ├─ setup/
│     ├─ run/
│     └─ migrate/
│
├─ storage/
│  ├─ quarantine/
│  ├─ approved-external/
│  └─ internal-review/
│
├─ docs/
│  ├─ architecture/
│  │  └─ ARCHITECTURE.md
│  ├─ api/
│  ├─ security/
│  ├─ testing/
│  ├─ reports/
│  └─ rules/
│
├─ .github/
│  └─ workflows/
│
├─ docker-compose.yml
├─ README.md
├─ SECURITY.md
└─ .env
```
