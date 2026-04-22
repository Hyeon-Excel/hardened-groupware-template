# TERMINOLOGY.md

## 1. 목적

본 문서는 저장소 전반의 용어를 일관되게 유지하기 위한 기준이다.

---

## 2. 핵심 용어

### 2.1 서비스 경계

| 용어 | 정의 |
| --- | --- |
| `external-web` | 공개 웹 프론트엔드 |
| `external-api` | 공개 웹 백엔드 API |
| `internal-web` | 내부 그룹웨어 프론트엔드 |
| `internal-api` | 내부 그룹웨어 백엔드 API |

### 2.2 데이터/스토리지 용어

| 용어 | 정의 |
| --- | --- |
| `external_db` | 공개 서비스 전용 DB |
| `internal_db` | 내부 그룹웨어 전용 DB |
| `uploaded_file` | 파일 메타/상태를 저장하는 owner DB 테이블 |
| `raw/*` | 업로드 직후 파일 prefix |
| `approved/*` | 사용 허용 파일 prefix |
| `rejected/*` | 차단 파일 prefix |
| `storage_key` | 오브젝트 스토리지 내 파일 경로 키 |

주의:

- `quarantine_storage`, `approved_external_storage`, `internal_review_storage`는 legacy 표현으로 더 이상 정본에서 사용하지 않는다.
- 파일 바이트 저장은 단일 오브젝트 스토리지, 보안 통제는 `scan_status` 상태값으로 표현한다.

### 2.3 파일 상태 용어

파일 상태 의미:

| 상태 | 의미 | 공개 UI 배지 문구 |
| --- | --- | --- |
| `PENDING` | 스캔 대기 | 접수됨 |
| `SCANNING` | 스캔 진행 중 | 보안 검사 중 |
| `APPROVED` | 사용 허용 | 사용 가능 |
| `REJECTED` | 정책/스캔 결과로 차단 | 처리 제한 |
| `FAILED` | 처리 실패(재시도 대상 가능) | 검사 실패(제한) |

공개 UI 배지 기본 문구(문의 상태):

| 상태 | 표시 문구 |
| --- | --- |
| `RECEIVED` | 접수됨 |
| `REVIEWING` | 검토 중 |
| `ANSWERED` | 답변 완료 |
| `CLOSED` | 처리 종료 |

공개 UI 배지 기본 문구(지원 상태):

| 상태 | 표시 문구 |
| --- | --- |
| `SUBMITTED` | 접수 완료 |
| `REVIEWING` | 검토 중 |
| `PASSED` | 합격 |
| `REJECTED` | 불합격 |

v0 기본값:

- `scan_status='APPROVED'`
- `scan_result_code='V0_SCAN_DISABLED'`

### 2.4 공개 파일 상태 사유 코드

공개 API(`ExternalFileStatusResponse.reason`, `ExternalSupportTicketDetailResponse.fileStatusReason`)는 아래 일반화 코드만 사용한다.

| 코드 | 의미 |
| --- | --- |
| `REVIEW_PENDING` | 아직 처리 대기/진행 중 |
| `POLICY_RESTRICTED` | 정책상 공개 사용자 제공 제한 |
| `SCAN_FAILED` | 검사 실패 또는 검사 엔진 오류 |
| `TEMPORARY_UNAVAILABLE` | 일시적 처리 불가(재시도 필요) |

내부 탐지 상세 코드/시그니처는 내부 API와 운영 로그에서만 사용한다.

### 2.5 공개 scan_result_code 사용 규칙

공개 API의 `scanResultCode`는 내부 엔진 상세값을 직접 노출하지 않는다.

| 코드 | 사용 시점 |
| --- | --- |
| `V0_SCAN_DISABLED` | v0 기준선(스캔 비활성) |
| `PUBLIC_SCAN_RESULT_UNAVAILABLE` | v1에서 외부 사용자에게 상세 결과를 마스킹할 때 |
| `null` | 첨부 없음, 스캔 전, 또는 노출 불필요 |

내부 운영/감사용 상세 코드는 내부 API(`InternalFileStatusResponse`)와 운영 로그에서만 사용한다.

---

## 3. API 경계 용어

| 용어 | 정의 |
| --- | --- |
| External User API | 외부 일반 사용자가 호출하는 공개 API |
| Internal Groupware API | 임직원/관리자용 내부 API |
| External Admin Internal API | 내부 서비스가 공개 데이터를 관리할 때 호출하는 internal 전용 API |

---

## 4. 상태값 표기 원칙

1. 상태 enum은 영문 대문자 사용
2. UI 노출 문구는 한국어 단순 표현 사용
3. 내부 탐지 정책/시그니처는 공개 UI에 노출하지 않음

---

## 5. 변경 이력

- 2026-04-16: 문서 최초 생성
- 2026-04-20: 단일 오브젝트 스토리지 + `uploaded_file` 상태 머신 용어로 개편
