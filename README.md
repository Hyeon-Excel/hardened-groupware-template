# hardened-groupware-template

생성형 AI 보조(바이브 코딩)로 빠르게 프로토타이핑한 **기업 그룹웨어 웹 인프라**를 대상으로,
취약점 분석 → 보안 하드닝 → 재검증 → 공개 가능한 안전 템플릿 배포까지 수행하는 보안 프로젝트입니다.
핵심은 AI 보조 개발 산출물에서 실제로 어떤 취약점이 발생하고, 보완 후 얼마나 개선되는지를 전후 데이터로 측정·기록하는 데 있습니다. 최종 결과물은 현업 조직이 바로 적용할 수 있는 v1 레퍼런스 템플릿입니다.

이 저장소는 단순한 웹 서비스 샘플이 아니라, 다음을 함께 다룹니다.

- 공개 웹 서비스와 내부 그룹웨어가 공존하는 기업형 웹 인프라
- 3계층 구조 기반 아키텍처 설계
- 세션/쿠키 기반 인증과 RBAC
- 파일 업로드 상태 머신(`uploaded_file.scan_status`) 기반 통제
- ASVS 기반 보안 점검
- OpenAPI-first API 계약 관리
- GitHub CodeQL / Dependency Review 기반 정적 분석
- 취약점 분석 전후 비교와 안전성 기준 템플릿화

---

## 프로젝트 목표

이 프로젝트의 핵심 목표는 다음과 같습니다.

1. 공개 웹 서비스와 내부 그룹웨어가 함께 존재하는 기업형 웹 인프라를 구축합니다.
2. 인증, 인가, 파일 처리, 관리자 기능, 서비스 간 경계 등 주요 보안 포인트를 중심으로 취약점을 분석합니다.
3. 분석 결과를 바탕으로 보안 하드닝을 수행하고, 개선 전후 보안 수준을 재검증합니다.
4. 최종적으로 GitHub에서 재현 가능한 **안전성 기준 레퍼런스 템플릿** 형태로 정리합니다.

---

## 핵심 컨셉

### 1) 공개 웹 + 내부 그룹웨어 분리

일반 사용자가 접근하는 공개 웹 서비스와, 임직원/관리자가 사용하는 내부 그룹웨어를 분리된 서비스 경계로 설계합니다.

### 2) External / Internal API 분리

- `external-api`: 일반 사용자용 공개 서비스 로직
- `internal-api`: 임직원/관리자용 그룹웨어 로직

내부 서비스는 공개 데이터를 직접 DB에서 수정하지 않고,  
반드시 공개 서비스의 내부 전용 관리 인터페이스를 통해 접근합니다.

### 3) 단일 스토리지 + 상태 머신 (v0 / v1 차등)

파일 바이트는 단일 오브젝트 스토리지(prefix: `raw/`, `approved/`, `rejected/`)에 저장하고,
보안 통제는 owner DB의 `uploaded_file.scan_status` 상태값으로 적용합니다.

v0/v1 상태 전이 상세 정본:

- [docs/architecture/ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md) 섹션 5 (상태 머신/흐름)
- [database/README.md](database/README.md) 섹션 1.1 (`uploaded_file` 필드/인덱스)
- [docs/security/SECURITY_BASELINE.md](docs/security/SECURITY_BASELINE.md) 섹션 7 (운영 기준선)

### 4) 보안 검증 중심 개발

이 프로젝트는 단순 기능 구현이 아니라, 아래 흐름 자체를 프로젝트 산출물로 봅니다.

- 구축
- 취약점 분석
- 보완
- 재검증
- 공개 배포 준비

---

## 시스템 아키텍처 요약

### 계층 구조

- **DMZ / External Ingress Zone**
  - `external-web` 정적 자산 서빙 + Reverse Proxy(Nginx)
  - `internal-web` 정적 자산 서빙 + Reverse Proxy(Nginx, 사내망 가정)

- **Application / WAS Zone**
  - `external-api`
  - `internal-api`

- **Data Zone**
  - `external_db` (공개 서비스 전용 DB)
  - `internal_db` (내부 그룹웨어 전용 DB)
  - object storage (`raw/`, `approved/`, `rejected/`)

DB는 `external_db`와 `internal_db` 두 개만 운영하며, 파일 바이트는 단일 오브젝트 스토리지에 저장한다.

### 인증 방식

- 사용자 인증: 세션 / 쿠키 기반
- 서비스 간 인증: 내부 전용 토큰 또는 서비스 계정

### 서비스 간 호출 원칙

- 허용: `internal-api -> external-api`
- 금지: `internal-api -> external_db` 직접 read/write

---

## 기술 스택

| 영역             | 스택                                          |
| ---------------- | --------------------------------------------- |
| Frontend         | React, Vite, Tailwind CSS                     |
| Web / Proxy      | Nginx                                         |
| Backend          | Java 17, Spring Boot 3.x, Spring Security 6.x |
| File Processing  | Spring 기반 스케줄러/배치(v1에서 활성)        |
| Database         | MariaDB                                       |
| File Storage     | 단일 오브젝트 스토리지 + prefix 분리          |
| Infra (실습)     | VMware 3-Tier                                 |
| Infra (재현)     | Docker Compose                                |
| API Contract     | OpenAPI-first (openapi.yaml 3.1.0)            |
| Security Review  | OWASP ASVS                                    |
| Static Analysis  | GitHub CodeQL                                 |
| Dependency Check | GitHub Dependency Review                      |

---

## 저장소 구조

### 현재 트리 (Phase 0 시점, 실존)

```text
hardened-groupware-template/
├─ apps/
│  ├─ external-api/        # Spring Boot (구현 진행 중)
│  ├─ external-web/        # React/Vite (구현 진행 중)
│  └─ internal-api/        # Spring Boot (구조만)
├─ database/
│  ├─ external/
│  └─ internal/
├─ docs/
│  ├─ architecture/
│  ├─ api/
│  ├─ security/
│  ├─ testing/
│  ├─ reports/
│  ├─ rules/
│  └─ archive/
├─ scripts/                # API 계약 drift 체크 등
├─ .github/                # workflows
├─ .gitignore
└─ README.md
```

### 향후 추가 예정 (Phase 1~5 진행에 따라 생성)

```text
hardened-groupware-template/
├─ apps/
│  └─ internal-web/        # Phase 1 최소 골격, Phase 3 이후 확장
├─ infra/
│  ├─ nginx/               # Phase 1 이후
│  ├─ docker/              # Phase 5 Docker Compose 재현용
│  ├─ vmware/              # 실습 VM 가이드
│  └─ scripts/
├─ storage/                # 로컬 개발용 단일 오브젝트 스토리지 표현
│  ├─ raw/                 # (v1에서만 사용)
│  ├─ approved/
│  └─ rejected/
├─ docker-compose.yml      # Phase 5
├─ SECURITY.md             # 보안 보고 정책 (공개 전 정리)
└─ .env (ignored)
```

> 상기 "향후 추가 예정" 경로는 현재 실존하지 않는다. 초기 세팅 시 `apps/external-api`, `apps/external-web`, `database/`, `docs/`만 유효하다.

---

## 문서 정본 기준

문서 참조 충돌을 막기 위해 아래 문서를 기준선으로 사용합니다.

- [docs/DOCSET_BASELINE.md](docs/DOCSET_BASELINE.md): 정본 문서 세트, 우선순위, 아카이브 정책
- [docs/TERMINOLOGY.md](docs/TERMINOLOGY.md): 용어/네이밍 표준
- [docs/rules/GIT_COLLABORATION_RULES.md](docs/rules/GIT_COLLABORATION_RULES.md): 협업 브랜치/커밋/병합 기준
- [docs/rules/PR_CHECKLIST.md](docs/rules/PR_CHECKLIST.md): PR 품질 게이트 체크리스트
- [docs/rules/SPRING_BOOT_BOOTSTRAP_RULES.md](docs/rules/SPRING_BOOT_BOOTSTRAP_RULES.md): external/internal API 공통 Spring Boot 생성 기준
- [docs/security/SECURITY_BASELINE.md](docs/security/SECURITY_BASELINE.md): 세션/토큰/보안 헤더 기준
- [docs/testing/TEST_STRATEGY.md](docs/testing/TEST_STRATEGY.md): 테스트 범위/비율/게이트 기준
- [docs/archive/README.md](docs/archive/README.md): 구버전 문서 보관 규칙

---

## 문서 읽는 순서

처음 보는 사람은 아래 5개 문서를 먼저 읽는 것을 권장합니다.

1. `docs/architecture/PLANNING.md`
2. `docs/architecture/ARCHITECTURE.md`
3. `docs/architecture/ROADMAP.md`
4. `docs/architecture/PAGE_STRUCTURE.md`
5. `docs/api/API.md`

나머지 정본/보조 문서 목록은 [docs/DOCSET_BASELINE.md](docs/DOCSET_BASELINE.md) 섹션 2를 따릅니다.

---

## 현재 설계된 주요 화면

공개/내부 라우트 구조와 권한 경계 정본은 [docs/architecture/PAGE_STRUCTURE.md](docs/architecture/PAGE_STRUCTURE.md)에서 관리합니다.
외부 상세 페이지 문서 링크와 작성 상태는 [docs/architecture/PAGE_SPECS_EXTERNAL.md](docs/architecture/PAGE_SPECS_EXTERNAL.md) 섹션 4를 따릅니다.

---

## 보안 검증 범위

핵심 검증 포인트:

- 인증/세션/인가(BOLA·IDOR 포함)
- 파일 업로드·다운로드 게이트 및 상태 전이
- external ↔ internal 서비스 경계
- v0 → v1 하드닝 전후 재검증

공격면 카탈로그와 ASVS 매핑 정본은 [docs/architecture/PLANNING.md](docs/architecture/PLANNING.md) 섹션 10과 11을 따릅니다.

---

## 진행 상태 (Phase 모델)

본 프로젝트는 `Phase 0~5`의 6단계 모델(문서 고정 → v0 구축 → 분석 → v1 하드닝 → 재검증 → 공개)을 따릅니다. 상세 일정과 완료 조건은 [docs/architecture/ROADMAP.md](docs/architecture/ROADMAP.md) 섹션 5와 6을 참고합니다.

| Phase   | 내용                                                                            | 상태                          |
| ------- | ------------------------------------------------------------------------------- | ----------------------------- |
| Phase 0 | 문서 기준선 확정 (PLANNING / ARCHITECTURE / API / DB / 보안 기준 / 테스트 전략) | 🟡 진행 중 (정합성 다듬기 중) |
| Phase 1 | v0 MVP 구축 (external 중심 / internal 최소 골격)                                | ⏳ 준비                       |
| Phase 2 | 모의해킹 · 취약점 분석 (ASVS / CodeQL / Burp · ZAP)                             | ⏳ 예정                       |
| Phase 3 | v1 하드닝 (finding 기반 보완)                                                   | ⏳ 예정                       |
| Phase 4 | 전후 재검증                                                                     | ⏳ 예정                       |
| Phase 5 | 최종 보고서 · 공개 템플릿 정리                                                  | ⏳ 예정                       |

Phase 0 세부 완료 항목:

- [x] 프로젝트 기획 (v0/v1 2단계 모델 확정)
- [x] 아키텍처 (2 DB + 단일 오브젝트 스토리지 + `uploaded_file` 상태 머신)
- [x] 실행 로드맵 (Phase 0~5)
- [x] 페이지 구조 및 공개 웹 주요 페이지 상세 명세
- [x] 내부 그룹웨어 핵심 페이지 상세 명세 1차
- [x] API 설계 문서 + OpenAPI 3.1 계약
- [x] API ↔ OpenAPI 동기화 / CI drift 체크
- [x] DB 스키마 코어 초안 / cross-DB 참조 무결성 전략
- [x] 협업 Git · PR 체크리스트 · Spring Boot 부트스트랩 규칙
- [x] 세션/서비스 토큰/보안 헤더 기준선(v0/v1 분리)
- [x] 테스트 전략(v0/v1 차등)

---

## 주의 사항

- 이 저장소는 방어적 보안 검증과 구조 개선을 위한 프로젝트입니다.
- 실제 악성코드 배포나 외부 대상 공격을 목적으로 하지 않습니다.
- 파일 보안 테스트 및 “테스트 페이로드” 평가는 승인된 폐쇄형 실습 환경에서만 수행하는 것을 전제로 합니다.

---

## 향후 계획

Phase 1(v0 MVP)

- external 핵심 사용자 플로우 구현(로그인, 문의, 지원서, 마이페이지)
- internal 최소 골격(로그인 + 대시보드) 확보
- 파일은 `uploaded_file` 상태(`V0_SCAN_DISABLED`) 기록만 적용
- v0 freeze 커밋 SHA 확정

Phase 2(분석)

- 시나리오 기반 모의해킹(Burp / ZAP / 수동)
- ASVS 매핑 + CodeQL / Dependency Review
- finding 백로그 확정

Phase 3~5

- v1 하드닝 (파일 보안 카드 적용, 세션·헤더·토큰 하드닝)
- 동일 시나리오 재검증 + 전후 비교 보고서
- Docker Compose 기반 공개 템플릿 + 실행 가이드 정리

---

## License

MIT License
