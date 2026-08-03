from PIL import Image, ImageDraw, ImageFont
import os

size = 96
img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
draw = ImageDraw.Draw(img)

# Draw a solid white circle
draw.ellipse((8, 8, size-8, size-8), fill=(255, 255, 255, 255))

# Draw a transparent 'A' or 'AF'
# Since we can't easily draw transparent text over a white shape without composite, we'll draw a white shape with a 'AF' mask.
mask = Image.new('L', (size, size), 0)
mask_draw = ImageDraw.Draw(mask)
mask_draw.ellipse((8, 8, size-8, size-8), fill=255)

# Cut out text
try:
    font = ImageFont.truetype("Arial.ttf", 50)
except:
    font = ImageFont.load_default()

text = "A"
# We'll just draw the text in black on the white mask
# Get text bounding box to center it
left, top, right, bottom = mask_draw.textbbox((0, 0), text, font=font)
w = right - left
h = bottom - top
mask_draw.text(((size-w)/2 - left, (size-h)/2 - top), text, fill=0, font=font)

# Apply mask
final_img = Image.new('RGBA', (size, size))
final_img.paste((255, 255, 255, 255), (0,0), mask=mask)

out_path = 'android/app/src/main/res/drawable/ic_notification.png'
final_img.save(out_path)
print("Created", out_path)
