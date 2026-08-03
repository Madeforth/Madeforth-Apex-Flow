from PIL import Image

def generate_notification_icon():
    img = Image.open('android/app/src/main/res/drawable/apexflow_brand_icon.png').convert("RGBA")
    data = img.getdata()
    new_data = []
    
    # We want a white silhouette on a transparent background.
    # We can use the alpha channel if it exists, or a luminance threshold to decide transparency.
    # Since the previous file was a JPEG, its alpha channel might be fully opaque.
    # Let's check its pixels. If it's fully opaque, we can threshold by luminance or a specific color.
    # Usually a brand icon has a logo on a dark/light background.
    for item in data:
        # item is (R, G, B, A)
        r, g, b, a = item
        brightness = sum([r, g, b]) / 3
        
        # If the background is dark and logo is light:
        # Or if we just want to make a simple circle or extract the shape.
        if brightness > 128:
            new_data.append((255, 255, 255, a))
        else:
            new_data.append((255, 255, 255, 0)) # transparent

    img.putdata(new_data)
    img.save('android/app/src/main/res/drawable/ic_notification.png', 'PNG')

generate_notification_icon()
