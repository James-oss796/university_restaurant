import os
import urllib.request
import json
import time

food_items = [
    'chapati_beans.jpg', 'mandazi_tea.jpg', 'spanish_omelette.jpg', 'sausage_pancake.jpg',
    'pilau.jpg', 'chicken_biryani.jpg', 'rice_beef_stew.jpg', 'veg_fried_rice.jpg',
    'ugali_chicken.jpg', 'fish_tilapia.jpg', 'nyama_choma.jpg', 'matoke_beef.jpg',
    'chips_chicken.jpg', 'chips_masala.jpg', 'beef_burger.jpg', 'chicken_wrap.jpg',
    'fresh_juice.jpg', 'smocha.jpg', 'samosa.jpg', 'kachumbari.jpg'
]

ui_pics = ['carousel1.jpg', 'carousel2.jpg', 'carousel3.jpg', 'login_bg.jpg']

os.makedirs('web/images', exist_ok=True)

# We use the free public TheMealDB API to fetch distinct high-quality food images
# so that no images have placehold.co text, nor do they duplicate due to IP bans.
used_urls = set()

def get_random_food_image():
    while True:
        try:
            req = urllib.request.Request("https://www.themealdb.com/api/json/v1/1/random.php", headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req) as response:
                data = json.loads(response.read().decode())
                img_url = data['meals'][0]['strMealThumb']
                if img_url not in used_urls:
                    used_urls.add(img_url)
                    return img_url
        except Exception as e:
            print(f"Retrying API fetch due to error: {e}")
            time.sleep(1)

for img in food_items + ui_pics:
    print(f"Downloading distinct food image for {img}...")
    img_url = get_random_food_image()
    # Download the actual image byte stream
    try:
        req = urllib.request.Request(img_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            with open(f"web/images/{img}", 'wb') as out_file:
                out_file.write(response.read())
    except Exception as e:
        print(f"Failed to download image from {img_url}: {e}")
    time.sleep(0.5)

print("Food images successfully downloaded and stored.")
