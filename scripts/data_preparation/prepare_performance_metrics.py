"""
PERFORMANCE METRICS DATA PREPARATION
Analyzes successful games and developer performance
"""

import pandas as pd
import numpy as np

print("=" * 60)
print("PERFORMANCE METRICS DATA PREPARATION")
print("=" * 60)

# Load data
df = pd.read_csv('steam_games.csv')
print(f"\n📊 Loaded {len(df):,} games")

# Filter games with at least 100 reviews for reliability
df = df[(df['Positive'] + df['Negative']) >= 100].copy()
print(f"✓ With 100+ reviews: {len(df):,} games")

# Calculate metrics
df['total_reviews'] = df['Positive'] + df['Negative']
df['positive_rate'] = (df['Positive'] / df['total_reviews'] * 100)

# Calculate popularity score for ranking
df['popularity_score'] = (
    0.5 * df['positive_rate'] + 
    0.5 * (np.log10(df['total_reviews'] + 1) / np.log10(df['total_reviews'].max() + 1) * 100)
)

# Sort by popularity score
df = df.sort_values('popularity_score', ascending=False).reset_index(drop=True)

# Select top 100 and a random sample of 100 from the middle range
top_100 = df.head(100).copy()
# Select from middle range (exclude top 500 and bottom 500)
middle_range = df.iloc[500:-500]
average_100 = middle_range.sample(n=100, random_state=42).copy()

print(f"\n🎯 Comparison: Top 100 vs Average 100 (from middle range)")
print(f"  • Top 100 games: Avg score {top_100['positive_rate'].mean():.1f}%, Avg reviews {top_100['total_reviews'].mean():.0f}")
print(f"  • Average 100 games: Avg score {average_100['positive_rate'].mean():.1f}%, Avg reviews {average_100['total_reviews'].mean():.0f}")

# === PANEL 1: HIGH-SCORE GAME CHARACTERISTICS ===
print("\n⭐ Panel 1: Game Characteristics Comparison")

# Compare top 100 vs average 100
characteristics = pd.DataFrame({
    'Category': ['Top 100', 'Average 100'],
    'Avg_Price': [
        top_100['Price'].mean(),
        average_100['Price'].mean()
    ],
    'Avg_Playtime': [
        top_100['Median playtime forever'].mean(),
        average_100['Median playtime forever'].mean()
    ],
    'Avg_DLC_Count': [
        top_100['DLC count'].mean(),
        average_100['DLC count'].mean()
    ],
    'Avg_Reviews': [
        top_100['total_reviews'].mean(),
        average_100['total_reviews'].mean()
    ]
})

characteristics.to_csv('performance_panel1_characteristics.csv', index=False)
print(f"  ✓ Saved characteristics comparison")
print(f"  • Top 100 avg price: ${characteristics.iloc[0]['Avg_Price']:.2f}")
print(f"  • Average 100 avg price: ${characteristics.iloc[1]['Avg_Price']:.2f}")

# === PANEL 2: SUCCESS CORRELATION FACTORS ===
print("\n📈 Panel 2: Success Correlation Factors")

# Use all games with 100+ reviews for correlation
# Calculate correlation between various metrics and success score (positive_rate)

# Define success metrics to analyze
correlation_data = []

# 1. Review Count (log scale for better correlation)
from scipy.stats import spearmanr
corr_reviews = spearmanr(np.log10(df['total_reviews'] + 1), df['positive_rate'])[0]
correlation_data.append(('Review Count', corr_reviews * 100))

# 2. Price
corr_price = spearmanr(df['Price'], df['positive_rate'])[0]
correlation_data.append(('Price', corr_price * 100))

# 3. DLC Count
corr_dlc = spearmanr(df['DLC count'], df['positive_rate'])[0]
correlation_data.append(('DLC Count', corr_dlc * 100))

# 4. Playtime
corr_playtime = spearmanr(df['Median playtime forever'], df['positive_rate'])[0]
correlation_data.append(('Playtime', corr_playtime * 100))

# 5. Multi-platform support (count of platforms)
df['platform_count'] = df[['Windows', 'Mac', 'Linux']].sum(axis=1)
corr_platform = spearmanr(df['platform_count'], df['positive_rate'])[0]
correlation_data.append(('Platform Count', corr_platform * 100))

# 6. Release Year (newer games)
df['Release_Year'] = pd.to_datetime(df['Release date'], errors='coerce').dt.year
df_with_year = df.dropna(subset=['Release_Year'])
if len(df_with_year) > 0:
    corr_year = spearmanr(df_with_year['Release_Year'], df_with_year['positive_rate'])[0]
    correlation_data.append(('Release Year', corr_year * 100))

# 7. Genre diversity (number of genres)
df['genre_count'] = df['Genres'].str.split(',').str.len()
corr_genres = spearmanr(df['genre_count'], df['positive_rate'])[0]
correlation_data.append(('Genre Diversity', corr_genres * 100))

# Create DataFrame and sort by correlation strength
success_factors = pd.DataFrame(correlation_data, columns=['Factor', 'Correlation'])
success_factors = success_factors.sort_values('Correlation', ascending=True)  # Ascending for horizontal bar

success_factors.to_csv('performance_panel2_factors.csv', index=False)
print(f"  ✓ Saved success correlation factors")
print(f"\n  Top 3 Positive Correlations:")
top_3 = success_factors.nlargest(3, 'Correlation')
for _, row in top_3.iterrows():
    print(f"    {row['Factor']}: {row['Correlation']:.1f}%")
print(f"\n  Top 3 Negative Correlations:")
bottom_3 = success_factors.nsmallest(3, 'Correlation')
for _, row in bottom_3.iterrows():
    print(f"    {row['Factor']}: {row['Correlation']:.1f}%")

# === PANEL 2B: ADDITIONAL SUCCESS FACTORS (for reference) ===
# Define success for factor analysis (use the same top 20% criteria)
df['is_successful'] = df['popularity_score'] >= df['popularity_score'].quantile(0.80)

# === PANEL 3: DEVELOPER SUCCESS RANKING ===
print("\n🏆 Panel 3: Top Developers by Success and Popularity")

# Clean developer names - take first developer only (for multi-developer games)
df['Main_Developer'] = df['Developers'].str.split(',').str[0].str.strip()

# Get developers with highest rated and most popular games
dev_stats = df.groupby('Main_Developer').agg({
    'Name': 'count',
    'positive_rate': 'mean',
    'total_reviews': 'sum',
    'Price': 'mean'
}).reset_index()

dev_stats.columns = ['Developer', 'Game_Count', 'Avg_Rating', 'Total_Reviews', 'Avg_Price']

# Filter: Must have significant player base (100K+ reviews) OR multiple quality games
dev_stats = dev_stats[
    ((dev_stats['Total_Reviews'] >= 100000)) |
    ((dev_stats['Game_Count'] >= 5) & (dev_stats['Total_Reviews'] >= 50000))
].copy()

# Also filter by quality - minimum 75% average rating
dev_stats = dev_stats[dev_stats['Avg_Rating'] >= 75].copy()

# Sort by total reviews (popularity) and take top 15
dev_stats = dev_stats.sort_values('Total_Reviews', ascending=False).head(15)

# Clean developer names
dev_stats['Developer'] = dev_stats['Developer'].apply(lambda x: x[:40])

dev_stats.to_csv('performance_panel3_developers.csv', index=False)
print(f"  ✓ Saved top 15 developers")
print(f"\n  Top 5 Most Popular Developers (by total reviews):")
for idx, row in dev_stats.head(5).iterrows():
    print(f"    {row['Developer']}: {row['Avg_Rating']:.1f}% rating, {int(row['Total_Reviews']):,} reviews, {int(row['Game_Count'])} games")

# === BONUS: TOP SUCCESSFUL GAMES ===
print("\n🎮 Bonus: Top 10 Most Successful Games")

# Get top games by combined score and popularity
df['game_success_score'] = (
    (df['positive_rate'] / 100) * 0.4 +  # 40% rating
    (np.log10(df['total_reviews'] + 1) / 6) * 0.4 +  # 40% popularity
    (np.log10(df['Median playtime forever'] + 1) / 4) * 0.2  # 20% engagement
) * 100

top_games = df.nlargest(18, 'game_success_score')[['Name', 'Developers', 'positive_rate', 'total_reviews', 'Price', 'game_success_score']].copy()
top_games['Name'] = top_games['Name'].str[:40]  # Shorten names
top_games['Developers'] = top_games['Developers'].str[:30]

top_games.to_csv('performance_panel4_top_games.csv', index=False)
print(f"  ✓ Saved top 18 successful games")
print(f"\n  Top 5 Games:")
for idx, row in top_games.head(5).iterrows():
    print(f"    {row['Name']} ({row['Developers']}): {row['positive_rate']:.1f}%, {int(row['total_reviews']):,} reviews")

print("\n" + "=" * 60)
print("✅ PERFORMANCE METRICS DATA PREPARATION COMPLETE")
print("=" * 60)
print("\nGenerated files:")
print("  1. performance_panel1_characteristics.csv - Game characteristics")
print("  2. performance_panel2_factors.csv - Success factors")
print("  3. performance_panel3_developers.csv - Top famous developer rankings")
print("  4. performance_panel4_top_games.csv - Most successful games")
print("\n🎨 Ready for Octave visualization!")
