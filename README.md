# hardened-groupware-template

AI-assisted 방식으로 프로토타이핑한 **기업 그룹웨어 웹 인프라**를 대상으로,  
취약점 분석 → 보안 하드닝 → 재검증 → 공개 가능한 Secure 템플릿화까지 수행하는 보안 프로젝트입니다.

이 저장소는 단순한 웹 서비스 샘플이 아니라, 다음을 함께 다룹니다.

- 공개 웹 서비스와 내부 그룹웨어가 공존하는 기업형 웹 인프라
- 3계층 구조 기반 아키텍처 설계
- 세션/쿠키 기반 인증과 RBAC
- 파일 업로드 검역(Quarantine) 및 상태 추적
- ASVS 기반 보안 점검
- OpenAPI-first API 계약 관리
- GitHub CodeQL / Dependency Review 기반 정적 분석
- 취약점 분석 전후 비교와 Secure-by-Default 템플릿화

---

## 프로젝트 목표

이 프로젝트의 핵심 목표는 다음과 같습니다.

1. 공개 웹 서비스와 내부 그룹웨어가 함께 존재하는 기업형 웹 인프라를 구축합니다.
2. 인증, 인가, 파일 처리, 관리자 기능, 서비스 간 경계 등 주요 보안 포인트를 중심으로 취약점을 분석합니다.
3. 분석 결과를 바탕으로 보안 하드닝을 수행하고, 개선 전후 보안 수준을 재검증합니다.
4. 최종적으로 GitHub에서 재현 가능한 **Secure-by-Default 레퍼런스 템플릿** 형태로 정리합니다.

---

## 핵심 컨셉

### 1) 공개 웹 + 내부 그룹웨어 분리

일반 사용자가 접근하는 공개 웹 서비스와, 임직원/관리자가 사용하는 내부 그룹웨어를 분리된 서비스 경계로 설계합니다.

### 2) External / Internal API 분리

- `external-api`: 일반 사용자용 공개 서비스 로직
- `internal-api`: 임직원/관리자용 그룹웨어 로직

내부 서비스는 공개 데이터를 직접 DB에서 수정하지 않고,  
반드시 공개 서비스의 내부 전용 관리 인터페이스를 통해 접근합니다.

### 3) 파일 검역 파이프라인

외부 업로드 파일은 곧바로 내부 검토나 공개 다운로드로 이어지지 않습니다.

기본 흐름:

- 업로드 수신
- `quarantine_storage` 저장
- 검역/정책 검사
- 승인 저장소로 이동
  - `approved_external_storage`
  - `internal_review_storage`

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
  - Nginx
  - 공개 웹 정적 자산 서빙
  - Reverse Proxy

- **Application / WAS Zone**
  - `external-web`
  - `external-api`
  - `internal-web`
  - `internal-api`
  - `file-worker`

- **Data Zone**
  - `external_db`
  - `internal_db`
  - `quarantine_storage`
  - `approved_external_storage`
  - `internal_review_storage`

### 인증 방식

- 사용자 인증: 세션 / 쿠키 기반
- 서비스 간 인증: 내부 전용 토큰 또는 서비스 계정

### 서비스 간 호출 원칙

- 허용: `internal-api -> external-api`
- 금지: `internal-api -> external_db` 직접 write

---

## 기술 스택

| 영역             | 스택                                          |
| ---------------- | --------------------------------------------- |
| Frontend         | React, Vite, Tailwind CSS                     |
| Web / Proxy      | Nginx                                         |
| Backend          | Java 17, Spring Boot 3.x, Spring Security 6.x |
| File Worker      | Node.js 20, TypeScript                        |
| Database         | MariaDB                                       |
| File Storage     | 웹 루트 밖 분리 저장소 기반 파일 스토리지     |
| Infra (실습)     | VMware 3-Tier                                 |
| Infra (재현)     | Docker Compose                                |
| API Contract     | OpenAPI-first (openapi.yaml 3.1.0)            |
| Security Review  | OWASP ASVS                                    |
| Static Analysis  | GitHub CodeQL                                 |
| Dependency Check | GitHub Dependency Review                      |

---

## 저장소 구조

```text
hardened-groupware-template/
├─ apps/
│  ├─ external-web/
│  ├─ external-api/
│  ├─ internal-web/
│  ├─ internal-api/
│  └─ file-worker/
├─ database/
│  ├─ external/
│  └─ internal/
├─ infra/
│  ├─ nginx/
│  ├─ docker/
│  ├─ vmware/
│  └─ scripts/
├─ storage/
│  ├─ quarantine/
│  ├─ approved-external/
│  └─ internal-review/
├─ docs/
│  ├─ architecture/
│  ├─ api/
│  ├─ security/
│  ├─ testing/
│  ├─ reports/
│  └─ rules/
├─ .github/
├─ docker-compose.yml
├─ README.md
├─ SECURITY.md
└─ .env (ignored)
```

---

## 문서 기준선 (Source of Truth)

문서 참조 충돌을 막기 위해 아래 문서를 기준선으로 사용합니다.

- [docs/DOCSET_BASELINE.md](docs/DOCSET_BASELINE.md): 정본 문서 세트, 우선순위, 아카이브 정책
- [docs/TERMINOLOGY.md](docs/TERMINOLOGY.md): 용어/네이밍 표준
- [docs/rules/GIT_COLLABORATION_RULES.md](docs/rules/GIT_COLLABORATION_RULES.md): 협업 브랜치/커밋/병합 기준
- [docs/rules/PR_CHECKLIST.md](docs/rules/PR_CHECKLIST.md): PR 품질 게이트 체크리스트
- [docs/security/SECURITY_BASELINE.md](docs/security/SECURITY_BASELINE.md): 세션/토큰/보안 헤더 기준
- [docs/testing/TEST_STRATEGY.md](docs/testing/TEST_STRATEGY.md): 테스트 범위/비율/게이트 기준
- [docs/archive/README.md](docs/archive/README.md): 구버전 문서 보관 규칙

---

## 문서 읽는 순서

처음 보는 사람은 아래 순서로 읽는 것을 권장합니다.

1. `docs/architecture/PLANNING.md`
   - 프로젝트 목적, 범위, 기술 스택, 보안 검증 방향

2. `docs/architecture/ARCHITECTURE.md`
   - 계층 구조, 데이터 소유권, 파일 검역 흐름, 서비스 간 호출 원칙, 실제 폴더 구조

3. `docs/architecture/ROADMAP.md`
   - 역할 분담, Phase, WBS, 완료 기준, 배포 준비

4. `docs/architecture/PAGE_STRUCTURE.md`
   - 공개 웹 / 내부 그룹웨어 라우트 구조, MVP 페이지, 권한 경계

5. `docs/api/API.md`
   - API 경계, 인증 규칙, CSRF, 파일 상태 API, 응답 포맷

6. `docs/api/openapi.yaml`
   - 실제 OpenAPI 계약 초안

7. 상세 페이지 명세
   - `docs/architecture/pages/external/CAREER_APPLY.md`
   - `docs/architecture/pages/external/MYPAGE_APPLICATIONS.md`
   - `docs/architecture/pages/external/SUPPORT_NEW.md`
   - `docs/architecture/pages/external/SUPPORT_ME.md`
   - `docs/architecture/pages/external/PAGE_SPEC_TEMPLATE.md`

8. 계약/경로 정리 문서
   - `docs/api/ENDPOINT_STANDARDIZATION_PLAN.md`
   - `docs/reports/API_CONTRACT_SYNC_CHECKLIST.md`

9. 내부 상세 페이지 명세
   - `docs/architecture/pages/internal/PAGE_SPEC_TEMPLATE_PRIVATE.md`
   - `docs/architecture/pages/internal/APPLICANT_DETAIL_INTERNAL.md`
   - `docs/architecture/pages/internal/SUPPORT_TICKET_DETAIL_INTERNAL.md`

10. DB 스키마 초안

   - `database/README.md`
   - `database/external/schema/V1__external_core.sql`
   - `database/internal/schema/V1__internal_core.sql`

11. 협업 규칙

   - `docs/rules/GIT_COLLABORATION_RULES.md`
   - `docs/rules/PR_CHECKLIST.md`

12. 보안 운영 기준

   - `docs/security/SECURITY_BASELINE.md`

13. 테스트 전략

   - `docs/testing/TEST_STRATEGY.md`

---

## 현재 설계된 주요 화면

### 공개 웹 서비스

- 로그인 / 회원가입
- 비밀번호 재설정
- 뉴스 / 공지사항
- 자료실
- 고객센터 문의 등록 / 내 문의 목록
- 채용 공고 목록 / 상세 / 지원서 제출
- 마이페이지 / 내 지원 내역
- 공통 에러 페이지 (`/403`, `/404`, `/500`, `/error`)

### 내부 그룹웨어

- 내부 로그인
- 대시보드
- 사내 공지
- 사원 디렉토리
- 전자결재
- 지원자 검토
- 고객 문의 대응
- 공개 사용자 관리
- 파일 검역 로그
- 감사 로그

---

## 보안 검증 범위

이 프로젝트는 아래 항목을 주요 검증 포인트로 삼습니다.

- 인증
- 세션
- 인가 (BOLA / IDOR 포함)
- 관리자 기능 보호
- 파일 업로드 / 다운로드 처리
- Path Traversal
- CSRF
- 공개 서비스와 내부 그룹웨어 간 경계
- 검역 / 차단 / 격리 정책
- 하드닝 전후 보안 수준 비교

---

## 진행 상태

현재 저장소는 다음 단계를 진행 중입니다.

- [x] 프로젝트 기획 정리
- [x] 아키텍처 문서화
- [x] 실행 로드맵 정리
- [x] 페이지 구조 및 공개 웹 주요 페이지 상세 명세 작성
- [x] 내부 그룹웨어 핵심 페이지 상세 명세 1차 작성
- [x] API 설계 문서 작성
- [x] OpenAPI 골격 작성
- [x] API 계약과 OpenAPI 완전 동기화
- [x] DB 스키마 코어 초안 작성
- [x] DB 인덱스 / cross-DB 참조 무결성 전략 초안 보강
- [x] 협업 Git/PR 규칙 문서 정리
- [x] CI 기반 OpenAPI lint / drift check 자동화
- [x] 세션/서비스 토큰/HTTP 보안 헤더 정책 문서화
- [x] 테스트 전략 문서화
- [ ] 초기 MVP 구현
- [ ] 보안 검증 및 하드닝
- [ ] 배포 및 공개 준비

---

## 주의 사항

- 이 저장소는 방어적 보안 검증과 구조 개선을 위한 프로젝트입니다.
- 실제 악성코드 배포나 외부 대상 공격을 목적으로 하지 않습니다.
- 파일 검역 및 “테스트 페이로드” 평가는 승인된 폐쇄형 실습 환경에서만 수행하는 것을 전제로 합니다.

---

## 향후 계획

- 내부 그룹웨어 상세 페이지 명세 완료
- OpenAPI 계약 보완 및 동기화
- MVP 구현 착수
- 검역 로그 시각화 화면 구현
- 하드닝 전/후 비교 보고서 정리
- 실행 가능한 공개 템플릿 배포

---

## License

MIT License
