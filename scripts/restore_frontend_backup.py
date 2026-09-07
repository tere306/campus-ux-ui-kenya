#!/usr/bin/env python3
"""Restore a Campus UX/UI frontend backup stored as ordered Base64/GZIP parts."""

from __future__ import annotations

import argparse
import base64
import gzip
import hashlib
from pathlib import Path

EXPECTED_SOURCE_SHA256 = "7e97173d39f5cf70d6994c4ad7b83f20046cb319d1993ce9e3b58a0e1e3ab6e8"
EXPECTED_GZIP_SHA256 = "d330b2bcf4605340756ba48e6b6ba17537cae139a80c6e57f5984eaf9725dabf"


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("backup_dir", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    parts = sorted(args.backup_dir.glob("part-*.b64"))
    if len(parts) != 12:
        raise SystemExit(f"Expected 12 backup parts, found {len(parts)}")

    encoded = "".join(p.read_text(encoding="utf-8").strip() for p in parts)
    compressed = base64.b64decode(encoded, validate=True)

    gzip_hash = sha256(compressed)
    if gzip_hash != EXPECTED_GZIP_SHA256:
        raise SystemExit(f"GZIP SHA-256 mismatch: {gzip_hash} != {EXPECTED_GZIP_SHA256}")

    source = gzip.decompress(compressed)
    source_hash = sha256(source)
    if source_hash != EXPECTED_SOURCE_SHA256:
        raise SystemExit(f"Source SHA-256 mismatch: {source_hash} != {EXPECTED_SOURCE_SHA256}")

    args.output.write_bytes(source)
    print(f"Restored {args.output} ({len(source)} bytes)")
    print(f"SHA-256: {source_hash}")


if __name__ == "__main__":
    main()
