#!/usr/bin/env python3
"""Check method+path drift between docs/api/API.md and docs/api/openapi.yaml."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

HTTP_METHODS = ("GET", "POST", "PUT", "PATCH", "DELETE")
HTTP_METHODS_LOWER = tuple(m.lower() for m in HTTP_METHODS)

API_MD_PATTERN = re.compile(r"`(?P<method>GET|POST|PUT|PATCH|DELETE)\s+(?P<path>/api/[^`\s]+)`")
OPENAPI_PATH_PATTERN = re.compile(r"^  (?P<path>/api/[^:\s]+):\s*$")
OPENAPI_METHOD_PATTERN = re.compile(r"^    (?P<method>get|post|put|patch|delete):\s*$")


def normalize_path(path: str) -> str:
    return path.split("?", 1)[0]


def collect_api_md_routes(api_md_path: Path) -> set[tuple[str, str]]:
    text = api_md_path.read_text(encoding="utf-8")
    routes: set[tuple[str, str]] = set()
    for match in API_MD_PATTERN.finditer(text):
        method = match.group("method")
        path = normalize_path(match.group("path"))
        if method in HTTP_METHODS and path.startswith("/api/"):
            routes.add((method, path))
    return routes


def collect_openapi_routes(openapi_path: Path) -> set[tuple[str, str]]:
    routes: set[tuple[str, str]] = set()
    current_path: str | None = None
    for line in openapi_path.read_text(encoding="utf-8").splitlines():
        path_match = OPENAPI_PATH_PATTERN.match(line)
        if path_match:
            current_path = path_match.group("path")
            continue

        method_match = OPENAPI_METHOD_PATTERN.match(line)
        if method_match and current_path is not None:
            method = method_match.group("method").upper()
            if method.lower() in HTTP_METHODS_LOWER:
                routes.add((method, current_path))
    return routes


def format_routes(routes: set[tuple[str, str]]) -> str:
    return "\n".join(f"- {method} {path}" for method, path in sorted(routes))


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Compare API method+path sets between API.md and openapi.yaml."
    )
    parser.add_argument(
        "--api-md",
        default="docs/api/API.md",
        help="Path to API.md document (default: docs/api/API.md)",
    )
    parser.add_argument(
        "--openapi",
        default="docs/api/openapi.yaml",
        help="Path to OpenAPI document (default: docs/api/openapi.yaml)",
    )
    args = parser.parse_args()

    api_md_path = Path(args.api_md)
    openapi_path = Path(args.openapi)

    if not api_md_path.exists():
        print(f"ERROR: API.md not found: {api_md_path}")
        return 2
    if not openapi_path.exists():
        print(f"ERROR: OpenAPI file not found: {openapi_path}")
        return 2

    api_md_routes = collect_api_md_routes(api_md_path)
    openapi_routes = collect_openapi_routes(openapi_path)

    only_in_api_md = api_md_routes - openapi_routes
    only_in_openapi = openapi_routes - api_md_routes

    print(f"API.md unique method+path: {len(api_md_routes)}")
    print(f"OpenAPI unique method+path: {len(openapi_routes)}")

    if not only_in_api_md and not only_in_openapi:
        print("PASS: API.md and OpenAPI are fully synchronized.")
        return 0

    print("FAIL: Drift detected between API.md and OpenAPI.")
    if only_in_api_md:
        print("\nOnly in API.md:")
        print(format_routes(only_in_api_md))
    if only_in_openapi:
        print("\nOnly in OpenAPI:")
        print(format_routes(only_in_openapi))
    return 1


if __name__ == "__main__":
    sys.exit(main())
