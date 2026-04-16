# TERMINOLOGY.md

## 1. 목적

본 문서는 문서 전반에서 사용하는 핵심 용어를 일관되게 유지하기 위한 기준이다.

---

## 2. 핵심 용어

### 2.1 서비스 경계

| 용어         | 정의                            |
| ------------ | ------------------------------- |
| external-web   | 공개 웹 프론트엔드              |
| external-api   | 공개 웹 백엔드 API              |
| internal-web | 내부 그룹웨어 프론트엔드        |
| internal-api | 내부 그룹웨어 백엔드 API        |
| file-worker  | 파일 검역/정책 검사 비동기 워커 |

### 2.2 저장소(논리 명칭)

| 용어                    | 정의                                 |
| ----------------------- | ------------------------------------ |
| quarantine_storage      | 외부 업로드 원본의 검역 대기 저장소  |
| approved_external_storage | 검역 통과 후 공개 배포 가능한 저장소 |
| internal_review_storage | 검역 통과 후 내부 검토 가능한 저장소 |

주의:

- `external_upload_storage`는 비권장(legacy) 표현이며 정본 문서에서는 사용하지 않는다.
- 문서에는 위 3개 논리 명칭을 우선 사용한다.

### 2.3 저장소(물리 경로)

| 물리 디렉터리             | 대응 논리 명칭            |
| ------------------------- | ------------------------- |
| `storage/quarantine`      | `quarantine_storage`      |
| `storage/approved-external` | `approved_external_storage` |
| `storage/internal-review` | `internal_review_storage` |

---

## 3. API 경계 용어

| 용어                      | 정의                                                         |
| ------------------------- | ------------------------------------------------------------ |
| External User API           | 외부 일반 사용자가 호출하는 공개 API                         |
| Internal Groupware API    | 임직원/관리자용 내부 API                                     |
| External Admin Internal API | 내부 서비스가 공개 데이터를 관리할 때 사용하는 내부 전용 API |

---

## 4. 상태값 표기 원칙

1. 상태 enum은 영문 대문자 스네이크/단어 조합을 사용한다.
2. 사용자 노출 문구는 한국어로 단순화한다.
3. 내부 탐지 정책/시그니처는 공개 UI에 노출하지 않는다.

### 4.1 지원서 상태값 구분

지원서(`career_applications`)의 상태값은 **생성 시점 상태**와 **관리자 변경 가능 상태**를 구분한다.

| 상태 | 설정 주체 | 설명 |
| --- | --- | --- |
| `SUBMITTED` | 시스템(생성 시 기본값) | 지원서 최초 제출 시 자동 부여. API를 통한 상태 변경 대상이 아님 |
| `RECEIVED` | 관리자 | 접수 확인 완료 |
| `REVIEWING` | 관리자 | 검토 진행 중 |
| `PASSED` | 관리자 | 합격 |
| `REJECTED` | 관리자 | 불합격 |

즉, `SUBMITTED`는 DB 기본값 전용이며 `PATCH .../status` API의 변경 가능 enum에는 포함되지 않는다.

---

## 5. 변경 이력

- 2026-04-16: 용어 기준 문서 최초 생성
- 2026-04-16: 지원서 상태값 구분(SUBMITTED vs 관리자 변경 상태) 추가
