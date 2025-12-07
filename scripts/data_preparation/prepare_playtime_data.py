# Steam Playtime Analysis - Data Preparation
import pandas as pd
import numpy as np

print("📊 PLAYTIME ANALYSIS - Data Preparation")
print("="*60)

# Load main CSV
print("\n1. Loading data...")
df = pd.read_csv("steam_games.csv")
print(f"   ✅ {len(df):,} games loaded")

# Filter: Sexual content removal (reuse previous logic)
print("\n2. Filtering inappropriate content...")
sexual_keywords = [
    'sexual', 'sex', 'nsfw', 'adult', 'nude', 'nudity', 'erotic', 
    'hentai', 'porn', 'xxx', 'mature', '18+', 'explicit'
]

def has_sexual_content(row):
    text_fields = []
    for col in ['Tags', 'Genres', 'Categories', 'About the game']:
        if pd.notna(row[col]):
            text_fields.append(str(row[col]).lower())
    combined = ' '.join(text_fields)
    return any(kw in combined for kw in sexual_keywords)

df['has_sexual'] = df.apply(has_sexual_content, axis=1)
filtered = df['has_sexual'].sum()
df = df[~df['has_sexual']].copy()
df = df.drop('has_sexual', axis=1)
print(f"   ✅ {filtered:,} inappropriate games removed")
print(f"   ✅ {len(df):,} clean games remain")

# Calculate positive rate
print("\n3. Calculating success metrics...")
df['positive_rate'] = df['Positive'] / (df['Positive'] + df['Negative'])
df['positive_rate'] = df['positive_rate'] * 100

# Filter: Minimum 50 reviews
print("\n4. Filtering by review count (min 50)...")
df_filtered = df[(df['Positive'] + df['Negative']) >= 50].copy()
print(f"   ✅ {len(df_filtered):,} games with sufficient reviews")

# Clean playtime data
print("\n5. Processing playtime data...")
df_filtered = df_filtered[df_filtered['Median playtime forever'].notna()].copy()
df_filtered = df_filtered[df_filtered['Median playtime forever'] >= 0].copy()
print(f"   ✅ {len(df_filtered):,} games with valid playtime data")

# Calculate log playtime
df_filtered['log_playtime'] = np.log10(df_filtered['Median playtime forever'] + 1)

# Create playtime categories
def categorize_playtime(hours):
    if hours < 1:
        return 0  # '<1h'
    elif hours < 2:
        return 1  # '1-2h (Refund Zone)'
    elif hours < 5:
        return 2  # '2-5h'
    elif hours < 10:
        return 3  # '5-10h'
    elif hours < 20:
        return 4  # '10-20h'
    elif hours < 50:
        return 5  # '20-50h'
    else:
        return 6  # '50h+'

df_filtered['playtime_category'] = df_filtered['Median playtime forever'].apply(categorize_playtime)

# Top 4 genres
print("\n6. Analyzing genres...")
genre_list = []
for genres in df_filtered['Genres'].dropna():
    if isinstance(genres, str):
        genre_list.extend(genres.split(','))

from collections import Counter
genre_counts = Counter(genre_list)
top_genres = [g[0] for g in genre_counts.most_common(4)]
print(f"   Top genres: {top_genres}")

def get_main_genre(genre_str):
    if pd.isna(genre_str):
        return 4  # Other
    genres = genre_str.split(',')
    for i, genre in enumerate(top_genres):
        if genre in genres:
            return i
    return 4  # Other

df_filtered['main_genre'] = df_filtered['Genres'].apply(get_main_genre)

# Save for Octave
print("\n7. Saving Octave-compatible data...")
octave_cols = [
    'Median playtime forever',
    'positive_rate',
    'log_playtime',
    'playtime_category',
    'main_genre'
]
df_filtered[octave_cols].to_csv('steam_analysis/playtime_data.csv', index=False)

# Save category mapping
with open('steam_analysis/playtime_mapping.txt', 'w', encoding='utf-8') as f:
    f.write("PLAYTIME CATEGORIES:\n")
    cats = ['<1h', '1-2h (Refund)', '2-5h', '5-10h', '10-20h', '20-50h', '50h+']
    for i, label in enumerate(cats):
        f.write(f"{i} = {label}\n")
    f.write("\nGENRE CATEGORIES:\n")
    for i, genre in enumerate(top_genres):
        f.write(f"{i} = {genre}\n")
    f.write("4 = Other\n")

# Statistics
print("\n" + "="*60)
print("DATA SUMMARY")
print("="*60)
print(f"Total games analyzed: {len(df_filtered):,}")
print(f"\nPlaytime statistics:")
print(f"  Min: {df_filtered['Median playtime forever'].min():.1f} hours")
print(f"  Max: {df_filtered['Median playtime forever'].max():.1f} hours")
print(f"  Mean: {df_filtered['Median playtime forever'].mean():.1f} hours")
print(f"  Median: {df_filtered['Median playtime forever'].median():.1f} hours")
print(f"\nSuccess rate statistics:")
print(f"  Min: {df_filtered['positive_rate'].min():.1f}%")
print(f"  Max: {df_filtered['positive_rate'].max():.1f}%")
print(f"  Mean: {df_filtered['positive_rate'].mean():.1f}%")
print(f"  Median: {df_filtered['positive_rate'].median():.1f}%")
print(f"\nPlaytime category distribution:")
for i, label in enumerate(cats):
    count = len(df_filtered[df_filtered['playtime_category'] == i])
    pct = count / len(df_filtered) * 100
    print(f"  {label:20s}: {count:6,} games ({pct:5.1f}%)")
print(f"\nTop genres:")
for i, genre in enumerate(top_genres):
    count = len(df_filtered[df_filtered['main_genre'] == i])
    print(f"  {genre:20s}: {count:6,} games")

print("\n✅ Data preparation complete!")
print("   📄 playtime_data.csv")
print("   📄 playtime_mapping.txt")
