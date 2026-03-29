#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
占位资源生成器
为游戏生成占位图片和特效资源
"""

import os
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

# 设置UTF-8输出
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

# 项目根目录
PROJECT_ROOT = Path(__file__).parent
ASSETS_DIR = PROJECT_ROOT / "Assets"

# 颜色定义（与游戏常量对应）
COLORS = {
    'ice': (77, 208, 225),        # #4DD0E1
    'thunder': (255, 213, 79),    # #FFD54F
    'fire': (255, 110, 64),       # #FF6E40
    'poison': (156, 204, 101),    # #9CCC65
    'white': (255, 255, 255),
    'black': (20, 20, 30),
    'gold': (230, 217, 153),
}

def create_directory(path):
    """创建目录"""
    path.mkdir(parents=True, exist_ok=True)
    print(f"✓ 创建目录: {path.relative_to(PROJECT_ROOT)}")

def create_gradient_circle(size, color, name="circle"):
    """创建渐变圆形"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = (size[0] // 2, size[1] // 2)
    radius = min(size) // 2
    
    # 绘制多层圆形创建渐变效果
    for i in range(radius, 0, -2):
        alpha = int(255 * (i / radius) * 0.8)
        current_color = color + (alpha,)
        draw.ellipse(
            [center[0] - i, center[1] - i, center[0] + i, center[1] + i],
            fill=current_color
        )
    
    return img

def create_projectile(size, color, name="projectile"):
    """创建抛射物图片"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 绘制箭头形状
    points = [
        (size[0] - 2, size[1] // 2),  # 尖端
        (2, 2),                        # 左上
        (size[0] // 3, size[1] // 2),  # 中间
        (2, size[1] - 2),              # 左下
    ]
    
    draw.polygon(points, fill=color + (255,))
    
    # 添加发光边缘
    draw.line(points + [points[0]], fill=color + (200,), width=1)
    
    return img

def create_explosion(size, color, name="explosion"):
    """创建爆炸效果"""
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = (size[0] // 2, size[1] // 2)
    
    # 绘制多个星形爆炸
    for angle in range(0, 360, 45):
        import math
        rad = math.radians(angle)
        x1 = center[0] + math.cos(rad) * (size[0] // 4)
        y1 = center[1] + math.sin(rad) * (size[1] // 4)
        x2 = center[0] + math.cos(rad) * (size[0] // 2 - 4)
        y2 = center[1] + math.sin(rad) * (size[1] // 2 - 4)
        
        draw.line([(x1, y1), (x2, y2)], fill=color + (200,), width=3)
    
    # 中心圆
    radius = size[0] // 6
    draw.ellipse(
        [center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius],
        fill=color + (255,)
    )
    
    return img

def create_icon(size, color, text, name="icon"):
    """创建图标"""
    img = Image.new('RGBA', size, COLORS['black'] + (255,))
    draw = ImageDraw.Draw(img)
    
    # 绘制边框
    draw.rectangle([0, 0, size[0]-1, size[1]-1], outline=color + (255,), width=3)
    
    # 绘制中心圆
    center = (size[0] // 2, size[1] // 2)
    radius = size[0] // 3
    draw.ellipse(
        [center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius],
        fill=color + (200,)
    )
    
    # 尝试添加文字
    try:
        font = ImageFont.truetype("arial.ttf", size[0] // 4)
    except:
        font = ImageFont.load_default()
    
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    text_pos = (center[0] - text_width // 2, center[1] - text_height // 2)
    
    draw.text(text_pos, text, fill=COLORS['white'] + (255,), font=font)
    
    return img

def create_card(size, color, title, name="card"):
    """创建宗派卡片"""
    img = Image.new('RGBA', size, COLORS['black'] + (255,))
    draw = ImageDraw.Draw(img)
    
    # 绘制边框
    draw.rectangle([0, 0, size[0]-1, size[1]-1], outline=color + (255,), width=4)
    
    # 绘制顶部图标区域
    icon_size = 80
    icon_y = 20
    icon_x = (size[0] - icon_size) // 2
    draw.ellipse(
        [icon_x, icon_y, icon_x + icon_size, icon_y + icon_size],
        fill=color + (150,)
    )
    
    # 绘制标题
    try:
        font_title = ImageFont.truetype("arial.ttf", 24)
        font_desc = ImageFont.truetype("arial.ttf", 14)
    except:
        font_title = ImageFont.load_default()
        font_desc = ImageFont.load_default()
    
    title_bbox = draw.textbbox((0, 0), title, font=font_title)
    title_width = title_bbox[2] - title_bbox[0]
    title_pos = ((size[0] - title_width) // 2, 120)
    
    draw.text(title_pos, title, fill=color + (255,), font=font_title)
    
    return img

def generate_sect_assets():
    """生成宗派相关资源"""
    print("\n=== 生成宗派资源 ===")
    
    sects_dir = ASSETS_DIR / "UI" / "Sects"
    create_directory(sects_dir)
    
    sects = [
        ('ice', COLORS['ice'], '冰', '冰心宗'),
        ('thunder', COLORS['thunder'], '雷', '雷鸣宗'),
        ('fire', COLORS['fire'], '火', '烈焰宗'),
        ('poison', COLORS['poison'], '毒', '毒瘴宗'),
    ]
    
    for sect_id, color, symbol, name in sects:
        # 图标 96x96
        icon = create_icon((96, 96), color, symbol, f"icon_sect_{sect_id}")
        icon_path = sects_dir / f"icon_sect_{sect_id}.png"
        icon.save(icon_path)
        print(f"  ✓ 生成图标: {icon_path.name}")
        
        # 卡片 160x240
        card = create_card((160, 240), color, name, f"card_sect_{sect_id}")
        card_path = sects_dir / f"card_sect_{sect_id}.png"
        card.save(card_path)
        print(f"  ✓ 生成卡片: {card_path.name}")

def generate_skill_effects():
    """生成技能特效资源"""
    print("\n=== 生成技能特效 ===")
    
    effects_dir = ASSETS_DIR / "Effects" / "Skills"
    create_directory(effects_dir)
    
    skills = [
        # 冰系
        ('ice_shard', COLORS['ice'], (16, 8), 'projectile'),
        ('ice_field', COLORS['ice'], (128, 128), 'circle'),
        ('ice_storm', COLORS['ice'], (256, 256), 'explosion'),
        
        # 雷系
        ('thunder_strike', COLORS['thunder'], (64, 64), 'explosion'),
        ('thunder_field', COLORS['thunder'], (120, 120), 'circle'),
        ('thunder_god', COLORS['thunder'], (200, 200), 'explosion'),
        
        # 火系
        ('fire_ball', COLORS['fire'], (24, 24), 'projectile'),
        ('fire_wall', COLORS['fire'], (200, 80), 'circle'),
        ('fire_meteor', COLORS['fire'], (240, 240), 'explosion'),
        
        # 毒系
        ('poison_dart', COLORS['poison'], (12, 6), 'projectile'),
        ('poison_cloud', COLORS['poison'], (140, 140), 'circle'),
        ('poison_plague', COLORS['poison'], (220, 220), 'explosion'),
    ]
    
    for skill_id, color, size, effect_type in skills:
        if effect_type == 'projectile':
            img = create_projectile(size, color, skill_id)
        elif effect_type == 'circle':
            img = create_gradient_circle(size, color, skill_id)
        else:  # explosion
            img = create_explosion(size, color, skill_id)
        
        img_path = effects_dir / f"{skill_id}.png"
        img.save(img_path)
        print(f"  ✓ 生成特效: {img_path.name} ({size[0]}x{size[1]})")

def generate_ui_assets():
    """生成UI资源"""
    print("\n=== 生成UI资源 ===")
    
    ui_dir = ASSETS_DIR / "UI"
    create_directory(ui_dir)
    
    # 技能栏背景
    skill_bar_bg = Image.new('RGBA', (400, 80), COLORS['black'] + (200,))
    draw = ImageDraw.Draw(skill_bar_bg)
    draw.rectangle([0, 0, 399, 79], outline=COLORS['gold'] + (255,), width=2)
    
    bg_path = ui_dir / "skill_bar_bg.png"
    skill_bar_bg.save(bg_path)
    print(f"  ✓ 生成UI: {bg_path.name}")
    
    # 宗派选择背景
    sect_bg = Image.new('RGBA', (640, 360), COLORS['black'] + (240,))
    draw = ImageDraw.Draw(sect_bg)
    draw.rectangle([0, 0, 639, 359], outline=COLORS['gold'] + (255,), width=3)
    
    sect_bg_path = ui_dir / "sect_selection_bg.png"
    sect_bg.save(sect_bg_path)
    print(f"  ✓ 生成UI: {sect_bg_path.name}")

def main():
    print("=" * 70)
    print("占位资源生成器")
    print("=" * 70)
    
    # 创建主资源目录
    create_directory(ASSETS_DIR)
    create_directory(ASSETS_DIR / "UI")
    create_directory(ASSETS_DIR / "Effects")
    
    # 生成各类资源
    generate_sect_assets()
    generate_skill_effects()
    generate_ui_assets()
    
    print("\n" + "=" * 70)
    print("✓ 所有占位资源生成完成！")
    print("=" * 70)
    print("\n资源位置:")
    print(f"  - 宗派资源: {ASSETS_DIR / 'UI' / 'Sects'}")
    print(f"  - 技能特效: {ASSETS_DIR / 'Effects' / 'Skills'}")
    print(f"  - UI资源: {ASSETS_DIR / 'UI'}")
    print("\n提示: 这些是占位资源，后续可以用AI工具生成更精美的版本")

if __name__ == "__main__":
    main()
