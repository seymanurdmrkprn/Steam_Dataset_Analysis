"""
TIME SERIES DATA PREPARATION
Prepares Steam games data for temporal analysis
"""

import pandas as pd
import numpy as np
from datetime import datetime

print("=" * 60)
print("TIME SERIES DATA PREPARATION")
print("=" * 60)

# Load data
df = pd.read_csv('steam_games.csv')
print(f"\n📊 Loaded {len(df):,} games")

# Parse dates
df['Release date'] = pd.to_datetime(df['Release date'], errors='coerce')
df_time = df.dropna(subset=['Release date']).copy()
print(f"✓ Valid dates: {len(df_time):,} games ({len(df_time)/len(df)*100:.1f}%)")

# Extract time components
df_time['release_year'] = df_time['Release date'].dt.year
df_time['release_month'] = df_time['Release date'].dt.month
df_time['release_quarter'] = df_time['Release date'].dt.quarter

# Filter to reasonable years (1995-2024)
df_time = df_time[(df_time['release_year'] >= 1995) & (df_time['release_year'] <= 2024)]
print(f"✓ Filtered to 1995-2024: {len(df_time):,} games")

# Calculate positive rate
df_time['positive_rate'] = (df_time['Positive'] / (df_time['Positive'] + df_time['Negative']) * 100)

# Filter games with at least 50 reviews
df_time = df_time[(df_time['Positive'] + df_time['Negative']) >= 50]
print(f"✓ With 50+ reviews: {len(df_time):,} games")

# === PANEL 1: YEARLY STATISTICS ===
print("\n📈 Panel 1: Yearly Statistics")
yearly_stats = df_time.groupby('release_year').agg(
    game_count=('Name', 'count'),
    avg_price=('Price', 'mean'),
    median_price=('Price', 'median'),
    avg_positive_rate=('positive_rate', 'mean'),
    avg_playtime=('Median playtime forever', 'mean'),
    windows_pct=('Windows', lambda x: (x == True).sum() / len(x) * 100),
    mac_pct=('Mac', lambda x: (x == True).sum() / len(x) * 100),
    linux_pct=('Linux', lambda x: (x == True).sum() / len(x) * 100)
).reset_index()

# Add 3-year moving averages for smoother trends
for col in ['avg_price', 'avg_positive_rate']:
    yearly_stats[f'{col}_ma3'] = yearly_stats[col].rolling(window=3, min_periods=1).mean()

yearly_stats.to_csv('time_panel1_yearly.csv', index=False)
print(f"  ✓ Saved: {len(yearly_stats)} years")
print(f"  • Year range: {yearly_stats['release_year'].min()}-{yearly_stats['release_year'].max()}")
print(f"  • Peak year: {yearly_stats.loc[yearly_stats['game_count'].idxmax(), 'release_year']} ({yearly_stats['game_count'].max():,} games)")

# === PANEL 2: PLATFORM EVOLUTION ===
print("\n🖥️  Panel 2: Platform Evolution")
platform_data = df_time.groupby('release_year').agg(
    total_games=('Name', 'count'),
    windows_count=('Windows', lambda x: (x == True).sum()),
    mac_count=('Mac', lambda x: (x == True).sum()),
    linux_count=('Linux', lambda x: (x == True).sum())
).reset_index()

platform_data['windows_pct'] = platform_data['windows_count'] / platform_data['total_games'] * 100
platform_data['mac_pct'] = platform_data['mac_count'] / platform_data['total_games'] * 100
platform_data['linux_pct'] = platform_data['linux_count'] / platform_data['total_games'] * 100

platform_data.to_csv('time_panel2_platforms.csv', index=False)
print(f"  ✓ Saved: {len(platform_data)} years")
print(f"  • Current Windows: {platform_data.iloc[-1]['windows_pct']:.1f}%")
print(f"  • Current Mac: {platform_data.iloc[-1]['mac_pct']:.1f}%")
print(f"  • Current Linux: {platform_data.iloc[-1]['linux_pct']:.1f}%")

# === PANEL 3: MONTHLY HEATMAP (Last 10 years) ===
print("\n📅 Panel 3: Monthly Release Patterns")
recent_years = df_time[df_time['release_year'] >= 2014].copy()
monthly_heatmap = recent_years.groupby(['release_year', 'release_month']).size().unstack(fill_value=0)

# Ensure all 12 months exist
for month in range(1, 13):
    if month not in monthly_heatmap.columns:
        monthly_heatmap[month] = 0
monthly_heatmap = monthly_heatmap.sort_index(axis=1)

monthly_heatmap.to_csv('time_panel3_monthly.csv')
print(f"  ✓ Saved: {len(monthly_heatmap)} years x 12 months")
busiest_month = monthly_heatmap.sum(axis=0).idxmax()
month_names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
print(f"  • Busiest month overall: {month_names[busiest_month]}")

# === PANEL 4: GENRE TRENDS ===
print("\n🎮 Panel 4: Genre Trends Over Time")

# Split all genre combinations and count individual genres
# Genres are separated by commas, not semicolons
all_individual_genres = []
for genres_str in df_time['Genres'].dropna():
    # Split by comma to get individual genres
    genres = [g.strip() for g in genres_str.split(',')]
    all_individual_genres.extend(genres)

# Get top 12 individual genres
genre_counts = pd.Series(all_individual_genres).value_counts()
top_genres = genre_counts.head(12).index.tolist()

print(f"  • Top 12 individual genres:")
for i, genre in enumerate(top_genres):
    print(f"    {i+1}. {genre} ({genre_counts[genre]:,} occurrences)")

# For each year, count games containing each genre
genre_yearly_data = []
for year in sorted(df_time['release_year'].unique()):
    year_games = df_time[df_time['release_year'] == year]
    year_counts = {'release_year': int(year)}
    
    for genre in top_genres:
        # Count games where this genre appears (match whole word)
        count = sum(year_games['Genres'].fillna('').str.contains(f'\\b{genre}\\b', regex=True, na=False, case=False))
        year_counts[genre] = int(count)
    
    genre_yearly_data.append(year_counts)

genre_yearly = pd.DataFrame(genre_yearly_data)

# Rename columns to remove spaces and special characters for easier Octave reading
column_mapping = {'release_year': 'Year'}
for i, genre in enumerate(top_genres):
    # Use simple column names: Genre1, Genre2, etc.
    column_mapping[genre] = f'Genre{i+1}'

genre_yearly_renamed = genre_yearly.rename(columns=column_mapping)
genre_yearly_renamed.to_csv('time_panel4_genres.csv', index=False)
print(f"  ✓ Saved: {len(genre_yearly)} years x {len(top_genres)} genres")

# Also save with original names for reference
genre_yearly.to_csv('time_panel4_genres_named.csv', index=False)

# Create genre mapping file
with open('time_genre_mapping.txt', 'w') as f:
    f.write("TOP 12 INDIVIDUAL GENRES:\n\n")
    for i, genre in enumerate(top_genres):
        count = genre_counts[genre]
        f.write(f"{i+1}. {genre} ({count:,} occurrences)\n")

print("\n" + "=" * 60)
print("✅ TIME SERIES DATA PREPARATION COMPLETE")
print("=" * 60)
print("\nGenerated files:")
print("  1. time_panel1_yearly.csv - Yearly statistics")
print("  2. time_panel2_platforms.csv - Platform evolution")
print("  3. time_panel3_monthly.csv - Monthly release heatmap")
print("  4. time_panel4_genres.csv - Genre trends")
print("  5. time_genre_mapping.txt - Genre labels")
print("\n🎨 Ready for Octave visualization!")
