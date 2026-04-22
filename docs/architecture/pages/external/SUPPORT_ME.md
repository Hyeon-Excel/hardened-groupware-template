# SUPPORT_ME.md

# 공개 웹 상세 페이지 명세

# `/support/me` 내 문의 목록 페이지

## 1. 문서 목적

본 문서는 공개 웹 서비스의 `/support/me` 페이지에 대한 상세 화면 명세를 정의한다.  
이 페이지는 로그인한 일반 사용자가 본인이 등록한 고객 문의 내역과 처리 상태를 확인하는 화면이다.

이 페이지는 다음 목적을 가진다.

- 사용자가 자신이 등록한 문의 목록을 조회
- 각 문의의 처리 상태를 확인
- 첨부파일이 있는 경우 파일 보안 검사 상태를 확인
- 문의 등록 페이지와 자연스럽게 연결
- 향후 문의 상세 페이지 확장 기반 제공

즉, 이 페이지는 단순 목록 화면이 아니라 **문의 처리 상태 + 첨부파일 상태 + 사용자 피드백**을 통합하는 핵심 후속 화면이다.

---

## 2. 페이지 기본 정보

| 항목           | 내용                                                                          |
| -------------- | ----------------------------------------------------------------------------- |
| 경로           | `/support/me`                                                                 |
| 페이지명       | 내 문의 목록 페이지                                                           |
| 목적           | 사용자의 문의 이력과 처리 상태 조회                                           |
| 인증 필요 여부 | 예                                                                            |
| 권한           | `PUBLIC_USER`                                                                 |
| 우선순위       | MVP                                                                           |
| 연결 서비스    | `external-web` → `external-api`                                                   |
| 주요 API       | `GET /api/external/support-tickets/me`, `GET /api/external/files/{fileId}/status` |

---

## 3. 진입 조건 및 접근 제어

## 3.1 진입 조건

- 공개 서비스 로그인 상태여야 한다.
- 일반 사용자 세션이 유효해야 한다.

## 3.2 접근 제어 규칙

- 비로그인 사용자는 `/login`으로 리다이렉트한다.
- 다른 사용자의 문의 목록은 조회할 수 없다.
- 서버는 항상 현재 로그인 세션 기준으로만 데이터를 반환한다.

---

## 4. 페이지 목적과 사용자 시나리오

## 4.1 주요 목적

- 사용자가 본인의 문의 내역을 목록으로 확인
- 각 문의의 처리 상태를 이해
- 첨부파일이 파일 보안 검사 중인지, 승인되었는지, 처리 제한되었는지 확인
- 상세 화면이 없어도 목록 수준에서 핵심 상태를 충분히 이해할 수 있도록 제공

## 4.2 대표 사용자 시나리오

1. 사용자가 로그인 후 고객센터 메뉴 또는 문의 등록 완료 화면에서 `/support/me`로 이동
2. 본인이 등록한 문의 목록 확인
3. 각 문의의 상태와 첨부파일 상태 확인
4. 아직 검토 중이면 대기 상태 확인
5. 첨부파일이 정책상 제한되었으면 간단한 안내 문구 확인
6. 필요 시 추후 `/support/:ticketId` 상세 화면으로 확장 가능

---

## 5. 페이지 레이아웃 구조

```text id="r6rmbm"
[MainLayout]
 ├─ Header
 ├─ Breadcrumb (고객센터 > 내 문의 목록)
 ├─ Support Status Summary
 ├─ Support Ticket List Section
 │   ├─ 문의 목록 테이블
 │   ├─ 문의 상태 배지
 │   ├─ 첨부파일 상태 배지
 │   └─ 빈 상태(Empty State)
 ├─ Status Help Panel
 └─ Footer
```

---

## 6. 화면 구성 요소 상세

## 6.1 상단 상태 요약 영역

목적:

- 사용자가 현재 문의 현황을 빠르게 파악

표시 항목 예시:

- 총 문의 수
- 처리 중 문의 수
- 답변 완료 문의 수

MVP에서는 단순 숫자 카드 2~3개 정도면 충분하다.

---

## 6.2 문의 목록 영역

### 표시 항목

| 항목          | 설명                      |
| ------------- | ------------------------- |
| 문의 ID       | 화면용 식별자             |
| 문의 제목     | 사용자가 작성한 문의 제목 |
| 문의 유형     | 계정/자료실/채용/기타 등  |
| 등록일        | 문의 제출일               |
| 문의 상태     | 현재 처리 상태            |
| 첨부파일 상태 | 파일 보안 검사/승인 상태            |
| 비고          | 제한/격리 등 간단 메시지  |

### 목록 표시 방식

MVP는 **테이블형**이 적절하다.

권장 컬럼:

- 제목
- 문의 유형
- 등록일
- 문의 상태
- 첨부파일 상태
- 비고

### 정렬 기준

- 최신 문의 우선 정렬

---

## 6.3 상태 배지

문의 상태/첨부파일 상태 enum과 사용자 표시 문구 정본은 [TERMINOLOGY.md](../../../TERMINOLOGY.md) 섹션 2.3을 따른다.

본 페이지 고유 규칙:

- 한 행에서 `status`와 `fileStatus`를 동시에 표시한다.
- 공개 사용자에게 내부 탐지 상세 사유/시그니처/정책 내부값은 노출하지 않는다.

---

## 6.4 상태 도움말 패널

목적:

- 사용자가 배지 의미를 쉽게 이해하도록 보조

작성 규칙:

- 도움말 문구는 섹션 6.3의 상태 라벨 기준을 재사용한다.
- 페이지 문맥(문의 접수, 답변 확인)에 맞춘 짧은 설명만 덧붙인다.

---

## 6.5 빈 상태(Empty State)

표시 조건:

- 등록된 문의가 없음

표시 문구 예시:

- “등록한 문의가 없습니다.”
- “문의가 필요하다면 고객센터에서 새 문의를 등록해보세요.”

버튼:

- `문의 등록하기`

---

## 7. 데이터 모델 초안

## 7.1 화면 상태(State)

```js id="n6f6cn"
const mySupportTicketsPageState = {
  loading: false,
  items: [],
  error: null,
  pagination: {
    page: 1,
    size: 10,
    total: 0,
  },
};
```

## 7.2 목록 아이템 타입 예시

```js id="r6d8vk"
const supportTicketListItem = {
  ticketId: 1001,
  title: "솔루션 데모 환경 문의",
  category: "TECHNICAL", // ACCOUNT | RESOURCE | CAREER | TECHNICAL | OTHER
  createdAt: "2026-04-20T11:00:00+09:00",
  status: "RECEIVED", // RECEIVED | REVIEWING | ANSWERED | CLOSED
  fileId: null, // int64 or null
  fileStatus: null, // PENDING | SCANNING | APPROVED | REJECTED | FAILED | null
};
```

---

## 8. 연결 API

## 8.1 내 문의 목록 조회

- `GET /api/external/support-tickets/me`

용도:

- 문의 목록 조회
- 문의 상태 반환
- 가능하면 첨부파일 상태도 함께 포함

권장 사항:

- 백엔드가 목록 API 응답에 `fileStatus`를 함께 포함해 주는 것이 가장 효율적이다.
- 목록 렌더링을 위해 별도 파일 상태 API를 매번 반복 호출하는 구조는 MVP에서 피한다.

---

## 8.2 파일 상태 조회

- `GET /api/external/files/{fileId}/status`

용도:

- 목록 API에 파일 상태가 포함되지 않은 경우 보조적으로 사용
- 특정 문의의 첨부 상태를 다시 확인할 때 사용

MVP 권장:

- 목록 API에 상태 포함
- 수동 재조회가 필요한 경우만 별도 호출

---

## 9. 렌더링 전략

## 9.1 권장 방식

MVP에서는 **문의 목록 API가 파일 상태를 함께 내려주는 방식**을 권장한다.

이유:

- N+1 요청 방지
- 구현 단순화
- 상태 배지 표시 일관성 확보

즉, 프론트는 아래 흐름으로 동작한다.

1. 페이지 진입
2. `GET /api/external/support-tickets/me`
3. 목록 렌더링
4. 문의 상태 + 첨부파일 상태 배지 표시

## 9.2 예외적 재조회

사용자가 “상태 새로고침”을 누르는 경우에만 `GET /api/external/files/{fileId}/status`를 사용한다.

---

## 10. 상호작용 요소

### 기본 상호작용

- 페이지네이션
- 새 문의 등록 버튼
- 상태 새로고침 버튼(선택)

### MVP에서 제외 가능

- 고급 필터
- 정렬 옵션
- 실시간 자동 폴링
- 문의 상세 페이지 연결

---

## 11. 상태값 및 사용자 메시지 설계

## 11.1 정상 메시지

- “문의 내역을 불러왔습니다.”

## 11.2 빈 목록 메시지

- “등록한 문의가 없습니다.”

## 11.3 첨부파일 상태 메시지

배지 라벨 정본은 섹션 6.3의 상태 라벨 기준을 따른다.
본 페이지에서는 배지 라벨 뒤에 문의 맥락 설명 문구를 1문장으로만 덧붙인다.

주의:

- 내부 탐지 방식, 악성코드 이름, 정책 내부값은 공개 사용자에게 노출하지 않는다.

---

## 12. 에러 처리 상세

| 상황                | 처리 방식                         |
| ------------------- | --------------------------------- |
| 비로그인 접근       | `/login` 리다이렉트               |
| 목록 조회 실패      | 인라인 에러 + 재시도 버튼         |
| 파일 상태 조회 실패 | 해당 셀에 “상태 확인 실패” 표시   |
| `401`               | 로그인 필요 메시지                |
| `403`               | `/403` 또는 접근 제한 안내        |
| `404`               | 특정 리소스 누락 시 일반 메시지   |
| `429`               | 토스트 메시지 표시                |
| `500`               | 공통 에러 메시지 또는 `/500` 이동 |

---

## 13. 컴포넌트 분리 제안

```text id="t2eboe"
MySupportTicketsPage
├─ SupportStatusSummary
├─ SupportTicketListTable
│  ├─ SupportTicketStatusBadge
│  ├─ FileStatusBadge
│  └─ EmptyState
├─ StatusHelpPanel
└─ RetryActionBar
```

권장 공통 컴포넌트:

- `SupportTicketStatusBadge`
- `FileStatusBadge`
- `EmptyState`
- `Pagination`

---

## 14. 프론트엔드 구현 기준

## 14.1 필요한 파일 제안

```text id="zmhrol"
apps/external-web/src/pages/support/MySupportTicketsPage.jsx
apps/external-web/src/components/support/SupportStatusSummary.jsx
apps/external-web/src/components/support/SupportTicketListTable.jsx
apps/external-web/src/components/common/SupportTicketStatusBadge.jsx
apps/external-web/src/components/common/FileStatusBadge.jsx
apps/external-web/src/api/support.js
apps/external-web/src/types/support.js
```

## 14.2 상태 관리 기준

- 페이지 단위 로컬 상태로 시작
- 목록 데이터는 페이지 진입 시 조회
- 파일 상태는 목록 응답에 포함하는 것을 우선
- 필요 시만 추가 조회

---

## 15. MVP 구현 범위 확정

포함:

- 문의 목록 조회
- 문의 상태 배지
- 첨부파일 상태 배지
- 빈 상태 UI
- 인라인 에러 처리
- 페이지네이션(단순형 가능)

제외:

- 문의 상세 페이지 분리
- 자동 폴링
- 고급 필터
- 첨부 원본 직접 열람
- 상세 보안 판정 사유 노출

---

## 16. 테스트 체크리스트

### 정상 흐름

- 로그인 상태에서 페이지 진입 가능
- 문의 목록 로드 가능
- 문의 상태 배지 정상 표시
- 첨부파일 상태 배지 정상 표시
- 빈 상태 UI 표시 가능

### 예외 흐름

- 비로그인 접근 차단
- 목록 API 실패 시 fallback 처리
- 파일 상태 누락 시 graceful fallback
- `429` 처리
- 서버 오류 처리

---

## 17. 요약

이 페이지의 핵심은 다음과 같다.

1. 로그인한 일반 사용자만 접근 가능하다.
2. 사용자는 자신의 문의 이력만 볼 수 있다.
3. 문의 상태와 첨부파일 상태를 함께 보여주는 것이 핵심이다.
4. 공개 화면에서는 보안 판정 결과를 단순화해 노출한다.
5. MVP에서는 목록 API가 파일 상태를 함께 반환하는 구조가 가장 효율적이다.
6. 이 페이지는 문의 등록 페이지의 후속 확인 화면 역할을 한다.
