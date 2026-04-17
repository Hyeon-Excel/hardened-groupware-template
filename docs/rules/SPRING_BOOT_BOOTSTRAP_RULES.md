# SPRING_BOOT_BOOTSTRAP_RULES.md

## 1. 목적

`external-api`와 `internal-api`를 서로 다른 방식으로 초기 생성하면,
초기부터 빌드/보안/운영 기준이 갈라져 유지보수 비용이 급증한다.

본 문서는 두 서비스의 Spring Boot 초기 생성 기준을 고정하기 위한 정본 규칙이다.

---

## 2. 적용 범위

- `apps/external-api`
- `apps/internal-api`

---

## 3. 공통 생성 기준 (필수)

아래 항목은 두 서비스에서 반드시 동일하게 맞춘다.

| 항목                     | 기준 |
| ------------------------ | ---- |
| Java Version             | 17 |
| Spring Boot              | 3.x (동일 patch/minor 강제) |
| Build Tool               | Maven Wrapper (`./mvnw`) |
| Packaging                | Jar |
| Charset / Locale         | UTF-8 / `Asia/Seoul` |
| DB Migration             | Flyway |
| API Contract             | OpenAPI-first (`docs/api/openapi.yaml`) |

### 3.1 Starter 의존성 기준 (필수)

두 서비스 모두 아래 Starter를 기본 포함한다.

- `spring-boot-starter-web`
- `spring-boot-starter-validation`
- `spring-boot-starter-security`
- `spring-boot-starter-data-jpa`
- `spring-boot-starter-actuator`
- `flyway-core`
- `mariadb-java-client`
- `spring-boot-starter-test`

선택 의존성(`lombok`, `devtools`)은 써도 되지만, 사용할 경우 두 서비스에 동시에 반영한다.

---

## 4. 서비스별 고정 식별자

| 서비스 | Group ID | Artifact ID | Base Package |
| ------ | -------- | ----------- | ------------ |
| external-api | `com.hgt` | `external-api` | `com.hgt.externalapi` |
| internal-api | `com.hgt` | `internal-api` | `com.hgt.internalapi` |

규칙:

- Group ID는 고정한다.
- Artifact ID는 서비스명과 일치시킨다.
- Base Package 네이밍 패턴은 동일하게 유지한다.

---

## 5. 초기 디렉터리 구조 기준

두 서비스는 아래 계층을 동일하게 생성한다.

```text
src/main/java/com/hgt/{service}/
├─ common/
├─ config/
├─ auth/
├─ domain/
├─ application/
├─ infrastructure/
└─ api/
```

초기 생성 시점에는 비어 있어도 괜찮지만, 폴더 구조는 동일하게 맞춘다.

---

## 6. 설정 파일 기준

두 서비스 모두 아래 파일을 동일한 패턴으로 둔다.

- `src/main/resources/application.yml`
- `src/main/resources/application-local.yml`
- `src/main/resources/application-test.yml`
- `src/main/resources/db/migration/`

정책:

- 민감 정보는 커밋하지 않는다.
- 환경별 차이는 profile 파일로만 분기한다.

---

## 7. 생성 순서 (권장 절차)

1. `external-api`를 기준 템플릿으로 생성한다.
2. 동일 옵션으로 `internal-api`를 생성한다.
3. 두 프로젝트의 `pom.xml`을 diff 비교해 서비스 식별자(artifact/base package) 외 차이가 없는지 확인한다.
4. 두 서비스 모두 `./mvnw test`가 통과하는 상태에서 첫 커밋한다.

---

## 8. 생성 완료 Definition of Done

아래를 모두 만족하면 “동일 규칙 생성 완료”로 본다.

- 두 서비스가 동일 Java/Spring Boot 버전을 사용한다.
- 두 서비스의 필수 Starter 구성이 일치한다.
- 두 서비스가 동일 디렉터리 계층을 가진다.
- 두 서비스에 profile 설정 파일이 준비된다.
- 두 서비스에서 기본 테스트가 통과한다.

---

## 9. 예외 처리 규칙

한 서비스에만 의존성을 추가해야 하는 경우, 바로 추가하지 않고 아래 순서로 진행한다.

1. 이유를 `docs/architecture/ARCHITECTURE.md` 또는 해당 기능 문서에 명시한다.
2. 본 문서(부트스트랩 규칙) “예외 이력”에 기록한다.
3. PR에서 차이점과 영향 범위를 리뷰한다.

---

## 10. 예외 이력

- (없음)

---

## 11. 변경 이력

- 2026-04-17: 문서 최초 생성 (external/internal Spring Boot 공통 생성 기준 확정)
