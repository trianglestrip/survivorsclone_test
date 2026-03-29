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
    
    create_animation_frames(
        "slash", 6, (96, 96), (255, 200, 50),
        os.path.join(textures_dir, "Animations")
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

if __name__ == "__main__":
    main()
