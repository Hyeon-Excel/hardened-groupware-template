# docs/archive

이 디렉터리는 구버전 문서를 보관하는 아카이브 영역이다.

## 사용 규칙

1. 현재 정본 문서와 역할이 겹치는 문서만 이동한다.
2. 파일명에 날짜와 상태를 포함한다.
   - 예: `ROADMAP_2026-04-16_pre-baseline.md`
3. 아카이브 문서 상단에 아래 메타를 기록한다.

```text
Status: archived
Archived-At: YYYY-MM-DD
Replaced-By: docs/...
Reason: baseline consolidation
```

4. 아카이브 문서는 신규 작업의 참조 기준으로 사용하지 않는다.
5. 참조 기준은 항상 [docs/DOCSET_BASELINE.md](../DOCSET_BASELINE.md)를 따른다.
