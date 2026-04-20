# PAGE_SPECS_EXTERNAL.md

# hardened-groupware-template 공개 웹 페이지 상세 명세 인덱스

## 1. 문서 목적

본 문서는 공개 웹(External Web) 페이지 명세의 **인덱스 허브**다.

이 문서는 다음만 담당한다.

- 공개 웹 라우트별 상세 명세 문서 위치(링크)
- 상세 명세 작성 상태 추적
- 문서 중복 최소화 규칙

페이지별 상세 UI/상태/에러/컴포넌트 설명은 개별 상세 문서에서만 관리한다.

---

## 2. 문서 경계

### 2.1 포함 범위

- 라우트별 상세 문서 링크
- 상세 명세 작성 상태
- 상세 명세 작성 우선순위

### 2.2 제외 범위

- 페이지별 상세 UI 구조(중복 서술 금지)
- 페이지별 상태 메시지 전문
- 페이지별 에러 처리 테이블 전문
- 공통 보안 정책 전문(세션/CSRF/파일 게이트 등)

상기 항목은 아래 정본 문서에서 관리한다.

---

## 3. 정본 참조

- 페이지 구조/권한 경계: [PAGE_STRUCTURE.md](PAGE_STRUCTURE.md)
- API 규칙/응답/상태코드: [API.md](../api/API.md)
- 계약 스펙: [openapi.yaml](../api/openapi.yaml)
- 보안 기준(v0/v1): [SECURITY_BASELINE.md](../security/SECURITY_BASELINE.md)
- 테스트 기준: [TEST_STRATEGY.md](../testing/TEST_STRATEGY.md)
- 프로젝트 단계(v0/v1): [PLANNING.md](PLANNING.md)

---

## 4. 공개 웹 페이지 카탈로그

| 경로 | 상세 명세 | 작성 상태 | 작성 우선순위 | 비고 |
| --- | --- | --- | --- | --- |
| `/` | 준비중 | 미작성 | 1차 | 홈 랜딩 |
| `/login` | 준비중 | 미작성 | 1차 | 세션 로그인 |
| `/signup` | 준비중 | 미작성 | 1차 | 일반 사용자 전용 |
| `/password-reset/request` | 준비중 | 미작성 | 1차 | 비밀번호 재설정 |
| `/password-reset/confirm` | 준비중 | 미작성 | 1차 | 비밀번호 재설정 |
| `/news` | 준비중 | 미작성 | 1차 | 목록형 |
| `/news/:newsId` | 준비중 | 미작성 | 1차 | 상세형 |
| `/notices` | 준비중 | 미작성 | 1차 | 목록형 |
| `/notices/:noticeId` | 준비중 | 미작성 | 1차 | 상세형 |
| `/resources` | 준비중 | 미작성 | 1차 | 목록에서 다운로드 |
| `/support` | 준비중 | 미작성 | 2차 | FAQ 간단 표시 |
| `/support/new` | [SUPPORT_NEW.md](pages/external/SUPPORT_NEW.md) | 작성 완료 | 1차 | 첨부 1개 |
| `/support/me` | [SUPPORT_ME.md](pages/external/SUPPORT_ME.md) | 작성 완료 | 1차 | 상태 배지 |
| `/support/:ticketId` | 준비중 | 미작성 | 2차 | 2차 구현 |
| `/careers` | 준비중 | 미작성 | 1차 | 목록형 |
| `/careers/:careerId` | 준비중 | 미작성 | 1차 | 상세형 |
| `/careers/:careerId/apply` | [CAREER_APPLY.md](pages/external/CAREER_APPLY.md) | 작성 완료 | 1차 | 첨부 1개 |
| `/mypage` | 준비중 | 미작성 | 1차 | 요약형 |
| `/mypage/profile` | 준비중 | 미작성 | 2차 | 2차 구현 |
| `/mypage/applications` | [MYPAGE_APPLICATIONS.md](pages/external/MYPAGE_APPLICATIONS.md) | 작성 완료 | 1차 | 상태 확인 |
| `/mypage/download-history` | 준비중 | 미작성 | 2차 | 후순위 |
| `/403` | 준비중 | 미작성 | 1차 | 공통 에러 페이지 |
| `/404` | 준비중 | 미작성 | 1차 | 공통 에러 페이지 |
| `/500` | 준비중 | 미작성 | 2차 | 2차 구현 |
| `/error` | 준비중 | 미작성 | 2차 | 2차 구현 |

---

## 5. 상세 명세 작성 상태

### 5.1 작성 완료

- [SUPPORT_NEW.md](pages/external/SUPPORT_NEW.md)
- [SUPPORT_ME.md](pages/external/SUPPORT_ME.md)
- [CAREER_APPLY.md](pages/external/CAREER_APPLY.md)
- [MYPAGE_APPLICATIONS.md](pages/external/MYPAGE_APPLICATIONS.md)

### 5.2 템플릿

- [PAGE_SPEC_TEMPLATE.md](pages/external/PAGE_SPEC_TEMPLATE.md)

### 5.3 추후 작성 대상

- `/`, `/login`, `/signup`, `/news`, `/news/:newsId`, `/notices`,
  `/notices/:noticeId`, `/resources`, `/careers`, `/careers/:careerId`, `/mypage`

---

## 6. 구현 우선순위

상세 작성 우선순위는 섹션 4 표의 `작성 우선순위` 열을 정본으로 사용한다.
구현 우선순위(MVP/추천/후순위)는 [PAGE_STRUCTURE.md](PAGE_STRUCTURE.md) 섹션 4.3과 5.3을 따른다.

---

## 7. 중복 최소화 규칙

1. 공통 보안 정책은 페이지 문서마다 재서술하지 않고 정본 링크로 참조한다.
2. API 경로/응답 스키마는 `API.md`와 `openapi.yaml`을 정본으로 보고, 페이지 문서에는 필요한 최소 맥락만 남긴다.
3. 동일한 에러 메시지 표를 여러 페이지에 반복하지 않는다.
4. 페이지 고유 정보(입력 필드, UI 배치, 사용자 흐름)만 각 상세 문서에 남긴다.

---

## 8. 요약

1. 본 문서는 공개 웹 상세 명세의 **인덱스**다.
2. 상세 본문은 개별 페이지 문서에서 관리한다.
3. 공통 정책은 정본 문서 링크로 참조하고, 중복 서술을 줄인다.
