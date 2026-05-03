import urllib.request
import time

food_images = {
    'chapati_beans.jpg': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&q=80&w=800', # Indian bread/food
    'spanish_omelette.jpg': 'https://images.unsplash.com/photo-1525059696034-4967a8e1dca2?auto=format&fit=crop&q=80&w=800', # Eggs/omelette
    'pilau.jpg': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&q=80&w=800', # Rice
    'chips_chicken.jpg': 'https://images.unsplash.com/photo-1605008585244-a0c5c4e0f49c?auto=format&fit=crop&q=80&w=800' # Chicken chips
}

for img_name, img_url in food_images.items():
    print(f"Downloading {img_name}...")
    try:
        req = urllib.request.Request(img_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            with open(f"web/images/{img_name}", 'wb') as out_file:
                out_file.write(response.read())
    except Exception as e:
        print(f"Failed to download image {img_name}: {e}")
    time.sleep(0.5)

print("Failed images successfully downloaded.")
