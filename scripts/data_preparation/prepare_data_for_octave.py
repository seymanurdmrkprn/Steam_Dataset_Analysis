# Steam Veri Hazırlama - Octave için
import pandas as pd
import numpy as np

print("CSV dosyası okunuyor...")
df = pd.read_csv("steam_games.csv")

print(f"✅ Veri yüklendi: {len(df):,} oyun")

# 1. Başarı metriği oluştur
print("\n1. Başarı metriği hesaplanıyor...")
df['positive_rate'] = df['Positive'] / (df['Positive'] + df['Negative'])
df['positive_rate'] = df['positive_rate'] * 100  # Yüzde olarak

# 1.5. Cinsel içerik filtresi (akademik uygunluk için)
print("1.5. Uygunsuz içerik filtreleniyor...")
initial_count = len(df)

# Tags, Genres, Categories sütunlarında cinsel içerik kontrolü
sexual_keywords = [
    'sexual', 'sex', 'nsfw', 'adult', 'nude', 'nudity', 'erotic', 
    'hentai', 'porn', 'xxx', 'mature', '18+', 'explicit'
]

# Filtreleme fonksiyonu
def has_sexual_content(row):
    text_fields = []
    
    # Kontrol edilecek alanları birleştir
    if pd.notna(row['Tags']):
        text_fields.append(str(row['Tags']).lower())
    if pd.notna(row['Genres']):
        text_fields.append(str(row['Genres']).lower())
    if pd.notna(row['Categories']):
        text_fields.append(str(row['Categories']).lower())
    if pd.notna(row['About the game']):
        text_fields.append(str(row['About the game']).lower())
    
    combined_text = ' '.join(text_fields)
    
    # Herhangi bir anahtar kelime var mı?
    for keyword in sexual_keywords:
        if keyword in combined_text:
            return True
    return False

# Uygunsuz içerik olanları işaretle
df['has_sexual_content'] = df.apply(has_sexual_content, axis=1)
filtered_count = df['has_sexual_content'].sum()

# Temiz oyunları seç
df = df[~df['has_sexual_content']].copy()
df = df.drop('has_sexual_content', axis=1)

print(f"   {filtered_count:,} uygunsuz içerikli oyun kaldırıldı")
print(f"   {len(df):,} temiz oyun kaldı")

# 2. Minimum review filtrelemesi - KALDIRILDI (tüm veriyi kullan)
print("2. Temel temizlik yapılıyor...")
df_filtered = df.copy()
# Sadece gerekli sütunları kontrol et
df_filtered = df_filtered[df_filtered['Positive'].notna() & df_filtered['Negative'].notna()]
df_filtered = df_filtered[(df_filtered['Positive'] + df_filtered['Negative']) > 0]  # En az 1 review
print(f"   {len(df_filtered):,} oyun (en az 1 review olan)")

# 3. Outlier temizleme - KALDIRILDI (tüm fiyat aralığını kullan)
print("3. Fiyat temizliği (NaN kontrolü)...")
df_filtered = df_filtered[df_filtered['Price'].notna()]
df_filtered = df_filtered[df_filtered['positive_rate'].notna()]
print(f"   {len(df_filtered):,} oyun kaldı")

# 4. Fiyat kategorileri
print("4. Fiyat kategorileri oluşturuluyor...")
def categorize_price(price):
    if price == 0:
        return 0  # 'Free (0)'
    elif price < 5:
        return 1  # '0-5'
    elif price < 10:
        return 2  # '5-10'
    elif price < 20:
        return 3  # '10-20'
    elif price < 30:
        return 4  # '20-30'
    elif price < 40:
        return 5  # '30-40'
    elif price < 60:
        return 6  # '40-60'
    else:
        return 7  # '60+'

df_filtered['price_category'] = df_filtered['Price'].apply(categorize_price)

# 5. Tür kategorizasyonu (Panel 6 için)
print("5. Tür analizi yapılıyor...")
# Genres sütunu boş olanları temizle
df_filtered['Genres'] = df_filtered['Genres'].fillna('Unknown')

# En popüler 4 türü belirle
genre_list = []
for genres in df_filtered['Genres']:
    if isinstance(genres, str) and genres != 'Unknown':
        genre_list.extend(genres.split(','))
        
from collections import Counter
genre_counts = Counter(genre_list)
top_genres = [g[0] for g in genre_counts.most_common(4)]
print(f"   En popüler türler: {top_genres}")

# Her oyun için ana türü belirle
def get_main_genre(genre_str):
    if pd.isna(genre_str) or genre_str == 'Unknown':
        return 4  # 'Other'
    genres = genre_str.split(',')
    for i, genre in enumerate(top_genres):
        if genre in genres:
            return i
    return 4  # 'Other'

df_filtered['main_genre'] = df_filtered['Genres'].apply(get_main_genre)

# 6. Octave için temiz veri kaydet
print("\n6. Octave için veri kaydediliyor...")
octave_data = df_filtered[['Price', 'positive_rate', 'price_category', 'main_genre', 'Name']].copy()
octave_data.to_csv('steam_analysis/octave_data.csv', index=False)

# İstatistikleri kaydet
stats_data = {
    'total_games': len(df_filtered),
    'top_genres': top_genres
}

# Özet istatistikler
print("\n" + "="*60)
print("VERİ ÖZETİ")
print("="*60)
print(f"Toplam oyun sayısı: {len(df_filtered):,}")
print(f"\nFiyat istatistikleri:")
print(f"  Min: ${df_filtered['Price'].min():.2f}")
print(f"  Max: ${df_filtered['Price'].max():.2f}")
print(f"  Ortalama: ${df_filtered['Price'].mean():.2f}")
print(f"  Medyan: ${df_filtered['Price'].median():.2f}")
print(f"\nPositive Rate istatistikleri:")
print(f"  Min: {df_filtered['positive_rate'].min():.1f}%")
print(f"  Max: {df_filtered['positive_rate'].max():.1f}%")
print(f"  Ortalama: {df_filtered['positive_rate'].mean():.1f}%")
print(f"  Medyan: {df_filtered['positive_rate'].median():.1f}%")
print(f"\nFiyat kategorilerine göre dağılım:")
price_labels = ['Free (0)', '0-5', '5-10', '10-20', '20-30', '30-40', '40-60', '60+']
for i, label in enumerate(price_labels):
    count = len(df_filtered[df_filtered['price_category'] == i])
    print(f"  {label:12s}: {count:5,} oyun")
print(f"\nEn popüler türler:")
for i, genre in enumerate(top_genres):
    count = len(df_filtered[df_filtered['main_genre'] == i])
    print(f"  {genre:20s}: {count:5,} oyun")

# Kategori eşleme dosyası oluştur
with open('steam_analysis/category_mapping.txt', 'w', encoding='utf-8') as f:
    f.write("FIYAT KATEGORİLERİ (price_category):\n")
    for i, label in enumerate(price_labels):
        f.write(f"{i} = {label}\n")
    f.write("\nTÜR KATEGORİLERİ (main_genre):\n")
    for i, genre in enumerate(top_genres):
        f.write(f"{i} = {genre}\n")
    f.write(f"4 = Other\n")

print("\n✅ Veri hazırlama tamamlandı!")
print("   📄 octave_data.csv - Ana veri dosyası")
print("   📄 category_mapping.txt - Kategori açıklamaları")
