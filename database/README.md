# database

이 디렉터리는 초기 DB 스키마 초안과 데이터 무결성 규칙을 관리한다.

## 구조

- `external/schema`: 공개 서비스 전용 DB 스키마
- `internal/schema`: 내부 그룹웨어 전용 DB 스키마

DB 운영 원칙:

- 데이터베이스는 `external_db`, `internal_db` 두 개만 사용한다.
- 파일은 단일 오브젝트 스토리지에 저장하고, prefix(`raw/`, `approved/`, `rejected/`)로 논리 구역을 분리한다.
- 파일 바이트는 DB에 저장하지 않고, 메타데이터/상태만 `uploaded_file` 테이블에 저장한다.

## 현재 포함 파일

- `external/schema/V1__external_core.sql`
- `internal/schema/V1__internal_core.sql`

## 스키마 운영 기준

### 1) 인덱스 기준

- 로그인/인증 식별자, 상태값, 생성일시, 폴링 대상 컬럼에는 기본 인덱스를 둔다.
- 파일 상태 테이블(`uploaded_file`)은 `scan_status + uploaded_at` 인덱스를 필수로 둔다.
- 고빈도 목록 조회 API에서 사용하는 `(status, created_at)` 패턴을 우선 인덱싱한다.

### 1.1 uploaded_file 공통 필드 기준

external/internal DB의 `uploaded_file`은 아래 필드를 공통 사용한다.

- `id`, `owner_id`, `storage_key`
- `original_filename`, `mime_type`, `size_bytes`, `sha256`
- `scan_status` (`PENDING`, `SCANNING`, `APPROVED`, `REJECTED`, `FAILED`)
- `scan_result_code`, `scan_engine`, `scanner_version`
- `last_error`, `retry_count`
- `uploaded_at`, `scanned_at`, `created_at`, `updated_at`

v0 기본값 규칙:

- `scan_status='APPROVED'`
- `scan_result_code='V0_SCAN_DISABLED'`

### 2) Cross-DB 참조 무결성 기준

`external_db`와 `internal_db` 간 직접 FK는 사용할 수 없으므로 아래 전략을 사용한다.

1. `internal-api`는 외부 엔티티 참조 전에 `external-api` 내부 API로 존재성/상태를 검증한다.
2. 검증된 외부 식별자는 `internal_db`의 참조 미러 테이블에 upsert 한다.
   - `external_application_refs`
   - `external_support_ticket_refs`
3. 내부 업무 테이블은 미러 테이블을 FK로 참조해 로컬 무결성을 보장한다.
   - `applicant_notes.application_id -> external_application_refs.application_id`
   - `support_ticket_replies.ticket_id -> external_support_ticket_refs.ticket_id`
4. 배치 재동기화 작업으로 미러 테이블 정합성을 주기적으로 점검한다.

### 3) 감사 로그 JSON 기준

- `audit_logs.metadata_json`은 JSON 타입으로 저장한다.
- 감사 이벤트 스키마 버전(`schemaVersion`) 필드를 메타데이터에 포함하는 것을 권장한다.

## 주의

- 본 스키마는 구현 시작 전 합의를 위한 초안이다.
- 실제 마이그레이션 도구(Flyway/Liquibase) 도입 시 파일명 규칙과 타입 정의를 최종 확정한다.
