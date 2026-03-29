from PIL import Image, ImageDraw, ImageFont
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

def create_ui_panel(size, bg_color, border_color, text, output_path):
    img = Image.new('RGBA', size, bg_color)
    draw = ImageDraw.Draw(img)
    
    draw.rectangle([0, 0, size[0]-1, size[1]-1], outline=border_color, width=3)
    
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

def create_health_bar(width, height, fill_percent, output_path):
    img = Image.new('RGBA', (width, height), (50, 50, 50, 255))
    draw = ImageDraw.Draw(img)
    
    draw.rectangle([0, 0, width-1, height-1], outline=(200, 200, 200), width=2)
    
    fill_width = int(width * fill_percent)
    if fill_percent > 0.5:
        fill_color = (0, 200, 0, 255)
    elif fill_percent > 0.25:
        fill_color = (200, 200, 0, 255)
    else:
        fill_color = (200, 0, 0, 255)
    
    draw.rectangle([2, 2, fill_width-2, height-2], fill=fill_color)
    
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
    
    print("\n=== Creating UI Elements ===")
    
    create_ui_panel(
        (300, 100), (50, 50, 100, 200), (100, 100, 200), 
        "Warm Snow UI",
        os.path.join(ui_dir, "placeholder_panel.png")
    )
    
    create_ui_panel(
        (200, 60), (100, 50, 50, 200), (200, 100, 100), 
        "Start Game",
        os.path.join(ui_dir, "placeholder_button.png")
    )
    
    create_health_bar(
        256, 32, 0.75,
        os.path.join(ui_dir, "placeholder_healthbar.png")
    )
    
    create_health_bar(
        256, 32, 0.5,
        os.path.join(ui_dir, "placeholder_healthbar_half.png")
    )
    
    create_health_bar(
        256, 32, 0.25,
        os.path.join(ui_dir, "placeholder_healthbar_low.png")
    )
    
    print("\n=== All placeholder resources created successfully! ===")
    print("\nNote: Created effects:")
    print("  - Slash attack (8 frames)")
    print("  - Sword swing (10 frames)")
    print("  - Dash effect (8 frames)")
    print("  - Hit effect (8 frames)")

if __name__ == "__main__":
    main()
