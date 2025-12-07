# Parquet'ten CSV'ye Dönüştürme
import pandas as pd

print("Parquet dosyası okunuyor...")
df = pd.read_parquet("steam_games.parquet")

print(f"✅ Veri yüklendi: {len(df):,} oyun, {len(df.columns)} sütun")

# CSV'ye kaydet
csv_filename = "steam_games.csv"
print(f"\nCSV dosyası oluşturuluyor: {csv_filename}")
df.to_csv(csv_filename, index=False, encoding='utf-8')

print(f"✅ CSV dosyası kaydedildi: {csv_filename}")
print(f"   Boyut: {len(df):,} satır x {len(df.columns)} sütun")
