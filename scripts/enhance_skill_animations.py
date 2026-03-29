#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量增强技能动画帧 PNG：按宗派调整颜色、对比度与高光，保留尺寸与 Alpha。
始终从 backup/ 中的原始文件读取（若尚无备份则先复制），避免重复叠加效果。
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image, ImageChops, ImageEnhance, ImageFilter, ImageOps

if sys.platform == "win32":
    import io

    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8")

REPO_ROOT = Path(__file__).resolve().parent.parent
ANIM_DIR = REPO_ROOT / "Textures" / "Skills" / "Animations"
BACKUP_DIR = ANIM_DIR / "backup"
REPORT_PATH = REPO_ROOT / "docs" / "ANIMATION_ENHANCEMENT_REPORT.md"

FRAME_RE = re.compile(r"_frame_(\d+)\.png$", re.IGNORECASE)


def ensure_rgba(img: Image.Image) -> Image.Image:
    if img.mode in ("RGBA", "LA"):
        return img.convert("RGBA") if img.mode == "LA" else img
    if img.mode == "P":
        return img.convert("RGBA")
    return img.convert("RGBA")


def merge_rgba(rgb: Image.Image, alpha: Image.Image) -> Image.Image:
    r, g, b = rgb.split()
    return Image.merge("RGBA", (r, g, b, alpha))


def frame_index_from_name(name: str) -> int:
    m = FRAME_RE.search(name)
    return int(m.group(1)) if m else 0


def enhance_ice(img: Image.Image) -> Image.Image:
    """冰心宗：偏蓝提亮、白色高光，保留透明度。"""
    img = ensure_rgba(img)
    r, g, b, a = img.split()
    r = r.point(lambda x: min(255, int(x * 1.08)))
    g = g.point(lambda x: min(255, int(x * 1.14)))
    b = b.point(lambda x: min(255, int(x * 1.26)))
    rgb = Image.merge("RGB", (r, g, b))
    rgb = ImageEnhance.Brightness(rgb).enhance(1.18)
    lum = ImageOps.grayscale(rgb)
    mask_bright = lum.point(lambda p: min(255, max(0, (p - 155) * 5)))
    mask_bright = mask_bright.filter(ImageFilter.GaussianBlur(1.2))
    white = Image.new("RGB", img.size, (245, 250, 255))
    black = Image.new("RGB", img.size, (0, 0, 0))
    hi = ImageChops.screen(rgb, Image.composite(white, black, mask_bright))
    rgb = Image.blend(rgb, hi, 0.30)
    return merge_rgba(rgb, a)


def enhance_thunder(img: Image.Image) -> Image.Image:
    """雷鸣宗：提高饱和度与对比度，黄边电光。"""
    img = ensure_rgba(img)
    r, g, b, a = img.split()
    rgb = Image.merge("RGB", (r, g, b))
    rgb = ImageEnhance.Color(rgb).enhance(1.25)
    rgb = ImageEnhance.Contrast(rgb).enhance(1.14)
    edges = rgb.filter(ImageFilter.FIND_EDGES).convert("L")
    edges = edges.point(lambda p: min(255, int(p * 2.8)))
    edges = edges.filter(ImageFilter.GaussianBlur(0.9))
    yellow = Image.new("RGB", img.size, (255, 252, 110))
    black = Image.new("RGB", img.size, (0, 0, 0))
    edge_layer = Image.composite(yellow, black, edges)
    lit = ImageChops.screen(rgb, edge_layer)
    rgb = Image.blend(rgb, lit, 0.42)
    return merge_rgba(rgb, a)


def enhance_fire(img: Image.Image) -> Image.Image:
    """烈焰宗：对比度提升、黄色焰心、边缘暖色发光。"""
    img = ensure_rgba(img)
    r, g, b, a = img.split()
    rgb = Image.merge("RGB", (r, g, b))
    rgb = ImageEnhance.Contrast(rgb).enhance(1.30)
    lum = ImageOps.grayscale(rgb)
    core_mask = lum.point(lambda p: min(255, max(0, (p - 142) * 4)))
    core_mask = core_mask.filter(ImageFilter.GaussianBlur(1.9))
    yellow = Image.new("RGB", img.size, (255, 218, 72))
    black = Image.new("RGB", img.size, (0, 0, 0))
    core_glow = Image.composite(yellow, rgb, core_mask)
    rgb = Image.blend(rgb, core_glow, 0.36)
    edge_m = ImageOps.grayscale(rgb).filter(ImageFilter.FIND_EDGES).convert("L")
    edge_m = edge_m.point(lambda p: min(255, int(p * 2.2)))
    edge_m = edge_m.filter(ImageFilter.GaussianBlur(1.1))
    warm = Image.new("RGB", img.size, (255, 138, 55))
    glow = Image.composite(warm, black, edge_m)
    rgb = Image.blend(rgb, ImageChops.screen(rgb, glow), 0.34)
    return merge_rgba(rgb, a)


def enhance_poison(img: Image.Image, frame_index: int) -> Image.Image:
    """毒瘴宗：略增通透、暗绿阴影、轻微位移营造流动感。"""
    img = ensure_rgba(img)
    r, g, b, a = img.split()
    a = a.point(lambda x: int(min(255, max(0, round(x * 0.80)))) if x > 0 else 0)
    rgb = Image.merge("RGB", (r, g, b))
    lum = ImageOps.grayscale(rgb)
    shadow = lum.point(lambda p: min(255, max(0, (255 - p) * 180 // 255)))
    shadow = shadow.filter(ImageFilter.GaussianBlur(1.4))
    shadow = shadow.point(lambda p: int(p * 0.32))
    dark_green = Image.new("RGB", img.size, (28, 72, 38))
    rgb = Image.composite(dark_green, rgb, shadow)
    dx = (frame_index % 5) - 2
    smear = ImageChops.offset(rgb, dx, 0)
    rgb = Image.blend(rgb, smear, 0.14)
    return merge_rgba(rgb, a)


ENHANCERS = {
    "ice_": lambda im, fi: enhance_ice(im),
    "thunder_": lambda im, fi: enhance_thunder(im),
    "fire_": lambda im, fi: enhance_fire(im),
    "poison_": lambda im, fi: enhance_poison(im, fi),
}


def sect_for_filename(name: str) -> str | None:
    lower = name.lower()
    for prefix in ENHANCERS:
        if lower.startswith(prefix):
            return prefix.rstrip("_")
    return None


def list_target_pngs() -> list[Path]:
    if not ANIM_DIR.is_dir():
        return []
    out: list[Path] = []
    for p in sorted(ANIM_DIR.iterdir()):
        if p.is_file() and p.suffix.lower() == ".png":
            if sect_for_filename(p.name):
                out.append(p)
    return out


def resolve_source_path(dest: Path) -> Path:
    """优先使用已备份的原始文件作为输入。"""
    backup_copy = BACKUP_DIR / dest.name
    if backup_copy.is_file():
        return backup_copy
    return dest


def ensure_backup(dest: Path, dry_run: bool) -> None:
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    backup_copy = BACKUP_DIR / dest.name
    if backup_copy.is_file():
        return
    if dry_run:
        print(f"  [dry-run] 将备份: {dest.name}")
        return
    shutil.copy2(dest, backup_copy)


def process_one(dest: Path, dry_run: bool) -> dict:
    sect = sect_for_filename(dest.name)
    assert sect is not None
    prefix = sect + "_"
    fi = frame_index_from_name(dest.name)
    src = resolve_source_path(dest)
    stat: dict = {
        "file": dest.name,
        "sect": sect,
        "source": "backup" if src.parent == BACKUP_DIR else "inline",
        "ok": False,
        "error": "",
    }
    try:
        with Image.open(src) as im:
            im = im.copy()
            orig_size = im.size
            out = ENHANCERS[prefix](im, fi)
            if out.size != orig_size:
                stat["error"] = f"size changed {orig_size} -> {out.size}"
                return stat
            if out.mode != "RGBA":
                out = out.convert("RGBA")
            if dry_run:
                stat["ok"] = True
                return stat
            out.save(dest, format="PNG", optimize=True)
            stat["ok"] = True
    except Exception as e:  # noqa: BLE001 — 报告用
        stat["error"] = str(e)
    return stat


def write_report(rows: list[dict], dry_run: bool) -> None:
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    by_sect: dict[str, int] = defaultdict(int)
    ok = sum(1 for r in rows if r.get("ok"))
    fail = [r for r in rows if not r.get("ok")]
    for r in rows:
        if r.get("ok"):
            by_sect[r["sect"]] += 1
    ts = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    lines = [
        "# 技能动画帧增强处理报告",
        "",
        f"- **生成时间**: {ts}",
        f"- **模式**: {'dry-run（未写入）' if dry_run else '已写入 PNG'}",
        f"- **动画目录**: `Textures/Skills/Animations/`",
        f"- **备份目录**: `Textures/Skills/Animations/backup/`",
        "",
        "## 宗派处理策略摘要",
        "",
        "| 宗派 | 前缀 | 处理要点 |",
        "|------|------|----------|",
        "| 冰心宗 | `ice_` | 蓝通道与整体提亮约 20% 量级、冷色高光、保留 Alpha |",
        "| 雷鸣宗 | `thunder_` | 饱和度 +25%、对比度提升、黄边与边缘提亮 |",
        "| 烈焰宗 | `fire_` | 对比度 +30%、黄色焰心、暖色边缘发光 |",
        "| 毒瘴宗 | `poison_` | Alpha×0.8 增强通透、暗绿阴影、按帧轻微位移 |",
        "",
        "## 统计",
        "",
        f"- 成功: **{ok}** / 总计 {len(rows)}",
        "",
        "### 按宗派",
        "",
    ]
    for s in sorted(by_sect.keys()):
        lines.append(f"- **{s}**: {by_sect[s]} 个文件")
    lines.extend(["", "## 明细", "", "| 文件 | 宗派 | 源 | 结果 |", "|------|------|-----|------|"])
    for r in rows:
        src = r.get("source", "")
        res = "ok" if r.get("ok") else f"失败: {r.get('error', '')}"
        lines.append(f"| `{r['file']}` | {r['sect']} | {src} | {res} |")
    if fail:
        lines.extend(["", "## 失败项", ""])
        for r in fail:
            lines.append(f"- `{r['file']}`: {r.get('error', '')}")
    lines.extend(
        [
            "",
            "## 依赖与运行",
            "",
            "```bash",
            "pip install Pillow",
            "python scripts/enhance_skill_animations.py",
            "# 仅预览: python scripts/enhance_skill_animations.py --dry-run",
            "```",
            "",
            "验证加载:",
            "",
            "- Godot: `res://tests/test_skill_animation_load.tscn`（`--headless`）",
            "- Pillow: `python scripts/verify_enhanced_animations.py`",
            "",
        ]
    )
    REPORT_PATH.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Enhance sect skill animation PNGs.")
    parser.add_argument("--dry-run", action="store_true", help="不写入文件，仅统计与报告")
    parser.add_argument(
        "--only",
        type=str,
        default="",
        help="仅处理此前缀，例如 ice_ / thunder_ / fire_ / poison_",
    )
    args = parser.parse_args()
    targets = list_target_pngs()
    if args.only:
        pref = args.only.lower()
        if not pref.endswith("_"):
            pref += "_"
        targets = [p for p in targets if p.name.lower().startswith(pref)]
    if not targets:
        print(f"未找到可处理的 PNG（目录 {ANIM_DIR}）。")
        write_report([], args.dry_run)
        return 1
    rows: list[dict] = []
    for dest in targets:
        if args.dry_run:
            ensure_backup(dest, dry_run=True)
        else:
            if not (BACKUP_DIR / dest.name).is_file() and dest.is_file():
                ensure_backup(dest, dry_run=False)
        row = process_one(dest, args.dry_run)
        rows.append(row)
        sym = "OK" if row["ok"] else "FAIL"
        print(f"[{sym}] {row['file']} ({row['sect']}) {row.get('error', '')}")
    write_report(rows, args.dry_run)
    print(f"报告已写入: {REPORT_PATH}")
    return 0 if all(r["ok"] for r in rows) else 2


if __name__ == "__main__":
    raise SystemExit(main())
