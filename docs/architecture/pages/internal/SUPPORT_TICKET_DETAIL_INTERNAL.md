# SUPPORT_TICKET_DETAIL_INTERNAL.md

# 내부 그룹웨어 상세 페이지 명세

# `/internal/support-tickets/:ticketId` 문의 상세 페이지

## 1. 문서 목적

본 문서는 내부 그룹웨어의 `/internal/support-tickets/:ticketId` 페이지에 대한 상세 명세를 정의한다.

핵심 목적:

- 고객 문의 상세 내용 확인
- 문의 상태 변경
- 내부 답변 등록
- 첨부파일 검역 상태 확인

---

## 2. 페이지 기본 정보

| 항목 | 내용 |
| --- | --- |
| 페이지명 | 문의 상세 |
| 경로 | `/internal/support-tickets/:ticketId` |
| 인증 필요 | 예 |
| 권한 | `MANAGER` 이상 |
| 주요 API | `GET /api/internal/support-tickets/{ticketId}`, `PATCH /api/internal/support-tickets/{ticketId}/status`, `POST /api/internal/support-tickets/{ticketId}/reply`, `GET /api/internal/files/{fileId}/status` |
| 우선순위 | MVP |

---

## 3. 접근 제어 규칙

- 로그인 필요: 내부 세션 없으면 `/internal/login`
- 권한 부족: `/internal/403`
- ticketId 불일치/없음: `/internal/404`

---

## 4. 대표 사용자 시나리오

1. 매니저가 문의 목록에서 상세 진입
2. 제목/내용/작성자/작성일 확인
3. 상태를 `REVIEWING`, `ANSWERED`, `CLOSED`로 변경
4. 답변 작성 후 등록
5. 첨부파일 상태가 `SCANNING`이면 추후 재확인

---

## 5. 화면 구성 요소

- 문의 요약 카드: ticketId, 작성자, 유형, 생성일
- 본문 패널: 제목/내용
- 첨부 상태 패널: fileId, 상태, 상태 사유
- 상태 변경 패널: 상태 드롭다운 + 저장
- 답변 등록 패널: 답변 입력 + 등록 버튼

---

## 6. 상태 모델

```ts
type TicketStatus = "RECEIVED" | "REVIEWING" | "ANSWERED" | "CLOSED";

type SupportTicketDetailState = {
  loading: boolean;
  savingStatus: boolean;
  savingReply: boolean;
  error: string | null;
};
```

---

## 7. 연결 API

## 7.1 상세 조회

- `GET /api/internal/support-tickets/{ticketId}`

## 7.2 상태 변경

- `PATCH /api/internal/support-tickets/{ticketId}/status`
- body: `{ "status": "ANSWERED" }`

## 7.3 답변 등록

- `POST /api/internal/support-tickets/{ticketId}/reply`
- body: `{ "reply": "문의 주신 내용에 대해 아래와 같이 안내드립니다." }`

## 7.4 파일 상태 조회

- `GET /api/internal/files/{fileId}/status`

---

## 8. 보안 및 감사 포인트

- 상태 변경 및 답변 등록은 감사 로그 대상
- 외부 공개 금지 정보는 내부에서만 표시
- 첨부파일 원본 다운로드는 정책 허용 범위에서만 처리

---

## 9. 에러 처리

| 상황 | 처리 |
| --- | --- |
| 400 | 입력값 오류 |
| 401 | 내부 로그인 유도 |
| 403 | 권한 부족 안내 |
| 404 | 문의 없음 안내 |
| 409 | 상태 충돌 안내 |
| 500 | 공통 오류 메시지 |

---

## 10. 테스트 체크리스트

- [ ] 권한 검증
- [ ] 문의 상세 조회 성공
- [ ] 상태 변경 성공/실패
- [ ] 답변 등록 성공/실패
- [ ] 첨부 상태 조회 실패 fallback
