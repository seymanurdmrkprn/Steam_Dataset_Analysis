#!/usr/bin/env python3
"""
Octave için basitleştirilmiş veri dosyaları oluşturur
"""

import pandas as pd

print("Demo verisini okuyorum...")
df = pd.read_csv('../../data/processed/demo_data.csv')

# Sayısal veriler (Octave dlmread için)
print("Sayisal veri dosyasi olusturuluyor...")
numeric_data = df[['AppID', 'Price', 'Positive', 'Negative', 'demo_score']].copy()
numeric_data.to_csv('../../data/processed/demo_data_simple.csv', index=False)

# String veriler (| ile ayrılmış)
print("String veri dosyasi olusturuluyor...")
with open('../../data/processed/demo_data_names.txt', 'w', encoding='utf-8') as f:
    f.write("Name|Developer|Genre\n")
    for idx, row in df.iterrows():
        name = str(row['Name']).replace('|', '-')
        dev = str(row['Developers']).replace('|', '-')
        genre = str(row['Genres']).replace('|', '-')
        f.write(f"{name}|{dev}|{genre}\n")

print("✅ Basitlestirilmis veri dosyalari olusturuldu!")
print("   - demo_data_simple.csv (sayisal veriler)")
print("   - demo_data_names.txt (string veriler)")
