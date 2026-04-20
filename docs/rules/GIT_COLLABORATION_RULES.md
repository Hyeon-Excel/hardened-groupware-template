# GIT_COLLABORATION_RULES.md

## 1. 목적

이 문서는 `hardened-groupware-template` 협업 시 사용할 Git 커밋 규칙과 브랜치 전략을 정의한다.

목표:

- 변경 이력을 읽기 쉽게 유지
- 리뷰/병합 충돌 최소화
- 문서 중심 설계 자산(API/OpenAPI/아키텍처) 동기화 강제

---

## 2. 브랜치 전략

### 2.1 기본 브랜치

- `main`: 배포/공유 가능한 안정 상태만 유지 (보호 브랜치)
- `develop`: 통합 개발 브랜치 (기본 PR 대상)

### 2.2 작업 브랜치 타입

| Prefix      | 용도                     | 생성 기준 브랜치 | 병합 대상                 |
| ----------- | ------------------------ | ---------------- | ------------------------- |
| `feat/`     | 기능 추가                | `develop`        | `develop`                 |
| `fix/`      | 버그 수정                | `develop`        | `develop`                 |
| `docs/`     | 문서 수정                | `develop`        | `develop`                 |
| `refactor/` | 동작 변경 없는 구조 개선 | `develop`        | `develop`                 |
| `test/`     | 테스트 추가/수정         | `develop`        | `develop`                 |
| `ci/`       | CI/CD 설정 변경          | `develop`        | `develop`                 |
| `chore/`    | 빌드/환경/의존성 관리    | `develop`        | `develop`                 |
| `hotfix/`   | 운영 치명 이슈 긴급 수정 | `main`           | `main` + `develop` 역병합 |

### 2.3 브랜치 네이밍 규칙

형식:

`<type>/<scope>-<short-description>`

규칙:

- 소문자, 하이픈(`-`) 사용
- 설명은 3~7 단어 이내
- 가능하면 이슈 번호 포함

예시:

- `feat/auth-external-login-rate-limit`
- `fix/files-security-status-mapping`
- `docs/api-openapi-sync-checklist`
- `hotfix/internal-auth-session-cookie`

### 2.4 브랜치 운영 원칙

- 작업 브랜치는 가급적 1~3일 내 병합 가능한 크기로 유지
- 장기 브랜치 금지 (7일 이상 지속 시 분할)
- 병합 전 `develop` 최신 상태를 반영(rebase 또는 merge)

---

## 3. 커밋 룰

### 3.1 커밋 메시지 형식 (Conventional Commits 기반)

형식:

`<type>(<scope>): <subject>`

`<body>` (선택)

`<footer>` (선택)

### 3.2 타입

- `feat`: 기능 추가
- `fix`: 버그 수정
- `docs`: 문서 변경
- `refactor`: 리팩터링 (동작 변화 없음)
- `test`: 테스트 추가/수정
- `ci`: CI 설정 변경
- `chore`: 환경/의존성/빌드 보조 작업
- `perf`: 성능 개선
- `security`: 보안 하드닝

### 3.3 스코프 권장값

- `external-web`
- `external-api`
- `internal-web`
- `internal-api`
- `file-security`
- `db-external`
- `db-internal`
- `api-contract`
- `architecture`
- `docs`

### 3.4 제목 작성 규칙

- 50자 내외, 명령형 현재시제
- 마침표 생략
- 하나의 변경 의도만 포함

예시:

- `feat(external-api): 지원 티켓 생성 엔드포인트 추가`
- `fix(file-security): 미확인 MIME 타입 파일의 다운로드 제공 차단`
- `docs(api-contract): careers me 경로를 정식 경로로 정렬`
- `security(internal-api): 서비스 토큰 검증 강제`

### 3.5 커밋 단위 규칙

- 커밋 1개 = 논리적으로 완결된 1개 변경
- 리팩터링과 기능 변경을 같은 커밋에 혼합 금지
- 대규모 포맷 변경은 별도 커밋으로 분리
- 자동 생성 산출물은 소스 변경 커밋과 분리

### 3.6 금지 사항

- `update`, `fix`, `misc` 같은 의미 없는 제목
- 여러 기능을 한 커밋에 혼합
- 동작 변경인데 테스트/문서 미반영

---

## 4. PR 및 병합 규칙

### 4.1 기본 병합 정책

- 기본: `Squash and merge`
- 머지 커밋 허용 조건: 릴리즈 브랜치/히스토리 보존이 필요한 경우만

### 4.2 PR 최소 요건

- 변경 목적 1~2문장
- 영향 범위(서비스/문서/DB) 명시
- 테스트 또는 검증 결과 첨부
- 롤백 전략(필요 시) 명시
- PR 본문에서 [PR_CHECKLIST.md](PR_CHECKLIST.md) 항목 확인

### 4.3 리뷰 규칙

- 최소 1명 승인 후 병합
- 보안/인증/권한/파일처리 변경은 2명 승인 권장

---

## 5. 프로젝트 전용 동기화 규칙

### 5.1 API 변경 시

아래 3개를 같은 PR에서 함께 반영한다.

1. `docs/api/API.md`
2. `docs/api/openapi.yaml`
3. `docs/reports/API_CONTRACT_SYNC_CHECKLIST.md`

### 5.2 페이지/라우트 변경 시

아래 문서를 함께 점검한다.

- `docs/architecture/PAGE_STRUCTURE.md`
- 관련 상세 페이지 명세 (`docs/architecture/pages/...`)
- API 경로 변경이 있으면 API 문서 세트 동시 반영

### 5.3 용어/경계 변경 시

- 용어 변경: `docs/TERMINOLOGY.md` 갱신
- 서비스 경계/데이터 소유권 변경: `docs/architecture/ARCHITECTURE.md` 갱신
- 일정/단계 영향 발생 시 `docs/architecture/ROADMAP.md`도 갱신

---

## 6. Hotfix 운영

1. `hotfix/*`를 `main`에서 분기
2. 수정 후 `main`으로 우선 병합
3. 동일 커밋을 `develop`에 역병합
4. 원인/재발방지 내용을 PR 본문 또는 별도 보고서에 기록

---

## 7. 빠른 체크리스트

PR 열기 전 확인:

- [ ] 브랜치 이름이 규칙에 맞다
- [ ] 커밋 메시지가 `<type>(<scope>): <subject>` 형식을 따른다
- [ ] 변경 범위와 테스트 결과를 PR에 기재했다
- [ ] API/페이지/용어 변경 시 관련 문서를 동기화했다
- [ ] API 변경 시 "OpenAPI 동기화 완료" 항목을 체크했다
- [ ] `develop` 최신 변경을 반영했다

---

## 8. 변경 이력

- 2026-04-16: 초안 작성
- 2026-04-16: PR 체크리스트 연동 항목 추가
