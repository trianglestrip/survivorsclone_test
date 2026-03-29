#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
生成所有宗派技能的特色动画帧占位
为Q/E/R技能生成视觉上有区分度的动画帧
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
ASSETS_DIR = "Assets/Skills"
os.makedirs(ASSETS_DIR, exist_ok=True)

# 宗派颜色配置
SECT_COLORS = {
    "ice": {
        "primary": (100, 200, 255),    # 冰蓝色
        "secondary": (200, 240, 255),  # 浅蓝色
        "glow": (150, 220, 255),       # 发光蓝
    },
    "thunder": {
        "primary": (150, 100, 255),    # 紫色
        "secondary": (200, 150, 255),  # 浅紫色
        "glow": (180, 130, 255),       # 发光紫
    },
    "fire": {
        "primary": (255, 120, 50),     # 橙红色
        "secondary": (255, 200, 100),  # 黄色
        "glow": (255, 160, 80),        # 发光橙
    },
    "poison": {
        "primary": (100, 255, 100),    # 绿色
        "secondary": (150, 255, 150),  # 浅绿色
        "glow": (120, 255, 120),       # 发光绿
    }
}

def create_projectile_frames(sect_id, colors, output_name, frame_count=4):
    """创建弹射物动画帧（Q技能）"""
    print(f"  生成 {output_name} 弹射物动画...")
    
    size = (32, 16)
    frames = []
    
    for frame in range(frame_count):
        img = Image.new('RGBA', size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # 动画进度
        progress = frame / frame_count
        
        # 主体（流线型）
        main_color = colors["primary"] + (200,)
        for i in range(3):
            offset = i * 2
            alpha = 200 - i * 50
            draw.ellipse(
                [offset, 4 + i, size[0] - 4 - offset, size[1] - 4 - i],
                fill=colors["primary"] + (alpha,)
            )
        
        # 尾焰效果
        tail_length = int(8 + math.sin(progress * math.pi * 2) * 2)
        for i in range(tail_length):
            x = i
            alpha = int(150 * (1 - i / tail_length))
            draw.ellipse(
                [x, size[1]//2 - 2, x + 4, size[1]//2 + 2],
                fill=colors["secondary"] + (alpha,)
            )
        
        # 前端光点
        glow_size = int(4 + math.sin(progress * math.pi * 2) * 1)
        draw.ellipse(
            [size[0] - glow_size - 2, size[1]//2 - glow_size, 
             size[0] - 2, size[1]//2 + glow_size],
            fill=colors["glow"] + (255,)
        )
        
        # 应用模糊
        img = img.filter(ImageFilter.GaussianBlur(radius=0.5))
        frames.append(img)
    
    # 保存所有帧
    for i, frame in enumerate(frames):
        output_path = f"{ASSETS_DIR}/{output_name}_frame_{i}.png"
        frame.save(output_path)
    
    print(f"    [OK] Generated {frame_count} frames")

def create_field_frames(sect_id, colors, output_name, frame_count=8):
    """创建领域/范围效果动画帧（E技能）"""
    print(f"  生成 {output_name} 领域动画...")
    
    size = (128, 128)
    frames = []
    
    for frame in range(frame_count):
        img = Image.new('RGBA', size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        progress = frame / frame_count
        center = (size[0] // 2, size[1] // 2)
        
        # 多层同心圆
        for layer in range(4):
            radius = int(50 - layer * 10 + math.sin(progress * math.pi * 2 + layer) * 5)
            alpha = int(150 - layer * 30)
            
            # 外圈光晕
            draw.ellipse(
                [center[0] - radius, center[1] - radius,
                 center[0] + radius, center[1] + radius],
                fill=colors["secondary"] + (alpha // 2,),
                outline=colors["glow"] + (alpha,),
                width=2
            )
        
        # 中心核心
        core_radius = int(15 + math.sin(progress * math.pi * 4) * 3)
        draw.ellipse(
            [center[0] - core_radius, center[1] - core_radius,
             center[0] + core_radius, center[1] + core_radius],
            fill=colors["primary"] + (200,)
        )
        
        # 旋转的能量线
        for i in range(6):
            angle = (progress * math.pi * 2 + i * math.pi / 3)
            x1 = center[0] + math.cos(angle) * 20
            y1 = center[1] + math.sin(angle) * 20
            x2 = center[0] + math.cos(angle) * 45
            y2 = center[1] + math.sin(angle) * 45
            draw.line(
                [(x1, y1), (x2, y2)],
                fill=colors["glow"] + (180,),
                width=2
            )
        
        # 应用模糊
        img = img.filter(ImageFilter.GaussianBlur(radius=1.0))
        frames.append(img)
    
    # 保存所有帧
    for i, frame in enumerate(frames):
        output_path = f"{ASSETS_DIR}/{output_name}_frame_{i}.png"
        frame.save(output_path)
    
    print(f"    [OK] Generated {frame_count} frames")

def create_ultimate_frames(sect_id, colors, output_name, frame_count=12):
    """创建终极技能动画帧（R技能）"""
    print(f"  生成 {output_name} 终极技能动画...")
    
    size = (192, 192)
    frames = []
    
    for frame in range(frame_count):
        img = Image.new('RGBA', size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        progress = frame / frame_count
        center = (size[0] // 2, size[1] // 2)
        
        # 外圈爆发波纹
        for wave in range(3):
            wave_progress = (progress + wave * 0.3) % 1.0
            radius = int(80 * wave_progress)
            alpha = int(200 * (1 - wave_progress))
            
            draw.ellipse(
                [center[0] - radius, center[1] - radius,
                 center[0] + radius, center[1] + radius],
                outline=colors["glow"] + (alpha,),
                width=3
            )
        
        # 旋转的能量螺旋
        for spiral in range(8):
            angle_offset = spiral * math.pi / 4
            for i in range(20):
                t = i / 20
                angle = angle_offset + progress * math.pi * 4 + t * math.pi * 2
                radius = 30 + t * 50
                x = center[0] + math.cos(angle) * radius
                y = center[1] + math.sin(angle) * radius
                point_size = int(3 + t * 2)
                alpha = int(200 * (1 - t))
                
                draw.ellipse(
                    [x - point_size, y - point_size,
                     x + point_size, y + point_size],
                    fill=colors["primary"] + (alpha,)
                )
        
        # 中心爆炸核心
        core_size = int(25 + math.sin(progress * math.pi * 6) * 5)
        for layer in range(3):
            r = core_size - layer * 5
            alpha = 255 - layer * 60
            draw.ellipse(
                [center[0] - r, center[1] - r,
                 center[0] + r, center[1] + r],
                fill=colors["glow"] + (alpha,)
            )
        
        # 应用强模糊
        img = img.filter(ImageFilter.GaussianBlur(radius=1.5))
        frames.append(img)
    
    # 保存所有帧
    for i, frame in enumerate(frames):
        output_path = f"{ASSETS_DIR}/{output_name}_frame_{i}.png"
        frame.save(output_path)
    
    print(f"    [OK] Generated {frame_count} frames")

def main():
    print("\n========================================")
    print("生成技能动画帧占位")
    print("========================================\n")
    
    skills = {
        "ice": {
            "Q": "ice_shard",
            "E": "ice_field", 
            "R": "ice_storm"
        },
        "thunder": {
            "Q": "thunder_strike",
            "E": "thunder_field",
            "R": "thunder_god"
        },
        "fire": {
            "Q": "fire_ball",
            "E": "fire_wall",
            "R": "fire_meteor"
        },
        "poison": {
            "Q": "poison_dart",
            "E": "poison_cloud",
            "R": "poison_plague"
        }
    }
    
    total_generated = 0
    
    for sect_id, sect_skills in skills.items():
        colors = SECT_COLORS[sect_id]
        sect_name = {
            "ice": "冰心宗",
            "thunder": "雷鸣宗",
            "fire": "烈焰宗",
            "poison": "毒瘴宗"
        }[sect_id]
        
        print(f"\n[{sect_name}]")
        
        # Q技能 - 弹射物
        create_projectile_frames(sect_id, colors, sect_skills["Q"], frame_count=4)
        total_generated += 4
        
        # E技能 - 领域
        create_field_frames(sect_id, colors, sect_skills["E"], frame_count=8)
        total_generated += 8
        
        # R技能 - 终极
        create_ultimate_frames(sect_id, colors, sect_skills["R"], frame_count=12)
        total_generated += 12
    
    print(f"\n========================================")
    print(f"[DONE] Total: {total_generated} animation frames")
    print(f"Output: {ASSETS_DIR}/")
    print(f"========================================\n")

if __name__ == "__main__":
    main()
