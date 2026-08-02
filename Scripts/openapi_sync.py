#!/usr/bin/env python3
"""Synchronize and verify the iOS OpenAPI artifact against immutable backend provenance."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import tempfile
from pathlib import Path


SCHEMA_VERSION = 1


def fail(message: str) -> None:
    raise SystemExit(f"FAIL: {message}")


def read_json(path: Path) -> object:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"invalid JSON at {path}: {error}")


def byte_sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def semantic_sha256(value: object) -> str:
    canonical = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def write_atomic(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as temporary:
        temporary.write(content)
        temporary.write("\n")
        temporary_path = Path(temporary.name)
    os.replace(temporary_path, path)


def valid_commit(value: str) -> bool:
    return len(value) == 40 and all(character in "0123456789abcdef" for character in value)


def sync(arguments: argparse.Namespace) -> None:
    backend_file = Path(arguments.backend_file)
    ios_file = Path(arguments.ios_file)
    provenance_file = Path(arguments.provenance)
    backend = read_json(backend_file)
    if not valid_commit(arguments.backend_commit):
        fail("backend commit must be a lowercase 40-character SHA")
    backend_byte_digest = byte_sha256(backend_file)
    backend_semantic_digest = semantic_sha256(backend)
    write_atomic(ios_file, json.dumps(backend, indent=2, ensure_ascii=False))
    provenance = {
        "schemaVersion": SCHEMA_VERSION,
        "backendRepository": arguments.backend_repository,
        "backendCommit": arguments.backend_commit,
        "backendArtifactByteSha256": backend_byte_digest,
        "backendArtifactSemanticSha256": backend_semantic_digest,
    }
    write_atomic(provenance_file, json.dumps(provenance, indent=2, sort_keys=True))
    print(
        "PASS sync"
        f" backend-commit={arguments.backend_commit}"
        f" backend-byte-sha256={backend_byte_digest}"
        f" semantic-sha256={backend_semantic_digest}"
    )


def check(arguments: argparse.Namespace) -> None:
    backend_file = Path(arguments.backend_file)
    ios_file = Path(arguments.ios_file)
    provenance_file = Path(arguments.provenance)
    backend = read_json(backend_file)
    ios = read_json(ios_file)
    provenance = read_json(provenance_file)
    if not isinstance(provenance, dict):
        fail("provenance must be an object")
    required = {
        "schemaVersion": SCHEMA_VERSION,
        "backendRepository": arguments.backend_repository,
        "backendCommit": arguments.expected_backend_commit,
        "backendArtifactByteSha256": byte_sha256(backend_file),
        "backendArtifactSemanticSha256": semantic_sha256(backend),
    }
    for key, expected in required.items():
        if provenance.get(key) != expected:
            fail(f"provenance {key} mismatch")
    if not valid_commit(provenance["backendCommit"]):
        fail("provenance backendCommit is not an exact SHA")
    ios_semantic_digest = semantic_sha256(ios)
    if ios_semantic_digest != required["backendArtifactSemanticSha256"]:
        fail("semantic OpenAPI drift")
    print(
        "PASS check"
        f" backend-commit={provenance['backendCommit']}"
        f" backend-byte-sha256={required['backendArtifactByteSha256']}"
        f" semantic-sha256={ios_semantic_digest}"
    )


def self_test() -> None:
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        backend = root / "backend.json"
        ios = root / "ios.json"
        provenance = root / "source.json"
        backend.write_text('{"openapi":"3.1.0","info":{"title":"Worth It"}}\n', encoding="utf-8")
        values = argparse.Namespace(
            backend_file=str(backend), ios_file=str(ios), provenance=str(provenance),
            backend_repository="kudg0/assets-invest-comparator",
            backend_commit="0" * 40,
        )
        sync(values)
        ios.write_text('{"openapi":"3.1.0","info":{"title":"Drift"}}\n', encoding="utf-8")
        check_values = argparse.Namespace(**vars(values), expected_backend_commit="0" * 40)
        try:
            check(check_values)
        except SystemExit as error:
            if "semantic OpenAPI drift" not in str(error):
                raise
        else:
            fail("self-test drift did not fail")
        sync(values)
        check(check_values)
    print("PASS self-test drift-fails-and-resync-recovers")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser()
    commands = result.add_subparsers(dest="command", required=True)
    for name in ("sync", "check"):
        command = commands.add_parser(name)
        command.add_argument("--backend-file", required=True)
        command.add_argument("--ios-file", default="Sources/WorthItAPI/openapi.json")
        command.add_argument("--provenance", default="Sources/WorthItAPI/openapi-source.json")
        command.add_argument("--backend-repository", required=True)
        if name == "sync":
            command.add_argument("--backend-commit", required=True)
        else:
            command.add_argument("--expected-backend-commit", required=True)
    commands.add_parser("self-test")
    return result


def main() -> None:
    arguments = parser().parse_args()
    if arguments.command == "sync":
        sync(arguments)
    elif arguments.command == "check":
        check(arguments)
    else:
        self_test()


if __name__ == "__main__":
    main()
