from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os
import math

def create_placeholder_texture(size, color, text, output_path):
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    draw.rectangle([0, 0, size[0]-1, size[1]-1], outline=color, width=2)
    draw.rectangle([2, 2, size[0]-3, size[1]-3], outline=color, width=1)
    
    font = ImageFont.load_default()
    
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    text_x = (size[0] - text_w) // 2
    text_y = (size[1] - text_h) // 2
    
    draw.text((text_x, text_y), text, fill=color, font=font)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Created: {output_path}")

def create_animation_frames(base_name, num_frames, size, color, output_dir):
    for i in range(num_frames):
        angle = (i / num_frames) * math.pi * 2
        offset_x = int(math.sin(angle) * 5)
        offset_y = int(math.cos(angle) * 5)
        
        img = Image.new('RGBA', size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        center_x = size[0] // 2 + offset_x
        center_y = size[1] // 2 + offset_y
        
        draw.ellipse([
            center_x - 20, center_y - 20, 
            center_x + 20, center_y + 20], 
            fill=color, outline=(255, 255, 255), width=2)
        
        output_path = os.path.join(output_dir, f"{base_name}_{i}.png")
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        img.save(output_path)
        print(f"Created: {output_path}")

def create_slash_attack_frames(num_frames, size, output_dir):
    for i in range(num_frames):
        img = Image.new('RGBA', size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        center_x = size[0] // 2
        center_y = size[1] // 2
        
        progress = i / (num_frames - 1)
        start_angle = -120 + progress * 240
        end_angle = start_angle + 60
        
        radius = 40 + progress * 10
        color_intensity = int(255 * (1 - progress * 0.5))
        color = (255, 200, 100, int(255 * (1 - progress * 0.7)))
        
        draw.arc([
            center_x - radius, center_y - radius,
            center_x + radius, center_y + radius
        ], start_angle, end_angle, fill=color, width=8)
        
        output_path = os.path.join(output_dir, f"slash_{i}.png")
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        img.save(output_path)
        print(f"Created: {output_path}")

def create_dash_effect_frames(num_frames, size, output_dir):
    for i in range(num_frames):
        img = Image.new('RGBA', size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        center_x = size[0] // 2
        center_y = size[1] // 2
        
        progress = i / (num_frames - 1)
        alpha = int(255 * (1 - progress))
        scale = 1.0 + progress * 0.5
        
        radius = int(20 * scale)
        color = (100, 150, 255, alpha)
        
        draw.ellipse([
            center_x - radius, center_y - radius,
            center_x + radius, center_y + radius
        ], fill=color)
        
        for j in range(3):
            offset_angle = (j * 120) * math.pi / 180
            trail_dist = progress * 30
            trail_x = center_x + math.cos(offset_angle) * trail_dist
            trail_y = center_y + math.sin(offset_angle) * trail_dist
            trail_alpha = int(alpha * 0.6)
            trail_radius = int(8 * (1 - progress))
            draw.ellipse([
                trail_x - trail_radius, trail_y - trail_radius,
                trail_x + trail_radius, trail_y + trail_radius
            ], fill=(150, 200, 255, trail_alpha))
        
        output_path = os.path.join(output_dir, f"dash_{i}.png")
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        img.save(output_path)
        print(f"Created: {output_path}")

def create_hit_effect_frames(num_frames, size, output_dir):
    for i in range(num_frames):
        img = Image.new('RGBA', size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        center_x = size[0] // 2
        center_y = size[1] // 2
        
        progress = i / (num_frames - 1)
        alpha = int(255 * (1 - progress))
        
        for j in range(8):
            angle = (j * 45) * math.pi / 180
            dist = progress * 30
            px = center_x + math.cos(angle) * dist
            py = center_y + math.sin(angle) * dist
            particle_radius = int(5 * (1 - progress))
            draw.ellipse([
                px - particle_radius, py - particle_radius,
                px + particle_radius, py + particle_radius
            ], fill=(255, 100, 100, alpha))
        
        flash_radius = int(20 * (1 - progress * 0.5))
        draw.ellipse([
            center_x - flash_radius, center_y - flash_radius,
            center_x + flash_radius, center_y + flash_radius
        ], fill=(255, 255, 200, int(alpha * 0.5)))
        
        output_path = os.path.join(output_dir, f"hit_{i}.png")
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        img.save(output_path)
        print(f"Created: {output_path}")

def create_sword_swing_frames(num_frames, size, output_dir):
    for i in range(num_frames):
        img = Image.new('RGBA', size, (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        center_x = size[0] // 2
        center_y = size[1] // 2
        
        progress = i / (num_frames - 1)
        start_angle = -60 + progress * 120
        
        sword_length = 50
        sword_width = 6
        
        angle_rad = start_angle * math.pi / 180
        end_x = center_x + math.cos(angle_rad) * sword_length
        end_y = center_y + math.sin(angle_rad) * sword_length
        
        alpha = int(255 * (1 - progress * 0.5))
        color = (200, 200, 200, alpha)
        
        draw.line([(center_x, center_y), (end_x, end_y)], 
                  fill=color, width=sword_width)
        
        output_path = os.path.join(output_dir, f"sword_swing_{i}.png")
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        img.save(output_path)
        print(f"Created: {output_path}")

def draw_warm_snow_border(draw, x1, y1, x2, y2, border_color, highlight_color):
    draw.rectangle([x1, y1, x2, y2], outline=border_color, width=3)
    draw.rectangle([x1+2, y1+2, x2-2, y2-2], outline=highlight_color, width=1)
    
    corner_size = 8
    draw.line([(x1, y1+corner_size), (x1, y1), (x1+corner_size, y1)], fill=highlight_color, width=2)
    draw.line([(x2-corner_size, y1), (x2, y1), (x2, y1+corner_size)], fill=highlight_color, width=2)
    draw.line([(x1, y2-corner_size), (x1, y2), (x1+corner_size, y2)], fill=highlight_color, width=2)
    draw.line([(x2-corner_size, y2), (x2, y2), (x2, y2-corner_size)], fill=highlight_color, width=2)

def create_warm_snow_skill_slot(size, key_text, skill_color, output_path):
    img = Image.new('RGBA', size, (20, 20, 35, 230))
    draw = ImageDraw.Draw(img)
    
    center_x = size[0] // 2
    center_y = size[1] // 2
    
    border_color = (80, 80, 100)
    highlight_color = skill_color
    
    draw_warm_snow_border(draw, 2, 2, size[0]-3, size[1]-3, border_color, highlight_color)
    
    inner_size = size[0] - 16
    inner_x1 = 8
    inner_y1 = 8
    inner_x2 = inner_x1 + inner_size
    inner_y2 = inner_y1 + inner_size
    
    gradient_steps = 10
    for i in range(gradient_steps):
        step_alpha = int(100 * (1 - i / gradient_steps))
        step_color = (*skill_color[:3], step_alpha)
        step_size = inner_size - i * 2
        if step_size > 0:
            offset = i
            draw.rectangle([
                inner_x1 + offset, inner_y1 + offset,
                inner_x2 - offset, inner_y2 - offset
            ], outline=step_color, width=1)
    
    font = ImageFont.load_default()
    
    bbox = draw.textbbox((0, 0), key_text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    
    key_x = size[0] - text_w - 8
    key_y = size[1] - text_h - 4
    
    bg_pad = 4
    draw.rectangle([
        key_x - bg_pad, key_y - bg_pad,
        key_x + text_w + bg_pad, key_y + text_h + bg_pad
    ], fill=(10, 10, 20, 200))
    
    draw.text((key_x, key_y), key_text, fill=(255, 255, 255), font=font)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Created: {output_path}")

def create_warm_snow_health_bar(width, height, fill_percent, output_path):
    img = Image.new('RGBA', (width, height), (10, 10, 20, 220))
    draw = ImageDraw.Draw(img)
    
    border_color = (100, 80, 60)
    highlight_color = (200, 180, 150)
    
    draw_warm_snow_border(draw, 1, 1, width-2, height-2, border_color, highlight_color)
    
    bar_x1 = 4
    bar_y1 = 4
    bar_x2 = width - 5
    bar_y2 = height - 5
    
    draw.rectangle([bar_x1, bar_y1, bar_x2, bar_y2], fill=(30, 20, 15, 255))
    
    fill_width = int((bar_x2 - bar_x1) * fill_percent)
    if fill_width > 0:
        if fill_percent > 0.5:
            fill_color = (180, 50, 50)
            glow_color = (255, 100, 100)
        elif fill_percent > 0.25:
            fill_color = (180, 150, 50)
            glow_color = (255, 220, 100)
        else:
            fill_color = (150, 50, 30)
            glow_color = (255, 80, 60)
        
        draw.rectangle([bar_x1, bar_y1, bar_x1 + fill_width, bar_y2], fill=fill_color)
        
        glow_height = (bar_y2 - bar_y1) // 3
        draw.rectangle([bar_x1, bar_y1, bar_x1 + fill_width, bar_y1 + glow_height], fill=(*glow_color[:3], 100))
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Created: {output_path}")

def create_warm_snow_panel(size, bg_color, border_color, highlight_color, text, output_path):
    img = Image.new('RGBA', size, bg_color)
    draw = ImageDraw.Draw(img)
    
    draw_warm_snow_border(draw, 2, 2, size[0]-3, size[1]-3, border_color, highlight_color)
    
    font = ImageFont.load_default()
    
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    text_x = (size[0] - text_w) // 2
    text_y = (size[1] - text_h) // 2
    
    draw.text((text_x, text_y), text, fill=(255, 255, 255), font=font)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Created: {output_path}")

def create_warm_snow_button(size, text, output_path):
    img = Image.new('RGBA', size, (40, 30, 25, 240))
    draw = ImageDraw.Draw(img)
    
    border_color = (120, 100, 80)
    highlight_color = (200, 180, 140)
    
    draw_warm_snow_border(draw, 1, 1, size[0]-2, size[1]-2, border_color, highlight_color)
    
    font = ImageFont.load_default()
    
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    text_x = (size[0] - text_w) // 2
    text_y = (size[1] - text_h) // 2
    
    draw.text((text_x, text_y), text, fill=(240, 220, 180), font=font)
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path)
    print(f"Created: {output_path}")

def main():
    base_dir = r"f:\project\SurvivorsClone_Test"
    
    textures_dir = os.path.join(base_dir, "Textures", "Placeholder")
    effects_dir = os.path.join(textures_dir, "Effects")
    ui_dir = os.path.join(base_dir, "Textures", "UI")
    
    print("=== Creating Placeholder Textures ===")
    
    create_placeholder_texture(
        (128, 128), (100, 200, 255), "Sword",
        os.path.join(textures_dir, "placeholder_sword.png")
    )
    
    create_placeholder_texture(
        (128, 128), (255, 100, 100), "Dash",
        os.path.join(textures_dir, "placeholder_dash.png")
    )
    
    create_placeholder_texture(
        (128, 128), (255, 200, 100), "Attack",
        os.path.join(textures_dir, "placeholder_attack.png")
    )
    
    create_animation_frames(
        "player_walk", 4, (64, 64), (100, 200, 100),
        os.path.join(textures_dir, "Animations")
    )
    
    print("\n=== Creating Attack Effects ===")
    
    create_slash_attack_frames(
        8, (128, 128),
        os.path.join(effects_dir, "Slash")
    )
    
    create_sword_swing_frames(
        10, (128, 128),
        os.path.join(effects_dir, "SwordSwing")
    )
    
    print("\n=== Creating Dash Effects ===")
    
    create_dash_effect_frames(
        8, (96, 96),
        os.path.join(effects_dir, "Dash")
    )
    
    print("\n=== Creating Hit Effects ===")
    
    create_hit_effect_frames(
        8, (96, 96),
        os.path.join(effects_dir, "Hit")
    )
    
    print("\n=== Creating Warm Snow Style UI Elements ===")
    
    create_warm_snow_panel(
        (300, 100), (30, 25, 40, 220), (100, 90, 120), (180, 160, 200),
        "Warm Snow",
        os.path.join(ui_dir, "placeholder_panel.png")
    )
    
    create_warm_snow_button(
        (200, 60), "Start Game",
        os.path.join(ui_dir, "placeholder_button.png")
    )
    
    create_warm_snow_health_bar(
        280, 36, 0.75,
        os.path.join(ui_dir, "placeholder_healthbar.png")
    )
    
    create_warm_snow_health_bar(
        280, 36, 0.5,
        os.path.join(ui_dir, "placeholder_healthbar_half.png")
    )
    
    create_warm_snow_health_bar(
        280, 36, 0.25,
        os.path.join(ui_dir, "placeholder_healthbar_low.png")
    )
    
    print("\n=== Creating Warm Snow Style Skill Bar UI ===")
    
    skill_slot_size = (72, 72)
    
    create_warm_snow_skill_slot(
        skill_slot_size, "Q", (100, 150, 255),
        os.path.join(ui_dir, "skill_slot_q.png")
    )
    
    create_warm_snow_skill_slot(
        skill_slot_size, "E", (150, 100, 255),
        os.path.join(ui_dir, "skill_slot_e.png")
    )
    
    create_warm_snow_skill_slot(
        skill_slot_size, "R", (255, 100, 150),
        os.path.join(ui_dir, "skill_slot_r.png")
    )
    
    create_warm_snow_skill_slot(
        skill_slot_size, "Shift", (100, 255, 150),
        os.path.join(ui_dir, "skill_slot_shift.png")
    )
    
    print("\n=== All placeholder resources created successfully! ===")
    print("\nNote: Created effects:")
    print("  - Slash attack (8 frames)")
    print("  - Sword swing (10 frames)")
    print("  - Dash effect (8 frames)")
    print("  - Hit effect (8 frames)")
    print("\nNote: Created Warm Snow style UI:")
    print("  - Skill slots (Q, E, R, Shift) with corner decorations")
    print("  - Health bars with gradient glow")
    print("  - Panel and button with warm snow aesthetic")

if __name__ == "__main__":
    main()
