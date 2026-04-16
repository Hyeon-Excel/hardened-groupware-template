# PAGE_SPECS_EXTERNAL.md

# hardened-groupware-template 공개 웹 페이지 상세 명세

## 1. 문서 목적

본 문서는 공개 웹 서비스(External Web)의 각 페이지에 대해 아래 항목을 구체화한다.

- 페이지 목적
- 진입 조건
- 주요 UI 구성
- 필요 데이터
- 사용자 액션
- 연결 API
- 예외 / 에러 처리
- MVP 포함 여부

이 문서는 프론트엔드 구현과 백엔드 API 우선순위 결정을 동시에 지원한다.

---

## 2. 공개 웹 공통 정책

### 2.1 공통 레이아웃

모든 공개 웹 페이지는 아래 공통 레이아웃을 사용한다.

- Header
- Global Navigation
- Main Content
- Footer
- Global Toast / Alert
- Error Fallback 처리

### 2.2 공통 헤더 메뉴

- 홈
- 뉴스
- 공지사항
- 자료실
- 고객센터
- 채용
- 로그인 / 회원가입
- 마이페이지 (로그인 시)

### 2.3 인증 정책

- 공개 웹 로그인은 일반 사용자 계정 기준이다.
- 로그인 후 접근 가능한 페이지는 세션/쿠키 기반 인증을 사용한다.
- 상태 변경 요청은 CSRF 토큰 검증을 전제로 한다.

### 2.4 파일 처리 정책

- 공개 웹에서 업로드되는 파일은 즉시 사용되지 않는다.
- 업로드 후 검역 상태를 가진다.
- 파일 상태는 필요 시 상태 조회 API로 확인한다.

### 2.5 MVP 범위

본 문서에서는 먼저 아래 페이지를 MVP 대상으로 정의한다.

- `/`
- `/login`
- `/signup`
- `/news`
- `/news/:newsId`
- `/notices`
- `/resources`
- `/support/new`
- `/support/me`
- `/careers`
- `/careers/:careerId`
- `/careers/:careerId/apply`
- `/mypage`
- `/mypage/applications`
- `/403`
- `/404`

---

## 3. 공개 웹 페이지 목록 요약

| 경로                       | 페이지명             | 인증 필요 |    MVP | 비고                           |
| -------------------------- | -------------------- | --------: | -----: | ------------------------------ |
| `/`                        | 메인 페이지          |    아니오 |     예 | 홈 랜딩                        |
| `/login`                   | 로그인               |    아니오 |     예 | 세션 로그인                    |
| `/signup`                  | 회원가입             |    아니오 |     예 | 일반 사용자 전용               |
| `/password-reset/request`  | 비밀번호 재설정 요청 |    아니오 |     예 | 후순위 구현 가능               |
| `/password-reset/confirm`  | 비밀번호 재설정 확인 |    아니오 |     예 | 후순위 구현 가능               |
| `/news`                    | 뉴스 목록            |    아니오 |     예 | 목록형                         |
| `/news/:newsId`            | 뉴스 상세            |    아니오 |     예 | 상세형                         |
| `/notices`                 | 공지사항 목록        |    아니오 |     예 | 목록형                         |
| `/notices/:noticeId`       | 공지 상세            |    아니오 |     예 | 상세형                         |
| `/resources`               | 자료실 목록          |    아니오 |     예 | 상세 페이지 없이 바로 다운로드 |
| `/support`                 | 고객센터 안내        |    아니오 | 아니오 | FAQ 간단 표시                  |
| `/support/new`             | 문의 등록            |        예 |     예 | 첨부 가능                      |
| `/support/me`              | 내 문의 목록         |        예 |     예 | 상태 표시                      |
| `/support/:ticketId`       | 문의 상세            |        예 | 아니오 | 2차 구현                       |
| `/careers`                 | 채용 공고 목록       |    아니오 |     예 | 목록형                         |
| `/careers/:careerId`       | 채용 공고 상세       |    아니오 |     예 | 상세형                         |
| `/careers/:careerId/apply` | 지원서 제출          |        예 |     예 | 첨부 1개 제한                  |
| `/mypage`                  | 마이페이지 홈        |        예 |     예 | 요약형                         |
| `/mypage/profile`          | 내 정보 관리         |        예 | 아니오 | 2차 구현                       |
| `/mypage/applications`     | 내 지원 내역         |        예 |     예 | 목록형                         |
| `/mypage/download-history` | 다운로드 이력        |        예 | 아니오 | 후순위                         |
| `/403`                     | 접근 거부            |    아니오 |     예 | 공통 에러 페이지               |
| `/404`                     | 페이지 없음          |    아니오 |     예 | 공통 에러 페이지               |
| `/500`                     | 서버 오류            |    아니오 | 아니오 | 2차 구현                       |
| `/error`                   | 공통 에러            |    아니오 | 아니오 | 2차 구현                       |

---

## 4. 페이지별 상세 명세

## 4.1 `/` 메인 페이지

### 목적

사용자가 공개 웹 서비스의 전체 기능으로 진입하는 첫 화면이다.

### 진입 조건

- 비로그인/로그인 모두 접근 가능

### 주요 UI 구성

- Hero 섹션
- 최근 뉴스 3건
- 주요 공지 3건
- 채용 배너 또는 최신 채용 2~3건
- 자료실 바로가기
- 로그인/회원가입 CTA

### 주요 데이터

- 대표 뉴스 목록
- 대표 공지 목록
- 최신 채용 목록

### 주요 액션

- 뉴스 상세 이동
- 공지 목록 이동
- 채용 목록 이동
- 로그인 이동
- 회원가입 이동

### 연결 API

- `GET /api/external/news?page=1&size=3`
- `GET /api/external/notices?page=1&size=3`
- `GET /api/external/careers?page=1&size=3`

### 에러 처리

- 섹션별 부분 로딩 실패 시 전체 페이지를 막지 않고 해당 카드 영역만 fallback 처리

---

## 4.2 `/login` 로그인 페이지

### 목적

일반 사용자 세션 로그인 처리

### 진입 조건

- 비로그인 사용자만 의미 있음
- 로그인 사용자는 `/mypage` 리다이렉트 가능

### 주요 UI 구성

- 로그인 폼
- 아이디 입력
- 비밀번호 입력
- 로그인 버튼
- 회원가입 링크
- 비밀번호 재설정 링크

### 주요 데이터

- 로그인 입력값
- CSRF 토큰

### 주요 액션

- 로그인 요청
- 회원가입 이동
- 비밀번호 재설정 이동

### 연결 API

- `GET /api/external/csrf`
- `POST /api/external/auth/login`

### 검증 규칙

- 필수값 검증
- 로그인 실패 시 일반화된 오류 메시지 표시

### 에러 처리

- `401`: "아이디 또는 비밀번호가 올바르지 않습니다."
- `429`: "잠시 후 다시 시도해주세요."

---

## 4.3 `/signup` 회원가입 페이지

### 목적

일반 사용자 계정 생성

### 진입 조건

- 비로그인 사용자

### 주요 UI 구성

- 회원가입 폼
- 아이디
- 이메일
- 이름
- 비밀번호
- 비밀번호 확인
- 회원가입 버튼

### 주요 데이터

- 계정 입력값
- CSRF 토큰

### 주요 액션

- 회원가입 요청
- 로그인 페이지 이동

### 연결 API

- `GET /api/external/csrf`
- `POST /api/external/auth/signup`

### 검증 규칙

- 필수값 검증
- 이메일 형식 검증
- 비밀번호 확인 일치 검증

### 에러 처리

- `409`: 중복 계정/이메일 안내
- `400`: 입력 검증 실패 안내

---

## 4.4 `/news` 뉴스 목록 페이지

### 목적

공개 뉴스 목록을 제공

### 진입 조건

- 누구나 접근 가능

### 주요 UI 구성

- 검색 입력
- 뉴스 카드 리스트
- 페이지네이션

### 주요 데이터

- 뉴스 목록
- 페이지 정보
- 검색어

### 주요 액션

- 뉴스 상세 이동
- 페이지 이동
- 검색

### 연결 API

- `GET /api/external/news?page=&size=&keyword=&sort=`

### 에러 처리

- 목록 로드 실패 시 목록 영역 fallback + 재시도 버튼

---

## 4.5 `/news/:newsId` 뉴스 상세 페이지

### 목적

특정 뉴스 상세 내용 제공

### 진입 조건

- 누구나 접근 가능

### 주요 UI 구성

- 제목
- 작성일
- 본문
- 목록으로 돌아가기 버튼

### 주요 데이터

- 뉴스 상세

### 주요 액션

- 목록 복귀

### 연결 API

- `GET /api/external/news/{newsId}`

### 에러 처리

- `404`: `/404` 또는 뉴스 없음 메시지

---

## 4.6 `/notices` 공지사항 목록 페이지

### 목적

공개 공지 목록 제공

### 진입 조건

- 누구나 접근 가능

### 주요 UI 구성

- 공지 리스트
- 페이지네이션

### 주요 데이터

- 공지 목록

### 주요 액션

- 공지 상세 이동

### 연결 API

- `GET /api/external/notices`

---

## 4.7 `/resources` 자료실 목록 페이지

### 목적

공개 배포 가능한 자료를 목록으로 제공

### 진입 조건

- 누구나 접근 가능

### 주요 UI 구성

- 자료 테이블 또는 카드 목록
- 제목
- 설명 요약
- 다운로드 버튼

### 주요 데이터

- 자료 목록
- 파일명/설명/생성일

### 주요 액션

- 다운로드

### 연결 API

- `GET /api/external/resources`
- `GET /api/external/resources/{resourceId}/download`

### MVP 결정

- 자료 상세 페이지는 두지 않는다.
- 목록에서 직접 다운로드한다.

### 에러 처리

- 다운로드 실패 시 토스트 표시
- 검증되지 않은 파일은 다운로드 대상이 아니어야 함

---

## 4.8 `/support/new` 문의 등록 페이지

상세 명세: [pages/external/SUPPORT_NEW.md](pages/external/SUPPORT_NEW.md)

요약: 로그인한 사용자가 고객 문의를 등록하는 페이지. 첨부파일 1개 허용, 검역 접수 흐름 포함.

---

## 4.9 `/support/me` 내 문의 목록 페이지

상세 명세: [pages/external/SUPPORT_ME.md](pages/external/SUPPORT_ME.md)

요약: 로그인한 사용자가 본인의 문의 이력과 상태를 조회하는 페이지. 상태 배지(`RECEIVED`, `REVIEWING`, `ANSWERED`, `CLOSED`) 표시.

---

## 4.10 `/careers` 채용 공고 목록 페이지

### 목적

채용 공고 목록 제공

### 진입 조건

- 누구나 접근 가능

### 주요 UI 구성

- 채용 카드 리스트
- 제목
- 부서/직무
- 상태
- 상세 이동

### 주요 데이터

- 채용 공고 목록

### 주요 액션

- 상세 이동

### 연결 API

- `GET /api/external/careers`

---

## 4.11 `/careers/:careerId` 채용 공고 상세 페이지

### 목적

특정 채용 공고 상세 조회

### 진입 조건

- 누구나 접근 가능

### 주요 UI 구성

- 공고 제목
- 설명
- 요구사항
- 지원 버튼

### 주요 데이터

- 공고 상세 정보

### 주요 액션

- 지원 페이지 이동

### 연결 API

- `GET /api/external/careers/{careerId}`

---

## 4.12 `/careers/:careerId/apply` 지원서 제출 페이지

상세 명세: [pages/external/CAREER_APPLY.md](pages/external/CAREER_APPLY.md)

요약: 로그인한 사용자가 채용 지원서를 제출하는 페이지. 첨부파일 1개 제한, 검역 접수 흐름 포함, 제출 후 마이페이지 이동.

---

## 4.13 `/mypage` 마이페이지 홈

### 목적

로그인 사용자의 개인 기능 허브

### 진입 조건

- 로그인 필요

### 주요 UI 구성

- 사용자 기본 정보 요약
- 최근 지원 건수
- 최근 문의 건수
- 하위 메뉴 이동 카드

### 주요 데이터

- 사용자 세션 정보
- 요약 정보

### 주요 액션

- 내 지원 내역 이동
- 내 정보 관리 이동

### 연결 API

- `GET /api/external/me`

---

## 4.14 `/mypage/applications` 내 지원 내역 페이지

상세 명세: [pages/external/MYPAGE_APPLICATIONS.md](pages/external/MYPAGE_APPLICATIONS.md)

요약: 로그인한 사용자가 본인의 지원서 제출 이력과 첨부파일 검역 상태를 조회하는 페이지.

---

## 4.15 공통 에러 페이지

## `/403`

### 목적

권한 부족 또는 접근 거부 시 안전한 안내

### 주요 UI 구성

- 권한 없음 메시지
- 홈 이동 버튼
- 이전 페이지 버튼

---

## `/404`

### 목적

없는 페이지 접근 시 처리

### 주요 UI 구성

- 페이지 없음 메시지
- 홈 이동 버튼

---

## `/500`

### 목적

서버 오류 발생 시 안전한 안내

### 주요 UI 구성

- 일시적 오류 메시지
- 홈 이동
- 재시도 버튼

---

## `/error`

### 목적

예외 상황 공통 fallback UI

### 주요 UI 구성

- 일반 오류 메시지
- 홈 이동

---

## 5. 공개 웹 공통 상태/메시지 규칙

### 성공 메시지 예시

- 로그인되었습니다.
- 문의가 접수되었습니다.
- 지원서가 접수되었습니다.

### 실패 메시지 예시

- 입력값을 다시 확인해주세요.
- 로그인 후 이용해주세요.
- 파일 검역 중입니다. 잠시 후 상태를 확인해주세요.
- 요청이 너무 많습니다. 잠시 후 다시 시도해주세요.

---

## 6. 프론트엔드 구현 우선순위

### 6.1 1차 골격 생성

- `MainLayout`
- `AuthLayout`
- `ErrorLayout`
- 라우터 구조 생성

### 6.2 MVP 페이지 우선 생성 순서

1. `/`
2. `/login`
3. `/signup`
4. `/news`
5. `/news/:newsId`
6. `/resources`
7. `/careers`
8. `/careers/:careerId`
9. `/careers/:careerId/apply`
10. `/support/new`
11. `/support/me`
12. `/mypage`
13. `/mypage/applications`
14. `/403`
15. `/404`

---

## 7. 세부 화면 명세 현황

### 작성 완료

- `/support/new` → [pages/external/SUPPORT_NEW.md](pages/external/SUPPORT_NEW.md)
- `/support/me` → [pages/external/SUPPORT_ME.md](pages/external/SUPPORT_ME.md)
- `/careers/:careerId/apply` → [pages/external/CAREER_APPLY.md](pages/external/CAREER_APPLY.md)
- `/mypage/applications` → [pages/external/MYPAGE_APPLICATIONS.md](pages/external/MYPAGE_APPLICATIONS.md)

### 추후 작성 대상

아래 페이지는 입력/인증 로직이 복잡하여 상세 명세 추가 작성을 권장한다.

- `/login`
- `/signup`

작성 시 공통 포맷은 [pages/external/PAGE_SPEC_TEMPLATE.md](pages/external/PAGE_SPEC_TEMPLATE.md)를 사용한다.

---

## 8. 요약

1. 공개 웹은 MVP 기준으로 필요한 화면만 먼저 구현한다.
2. 자료실 상세 페이지는 제외하고 목록에서 바로 다운로드한다.
3. 고객센터는 문의 등록 중심으로 간다.
4. 지원서 첨부는 1개로 제한한다.
5. 에러 페이지를 명시적으로 두어 안전한 fallback UI를 제공한다.
6. 파일 상태가 필요한 화면은 상태 조회 API를 전제로 설계한다.
