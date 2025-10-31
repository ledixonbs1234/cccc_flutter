"""
Script tạo icon cho ứng dụng CCCD Flutter
Yêu cầu: pip install pillow
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_cccd_icon(output_path, size=1024):
    """
    Tạo icon cho ứng dụng CCCD với thiết kế đơn giản
    """
    # Tạo canvas với màu nền gradient
    img = Image.new('RGB', (size, size), color='#2C3E50')
    draw = ImageDraw.Draw(img)
    
    # Màu sắc từ cờ Việt Nam
    red = '#DA251D'
    yellow = '#FFCD00'
    white = '#FFFFFF'
    
    # Vẽ nền gradient đỏ
    for y in range(size):
        color_value = int(218 - (y / size) * 30)  # Gradient từ đỏ đậm đến đỏ nhạt
        draw.rectangle([(0, y), (size, y+1)], fill=(color_value, 37, 29))
    
    # Vẽ hình thẻ CCCD (hình chữ nhật bo góc ở giữa)
    card_width = int(size * 0.7)
    card_height = int(size * 0.45)
    card_x = (size - card_width) // 2
    card_y = (size - card_height) // 2
    card_radius = 30
    
    # Vẽ bóng cho thẻ
    shadow_offset = 15
    draw.rounded_rectangle(
        [(card_x + shadow_offset, card_y + shadow_offset), 
         (card_x + card_width + shadow_offset, card_y + card_height + shadow_offset)],
        radius=card_radius,
        fill='#00000040'
    )
    
    # Vẽ thẻ CCCD màu trắng
    draw.rounded_rectangle(
        [(card_x, card_y), (card_x + card_width, card_y + card_height)],
        radius=card_radius,
        fill=white
    )
    
    # Vẽ viền vàng cho thẻ
    draw.rounded_rectangle(
        [(card_x, card_y), (card_x + card_width, card_y + card_height)],
        radius=card_radius,
        outline=yellow,
        width=8
    )
    
    # Vẽ các đường line mô phỏng thông tin trên thẻ
    line_x_start = card_x + 40
    line_y_start = card_y + 40
    line_spacing = 35
    
    # Vẽ ảnh đại diện (hình vuông bên trái)
    photo_size = int(card_height * 0.6)
    photo_x = card_x + 30
    photo_y = card_y + 30
    draw.rounded_rectangle(
        [(photo_x, photo_y), (photo_x + photo_size, photo_y + photo_size)],
        radius=10,
        fill='#E0E0E0',
        outline='#999999',
        width=3
    )
    
    # Vẽ các line thông tin bên phải ảnh
    info_x_start = photo_x + photo_size + 40
    for i in range(4):
        line_y = photo_y + 15 + (i * line_spacing)
        line_width = card_width - (info_x_start - card_x) - 40
        if i % 2 == 0:
            line_width = int(line_width * 0.8)
        draw.rounded_rectangle(
            [(info_x_start, line_y), (info_x_start + line_width, line_y + 15)],
            radius=5,
            fill='#BDBDBD'
        )
    
    # Vẽ biểu tượng quét/scan (các đường góc)
    corner_size = 60
    corner_thickness = 12
    corner_color = yellow
    
    # Góc trên trái
    draw.rectangle([(card_x - 20, card_y - 20), (card_x - 20 + corner_size, card_y - 20 + corner_thickness)], fill=corner_color)
    draw.rectangle([(card_x - 20, card_y - 20), (card_x - 20 + corner_thickness, card_y - 20 + corner_size)], fill=corner_color)
    
    # Góc trên phải
    draw.rectangle([(card_x + card_width + 20 - corner_size, card_y - 20), 
                   (card_x + card_width + 20, card_y - 20 + corner_thickness)], fill=corner_color)
    draw.rectangle([(card_x + card_width + 20 - corner_thickness, card_y - 20), 
                   (card_x + card_width + 20, card_y - 20 + corner_size)], fill=corner_color)
    
    # Góc dưới trái
    draw.rectangle([(card_x - 20, card_y + card_height + 20 - corner_thickness), 
                   (card_x - 20 + corner_size, card_y + card_height + 20)], fill=corner_color)
    draw.rectangle([(card_x - 20, card_y + card_height + 20 - corner_size), 
                   (card_x - 20 + corner_thickness, card_y + card_height + 20)], fill=corner_color)
    
    # Góc dưới phải
    draw.rectangle([(card_x + card_width + 20 - corner_size, card_y + card_height + 20 - corner_thickness), 
                   (card_x + card_width + 20, card_y + card_height + 20)], fill=corner_color)
    draw.rectangle([(card_x + card_width + 20 - corner_thickness, card_y + card_height + 20 - corner_size), 
                   (card_x + card_width + 20, card_y + card_height + 20)], fill=corner_color)
    
    # Lưu file
    img.save(output_path, quality=95)
    print(f"✓ Đã tạo icon: {output_path}")
    
    # Tạo các kích thước khác nhau
    sizes = [512, 192, 96]
    base_name = os.path.splitext(output_path)[0]
    for s in sizes:
        resized = img.resize((s, s), Image.Resampling.LANCZOS)
        output = f"{base_name}_{s}.png"
        resized.save(output, quality=95)
        print(f"✓ Đã tạo icon {s}x{s}: {output}")

if __name__ == "__main__":
    # Đường dẫn output
    output_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "icon")
    os.makedirs(output_dir, exist_ok=True)
    
    # Tạo icon PNG
    output_path = os.path.join(output_dir, "icon.png")
    create_cccd_icon(output_path, 1024)
    
    print("\n✅ Hoàn thành! Các file icon đã được tạo trong thư mục assets/icon/")
    print("📝 Tiếp theo:")
    print("   1. Cập nhật flutter_launcher_icons.yaml để sử dụng icon.png")
    print("   2. Chạy: flutter pub run flutter_launcher_icons")
