"""
Genre Pricing Analysis
Calculates average price for top 20 most popular genres
"""
import pandas as pd
import numpy as np

print("Loading dataset...")
df = pd.read_csv('../../data/raw/steam_games.csv')
print(f"Total games: {len(df):,}")

# Clean price data
df = df[df['Price'].notna()].copy()
print(f"Games with price data: {len(df):,}")

# Parse genres
print("\nExtracting genres...")
genre_counts = {}
genre_prices = {}

for idx, row in df.iterrows():
    if pd.notna(row['Genres']):
        genres = [g.strip() for g in str(row['Genres']).split(',')]
        price = row['Price']
        
        for genre in genres:
            if genre not in genre_counts:
                genre_counts[genre] = 0
                genre_prices[genre] = []
            
            genre_counts[genre] += 1
            genre_prices[genre].append(price)

# Get top 20 genres by game count
print("\nCalculating statistics...")
top_genres = sorted(genre_counts.items(), key=lambda x: x[1], reverse=True)[:20]

# Prepare data for Octave
results = []
for genre, count in top_genres:
    prices = genre_prices[genre]
    avg_price = np.mean(prices)
    median_price = np.median(prices)
    std_price = np.std(prices)
    
    results.append({
        'Genre': genre,
        'GameCount': count,
        'AvgPrice': avg_price,
        'MedianPrice': median_price,
        'StdPrice': std_price,
        'MinPrice': np.min(prices),
        'MaxPrice': np.max(prices)
    })
    
    print(f"{genre:20s} | Games: {count:5,d} | Avg: ${avg_price:6.2f} | Median: ${median_price:6.2f}")

# Save to CSV
output_df = pd.DataFrame(results)
output_file = '../../data/processed/genre_pricing.csv'
output_df.to_csv(output_file, index=False)

print(f"\n✅ Genre pricing data saved: {output_file}")
print(f"   Top 20 genres with {output_df['GameCount'].sum():,} total game instances")
