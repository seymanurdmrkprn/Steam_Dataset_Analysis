"""
DEMO İÇİN BİLİNEN OYUNLARI FİLTRELEME
Octave demo için tanınmış yapımcı ve oyunlardan oluşan küçük bir veri havuzu oluşturur
"""

import pandas as pd
import numpy as np

# Ana veriyi yükle
print("Ana veri yükleniyor...")
df = pd.read_csv('../../data/raw/steam_games.csv')
print(f"Toplam oyun sayısı: {len(df):,}")

# Bilinen yapımcılar ve yayıncılar
populer_yapimcilar = [
    'Valve', 'Rockstar', 'CD PROJEKT RED', 'Bethesda', 'Ubisoft', 'Electronic Arts',
    'Square Enix', 'Capcom', 'FromSoftware', 'Kojima Productions', 'BioWare',
    'Bungie', 'Epic Games', 'Blizzard', 'id Software', 'Obsidian', 'Paradox',
    '2K Games', 'SEGA', 'Nintendo', 'Sony', 'Microsoft', 'Activision',
    'Take-Two', 'Bandai Namco', 'Konami', 'Supergiant Games', 'Team Cherry',
    'ConcernedApe', 'Re-Logic', 'Mojang', 'Hello Games', 'Grinding Gear Games',
    'Digital Extremes', 'Facepunch Studios', 'Klei Entertainment'
]

print("\nBilinen yapımcıları filtreleme...")
# Developer veya Publisher'da bu yapımcılardan herhangi biri geçiyorsa al
bilinen_oyunlar = df[
    df['Developers'].str.contains('|'.join(populer_yapimcilar), case=False, na=False, regex=True) |
    df['Publishers'].str.contains('|'.join(populer_yapimcilar), case=False, na=False, regex=True)
].copy()

print(f"Bilinen yapımcıların oyunları: {len(bilinen_oyunlar):,}")

# Ayrıca çok popüler/bilinen oyunları da ekle (review sayısına göre)
print("\nEn popüler oyunları ekleme...")
populer_oyunlar = df.nlargest(500, 'Positive')

# İkisini birleştir ve tekrarları temizle
demo_havuzu = pd.concat([bilinen_oyunlar, populer_oyunlar]).drop_duplicates(subset=['AppID'])

print(f"Demo havuzu toplam oyun: {len(demo_havuzu):,}")

# En iyi bilinen oyunları önceliklendir (rating + review sayısı)
demo_havuzu['demo_score'] = (
    demo_havuzu['Positive'] / (demo_havuzu['Positive'] + demo_havuzu['Negative'] + 1) * 0.5 +
    np.log1p(demo_havuzu['Positive'] + demo_havuzu['Negative']) / 20 * 0.5
)

demo_havuzu = demo_havuzu.nlargest(3000, 'demo_score')

print(f"\nFinal demo havuzu: {len(demo_havuzu):,} oyun")

# İstatistikler
print("\n" + "="*60)
print("DEMO HAVUZU İSTATİSTİKLERİ")
print("="*60)
print(f"Toplam oyun: {len(demo_havuzu):,}")
print(f"Ortalama fiyat: ${demo_havuzu['Price'].mean():.2f}")
print(f"Ortalama rating: {(demo_havuzu['Positive'] / (demo_havuzu['Positive'] + demo_havuzu['Negative'])).mean() * 100:.1f}%")
print(f"Toplam review: {(demo_havuzu['Positive'] + demo_havuzu['Negative']).sum():,}")

# En çok oyunu olan yapımcılar
print("\nEn çok temsil edilen yapımcılar:")
df_main_dev = demo_havuzu.copy()
df_main_dev['Main_Developer'] = df_main_dev['Developers'].str.split(',').str[0].str.strip()
top_devs = df_main_dev['Main_Developer'].value_counts().head(15)
for dev, count in top_devs.items():
    print(f"  {dev}: {count} oyun")

# Örnek oyunlar
print("\nÖrnek tanınmış oyunlar (ilk 30):")
ornek_oyunlar = demo_havuzu.nlargest(30, 'demo_score')[['Name', 'Developers', 'Price', 'Positive']]
for idx, row in ornek_oyunlar.iterrows():
    dev = row['Developers'].split(',')[0] if pd.notna(row['Developers']) else 'Unknown'
    print(f"  - {row['Name'][:50]:50} | {dev[:25]:25} | ${row['Price']:6.2f} | {row['Positive']:>8,} reviews")

# Kaydet
output_file = '../../data/processed/demo_data.csv'
demo_havuzu.to_csv(output_file, index=False)
print(f"\n✅ Demo verisi kaydedildi: {output_file}")
print(f"   Boyut: {len(demo_havuzu):,} oyun")
print(f"   Octave'de hızlıca yüklenebilir!")
