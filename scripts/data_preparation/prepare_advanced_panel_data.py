"""
Prepare preprocessed data files for advanced Octave panels (21-24)
This creates simplified CSV files that Octave can load instantly
"""

import pandas as pd
import numpy as np
import time

print("="*60)
print("PREPARING ADVANCED PANEL DATA")
print("="*60)

start_time = time.time()

# Load full dataset
print("\n>>> Loading full dataset (83,560 games)...")
df = pd.read_csv('../steam_games.csv')
print(f"    Loaded: {len(df)} games, {len(df.columns)} columns")

# =============================================================================
# PANEL 21: SCATTER PLOT DATA (Price vs Rating with Reviews)
# =============================================================================
print("\n>>> Preparing Panel 21 data (Scatter: Price vs Rating)...")

# Calculate total reviews and rating
df['total_reviews'] = df['Positive'] + df['Negative']
df['rating'] = (df['Positive'] / df['total_reviews'] * 100).fillna(0)

# Filter games with > 10 reviews
scatter_df = df[df['total_reviews'] > 10].copy()
print(f"    Filtered to {len(scatter_df)} games with >10 reviews")

# Extract needed columns
scatter_data = scatter_df[['Price', 'rating', 'total_reviews']].copy()
scatter_data = scatter_data.dropna()

# Save to CSV
scatter_data.to_csv('panel21_scatter_data.csv', index=False, header=False)
print(f"    Saved: panel21_scatter_data.csv ({len(scatter_data)} rows, 3 cols)")

# =============================================================================
# PANEL 22: BOX PLOT DATA (Review Distribution)
# =============================================================================
print("\n>>> Preparing Panel 22 data (Box Plot: Reviews)...")

# Need price, rating, reviews
boxplot_data = df[['Price', 'rating', 'total_reviews']].copy()
boxplot_data = boxplot_data.dropna()

# Save to CSV
boxplot_data.to_csv('panel22_boxplot_data.csv', index=False, header=False)
print(f"    Saved: panel22_boxplot_data.csv ({len(boxplot_data)} rows, 3 cols)")

# =============================================================================
# PANEL 23: LINE CHART DATA (Yearly Trends - Simulated)
# =============================================================================
print("\n>>> Preparing Panel 23 data (Line Chart: Trends)...")

# Sort by total_reviews descending to simulate recency
line_df = df.sort_values('total_reviews', ascending=False).copy()

# Need price, rating, reviews for trend analysis
line_data = line_df[['Price', 'rating', 'total_reviews']].copy()
line_data = line_data.dropna()

# Save to CSV (sorted by popularity = recency proxy)
line_data.to_csv('panel23_linechart_data.csv', index=False, header=False)
print(f"    Saved: panel23_linechart_data.csv ({len(line_data)} rows, 3 cols)")

# =============================================================================
# PANEL 24: STACKED BAR DATA (Platform Support)
# =============================================================================
print("\n>>> Preparing Panel 24 data (Stacked Bar: Platform)...")

# Need price and rating for platform simulation logic
stacked_data = df[['Price', 'rating']].copy()
stacked_data = stacked_data.dropna()

# Save to CSV
stacked_data.to_csv('panel24_stackedbar_data.csv', index=False, header=False)
print(f"    Saved: panel24_stackedbar_data.csv ({len(stacked_data)} rows, 2 cols)")

# =============================================================================
# SUMMARY
# =============================================================================
elapsed = time.time() - start_time

print("\n" + "="*60)
print("DATA PREPARATION COMPLETE!")
print("="*60)
print(f"\nTotal time: {elapsed:.1f} seconds")
print("\nCreated files:")
print("  1. panel21_scatter_data.csv    - Price, Rating, Reviews")
print("  2. panel22_boxplot_data.csv    - Price, Rating, Reviews")
print("  3. panel23_linechart_data.csv  - Price, Rating, Reviews (sorted)")
print("  4. panel24_stackedbar_data.csv - Price, Rating")
print("\nOctave scripts will load these files instantly!")
print("Expected speedup: ~60 seconds -> ~2 seconds per panel")
