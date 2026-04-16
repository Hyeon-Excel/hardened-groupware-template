# PR_CHECKLIST.md

## 1. 목적

이 문서는 PR 생성 시 품질 게이트를 빠르게 점검하기 위한 공통 체크리스트다.

---

## 2. 기본 체크

- [ ] PR 제목이 변경 의도를 명확히 설명한다.
- [ ] PR 설명에 배경/목적이 1~2문장으로 정리되어 있다.
- [ ] 영향 범위(서비스/문서/DB/인프라)가 명시되어 있다.
- [ ] 테스트 또는 검증 결과가 첨부되어 있다.
- [ ] 롤백 전략(필요 시)이 명시되어 있다.

---

## 3. API/계약 변경 체크

API 경로, 요청/응답 스키마, 인증 규칙이 바뀌면 아래 항목을 모두 체크한다.

- [ ] `docs/api/API.md`를 업데이트했다.
- [ ] `docs/api/openapi.yaml`을 업데이트했다.
- [ ] `docs/reports/API_CONTRACT_SYNC_CHECKLIST.md`를 업데이트했다.
- [ ] PR 본문에 **OpenAPI 동기화 완료**를 명시했다.
- [ ] `API Contract Guard` CI(`openapi lint`, `drift check`)가 통과했다.

---

## 4. 페이지/아키텍처 변경 체크

- [ ] 페이지 라우트/권한 변경 시 `docs/architecture/PAGE_STRUCTURE.md`를 반영했다.
- [ ] 상세 페이지 명세(`docs/architecture/pages/...`)가 필요하면 함께 반영했다.
- [ ] 서비스 경계/데이터 소유권 변경 시 `docs/architecture/ARCHITECTURE.md`를 반영했다.
- [ ] 일정/마일스톤 영향이 있으면 `docs/architecture/ROADMAP.md`를 반영했다.

---

## 5. 용어/규칙 변경 체크

- [ ] 용어 추가/변경 시 `docs/TERMINOLOGY.md`를 반영했다.
- [ ] 협업 규칙 변경 시 `docs/rules/GIT_COLLABORATION_RULES.md`를 반영했다.
- [ ] 테스트 범위/품질 게이트 변경 시 `docs/testing/TEST_STRATEGY.md`를 반영했다.
- [ ] 문서 기준선 영향이 있으면 `docs/DOCSET_BASELINE.md`를 반영했다.

---

## 6. 변경 이력

- 2026-04-16: 초안 작성
