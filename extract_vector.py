from PIL import Image

def extract_silhouette(input_path, output_path, target_size=96):
    img = Image.open(input_path).convert('RGB')
    width, height = img.size
    
    # Estimate background color from corners
    corners = [
        img.getpixel((0, 0)),
        img.getpixel((width-1, 0)),
        img.getpixel((0, height-1)),
        img.getpixel((width-1, height-1))
    ]
    # Average corner color
    bg_r = sum(c[0] for c in corners) // 4
    bg_g = sum(c[1] for c in corners) // 4
    bg_b = sum(c[2] for c in corners) // 4
    
    # Create new transparent image
    out_img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    pixels = img.load()
    out_pixels = out_img.load()
    
    tolerance = 40 # Color distance tolerance
    
    for y in range(height):
        for x in range(width):
            r, g, b = pixels[x, y]
            # Calculate distance from background color
            dist = ((r - bg_r)**2 + (g - bg_g)**2 + (b - bg_b)**2)**0.5
            
            if dist > tolerance:
                # Foreground -> Make white
                # We can also add some anti-aliasing if we scale opacity by dist, 
                # but a hard threshold is fine for scaling down.
                out_pixels[x, y] = (255, 255, 255, 255)
            else:
                # Background -> Make transparent
                out_pixels[x, y] = (255, 255, 255, 0)
                
    # Now we have a high-res silhouette. Let's crop to bounding box.
    bbox = out_img.getbbox()
    if bbox:
        out_img = out_img.crop(bbox)
        
    # Create a square canvas to center the cropped image
    max_dim = max(out_img.size)
    padded = Image.new('RGBA', (max_dim, max_dim), (0,0,0,0))
    offset = ((max_dim - out_img.width) // 2, (max_dim - out_img.height) // 2)
    padded.paste(out_img, offset)
    
    # Add a little padding (10%)
    pad = int(max_dim * 0.1)
    final_square = Image.new('RGBA', (max_dim + 2*pad, max_dim + 2*pad), (0,0,0,0))
    final_square.paste(padded, (pad, pad))
    
    # Resize
    final_icon = final_square.resize((target_size, target_size), Image.Resampling.LANCZOS)
    final_icon.save(output_path)
    print("Saved", output_path)

extract_silhouette('android/app/src/main/res/drawable/apexflow_brand_icon.png', 'android/app/src/main/res/drawable/ic_notification.png')
