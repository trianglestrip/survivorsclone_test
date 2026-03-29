#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
用 Pillow 校验增强后的技能动画 PNG：可打开、含透明通道、尺寸与 backup 一致。
不依赖 Godot。运行前请已执行: pip install Pillow
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

if sys.platform == "win32":
    import io

    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8")

REPO_ROOT = Path(__file__).resolve().parent.parent
ANIM_DIR = REPO_ROOT / "Textures" / "Skills" / "Animations"
BACKUP_DIR = ANIM_DIR / "backup"
PREFIXES = ("ice_", "thunder_", "fire_", "poison_")


def main() -> int:
    if not ANIM_DIR.is_dir():
        print(f"目录不存在: {ANIM_DIR}")
        return 1
    def _is_skill_png(name: str) -> bool:
        n = name.lower()
        return any(n.startswith(p) for p in PREFIXES)

    files = sorted(p for p in ANIM_DIR.iterdir() if p.is_file() and p.suffix.lower() == ".png" and _is_skill_png(p.name))
    if not files:
        print("未找到技能动画 PNG。")
        return 1
    errors = 0
    for path in files:
        try:
            with Image.open(path) as im:
                im.load()
                if im.mode not in ("RGBA", "RGB", "P", "LA"):
                    print(f"[WARN] {path.name}: 模式 {im.mode}")
                rgba = im.convert("RGBA")
                a = rgba.split()[3]
                extrema = a.getextrema()
                if extrema == (255, 255):
                    print(f"[WARN] {path.name}: Alpha 全不透明（可能正常）")
                backup = BACKUP_DIR / path.name
                if backup.is_file():
                    with Image.open(backup) as b:
                        if b.size != im.size:
                            print(f"[FAIL] {path.name}: 尺寸与 backup 不一致 {im.size} vs {b.size}")
                            errors += 1
        except Exception as e:  # noqa: BLE001
            print(f"[FAIL] {path.name}: {e}")
            errors += 1
    print(f"校验完成: {len(files)} 个文件, 错误 {errors}")
    return 0 if errors == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())
