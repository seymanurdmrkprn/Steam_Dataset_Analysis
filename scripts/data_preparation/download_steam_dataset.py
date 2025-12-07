# Steam Games Dataset - Direkt Parquet İndirme
import pandas as pd
import urllib.request
import os

print("Steam Games Dataset indiriliyor...")
print("(Parquet dosyası ~123 MB, biraz zaman alabilir)\n")

# Parquet dosyasını indir
url = "https://huggingface.co/datasets/FronkonGames/steam-games-dataset/resolve/refs%2Fconvert%2Fparquet/default/train/0000.parquet"
filename = "steam_games.parquet"

if not os.path.exists(filename):
    print("İndiriliyor...")
    urllib.request.urlretrieve(url, filename)
    print(f"✅ İndirme tamamlandı: {filename}")
else:
    print(f"✅ Dosya zaten mevcut: {filename}")

# Parquet dosyasını oku
print("\nVeri okunuyor...")
df = pd.read_parquet(filename)

print(f"\n✅ Veri yüklendi!")
print(f"Toplam oyun: {len(df):,}")
print(f"Toplam sütun: {len(df.columns)}")
print(f"\nİlk 5 sütun: {list(df.columns)[:5]}")
print(f"\nVeri 'df' değişkeninde hazır.")
