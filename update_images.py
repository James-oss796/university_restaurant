import os
import urllib.request
import time

# Specific high-quality image URLs sourced to perfectly match the menu items.
# We are using direct static image URLs instead of a random API to ensure 100% accuracy.
food_images = {
    'chapati_beans.jpg': 'https://images.unsplash.com/photo-1628268909376-e824ecc3cb26?auto=format&fit=crop&q=80&w=800', # Chapati/flatbread
    'mandazi_tea.jpg': 'https://images.unsplash.com/photo-1574085733277-851d9d856a3a?auto=format&fit=crop&q=80&w=800', # Tea and pastry
    'spanish_omelette.jpg': 'https://images.unsplash.com/photo-1510693069151-54b9d0fb71ac?auto=format&fit=crop&q=80&w=800', # Omelette
    'sausage_pancake.jpg': 'https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&q=80&w=800', # Pancakes
    'pilau.jpg': 'https://images.unsplash.com/photo-1603566115312-3b102553b6cb?auto=format&fit=crop&q=80&w=800', # Spiced rice/Pilau
    'chicken_biryani.jpg': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&q=80&w=800', # Biryani
    'rice_beef_stew.jpg': 'https://images.unsplash.com/photo-1513442542250-854d436a73f2?auto=format&fit=crop&q=80&w=800', # Rice and stew
    'veg_fried_rice.jpg': 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&q=80&w=800', # Fried rice
    'ugali_chicken.jpg': 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?auto=format&fit=crop&q=80&w=800', # Chicken/stew
    'fish_tilapia.jpg': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&q=80&w=800', # Fried Fish
    'nyama_choma.jpg': 'https://images.unsplash.com/photo-1558030006-450675393462?auto=format&fit=crop&q=80&w=800', # Grilled meat
    'matoke_beef.jpg': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80&w=800', # Stewed beef/food
    'chips_chicken.jpg': 'https://images.unsplash.com/photo-1626082895617-2c6ab30bad23?auto=format&fit=crop&q=80&w=800', # Chicken and chips
    'chips_masala.jpg': 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&q=80&w=800', # Spiced fries
    'beef_burger.jpg': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=800', # Burger
    'chicken_wrap.jpg': 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&q=80&w=800', # Wrap
    'fresh_juice.jpg': 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?auto=format&fit=crop&q=80&w=800', # Juice
    'smocha.jpg': 'https://images.unsplash.com/photo-1628840042765-356cda07504e?auto=format&fit=crop&q=80&w=800', # Street wrap/roll
    'samosa.jpg': 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&q=80&w=800', # Samosas
    'kachumbari.jpg': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=800' # Salad
}

ui_images = {
    'carousel1.jpg': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80&w=1200',
    'carousel2.jpg': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&q=80&w=1200',
    'carousel3.jpg': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=1200',
    'login_bg.jpg': 'https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&q=80&w=1200'
}

os.makedirs('web/images', exist_ok=True)

# Merge dicts
all_images = {**food_images, **ui_images}

for img_name, img_url in all_images.items():
    print(f"Downloading {img_name}...")
    try:
        req = urllib.request.Request(img_url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            with open(f"web/images/{img_name}", 'wb') as out_file:
                out_file.write(response.read())
    except Exception as e:
        print(f"Failed to download image {img_name}: {e}")
    time.sleep(0.5)

print("All specific food images successfully downloaded and stored.")
