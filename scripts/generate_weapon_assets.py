#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成所有武器的精灵和图标
为6种武器生成视觉上有区分度的精灵
"""

from PIL import Image, ImageDraw, ImageFilter
import os
import math
import sys

# 设置UTF-8输出
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# 确保输出目录存在
ASSETS_DIR = "Assets/Weapons"
os.makedirs(ASSETS_DIR, exist_ok=True)

# 武器配置
WEAPONS = {
    "sword_basic": {
        "name": "Nameless Sword",
        "type": "sword",
        "color": (180, 180, 200),
        "glow": (220, 220, 240),
        "size": (48, 12)
    },
    "sword_frost": {
        "name": "Frost River",
        "type": "sword",
        "color": (100, 200, 255),
        "glow": (150, 220, 255),
        "size": (52, 14)
    },
    "hammer_thunder": {
        "name": "Thunder Hammer",
        "type": "hammer",
        "color": (150, 100, 255),
        "glow": (200, 150, 255),
        "size": (32, 32)
    },
    "staff_fire": {
        "name": "Fire Staff",
        "type": "staff",
        "color": (255, 120, 50),
        "glow": (255, 200, 100),
        "size": (16, 64)
    },
    "dagger_poison": {
        "name": "Poison Dagger",
        "type": "dagger",
        "color": (100, 255, 100),
        "glow": (150, 255, 150),
        "size": (32, 10)
    },
    "spear_legendary": {
        "name": "Legendary Spear",
        "type": "spear",
        "color": (255, 215, 0),
        "glow": (255, 240, 150),
        "size": (16, 72)
    }
}

def create_sword_sprite(weapon_id, config):
    """创建剑类武器精灵"""
    size = config["size"]
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 剑刃
    blade_points = [
        (size[0] - 4, size[1] // 2),  # 剑尖
        (size[0] // 3, size[1] // 2 - 4),  # 上刃
        (4, size[1] // 2 - 2),  # 护手上
        (4, size[1] // 2 + 2),  # 护手下
        (size[0] // 3, size[1] // 2 + 4),  # 下刃
    ]
    draw.polygon(blade_points, fill=config["color"] + (255,), outline=config["glow"] + (255,))
    
    # 剑柄
    draw.rectangle(
        [2, size[1] // 2 - 1, 8, size[1] // 2 + 1],
        fill=(100, 80, 60, 255)
    )
    
    # 光效
    for i in range(3):
        x = size[0] - 8 - i * 8
        draw.ellipse(
            [x - 2, size[1] // 2 - 1, x + 2, size[1] // 2 + 1],
            fill=config["glow"] + (200 - i * 50,)
        )
    
    return img.filter(ImageFilter.GaussianBlur(radius=0.3))

def create_hammer_sprite(weapon_id, config):
    """创建锤类武器精灵"""
    size = config["size"]
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 锤头
    head_size = size[0] // 2
    draw.ellipse(
        [size[0] - head_size - 2, 2,
         size[0] - 2, size[1] - 2],
        fill=config["color"] + (255,),
        outline=config["glow"] + (255,),
        width=2
    )
    
    # 锤柄
    draw.rectangle(
        [2, size[1] // 2 - 2, size[0] - head_size, size[1] // 2 + 2],
        fill=(80, 60, 40, 255)
    )
    
    # 能量光晕
    for i in range(2):
        r = head_size // 2 + i * 3
        center = (size[0] - head_size // 2 - 2, size[1] // 2)
        draw.ellipse(
            [center[0] - r, center[1] - r,
             center[0] + r, center[1] + r],
            outline=config["glow"] + (150 - i * 50,),
            width=2
        )
    
    return img.filter(ImageFilter.GaussianBlur(radius=0.5))

def create_staff_sprite(weapon_id, config):
    """创建法杖类武器精灵"""
    size = config["size"]
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 法杖杆
    draw.rectangle(
        [size[0] // 2 - 2, 10, size[0] // 2 + 2, size[1] - 4],
        fill=(60, 40, 20, 255)
    )
    
    # 顶部宝珠
    orb_size = size[0] - 4
    draw.ellipse(
        [2, 2, orb_size + 2, orb_size + 2],
        fill=config["color"] + (200,),
        outline=config["glow"] + (255,),
        width=2
    )
    
    # 内部光芒
    inner_size = orb_size // 2
    center = (orb_size // 2 + 2, orb_size // 2 + 2)
    draw.ellipse(
        [center[0] - inner_size // 2, center[1] - inner_size // 2,
         center[0] + inner_size // 2, center[1] + inner_size // 2],
        fill=config["glow"] + (255,)
    )
    
    # 能量流动
    for i in range(4):
        y = 15 + i * 12
        draw.ellipse(
            [size[0] // 2 - 1, y, size[0] // 2 + 1, y + 4],
            fill=config["glow"] + (150,)
        )
    
    return img.filter(ImageFilter.GaussianBlur(radius=0.5))

def create_dagger_sprite(weapon_id, config):
    """创建匕首类武器精灵"""
    size = config["size"]
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 刀刃（三角形）
    blade_points = [
        (size[0] - 2, size[1] // 2),  # 刀尖
        (size[0] // 3, size[1] // 2 - 3),  # 上刃
        (size[0] // 3, size[1] // 2 + 3),  # 下刃
    ]
    draw.polygon(blade_points, fill=config["color"] + (255,), outline=(200, 200, 200, 255))
    
    # 刀柄
    draw.rectangle(
        [2, size[1] // 2 - 2, size[0] // 3, size[1] // 2 + 2],
        fill=(40, 40, 40, 255)
    )
    
    # 毒液滴落效果
    for i in range(2):
        x = size[0] - 6 - i * 8
        y = size[1] // 2 + 2
        draw.ellipse(
            [x, y, x + 3, y + 4],
            fill=config["glow"] + (180,)
        )
    
    return img.filter(ImageFilter.GaussianBlur(radius=0.3))

def create_spear_sprite(weapon_id, config):
    """创建长枪类武器精灵"""
    size = config["size"]
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 枪杆
    draw.rectangle(
        [size[0] // 2 - 2, 12, size[0] // 2 + 2, size[1] - 4],
        fill=(80, 60, 40, 255)
    )
    
    # 枪头
    spear_points = [
        (size[0] // 2, 2),  # 尖端
        (size[0] // 2 - 6, 14),  # 左侧
        (size[0] // 2 + 6, 14),  # 右侧
    ]
    draw.polygon(spear_points, fill=config["color"] + (255,), outline=config["glow"] + (255,))
    
    # 装饰纹路
    for i in range(3):
        y = 20 + i * 15
        draw.line(
            [(size[0] // 2 - 3, y), (size[0] // 2 + 3, y)],
            fill=config["glow"] + (200,),
            width=1
        )
    
    # 金色光芒
    for i in range(4):
        alpha = 200 - i * 40
        draw.ellipse(
            [size[0] // 2 - 2 - i, 6 - i,
             size[0] // 2 + 2 + i, 10 + i],
            outline=config["glow"] + (alpha,)
        )
    
    return img.filter(ImageFilter.GaussianBlur(radius=0.4))

def create_weapon_icon(weapon_id, config):
    """创建武器图标（用于UI）"""
    size = (64, 64)
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 背景圆形
    draw.ellipse(
        [4, 4, size[0] - 4, size[1] - 4],
        fill=(40, 40, 50, 200),
        outline=config["glow"] + (255,),
        width=2
    )
    
    # 简化的武器图标
    center = (size[0] // 2, size[1] // 2)
    weapon_type = config["type"]
    
    if weapon_type in ["sword", "dagger"]:
        # 剑/匕首 - 斜线
        draw.line(
            [(center[0] - 15, center[1] + 15), (center[0] + 15, center[1] - 15)],
            fill=config["color"] + (255,),
            width=6
        )
        draw.ellipse(
            [center[0] - 4, center[1] - 4, center[0] + 4, center[1] + 4],
            fill=config["glow"] + (255,)
        )
    
    elif weapon_type == "hammer":
        # 锤子 - T形
        draw.rectangle(
            [center[0] - 2, center[1] - 5, center[0] + 2, center[1] + 15],
            fill=(80, 60, 40, 255)
        )
        draw.ellipse(
            [center[0] - 12, center[1] - 15, center[0] + 12, center[1] - 5],
            fill=config["color"] + (255,)
        )
    
    elif weapon_type == "staff":
        # 法杖 - 杆+宝珠
        draw.rectangle(
            [center[0] - 2, center[1] - 5, center[0] + 2, center[1] + 18],
            fill=(60, 40, 20, 255)
        )
        draw.ellipse(
            [center[0] - 10, center[1] - 18, center[0] + 10, center[1] - 8],
            fill=config["color"] + (200,),
            outline=config["glow"] + (255,),
            width=2
        )
    
    elif weapon_type == "spear":
        # 长枪 - 竖线+尖头
        draw.rectangle(
            [center[0] - 2, center[1] - 5, center[0] + 2, center[1] + 18],
            fill=(80, 60, 40, 255)
        )
        points = [
            (center[0], center[1] - 18),
            (center[0] - 8, center[1] - 8),
            (center[0] + 8, center[1] - 8)
        ]
        draw.polygon(points, fill=config["color"] + (255,))
    
    return img.filter(ImageFilter.GaussianBlur(radius=0.3))

def main():
    print("\n========================================")
    print("Generate Weapon Assets")
    print("========================================\n")
    
    total_generated = 0
    
    for weapon_id, config in WEAPONS.items():
        print(f"[{config['name']}]")
        
        # 生成武器精灵（用于攻击动画）
        if config["type"] == "sword" or config["type"] == "dagger":
            sprite = create_sword_sprite(weapon_id, config)
        elif config["type"] == "hammer":
            sprite = create_hammer_sprite(weapon_id, config)
        elif config["type"] == "staff":
            sprite = create_staff_sprite(weapon_id, config)
        elif config["type"] == "spear":
            sprite = create_spear_sprite(weapon_id, config)
        else:
            sprite = create_sword_sprite(weapon_id, config)
        
        sprite_path = f"{ASSETS_DIR}/{weapon_id}_sprite.png"
        sprite.save(sprite_path)
        print(f"  [OK] Sprite: {sprite_path}")
        total_generated += 1
        
        # 生成武器图标（用于UI）
        icon = create_weapon_icon(weapon_id, config)
        icon_path = f"{ASSETS_DIR}/{weapon_id}_icon.png"
        icon.save(icon_path)
        print(f"  [OK] Icon: {icon_path}")
        total_generated += 1
    
    print(f"\n========================================")
    print(f"[DONE] Total: {total_generated} weapon assets")
    print(f"Output: {ASSETS_DIR}/")
    print(f"========================================\n")

if __name__ == "__main__":
    main()
