# DOCSET_BASELINE.md

## 1. 목적

이 문서는 본 저장소의 문서 정본(SoT) 기준을 고정한다.

목표:

- 참여자마다 다른 문서를 참조하는 문제 방지
- 기획/아키텍처/API/화면 명세의 단일 기준 고정
- 중복 문서 발생 시 아카이브 절차 표준화

---

## 2. 정본 문서 세트

아래 문서가 현재 기준선이다.

| 영역                  | 정본 문서                                                                                               | 역할                                     |
| --------------------- | ------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| 프로젝트 기획         | [docs/architecture/PLANNING.md](architecture/PLANNING.md)                                               | 목표, 범위, 기술 스택, 보안 검증 방향    |
| 아키텍처              | [docs/architecture/ARCHITECTURE.md](architecture/ARCHITECTURE.md)                                       | 계층 구조, 서비스 경계, 데이터/파일 흐름 |
| 실행 계획             | [docs/architecture/ROADMAP.md](architecture/ROADMAP.md)                                                 | 역할 분담, Phase, 완료 기준              |
| 페이지 구조           | [docs/architecture/PAGE_STRUCTURE.md](architecture/PAGE_STRUCTURE.md)                                   | 공개/내부 라우트, 권한, MVP              |
| 공개 페이지 상세 총괄 | [docs/architecture/PAGE_SPECS_EXTERNAL.md](architecture/PAGE_SPECS_EXTERNAL.md)                             | 공개 웹 상세 명세 인덱스                 |
| 상세 페이지 템플릿    | [docs/architecture/pages/external/PAGE_SPEC_TEMPLATE.md](architecture/pages/external/PAGE_SPEC_TEMPLATE.md) | 상세 명세 공통 포맷                      |
| API 정책              | [docs/api/API.md](api/API.md)                                                                           | 경계, 인증, 규칙, API 카탈로그           |
| OpenAPI 계약          | [docs/api/openapi.yaml](api/openapi.yaml)                                                               | 구현 기준 계약 스펙                      |
| 경로 표준화           | [docs/api/ENDPOINT_STANDARDIZATION_PLAN.md](api/ENDPOINT_STANDARDIZATION_PLAN.md)                       | canonical/deprecated 정책                |
| 계약 동기화 체크      | [docs/reports/API_CONTRACT_SYNC_CHECKLIST.md](reports/API_CONTRACT_SYNC_CHECKLIST.md)                   | API.md ↔ OpenAPI 불일치 추적             |
| 내부 페이지 상세 템플릿 | [docs/architecture/pages/internal/PAGE_SPEC_TEMPLATE_PRIVATE.md](architecture/pages/internal/PAGE_SPEC_TEMPLATE_PRIVATE.md) | 내부 그룹웨어 상세 명세 공통 포맷        |
| DB 스키마 초안        | [database/README.md](../database/README.md)                                                             | DB 스키마 구조 및 관리 기준              |
| 용어 기준             | [docs/TERMINOLOGY.md](TERMINOLOGY.md)                                                                   | 용어/네이밍 기준                         |
| 보안 운영 기준        | [docs/security/SECURITY_BASELINE.md](security/SECURITY_BASELINE.md)                                     | 세션/토큰/보안 헤더 운영 기준            |
| 테스트 전략           | [docs/testing/TEST_STRATEGY.md](testing/TEST_STRATEGY.md)                                               | 단위/통합/E2E 범위 및 품질 게이트 기준   |
| 협업 Git 규칙         | [docs/rules/GIT_COLLABORATION_RULES.md](rules/GIT_COLLABORATION_RULES.md)                               | 브랜치/커밋/병합 협업 기준               |
| PR 체크리스트         | [docs/rules/PR_CHECKLIST.md](rules/PR_CHECKLIST.md)                                                     | PR 품질 게이트 및 문서 동기화 기준       |
| 백엔드 부트스트랩 규칙 | [docs/rules/SPRING_BOOT_BOOTSTRAP_RULES.md](rules/SPRING_BOOT_BOOTSTRAP_RULES.md)                       | external/internal API 공통 생성 기준     |

---

## 3. 정본 우선순위 규칙

같은 주제에 문서가 2개 이상 존재할 경우 아래 규칙을 따른다.

1. API 계약은 [docs/api/openapi.yaml](api/openapi.yaml)을 우선한다.
2. 아키텍처 경계와 저장소 책임은 [docs/architecture/ARCHITECTURE.md](architecture/ARCHITECTURE.md)를 우선한다.
3. 페이지 구조/권한/MVP는 [docs/architecture/PAGE_STRUCTURE.md](architecture/PAGE_STRUCTURE.md)를 우선한다.
4. 공개 웹 상세 화면은 [docs/architecture/PAGE_SPECS_EXTERNAL.md](architecture/PAGE_SPECS_EXTERNAL.md)와 개별 상세 문서를 우선한다.
5. 용어 충돌 시 [docs/TERMINOLOGY.md](TERMINOLOGY.md)를 우선한다.
6. 세션/서비스 토큰/보안 헤더 정책은 [docs/security/SECURITY_BASELINE.md](security/SECURITY_BASELINE.md)를 우선한다.
7. 테스트 범위/품질 게이트 충돌 시 [docs/testing/TEST_STRATEGY.md](testing/TEST_STRATEGY.md)를 우선한다.
8. 브랜치/커밋/PR 운영 규칙 충돌 시 [docs/rules/GIT_COLLABORATION_RULES.md](rules/GIT_COLLABORATION_RULES.md)를 우선한다.
9. Spring Boot 초기 생성/버전/의존성 기준 충돌 시 [docs/rules/SPRING_BOOT_BOOTSTRAP_RULES.md](rules/SPRING_BOOT_BOOTSTRAP_RULES.md)를 우선한다.

---

## 3.1 중복 최소화 규칙

문서 가독성을 위해 동일 내용을 여러 문서에 반복 서술하지 않는다.

1. 공통 정책 전문은 1개 정본 문서에만 유지한다.
2. 다른 문서에서는 2~3줄 요약 + 정본 링크만 남긴다.
3. 페이지 상세 문서는 "해당 페이지에서만 달라지는 정보"만 포함한다.
4. 정본 변경 시 파생 문서는 문구 동기화보다 링크 정합성 확인을 우선한다.

---

## 4. 버전 및 아카이브 정책

중복/구버전 문서가 발생하면 아래 절차를 따른다.

1. 정본을 1개 확정한다.
2. 구버전을 [docs/archive](archive/README.md)로 이동한다.
3. 파일명에 날짜를 포함한다.
   - 예: `PLANNING_2026-04-16_pre-baseline.md`
4. 아카이브 파일 상단에 상태를 명시한다.
   - `Status: archived`
   - `Replaced-By: docs/...`
5. 정본 문서의 "관련 문서" 섹션에 교체 이력을 1줄 남긴다.

---

## 5. 운영 체크리스트

- [ ] 신규 문서 생성 시 기존 정본 문서와 역할 충돌 없는지 확인
- [ ] 정본 문서 수정 시 관련 문서 링크 동기화
- [ ] API 변경 시 `API.md`와 `openapi.yaml` 동시 업데이트
- [ ] 용어 신규 추가 시 [docs/TERMINOLOGY.md](TERMINOLOGY.md) 반영
- [ ] 세션/토큰/보안 헤더 정책 변경 시 [docs/security/SECURITY_BASELINE.md](security/SECURITY_BASELINE.md) 반영
- [ ] 테스트 범위/게이트 변경 시 [docs/testing/TEST_STRATEGY.md](testing/TEST_STRATEGY.md) 반영
- [ ] 공통 내용은 복붙하지 않고 정본 링크 참조로 처리했는지 확인
- [ ] PR 작성 시 [docs/rules/PR_CHECKLIST.md](rules/PR_CHECKLIST.md) 항목 점검
- [ ] external/internal API 생성 기준 변경 시 [docs/rules/SPRING_BOOT_BOOTSTRAP_RULES.md](rules/SPRING_BOOT_BOOTSTRAP_RULES.md) 반영

---

## 6. 변경 이력

- 2026-04-16: 기준선 문서 최초 생성
- 2026-04-16: 내부 페이지 상세 템플릿, DB 스키마 초안 정본 세트 추가
- 2026-04-16: 협업 Git 규칙 및 PR 체크리스트 문서 정본 세트 추가
- 2026-04-16: 보안 운영 기준 문서 정본 세트 추가
- 2026-04-16: 테스트 전략 문서 정본 세트 추가
- 2026-04-17: Spring Boot 공통 부트스트랩 규칙 문서 정본 세트 추가
- 2026-04-20: 프로젝트 주제 회귀(모의해킹·취약점 분석 중심)와 파일 처리 모델 재정의(단일 오브젝트 스토리지 + 상태 머신)에 따라 PLANNING.md 재작성, 구버전은 `docs/archive/PLANNING_2026-04-20_pre-pentest-pivot.md`로 이동
- 2026-04-20: 문서 중복 최소화 규칙(정본 링크 우선, 페이지 문서 고유 정보 중심) 추가
