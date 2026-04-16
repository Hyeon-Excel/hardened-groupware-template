# CAREER_APPLY.md

# 공개 웹 상세 페이지 명세

# `/careers/:careerId/apply` 지원서 제출 페이지

## 1. 문서 목적

본 문서는 공개 웹 서비스의 `/careers/:careerId/apply` 페이지에 대한 상세 화면 명세를 정의한다.  
이 페이지는 공개 웹의 핵심 입력 화면이며, 다음 특성을 가진다.

- 로그인 필요
- 텍스트 입력 + 파일 업로드 포함
- 세션/쿠키 기반 인증
- CSRF 보호 필요
- 파일 검역 비동기 처리
- 업로드 후 상태 추적 가능

즉, 본 페이지는 단순 폼이 아니라 **인증, 입력 검증, 파일 검역, 상태 확인, 에러 처리**가 동시에 필요한 복합 페이지다.

---

## 2. 페이지 기본 정보

| 항목           | 내용                                                                                                                                                      |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 경로           | `/careers/:careerId/apply`                                                                                                                                |
| 페이지명       | 지원서 제출 페이지                                                                                                                                        |
| 목적           | 로그인한 일반 사용자가 특정 채용 공고에 지원서를 제출                                                                                                     |
| 인증 필요 여부 | 예                                                                                                                                                        |
| 권한           | `PUBLIC_USER`                                                                                                                                             |
| 우선순위       | MVP                                                                                                                                                       |
| 연결 서비스    | `external-web` → `external-api`                                                                                                                               |
| 주요 API       | `GET /api/external/careers/{careerId}`, `GET /api/external/csrf`, `POST /api/external/careers/{careerId}/applications`, `GET /api/external/files/{fileId}/status` |

---

## 3. 진입 조건 및 접근 제어

## 3.1 진입 조건

사용자는 아래 조건을 만족해야 페이지를 정상 이용할 수 있다.

- 공개 서비스 로그인 상태
- 유효한 채용 공고 ID
- 지원 가능한 상태의 채용 공고

## 3.2 접근 제어 규칙

- 비로그인 사용자는 `/login`으로 리다이렉트한다.
- 존재하지 않는 `careerId`는 `404` 처리한다.
- 마감된 공고는 제출 버튼을 비활성화하거나 지원 불가 메시지를 표시한다.
- 이미 지원한 사용자에 대한 중복 제출 정책은 백엔드 검증 후 프론트에서 메시지로 안내한다.

---

## 4. 페이지 목적과 사용자 시나리오

## 4.1 주요 목적

- 사용자가 특정 채용 공고에 대해 지원서를 제출할 수 있도록 한다.
- 제출 과정에서 필수 입력값을 검증한다.
- 첨부파일을 1개 업로드하고, 검역이 비동기로 진행된다는 점을 안내한다.
- 제출 직후 성공/실패를 명확히 알려준다.
- 제출 후 내 지원 내역 페이지로 이동할 수 있게 한다.

## 4.2 대표 사용자 시나리오

1. 사용자가 채용 공고 상세 페이지에서 “지원하기” 버튼 클릭
2. 지원서 제출 페이지 진입
3. 공고 정보 재확인
4. 이름, 이메일, 전화번호, 자기소개 입력
5. 첨부파일 1개 업로드
6. 제출 버튼 클릭
7. CSRF 토큰 검증 + 입력 검증 + 업로드 접수
8. 서버가 `202 Accepted` 응답 반환
9. 프론트가 “지원서가 접수되었으며 첨부파일은 검역 중일 수 있습니다” 메시지 표시
10. 사용자를 `/mypage/applications`로 이동시키거나 성공 상태 화면 표시

---

## 5. 페이지 레이아웃 구조

```text
[MainLayout]
 ├─ Header
 ├─ Breadcrumb (채용 > 공고 상세 > 지원서 제출)
 ├─ Career Summary Card
 ├─ Application Form Section
 │   ├─ 기본 정보 입력
 │   ├─ 자기소개 입력
 │   ├─ 첨부파일 업로드
 │   ├─ 파일 검역 안내 문구
 │   └─ 제출 버튼 / 취소 버튼
 ├─ Validation / Error Message Area
 └─ Footer
```

---

## 6. 화면 구성 요소 상세

## 6.1 상단 공고 요약 카드

목적:

- 사용자가 현재 어떤 공고에 지원 중인지 다시 확인

표시 항목:

- 공고 제목
- 부서/직무
- 상태 (`OPEN`, `CLOSED`)
- 마감일
- 짧은 설명

데이터 출처:

- `GET /api/external/careers/{careerId}`

---

## 6.2 지원서 입력 폼

### 입력 필드

| 필드     | 타입     |   필수 | 설명                      |
| -------- | -------- | -----: | ------------------------- |
| 이름     | text     |     예 | 지원자 이름               |
| 이메일   | email    |     예 | 지원자 이메일             |
| 전화번호 | text     | 아니오 | 연락처                    |
| 자기소개 | textarea | 아니오 | 자유 서술                 |
| 첨부파일 | file     |     예 | 이력서 또는 단일 압축파일 |

### 정책

- 첨부파일은 **1개만 허용**
- 허용 파일 형식 및 크기 제한은 백엔드 정책에 따르며, 프론트는 가능한 범위에서 사전 안내
- 다중 업로드 UI는 두지 않는다

---

## 6.3 파일 업로드 안내 영역

표시 목적:

- 사용자가 업로드 직후 파일이 바로 사용되는 것이 아니라 검역될 수 있음을 이해하도록 안내

예시 문구:

- “첨부파일은 업로드 후 보안 검사를 거칠 수 있습니다.”
- “검사 결과에 따라 내부 검토에 사용되지 않을 수 있습니다.”
- “지원서 접수 성공은 첨부파일 최종 승인과 동일하지 않을 수 있습니다.”

---

## 6.4 액션 버튼 영역

버튼 구성:

- `제출`
- `취소` 또는 `이전으로`

동작:

- 제출: 입력 검증 후 API 호출
- 취소: 이전 페이지 또는 채용 공고 상세로 이동

버튼 상태:

- 필수값 미입력 시 제출 버튼 비활성화 가능
- 제출 중에는 중복 제출 방지를 위해 로딩 상태 처리

---

## 7. 데이터 모델 초안

## 7.1 화면 상태(State)

```ts
type CareerApplyPageState = {
  loading: boolean;
  submitting: boolean;
  career: CareerSummary | null;
  form: {
    name: string;
    email: string;
    phone: string;
    coverLetter: string;
    resumeFile: File | null;
  };
  validationErrors: Record<string, string>;
  submitResult: {
    applicationId?: number;
    fileId?: string;
    jobId?: string;
    status?: "PENDING" | "SCANNING";
  } | null;
};
```

## 7.2 공고 요약 데이터 예시

```ts
type CareerSummary = {
  careerId: number;
  title: string;
  department?: string;
  description?: string;
  status: "OPEN" | "CLOSED";
  deadline?: string;
};
```

---

## 8. 연결 API

## 8.1 공고 상세 조회

- `GET /api/external/careers/{careerId}`

용도:

- 공고 제목과 상태를 표시
- 마감 여부 판단

---

## 8.2 CSRF 토큰 조회

- `GET /api/external/csrf`

용도:

- 제출 전에 CSRF 토큰 확보

---

## 8.3 지원서 제출

- `POST /api/external/careers/{careerId}/applications`

Content-Type:

- `multipart/form-data`

전송 데이터:

- `name`
- `email`
- `phone`
- `coverLetter`
- `resumeFile`

예상 응답:

- `202 Accepted`

응답 예시:

```json
{
  "success": true,
  "code": "FILE_UPLOAD_ACCEPTED",
  "message": "지원서가 접수되었습니다. 첨부파일은 검역 중일 수 있습니다.",
  "data": {
    "fileId": "file_12345",
    "jobId": "job_67890",
    "status": "PENDING"
  },
  "timestamp": "2026-04-15T12:00:00Z"
}
```

---

## 8.4 파일 상태 조회

- `GET /api/external/files/{fileId}/status`

용도:

- 제출 직후 또는 내 지원 내역 페이지에서 첨부파일 상태 확인

상태 예시:

- `PENDING`
- `SCANNING`
- `APPROVED`
- `REJECTED`
- `QUARANTINED`

주의:

- 이 페이지에서는 제출 직후 상태를 즉시 보여줄 수는 있지만,
- 지속적인 폴링은 `mypage/applications`에서 수행하는 편이 더 적절하다.

---

## 9. 입력 검증 규칙

## 9.1 클라이언트 측 검증

| 필드      | 검증 규칙              |
| --------- | ---------------------- |
| 이름      | 비어 있지 않아야 함    |
| 이메일    | 이메일 형식이어야 함   |
| 첨부파일  | 1개만 허용             |
| 공고 상태 | `OPEN`이어야 제출 가능 |

## 9.2 서버 측 검증 전제

- 세션 인증 확인
- CSRF 토큰 검증
- 입력값 검증
- 중복 지원 정책 검증
- 파일 정책 검증

프론트는 서버 검증을 대체하지 않는다.

---

## 10. 상태값 및 사용자 메시지 설계

## 10.1 제출 전

- “지원 내용을 입력해주세요.”
- “첨부파일은 1개만 업로드할 수 있습니다.”

## 10.2 제출 성공

- “지원서가 접수되었습니다.”
- “첨부파일은 보안 검사를 거칠 수 있습니다.”
- “지원 내역에서 상태를 확인할 수 있습니다.”

## 10.3 제출 실패

### 인증 실패

- “로그인 후 이용해주세요.”

### 입력값 오류

- “입력값을 다시 확인해주세요.”

### 중복 지원

- “이미 해당 공고에 지원한 이력이 있습니다.”

### 요청 과다

- “요청이 너무 많습니다. 잠시 후 다시 시도해주세요.”

### 서버 오류

- “일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.”

---

## 11. 에러 처리 상세

| 상황           | 처리 방식                         |
| -------------- | --------------------------------- |
| 비로그인 접근  | `/login` 리다이렉트               |
| 잘못된 공고 ID | `/404` 또는 에러 메시지           |
| 마감된 공고    | 제출 버튼 비활성화 + 안내 문구    |
| 400            | 필드 오류 메시지 표시             |
| 401            | 로그인 유도                       |
| 403            | 접근 거부 또는 정책 위반 안내     |
| 409            | 중복 지원 안내                    |
| 429            | 토스트 메시지 표시                |
| 500            | 공통 에러 메시지 또는 `/500` 이동 |

---

## 12. 컴포넌트 분리 제안

추천 컴포넌트 구조:

```text
CareerApplyPage
├─ CareerSummaryCard
├─ ApplicationForm
│  ├─ InputField(name)
│  ├─ InputField(email)
│  ├─ InputField(phone)
│  ├─ TextareaField(coverLetter)
│  ├─ FileUploadField(resumeFile)
│  └─ SubmitActionBar
├─ ValidationMessageBox
└─ FilePolicyNotice
```

---

## 13. 프론트엔드 구현 기준

## 13.1 필요한 파일 제안

```text
apps/external-web/src/pages/careers/CareerApplyPage.tsx
apps/external-web/src/components/careers/CareerSummaryCard.tsx
apps/external-web/src/components/careers/ApplicationForm.tsx
apps/external-web/src/components/common/FileUploadField.tsx
apps/external-web/src/api/careers.ts
apps/external-web/src/types/career.ts
```

## 13.2 상태 관리 기준

- 로컬 상태로 시작
- 제출 결과만 페이지 수준 상태로 보관
- 전역 상태 도입은 필요 시 확장

---

## 14. MVP 구현 범위 확정

이 페이지의 MVP 범위는 아래와 같다.

포함:

- 공고 요약 표시
- 기본 지원서 입력
- 첨부파일 1개 업로드
- 제출 처리
- 검역 안내 문구
- 성공/실패 메시지

제외:

- 자동 임시 저장
- 다중 첨부
- 첨부파일 드래그앤드롭 고도화
- 실시간 파일 상태 폴링
- 고급 입력 검증 UI

---

## 15. 테스트 체크리스트

### 정상 흐름

- 로그인 상태에서 페이지 진입 가능
- 공고 정보 로드 가능
- 필수값 입력 후 제출 가능
- `202 Accepted` 응답 처리 가능

### 예외 흐름

- 비로그인 접근 차단
- 잘못된 공고 ID 처리
- 첨부파일 미첨부 시 제출 차단
- 중복 제출 방지
- `429` 처리
- 서버 오류 처리

---

## 16. 요약

1. 로그인한 일반 사용자만 접근 가능하다.
2. 첨부파일은 1개만 허용한다.
3. 제출 성공은 최종 승인 완료가 아니라 **업로드 접수 성공**일 수 있다.
4. 첨부파일은 비동기 검역 흐름을 따른다.
5. 에러 메시지와 제출 결과는 사용자가 이해할 수 있게 명확히 보여야 한다.
6. MVP에서는 단순하고 안정적인 흐름을 우선한다.
