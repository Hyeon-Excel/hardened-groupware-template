# APPLICANT_DETAIL_INTERNAL.md

# 내부 그룹웨어 상세 페이지 명세

# `/internal/applicants/:applicationId` 지원자 상세 페이지

## 1. 문서 목적

본 문서는 내부 그룹웨어의 `/internal/applicants/:applicationId` 페이지에 대한 상세 명세를 정의한다.

핵심 목적:

- 지원자 상세 정보 검토
- 첨부파일 상태 확인
- 채용 진행 상태 변경
- 검토 메모 기록

---

## 2. 페이지 기본 정보

| 항목 | 내용 |
| --- | --- |
| 페이지명 | 지원자 상세 |
| 경로 | `/internal/applicants/:applicationId` |
| 인증 필요 | 예 |
| 권한 | `MANAGER` 이상 |
| 주요 API | `GET /api/internal/applicants/{applicationId}`, `PATCH /api/internal/applicants/{applicationId}/status`, `POST /api/internal/applicants/{applicationId}/notes`, `GET /api/internal/files/{fileId}/status` |
| 우선순위 | MVP |

---

## 3. 접근 제어 규칙

- 로그인 필요: 내부 세션 없으면 `/internal/login` 이동
- 권한 부족: `/internal/403`
- 존재하지 않는 applicationId: `/internal/404`

---

## 4. 페이지 시나리오

1. 매니저가 지원자 목록에서 상세 진입
2. 지원자 기본정보/자기소개/첨부 상태 확인
3. 상태를 `REVIEWING`, `PASSED`, `REJECTED` 중 하나로 변경
4. 평가 메모 등록
5. 결과가 목록 화면에 반영

---

## 5. 화면 구성 요소

- 지원자 요약 카드: 이름, 이메일, 지원 공고, 제출일
- 지원서 상세 섹션: 연락처, 자기소개
- 첨부파일 상태 섹션: fileId, 검역 상태, 사유
- 상태 변경 패널: 드롭다운 + 저장 버튼
- 검토 메모 패널: 메모 목록 + 메모 작성

---

## 6. 상태값 설계

```ts
type ApplicantStatus = "RECEIVED" | "REVIEWING" | "PASSED" | "REJECTED";

type ApplicantDetailState = {
  loading: boolean;
  savingStatus: boolean;
  savingNote: boolean;
  error: string | null;
};
```

---

## 7. 연결 API

## 7.1 상세 조회

- `GET /api/internal/applicants/{applicationId}`

## 7.2 상태 변경

- `PATCH /api/internal/applicants/{applicationId}/status`
- body: `{ "status": "REVIEWING" }`

## 7.3 메모 등록

- `POST /api/internal/applicants/{applicationId}/notes`
- body: `{ "note": "기술면접 진행 권장" }`

## 7.4 파일 상태 조회

- `GET /api/internal/files/{fileId}/status`

---

## 8. 보안 및 감사 포인트

- 상태 변경/메모 등록은 `MANAGER` 이상만 가능
- 민감정보(개인 연락처)는 최소 노출
- 상태 변경 이벤트는 감사 로그 대상
- 첨부파일 상세 보안 판정은 내부 화면에서만 표시

---

## 9. 에러 처리

| 상황 | 처리 |
| --- | --- |
| 400 | 입력값 오류 메시지 |
| 401 | 로그인 유도 |
| 403 | 권한 부족 안내 |
| 404 | 지원자 없음 안내 |
| 409 | 상태 충돌 안내 |
| 500 | 공통 오류 메시지 |

---

## 10. 테스트 체크리스트

- [ ] 권한 없는 계정 접근 차단
- [ ] 상세 조회 성공
- [ ] 상태 변경 성공/실패 처리
- [ ] 메모 등록 성공/실패 처리
- [ ] 파일 상태 조회 실패 fallback
